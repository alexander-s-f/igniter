# frozen_string_literal: true

require "open3"

module Igniter
  module Cluster
    module Replication
    # Thin subprocess wrapper over the +ssh+ and +scp+ CLI tools.
    #
    # Provides exec/exec! for running remote commands and upload! for
    # copying local files to the remote host. No external gems required.
    class SSHSession
      class SSHError < Igniter::Error; end

      DEFAULT_CONNECT_TIMEOUT = 10

      def initialize(host:, user:, key: nil, port: 22, connect_timeout: DEFAULT_CONNECT_TIMEOUT)
        @host            = host
        @user            = user
        @key             = key
        @port            = port
        @connect_timeout = connect_timeout
      end

      # Run a command on the remote host. Raises SSHError on non-zero exit.
      # Returns stdout string on success.
      def exec!(command)
        result = exec(command)
        raise SSHError, "SSH command failed on #{@host}: #{command.inspect}\n#{result[:stderr]}" \
          unless result[:success]

        result[:stdout]
      end

      # Run a command on the remote host.
      # Returns a Hash: { stdout:, stderr:, success:, exit_code: }
      def exec(command)
        stdout, stderr, status = Open3.capture3(*build_cmd(command))
        { stdout: stdout, stderr: stderr, success: status.success?, exit_code: status.exitstatus }
      end

      # Upload a local file to the remote host via scp.
      # Raises SSHError on failure.
      def upload!(local_path, remote_path)
        args = ["scp", *scp_opts, "-P", @port.to_s, local_path, "#{@user}@#{@host}:#{remote_path}"]
        _, stderr, status = Open3.capture3(*args)
        raise SSHError, "SCP upload failed to #{@host}: #{stderr}" unless status.success?
      end

      # Quick connectivity test. Returns true if the remote responds.
      def test_connection
        exec("echo ok")[:success]
      end

      private

      def build_cmd(command)
        ["ssh", *ssh_opts, "-p", @port.to_s, "#{@user}@#{@host}", command]
      end

      def ssh_opts
        opts = [
          "-o", "StrictHostKeyChecking=no",
          "-o", "BatchMode=yes",
          "-o", "ConnectTimeout=#{@connect_timeout}"
        ]
        opts += ["-i", @key] if @key
        opts
      end

      def scp_opts
        opts = ["-o", "StrictHostKeyChecking=no", "-B"]
        opts += ["-i", @key] if @key
        opts
      end
    end
    end
  end
end
