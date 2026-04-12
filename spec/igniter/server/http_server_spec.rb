# frozen_string_literal: true

require "spec_helper"
require "igniter/server"

RSpec.describe Igniter::Server::HttpServer do
  wait_readable_error = Class.new(IOError) do
    include IO::WaitReadable
  end

  let(:config) { Igniter::Server::Config.new }
  subject(:server) { described_class.new(config) }

  describe "#accept_connection" do
    it "returns nil when the server socket is closed during select" do
      tcp_server = instance_double(TCPServer)

      server.instance_variable_set(:@tcp_server, tcp_server)
      server.instance_variable_set(:@running, true)

      allow(tcp_server).to receive(:accept_nonblock).and_raise(wait_readable_error.new)
      allow(IO).to receive(:select).with([tcp_server], nil, nil, 0.5).and_raise(Errno::EBADF.new)

      expect(server.send(:accept_connection)).to be_nil
    end

    it "returns nil without waiting when the server is already stopping" do
      tcp_server = instance_double(TCPServer)

      server.instance_variable_set(:@tcp_server, tcp_server)
      server.instance_variable_set(:@running, false)

      allow(tcp_server).to receive(:accept_nonblock).and_raise(wait_readable_error.new)
      expect(IO).not_to receive(:select)

      expect(server.send(:accept_connection)).to be_nil
    end
  end
end
