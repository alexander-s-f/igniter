# frozen_string_literal: true

module Igniter
  module Replication
    # Abstract base class for deployment bootstrappers.
    #
    # Subclasses implement three lifecycle methods:
    #   install — copy/install the application on the remote
    #   start   — launch the application process
    #   verify  — confirm the application is running (default impl provided)
    class Bootstrapper
      BootstrapError = Class.new(Igniter::Error)

      # Install the application on the remote server.
      #
      # @param session [SSHSession] active SSH session to the remote host
      # @param manifest [Manifest] self-description of the running instance
      # @param env [Hash] environment variables to write on remote
      # @param target_path [String] base directory on the remote server
      def install(session:, manifest:, env: {}, target_path: "/opt/igniter")
        raise NotImplementedError, "#{self.class}#install not implemented"
      end

      # Start the application on the remote server.
      #
      # @param session [SSHSession] active SSH session to the remote host
      # @param manifest [Manifest] self-description of the running instance
      # @param target_path [String] base directory on the remote server
      def start(session:, manifest:, target_path: "/opt/igniter")
        raise NotImplementedError, "#{self.class}#start not implemented"
      end

      # Verify the application is running on the remote server.
      # Returns true if Igniter can be loaded, false otherwise.
      #
      # @param session [SSHSession] active SSH session to the remote host
      # @param target_path [String] base directory on the remote server (unused by default impl)
      def verify(session:, target_path: "/opt/igniter") # rubocop:disable Lint/UnusedMethodArgument
        result = session.exec("ruby -e 'require \"igniter\"; puts Igniter::VERSION' 2>/dev/null")
        result[:success] && !result[:stdout].strip.empty?
      rescue SSHSession::SSHError
        false
      end

      protected

      # Write environment variables to a shell-sourceable file on the remote.
      #
      # @param session [SSHSession] active SSH session
      # @param env [Hash] key-value pairs to export
      # @param path [String] remote path for the env file
      def write_env_file(session:, env:, path:)
        return if env.nil? || env.empty?

        require "shellwords"
        lines = env.map { |k, v| "export #{k}=#{v.to_s.shellescape}" }.join("\n")
        session.exec!("printf '%s\\n' #{lines.shellescape} > #{path}")
      end
    end
  end
end
