require "spec_helper"

module JstdRunner
  describe CLI do
    let(:runner) { mock(Runner, :options => {}) }
    before { Runner.stub!(:new).and_return(runner) }

    def cli(str = '')
      CLI.new(str.split(" "))
    end

    it "configures the port" do
      cli "--port 1234"
      runner.options[:port].should == 1234
    end

    it "configures VNC" do
      cli "--vnc"
      runner.options[:vnc].should be_true
    end

    it "configures the monitoring interval" do
      cli "--monitor 10"
      runner.options[:monitor_interval].should == 10
    end

    it "configures the browser type" do
      cli "--browser chrome"
      runner.options[:browser].should == :chrome
    end

    it "configures daemonization" do
      cli "--daemonize /foo/bar"
      runner.options[:daemonize].should == "/foo/bar"
    end

    it "configures email notifications" do
      cli "--notify a@b.com,x@y.com"
      runner.options[:emails].should == %w[a@b.com x@y.com]
    end

    it "delegates to the runner when run" do
      runner.should_receive(:run)
      cli.run
    end

    it "configures restarts" do
      cli "--restart 01:15"
      runner.options[:restart_at].should == "01:15"
    end
  end
end