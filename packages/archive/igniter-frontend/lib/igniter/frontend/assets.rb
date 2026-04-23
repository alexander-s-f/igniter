# frozen_string_literal: true

module Igniter
  module Frontend
    module Assets
      DEFAULT_MOUNT_PATH = "/__frontend"
      DEFAULT_SOURCE_PATH = "frontend"
      JAVASCRIPT_CONTENT_TYPE = "text/javascript; charset=utf-8"

      module_function

      def build_config(root_dir:, source_path: DEFAULT_SOURCE_PATH, mount_path: DEFAULT_MOUNT_PATH)
        normalized_mount_path = normalize_mount_path(mount_path)
        source_root = File.expand_path(source_path, root_dir)

        {
          mount_path: normalized_mount_path,
          root_dir: File.expand_path(root_dir),
          source_path: source_path.to_s,
          source_root: source_root
        }
      end

      def runtime_path(mount_path: DEFAULT_MOUNT_PATH)
        "#{normalize_mount_path(mount_path)}/runtime.js"
      end

      def javascript_path(logical_path, mount_path: DEFAULT_MOUNT_PATH)
        normalized_logical_path = normalize_logical_path(logical_path)
        "#{normalize_mount_path(mount_path)}/assets/#{normalized_logical_path}"
      end

      def runtime_handler
        lambda do |params:, body:, headers:, env:, raw_body:, config:| # rubocop:disable Lint/UnusedBlockArgument
          {
            status: 200,
            body: Frontend::JavaScript.runtime_source,
            headers: { "Content-Type" => JAVASCRIPT_CONTENT_TYPE }
          }
        end
      end

      def javascript_handler(frontend_assets_config)
        lambda do |params:, body:, headers:, env:, raw_body:, config:| # rubocop:disable Lint/UnusedBlockArgument
          logical_path = params.fetch(:logical_path, "")
          asset_path = resolve_asset_path(frontend_assets_config, logical_path)

          if asset_path.nil?
            {
              status: 404,
              body: "Frontend asset not found: #{logical_path}",
              headers: { "Content-Type" => "text/plain; charset=utf-8" }
            }
          else
            {
              status: 200,
              body: File.read(asset_path),
              headers: { "Content-Type" => JAVASCRIPT_CONTENT_TYPE }
            }
          end
        end
      end

      def javascript_route_pattern(mount_path: DEFAULT_MOUNT_PATH)
        mount = Regexp.escape(normalize_mount_path(mount_path))
        %r{\A#{mount}/assets/(?<logical_path>.+)\z}
      end

      def normalize_mount_path(mount_path)
        path = mount_path.to_s.strip
        path = DEFAULT_MOUNT_PATH if path.empty?
        path = "/#{path}" unless path.start_with?("/")
        path = path.gsub(%r{/+}, "/")
        return "/" if path == "/"

        path.sub(%r{/\z}, "")
      end

      def normalize_logical_path(logical_path)
        path = logical_path.to_s.strip
        path = "#{path}.js" if File.extname(path).empty?
        path.sub(%r{\A/+}, "")
      end

      def resolve_asset_path(frontend_assets_config, logical_path)
        normalized_path = normalize_logical_path(logical_path)
        return nil unless normalized_path.end_with?(".js")

        segments = normalized_path.split("/")
        return nil if segments.empty? || segments.any? { |segment| segment.empty? || segment == "." || segment == ".." }

        source_root = frontend_assets_config.fetch(:source_root)
        candidate = File.expand_path(normalized_path, source_root)
        return nil unless candidate == source_root || candidate.start_with?("#{source_root}/")
        return nil unless File.file?(candidate)

        candidate
      end
    end
  end
end
