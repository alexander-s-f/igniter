# frozen_string_literal: true

require "tmpdir"
require "fileutils"

module Igniter
  module Cluster
    module Replication
    module Bootstrappers
      # Deploys by creating a gzipped tarball of the local source tree,
      # uploading it via SCP, and extracting it on the remote host.
      #
      # This strategy works without git or internet access on the remote,
      # making it suitable for air-gapped or private environments.
      class Tarball < Bootstrapper
        def install(session:, manifest:, env: {}, target_path: "/opt/igniter")
          tarball = create_tarball(manifest)
          begin
            remote_tar = "/tmp/igniter_replication_#{Process.pid}.tar.gz"
            session.upload!(tarball, remote_tar)
            extract_and_install(session, remote_tar, target_path)
            write_env_file(session: session, env: env, path: "#{target_path}/.env")
          ensure
            FileUtils.rm_f(tarball)
          end
        end

        def start(session:, manifest:, target_path: "/opt/igniter")
          app_path = "#{target_path}/app"
          log_path = "#{target_path}/igniter.log"
          cmd      = File.basename(manifest.startup_command)
          session.exec!("cd #{app_path} && nohup ruby #{cmd} >> #{log_path} 2>&1 &")
        end

        private

        def extract_and_install(session, remote_tar, target_path)
          app_path = "#{target_path}/app"
          session.exec!("mkdir -p #{app_path}")
          session.exec!("tar -xzf #{remote_tar} -C #{app_path} --strip-components=1")
          session.exec!("cd #{app_path} && gem install bundler --no-document")
          session.exec!("cd #{app_path} && bundle install --without development test")
          session.exec!("rm -f #{remote_tar}")
        end

        def create_tarball(manifest)
          source  = manifest.source_path
          tmpfile = File.join(Dir.tmpdir, "igniter_replication_#{Process.pid}.tar.gz")
          parent  = File.dirname(source)
          name    = File.basename(source)
          system("tar", "-czf", tmpfile, "-C", parent, name)
          tmpfile
        end
      end
    end
    end
  end
end
