# frozen_string_literal: true

require "cgi"
require "json"
require_relative "../../cluster"

module Igniter
  class App
    module Generators
      class Cluster
        NODE_PROFILES = [
          {
            profile: "seed",
            role: "seed",
            port: 4667,
            declared_capabilities: %i[mesh_seed routing status_api],
            mocked_capabilities: [:notifications],
            tags: %i[local seed]
          },
          {
            profile: "edge",
            role: "edge",
            port: 4668,
            declared_capabilities: %i[audio_ingest status_api],
            mocked_capabilities: %i[piper_tts whisper_asr],
            tags: %i[audio edge local],
            seeds: ["http://127.0.0.1:4667"]
          },
          {
            profile: "analyst",
            role: "analyst",
            port: 4669,
            declared_capabilities: %i[analysis status_api],
            mocked_capabilities: %i[local_llm rag],
            tags: %i[analyst local reasoning],
            seeds: ["http://127.0.0.1:4667"]
          }
        ].freeze

        def initialize(name, minimal: false)
          @name = name.to_s
          @minimal = minimal
          @base = Igniter::App::Generator.new(name, minimal: minimal)
          @identities = build_identities
        end

        def generate
          @base.generate
          expand_stack_shape
          expand_main_surface
          add_dashboard_app
          write "README.md", cluster_readme
        end

        private

        attr_reader :base
        attr_reader :identities

        def build_identities
          NODE_PROFILES.each_with_object({}) do |profile, memo|
            node_name = generated_node_name(profile.fetch(:profile))
            memo[node_name] = Igniter::Cluster::Identity::NodeIdentity.generate(node_id: node_name)
          end
        end

        def expand_stack_shape
          create_dir "apps/dashboard/spec"
          create_dir "lib/#{namespace_path}/dashboard"
          create_dir "lib/#{namespace_path}/main"
          create_dir "lib/#{namespace_path}/shared"
          write "stack.rb", stack_rb
          write "stack.yml", stack_yml
          write "spec/stack_spec.rb", stack_spec
          write "lib/#{namespace_path}/shared/node_identity_catalog.rb", node_identity_catalog_rb
          write "lib/#{namespace_path}/shared/capability_profile.rb", capability_profile_rb
          write "lib/#{namespace_path}/shared/stack_overview.rb", stack_overview_rb
          write "lib/#{namespace_path}/shared/routing_demo.rb", routing_demo_rb
        end

        def expand_main_surface
          write "apps/main/app.rb", main_app_rb
          write "apps/main/spec/main_app_spec.rb", main_app_spec
          write "lib/#{namespace_path}/main/status_handler.rb", main_status_handler_rb
        end

        def add_dashboard_app
          write "apps/dashboard/app.rb", dashboard_app_rb
          write "apps/dashboard/app.yml", dashboard_app_yml
          write "apps/dashboard/spec/spec_helper.rb", dashboard_spec_helper
          write "apps/dashboard/spec/dashboard_app_spec.rb", dashboard_app_spec
          write "lib/#{namespace_path}/dashboard/home_handler.rb", dashboard_home_handler_rb
          write "lib/#{namespace_path}/dashboard/overview_handler.rb", dashboard_overview_handler_rb
          write "lib/#{namespace_path}/dashboard/self_heal_demo_handler.rb", dashboard_self_heal_demo_handler_rb
        end

        def path(rel)
          File.join(@name, rel)
        end

        def write(rel, content)
          File.write(path(rel), content)
        end

        def create_dir(rel)
          FileUtils.mkdir_p(path(rel))
        end

        def project_name
          File.basename(@name)
        end

        def module_name
          project_name.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map(&:capitalize).join
        end

        def namespace_path
          project_name.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        end

        def env_prefix
          namespace_path.upcase
        end

        def stack_class_name
          "#{module_name}::Stack"
        end

        def generated_node_name(profile)
          "#{namespace_path}-#{profile}"
        end

        def stack_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/stack"
            require_relative "apps/main/app"
            require_relative "apps/dashboard/app"

            module #{module_name}
              class Stack < Igniter::Stack
                root_dir __dir__
                shared_lib_path "lib"

                app :main, path: "apps/main", klass: #{module_name}::MainApp, default: true
                app :dashboard, path: "apps/dashboard", klass: #{module_name}::DashboardApp

                mount :dashboard, at: "/dashboard"
              end
            end

            if $PROGRAM_NAME == __FILE__
              #{stack_class_name}.start_cli(ARGV)
            end
          RUBY
        end

        def stack_yml
          extra_env = {
            "seed" => {
              "#{env_prefix}_AUTO_ANNOUNCE" => "\"true\"",
              "#{env_prefix}_START_DISCOVERY" => "\"false\"",
              "#{env_prefix}_AUTO_SELF_HEAL" => "\"true\""
            },
            "edge" => {
              "#{env_prefix}_SEEDS" => "http://127.0.0.1:4667",
              "#{env_prefix}_AUTO_ANNOUNCE" => "\"true\"",
              "#{env_prefix}_START_DISCOVERY" => "\"true\"",
              "#{env_prefix}_AUTO_SELF_HEAL" => "\"true\""
            },
            "analyst" => {
              "#{env_prefix}_SEEDS" => "http://127.0.0.1:4667",
              "#{env_prefix}_AUTO_ANNOUNCE" => "\"true\"",
              "#{env_prefix}_START_DISCOVERY" => "\"true\"",
              "#{env_prefix}_AUTO_SELF_HEAL" => "\"true\""
            }
          }

          rendered = NODE_PROFILES.map do |profile|
            profile_name = profile.fetch(:profile)
            extras = extra_env.fetch(profile_name).map { |key, value| "        #{key}: #{value}" }.join("\n")

            <<~YAML.chomp
                #{profile_name}:
                  role: #{profile.fetch(:role)}
                  port: #{profile.fetch(:port)}
                  public: true
                  environment:
                    #{env_prefix}_NODE_NAME: #{generated_node_name(profile_name)}
                    #{env_prefix}_NODE_ROLE: #{profile.fetch(:role)}
                    #{env_prefix}_NODE_URL: http://127.0.0.1:#{profile.fetch(:port)}
                    #{env_prefix}_LOCAL_CAPABILITIES: #{profile.fetch(:declared_capabilities).join(",")}
                    #{env_prefix}_MOCK_CAPABILITIES: #{profile.fetch(:mocked_capabilities).join(",")}
                    #{env_prefix}_NODE_TAGS: #{profile.fetch(:tags).join(",")}
            #{extras}
            YAML
          end.join("\n\n")

          <<~YAML
            stack:
              name: #{project_name}
              root_app: main
              default_node: seed
              shared_lib_paths:
                - lib

            server:
              host: 0.0.0.0

            nodes:
          #{rendered}

            persistence:
              data:
                adapter: sqlite
                path: var/#{project_name}_data.sqlite3
          YAML
        end

        def stack_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"

            RSpec.describe #{stack_class_name} do
              it "registers a mounted dashboard and local cluster node profiles" do
                expect(described_class.root_app).to eq(:main)
                expect(described_class.default_node).to eq(:seed)
                expect(described_class.app(:main)).to be(#{module_name}::MainApp)
                expect(described_class.app(:dashboard)).to be(#{module_name}::DashboardApp)
                expect(described_class.mounts).to eq(dashboard: "/dashboard")
                expect(described_class.node_names).to eq(%i[seed edge analyst])
              end
            end
          RUBY
        end

        def node_identity_catalog_rb
          entries = identities.map do |node_name, identity|
            <<~RUBY.chomp
                #{node_name.inspect} => {
                  public_key: <<~PEM,
            #{indent(identity.public_key_pem, 10)}\
                  PEM
                  private_key: <<~PEM
            #{indent(identity.private_key_pem, 10)}\
                  PEM
                }
            RUBY
          end.join(",\n")

          <<~RUBY
            # frozen_string_literal: true

            module #{module_name}
              module Shared
                module NodeIdentityCatalog
                  module_function

                  IDENTITIES = {
            #{entries}
                  }.freeze

                  def identity_for(node_name)
                    source = IDENTITIES.fetch(node_name.to_s)
                    Igniter::Cluster::Identity::NodeIdentity.new(
                      node_id: node_name.to_s,
                      public_key_pem: source.fetch(:public_key),
                      private_key_pem: source.fetch(:private_key)
                    )
                  end

                  def trust_store
                    entries = IDENTITIES.map do |node_name, keys|
                      {
                        node_id: node_name,
                        public_key: keys.fetch(:public_key),
                        label: "#{namespace_path}-local"
                      }
                    end
                    Igniter::Cluster::Trust::TrustStore.new(entries)
                  end
                end
              end
            end
          RUBY
        end

        def capability_profile_rb
          defaults = NODE_PROFILES.map do |profile|
            <<~RUBY.chomp
                #{profile.fetch(:profile).inspect} => {
                  role: #{profile.fetch(:role).inspect},
                  port: #{profile.fetch(:port)},
                  declared_capabilities: #{profile.fetch(:declared_capabilities).inspect},
                  mocked_capabilities: #{profile.fetch(:mocked_capabilities).inspect},
                  tags: #{profile.fetch(:tags).inspect},
                  seeds: #{Array(profile[:seeds]).inspect}
                }
            RUBY
          end.join(",\n")

          <<~RUBY
            # frozen_string_literal: true

            require_relative "node_identity_catalog"

            module #{module_name}
              module Shared
                module CapabilityProfile
                  module_function

                  DEFAULT_NODE = "seed"
                  DEFAULT_PORT = 4667
                  DEFAULTS = {
            #{defaults}
                  }.freeze

                  def current(env = ENV)
                    node_profile = string(env["IGNITER_NODE"], default: DEFAULT_NODE)
                    defaults = DEFAULTS.fetch(node_profile, {})
                    node_name = string(env["#{env_prefix}_NODE_NAME"], default: "#{namespace_path}-\#{node_profile}")
                    node_role = string(env["#{env_prefix}_NODE_ROLE"], default: defaults.fetch(:role, node_profile))
                    port = integer(env["PORT"], default: defaults.fetch(:port, DEFAULT_PORT))
                    local_url = string(env["#{env_prefix}_NODE_URL"], default: "http://127.0.0.1:\#{port}")

                    declared = csv(env["#{env_prefix}_LOCAL_CAPABILITIES"], default: defaults.fetch(:declared_capabilities, []))
                    mocked = csv(env["#{env_prefix}_MOCK_CAPABILITIES"], default: defaults.fetch(:mocked_capabilities, []))
                    tags = csv(env["#{env_prefix}_NODE_TAGS"], default: defaults.fetch(:tags, []))
                    seeds = csv_strings(env["#{env_prefix}_SEEDS"], default: defaults.fetch(:seeds, []))

                    {
                      node_profile: node_profile,
                      node_name: node_name,
                      node_role: node_role,
                      port: port,
                      local_url: local_url,
                      declared_capabilities: declared,
                      mocked_capabilities: mocked,
                      effective_capabilities: (declared + mocked).uniq.sort,
                      tags: tags,
                      seeds: seeds,
                      start_discovery: truthy?(env["#{env_prefix}_START_DISCOVERY"]),
                      auto_self_heal: !falsy?(env["#{env_prefix}_AUTO_SELF_HEAL"]),
                      self_heal_interval: integer(env["#{env_prefix}_SELF_HEAL_INTERVAL"], default: 15),
                      auto_announce: !falsy?(env["#{env_prefix}_AUTO_ANNOUNCE"]),
                      identity: NodeIdentityCatalog.identity_for(node_name),
                      trust_store: NodeIdentityCatalog.trust_store,
                      metadata: {
                        cluster_demo: {
                          node_profile: node_profile,
                          role: node_role,
                          declared_capabilities: declared,
                          mocked_capabilities: mocked
                        }
                      }
                    }
                  end

                  def discovery_snapshot(env = ENV)
                    profile = current(env)

                    {
                      node: {
                        name: profile[:node_name],
                        profile: profile[:node_profile],
                        role: profile[:node_role],
                        port: profile[:port],
                        url: profile[:local_url]
                      },
                      identity: {
                        node_id: profile[:identity].node_id,
                        fingerprint: profile[:identity].fingerprint,
                        algorithm: profile[:identity].algorithm
                      },
                      trust: {
                        known_peers: profile[:trust_store].size,
                        entries: profile[:trust_store].to_h[:entries]
                      },
                      governance: {
                        trail: Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 5),
                        checkpoint: governance_checkpoint_snapshot
                      },
                      capabilities: {
                        declared: profile[:declared_capabilities],
                        mocked: profile[:mocked_capabilities],
                        effective: profile[:effective_capabilities]
                      },
                      tags: profile[:tags],
                      seeds: profile[:seeds],
                      discovery: {
                        start: profile[:start_discovery],
                        auto_announce: profile[:auto_announce],
                        auto_self_heal: profile[:auto_self_heal],
                        self_heal_interval: profile[:self_heal_interval]
                      }
                    }
                  end

                  def discovered_peers
                    return [] unless defined?(Igniter::Cluster::Mesh)

                    Igniter::Cluster::Mesh.config.peer_registry.all.map do |peer|
                      {
                        name: peer.name,
                        url: peer.url,
                        capabilities: peer.capabilities,
                        tags: peer.tags,
                        metadata: peer.metadata,
                        identity: peer.metadata[:mesh_identity],
                        trust: peer.metadata[:mesh_trust]
                      }
                    end.sort_by { |peer| peer.fetch(:name) }
                  rescue StandardError
                    []
                  end

                  def configure_cluster!(config, env = ENV)
                    profile = current(env)

                    config.peer_name = profile[:node_name]
                    config.local_capabilities = profile[:effective_capabilities]
                    config.local_tags = profile[:tags]
                    config.local_metadata = profile[:metadata]
                    config.seeds = profile[:seeds]
                    config.local_url = profile[:local_url]
                    config.start_discovery = profile[:start_discovery]
                    config.auto_announce = profile[:auto_announce]
                    config.auto_self_heal = profile[:auto_self_heal]
                    config.self_heal_interval = profile[:self_heal_interval]
                    config.identity = profile[:identity]
                    config.trust_store = profile[:trust_store]
                  end

                  def governance_checkpoint_snapshot
                    checkpoint = Igniter::Cluster::Mesh.config.governance_checkpoint(limit: 5)
                    assessment = Igniter::Cluster::Trust::Verifier.assess_governance_checkpoint(
                      checkpoint,
                      trust_store: Igniter::Cluster::Mesh.config.trust_store
                    )

                    {
                      node_id: checkpoint.node_id,
                      fingerprint: checkpoint.fingerprint,
                      crest_digest: checkpoint.crest_digest,
                      checkpointed_at: checkpoint.checkpointed_at,
                      trust: assessment.to_h
                    }
                  rescue StandardError
                    nil
                  end

                  def csv(value, default: [])
                    text = value.to_s.strip
                    items = if text.empty?
                              Array(default)
                            else
                              text.split(",")
                            end

                    items.map { |entry| entry.to_s.strip }.reject(&:empty?).map(&:to_sym).uniq.sort
                  end

                  def csv_strings(value, default: [])
                    text = value.to_s.strip
                    items = if text.empty?
                              Array(default)
                            else
                              text.split(",")
                            end

                    items.map { |entry| entry.to_s.strip }.reject(&:empty?).uniq.sort
                  end

                  def truthy?(value)
                    %w[1 true yes on].include?(value.to_s.strip.downcase)
                  end

                  def falsy?(value)
                    %w[0 false no off].include?(value.to_s.strip.downcase)
                  end

                  def string(value, default:)
                    text = value.to_s.strip
                    text.empty? ? default.to_s : text
                  end

                  def integer(value, default:)
                    text = value.to_s.strip
                    text.empty? ? default.to_i : Integer(text)
                  end
                end
              end
            end
          RUBY
        end

        def stack_overview_rb
          <<~RUBY
            # frozen_string_literal: true

            require "time"
            require_relative "capability_profile"

            module #{module_name}
              module Shared
                module StackOverview
                  module_function

                  def build
                    deployment = #{stack_class_name}.deployment_snapshot
                    nodes = deployment.fetch("nodes", {}).transform_values do |config|
                      {
                        role: config["role"],
                        public: config["public"],
                        port: config["port"],
                        host: config["host"],
                        command: config["command"],
                        mounts: config.fetch("mounts", {}),
                        environment: config.fetch("environment", {})
                      }
                    end
                    routing = routing_snapshot

                    {
                      generated_at: Time.now.utc.iso8601,
                      stack: {
                        name: #{stack_class_name}.stack_settings.dig("stack", "name"),
                        root_app: deployment.dig("stack", "root_app"),
                        default_node: deployment.dig("stack", "default_node"),
                        mounts: deployment.dig("stack", "mounts"),
                        apps: #{stack_class_name}.app_names.map(&:to_s)
                      },
                      counts: {
                        apps: #{stack_class_name}.app_names.size,
                        nodes: nodes.size,
                        discovered_peers: CapabilityProfile.discovered_peers.size,
                        trusted_peers: CapabilityProfile.discovered_peers.count { |peer| peer.dig(:trust, :status) == :trusted },
                        routing_plans: routing[:plan_count]
                      },
                      current_node: CapabilityProfile.discovery_snapshot,
                      routing: routing,
                      discovered_peers: CapabilityProfile.discovered_peers,
                      nodes: nodes,
                      apps: deployment.fetch("apps").transform_values do |config|
                        {
                          path: config["path"],
                          class_name: config["class_name"],
                          default: config["default"]
                        }
                      end
                    }
                  end

                  def routing_snapshot
                    report = Igniter::Cluster::Mesh.config.current_routing_report
                    routing = Hash(report&.dig(:routing) || {})
                    trail = Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 8)
                    latest_tick = Array(trail[:events]).reverse.find { |event| event[:type] == :routing_self_heal_tick }

                    {
                      active: !routing.empty?,
                      total: routing.fetch(:total, 0),
                      pending: routing.fetch(:pending, 0),
                      failed: routing.fetch(:failed, 0),
                      plan_count: Array(routing[:plans]).size,
                      incidents: Hash(routing.dig(:facets, :by_incident) || {}),
                      plan_actions: Hash(routing.dig(:facets, :by_plan_action) || {}),
                      entries: Array(routing[:entries]).first(5).map do |entry|
                        {
                          node_name: entry[:node_name],
                          status: entry[:status],
                          routing_trace_summary: entry[:routing_trace_summary]
                        }
                      end,
                      latest_self_heal_tick: latest_tick && {
                        type: latest_tick[:type],
                        timestamp: latest_tick[:timestamp],
                        payload: latest_tick[:payload]
                      }
                    }
                  rescue StandardError
                    {
                      active: false,
                      total: 0,
                      pending: 0,
                      failed: 0,
                      plan_count: 0,
                      incidents: {},
                      plan_actions: {},
                      entries: [],
                      latest_self_heal_tick: nil
                    }
                  end
                end
              end
            end
          RUBY
        end

        def routing_demo_rb
          <<~RUBY
            # frozen_string_literal: true

            module #{module_name}
              module Shared
                module RoutingDemo
                  module_function

                  def run!(scenario: "governance_gate")
                    report = build_report(scenario.to_s)
                    Igniter::Cluster::Mesh.config.record_routing_report!(report)
                    result = Igniter::Cluster::Mesh.repair_loop.heal_once

                    {
                      scenario: scenario.to_s,
                      report: report,
                      result: result.to_h,
                      trail: Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 8)
                    }
                  end

                  def build_report(scenario)
                    case scenario
                    when "peer_unreachable"
                      {
                        routing: {
                          total: 1,
                          pending: 1,
                          failed: 0,
                          plans: [
                            {
                              action: :refresh_peer_health,
                              scope: :mesh_health,
                              automated: true,
                              requires_approval: false,
                              params: {
                                peer_name: "#{namespace_path}-edge",
                                selected_url: "http://127.0.0.1:4668"
                              },
                              sources: [
                                {
                                  node_name: :voice_sync,
                                  status: :pending,
                                  incident: :peer_unreachable,
                                  hint_code: :restore_peer_connectivity
                                }
                              ]
                            }
                          ],
                          facets: {
                            by_incident: { peer_unreachable: 1 },
                            by_plan_action: { refresh_peer_health: 1 }
                          },
                          entries: [
                            {
                              node_name: :voice_sync,
                              status: :pending,
                              routing_trace_summary: "mode=capability eligible=0 selected=none reasons=unreachable"
                            }
                          ]
                        }
                      }
                    else
                      {
                        routing: {
                          total: 1,
                          pending: 1,
                          failed: 0,
                          plans: [
                            {
                              action: :refresh_governance_checkpoint,
                              scope: :mesh_governance,
                              automated: true,
                              requires_approval: false,
                              params: {
                                governance_keys: %i[trust latest_type blocked_events],
                                peer_candidates: ["#{namespace_path}-analyst"]
                              },
                              sources: [
                                {
                                  node_name: :analysis_result,
                                  status: :pending,
                                  incident: :governance_gate,
                                  hint_code: :wait_for_governance_crest
                                }
                              ]
                            },
                            {
                              action: :relax_governance_requirements,
                              scope: :routing_governance,
                              automated: false,
                              requires_approval: true,
                              params: {
                                governance_keys: %i[trust latest_type blocked_events],
                                peer_candidates: ["#{namespace_path}-analyst"]
                              },
                              sources: [
                                {
                                  node_name: :analysis_result,
                                  status: :pending,
                                  incident: :governance_gate,
                                  hint_code: :relax_governance_requirements
                                }
                              ]
                            }
                          ],
                          facets: {
                            by_incident: { governance_gate: 1 },
                            by_plan_action: {
                              refresh_governance_checkpoint: 1,
                              relax_governance_requirements: 1
                            }
                          },
                          entries: [
                            {
                              node_name: :analysis_result,
                              status: :pending,
                              routing_trace_summary: "mode=capability eligible=0 selected=none reasons=query_mismatch"
                            }
                          ]
                        }
                      }
                    end
                  end
                end
              end
            end
          RUBY
        end

        def main_app_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/app"
            require "igniter/cluster"
            require "igniter/core"
            require_relative "../../lib/#{namespace_path}/main/status_handler"
            require_relative "../../lib/#{namespace_path}/shared/capability_profile"

            module #{module_name}
              class MainApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"
                host :cluster_app

                tools_path     "app/tools"
                skills_path    "app/skills"
                executors_path "app/executors"
                contracts_path "app/contracts"
                agents_path    "app/agents"

                route "GET", "/v1/home/status", with: #{module_name}::Main::StatusHandler

                on_boot do
                  register "GreetContract", #{module_name}::GreetContract
                end

                configure do |c|
                  c.app_host.host = "0.0.0.0"
                  c.app_host.port = Integer(ENV.fetch("PORT", "4667"))
                  c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
                  #{module_name}::Shared::CapabilityProfile.configure_cluster!(c.cluster_app_host)
                end
              end
            end
          RUBY
        end

        def main_status_handler_rb
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Main
                module StatusHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    {
                      status: 200,
                      body: JSON.generate(
                        generated_at: snapshot.fetch(:generated_at),
                        stack: snapshot.fetch(:stack),
                        apps: snapshot.fetch(:apps),
                        current_node: snapshot.fetch(:current_node),
                        routing: snapshot.fetch(:routing),
                        discovered_peers: snapshot.fetch(:discovered_peers),
                        nodes: snapshot.fetch(:nodes),
                        counts: snapshot.fetch(:counts)
                      ),
                      headers: { "Content-Type" => "application/json" }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def main_app_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"
            require "json"
            require "stringio"

            RSpec.describe #{module_name}::MainApp do
              before do
                Igniter::Cluster::Mesh.reset!
              end

              it "builds a cluster-ready app with identity and trust" do
                config = described_class.send(:build!)

                expect(config.registry.registered?("GreetContract")).to be(true)
                expect(config.peer_name).to eq("#{namespace_path}-seed")
                expect(config.peer_capabilities).to include(:mesh_seed, :notifications, :routing, :status_api)
                expect(config.peer_identity).not_to be_nil
                expect(config.peer_identity.node_id).to eq("#{namespace_path}-seed")
                expect(config.peer_trust_store.size).to eq(3)
              end

              it "exposes a status endpoint for the cluster sandbox snapshot" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/v1/home/status",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(body.each.to_a.join)

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("application/json")
                expect(payload.dig("stack", "root_app")).to eq("main")
                expect(payload.dig("stack", "default_node")).to eq("seed")
                expect(payload.dig("current_node", "node", "name")).to eq("#{namespace_path}-seed")
                expect(payload.dig("current_node", "identity", "node_id")).to eq("#{namespace_path}-seed")
                expect(payload.dig("current_node", "trust", "known_peers")).to eq(3)
                expect(payload.dig("current_node", "governance", "checkpoint", "trust", "status")).to eq("trusted")
                expect(payload.dig("routing", "active")).to eq(false)
                expect(payload.dig("nodes", "analyst", "port")).to eq(4669)
              end
            end

            RSpec.describe #{module_name}::GreetContract do
              it "returns a greeting" do
                result = described_class.new(name: "Alice").result.greeting

                expect(result[:message]).to include("Alice")
                expect(result[:greeted_at]).to be_a(String)
              end
            end
          RUBY
        end

        def dashboard_app_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/app"
            require "igniter/core"
            require_relative "../../lib/#{namespace_path}/dashboard/home_handler"
            require_relative "../../lib/#{namespace_path}/dashboard/overview_handler"
            require_relative "../../lib/#{namespace_path}/dashboard/self_heal_demo_handler"

            module #{module_name}
              class DashboardApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"

                route "GET", "/", with: #{module_name}::Dashboard::HomeHandler
                route "GET", "/api/overview", with: #{module_name}::Dashboard::OverviewHandler
                route "POST", "/demo/self-heal", with: #{module_name}::Dashboard::SelfHealDemoHandler
              end
            end
          RUBY
        end

        def dashboard_app_yml
          <<~YAML
            persistence:
              execution:
                adapter: memory
                path: var/dashboard_executions.sqlite3
          YAML
        end

        def dashboard_spec_helper
          <<~RUBY
            # frozen_string_literal: true

            require_relative "../../../spec/spec_helper"

            #{module_name}::DashboardApp.send(:build!)
          RUBY
        end

        def dashboard_home_handler_rb
          <<~RUBY
            # frozen_string_literal: true

            require "cgi"
            require "json"
            require "igniter/plugins/view/response"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Dashboard
                module HomeHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    Igniter::Plugins::View::Response.html(render_page(snapshot: snapshot, base_path: env["SCRIPT_NAME"].to_s))
                  end

                  def render_page(snapshot:, base_path:)
                    current = snapshot.fetch(:current_node)
                    routing = snapshot.fetch(:routing)
                    peers = snapshot.fetch(:discovered_peers)

                    <<~HTML
                      <!doctype html>
                      <html lang="en">
                        <head>
                          <meta charset="utf-8">
                          <meta name="viewport" content="width=device-width, initial-scale=1">
                          <title>#{module_name} Cluster Dashboard</title>
                          <style>
                            body { font-family: ui-sans-serif, system-ui, sans-serif; margin: 0; background: #f4efe5; color: #1f1c18; }
                            main { max-width: 1040px; margin: 0 auto; padding: 32px 20px 48px; }
                            .hero, .panel { background: white; border: 1px solid #dfd1bb; border-radius: 18px; padding: 20px; margin-bottom: 18px; }
                            .grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); }
                            .actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 12px; }
                            form { margin: 0; }
                            button { background: #145f56; color: white; border: 0; border-radius: 999px; padding: 10px 14px; cursor: pointer; }
                            code, pre { font-family: ui-monospace, SFMono-Regular, monospace; }
                            pre { white-space: pre-wrap; font-size: 13px; margin: 0; }
                            .meta { color: #5f574a; }
                          </style>
                        </head>
                        <body>
                          <main>
                            <section class="hero">
                              <h1>#{module_name} Cluster Dashboard</h1>
                              <p>Cluster-ready scaffold with mounted apps, local node profiles, mocked capabilities, and a self-heal demo.</p>
                              <p class="meta">
                                current_node=\#{h(current.dig(:node, :name))} ·
                                profile=\#{h(current.dig(:node, :profile))} ·
                                role=\#{h(current.dig(:node, :role))}
                              </p>
                              <p class="meta">
                                capabilities=\#{h(current.dig(:capabilities, :effective).join(", "))} ·
                                peers=\#{peers.size} ·
                                routing_active=\#{routing[:active]}
                              </p>
                            </section>

                            <section class="panel">
                              <h2>Self-Heal Demo</h2>
                              <p>Trigger a synthetic routing incident and watch automated remediation update the governance trail.</p>
                              <div class="actions">
                                <form action="\#{route(base_path, "/demo/self-heal?scenario=governance_gate")}" method="post">
                                  <button type="submit">Trigger Governance Gate</button>
                                </form>
                                <form action="\#{route(base_path, "/demo/self-heal?scenario=peer_unreachable")}" method="post">
                                  <button type="submit">Trigger Peer Repair</button>
                                </form>
                                <a href="\#{route(base_path, "/api/overview")}">Overview API</a>
                              </div>
                            </section>

                            <section class="grid">
                              <article class="panel">
                                <h2>Current Node</h2>
                                <pre>\#{h(JSON.pretty_generate(current))}</pre>
                              </article>
                              <article class="panel">
                                <h2>Routing</h2>
                                <pre>\#{h(JSON.pretty_generate(routing))}</pre>
                              </article>
                              <article class="panel">
                                <h2>Peers</h2>
                                <pre>\#{h(JSON.pretty_generate(peers))}</pre>
                              </article>
                            </section>
                          </main>
                        </body>
                      </html>
                    HTML
                  end

                  def route(base_path, suffix)
                    [base_path.to_s.sub(%r{/+\z}, ""), suffix].join
                  end

                  def h(value)
                    CGI.escapeHTML(value.to_s)
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_overview_handler_rb
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Dashboard
                module OverviewHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    {
                      status: 200,
                      body: JSON.generate(snapshot),
                      headers: { "Content-Type" => "application/json" }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_self_heal_demo_handler_rb
          <<~RUBY
            # frozen_string_literal: true

            require_relative "../shared/routing_demo"

            module #{module_name}
              module Dashboard
                module SelfHealDemoHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    scenario = params.fetch("scenario", body.fetch("scenario", "governance_gate")).to_s
                    #{module_name}::Shared::RoutingDemo.run!(scenario: scenario)
                    base_path = env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
                    location = [base_path, ""].reject(&:empty?).join("/") + "/?demo=\#{scenario}"

                    {
                      status: 303,
                      body: "",
                      headers: { "Location" => location }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_app_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"
            require "json"
            require "stringio"

            RSpec.describe #{module_name}::DashboardApp do
              before do
                Igniter::Cluster::Mesh.reset!
              end

              it "renders the overview endpoint" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/api/overview",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(body.each.to_a.join)

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("application/json")
                expect(payload.dig("stack", "root_app")).to eq("main")
                expect(payload.dig("stack", "default_node")).to eq("seed")
                expect(payload.dig("nodes", "seed", "mounts", "dashboard")).to eq("/dashboard")
                expect(payload.dig("counts", "routing_plans")).to eq(0)
              end

              it "renders the cluster dashboard home page" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/",
                  "rack.input" => StringIO.new
                )

                html = body.each.to_a.join

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("text/html")
                expect(html).to include("#{module_name} Cluster Dashboard")
                expect(html).to include("Self-Heal Demo")
                expect(html).to include("/demo/self-heal?scenario=governance_gate")
              end

              it "runs the self-heal demo and exposes routing activity" do
                app = described_class.rack_app

                demo_status, demo_headers, = app.call(
                  "REQUEST_METHOD" => "POST",
                  "PATH_INFO" => "/demo/self-heal",
                  "QUERY_STRING" => "scenario=governance_gate",
                  "rack.input" => StringIO.new
                )

                overview_status, _overview_headers, overview_body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/api/overview",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(overview_body.each.to_a.join)

                expect(demo_status).to eq(303)
                expect(demo_headers["Location"]).to eq("/?demo=governance_gate")
                expect(overview_status).to eq(200)
                expect(payload.dig("routing", "active")).to eq(true)
                expect(payload.dig("routing", "plan_count")).to eq(2)
                expect(payload.dig("routing", "incidents", "governance_gate")).to eq(1)
              end
            end
          RUBY
        end

        def cluster_readme
          <<~MARKDOWN
            # #{module_name}

            This stack was generated with the `cluster` scaffold profile.

            It is the smallest stack-first scaffold that already feels cluster-native:

            - mounted `dashboard` app
            - local node profiles in `stack.yml`
            - mocked capabilities for local mesh demos
            - signed node identities and trust store
            - a small self-heal demo for routing/governance

            ## Reading Order

            1. `stack.rb`
            2. `stack.yml`
            3. `lib/#{namespace_path}/shared/capability_profile.rb`
            4. `apps/main/app.rb`
            5. `apps/dashboard/app.rb`

            ## Boot

            ```bash
            bundle install
            bin/console --node seed
            bin/dev
            ```

            Open:

            - `http://127.0.0.1:4667/v1/home/status`
            - `http://127.0.0.1:4667/dashboard`
            - `http://127.0.0.1:4668/dashboard`
            - `http://127.0.0.1:4669/dashboard`

            `bin/dev` also writes per-node logs to `var/log/dev/*.log`.
          MARKDOWN
        end

        def indent(text, spaces)
          prefix = " " * spaces
          text.lines.map { |line| "#{prefix}#{line}" }.join
        end
      end
    end
  end
end
