require "spec_helper"

module JstdRunner
  describe Server do

    let(:server) { Server.new(4224) }
    let(:mock_process) { mock(ChildProcess, :start => true) }
    let(:connected_poller) { mock(:connected? => true, :closed? => false) }
    let(:closed_poller) {  mock(:connected? => false, :closed? => true) }

    it "has a correct reference to the bundled jar" do
      File.exist?(Server::JAR).should be_true
    end

    it "launches the server on the given port" do
      server.stub!(:immediate_poller => closed_poller)

      ChildProcess.should_receive(:new).with(
        "java", "-jar", /JsTestDriver.+\.jar/, "--port", "4224"
      ).and_return(mock_process)

      server.stub!(:long_poller).and_return(connected_poller)

      server.start
    end

    it "raises a StartupError if the server is already running" do
      server.stub!(:immediate_poller => connected_poller)
      server.stub!(:process => mock_process)

      lambda { server.start }.should raise_error(Server::StartupError)
    end

    it "raises a StartupError if the server doesn't start" do
      server.stub!(:immediate_poller => closed_poller)
      server.stub!(:long_poller => closed_poller)
      server.stub!(:process => mock_process)

      # in case it's alive but not launched properly
      mock_process.should_receive(:stop)

      lambda { server.start }.should raise_error(Server::StartupError)
    end

    it "restarts the server" do
      server.should_receive(:stop).once
      server.should_receive(:start).once

      server.restart
    end

    it "restarts the server even if stop fails" do
      server.should_receive(:stop).and_raise("argh")
      server.should_receive(:start).once

      server.restart
    end

    it "stops the server" do
      server.stub!(:process => mock_process)
      server.stub!(:long_poller => mock(:closed? => true))

      mock_process.should_receive(:stop)

      server.stop
    end

    it "raises a StopError if the server could not be stopped" do
      server.stub!(:process => mock_process)
      server.stub!(:long_poller => connected_poller)

      mock_process.should_receive(:stop)

      lambda { server.stop }.should raise_error(Server::StopError)
    end

    it "knows if the server is alive" do
      server.stub!(:process => mock(:alive? => true))
      server.stub!(:immediate_poller => connected_poller)

      server.should be_running
    end

    it "considers the server dead if it does not respond to connections" do
      server.stub!(:process => mock(:alive? => true))
      server.stub!(:immediate_poller => closed_poller)

      server.should_not be_running
    end

    it "considers the server dead if the process died" do
      server.stub!(:process => mock(:alive? => false))

      server.should_not be_running
    end

  end
end
