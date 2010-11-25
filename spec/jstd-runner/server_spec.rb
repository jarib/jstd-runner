require "spec_helper"

module JstdRunner
  describe Server do

    let(:server) { Server.new(4224) }

    before {
      server.stub!(:long_poller => mock(:connected? => true))
    }

    it "launches the server on the given port" do
      ChildProcess.should_receive(:new).with(
        "java", "-jar", /JsTestDriver.+\.jar/, "--port", "4224"
      ).and_return(mock(ChildProcess, :start => true))

      server.start
    end

  end
end