require "spec_helper"

module JstdRunner
  describe Runner do
    let(:runner) { Runner.new }

    before {
      EM.stub!(:run).and_yield
      runner.stub!(:at_exit)
      runner.stub!(:trap)
    }

    it "runs and watches the server" do
      browser = mock(Browser, :capture => nil).as_null_object
      runner.stub!(:browser).and_return(browser)

      server = mock(Server, :host => "localhost", :port => 4224)
      Server.should_receive(:new).with(4224, nil).and_return(server)
      server.should_receive(:start)
      server.should_receive(:monitor).with(10)

      runner.run
    end

    it "runs, captures and watches the browser" do
      server = mock(Server, :host => "localhost", :port => 1234).as_null_object
      runner.stub!(:server).and_return(server)

      browser = mock(Browser)
      Browser.should_receive(:new).with(:firefox).and_return(browser)
      browser.should_receive(:start)
      browser.should_receive(:capture).with("localhost", 1234)
      browser.should_receive(:monitor).with(10)

      runner.run
    end

    it "sets up restarts" do
      browser = mock(Browser).as_null_object
      server = mock(Server, :host => "localhost", :port => 1234).as_null_object

      runner.stub!(:browser).and_return browser
      runner.stub!(:server).and_return server

      EM.should_receive(:daily).with("01:15").and_yield
      runner.options[:restart_at] = "01:15"

      server.should_receive(:restart)
      browser.should_receive(:restart)
      browser.should_receive(:capture).with("localhost", 1234).twice

      runner.run
    end

    # TODO: more specs here
  end
end
