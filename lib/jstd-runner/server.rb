module JstdRunner
  class Server
    include Monitorable

    class StartupError < StandardError
    end

    class StopError < StandardError
    end

    JAR            = File.expand_path("../JsTestDriver-1.3.3d.jar", __FILE__)
    LAUNCH_TIMEOUT = 120 # this is huge, but I've seen it happen

    attr_reader :host, :port

    def initialize(port, jar = nil)
      @host       = "127.0.0.1"
      @port       = Integer(port)
      @restarting = false
      @jar        = jar || JAR
    end

    def start
      Log.info "starting JsTestDriver from #{@jar}"

      if immediate_poller.connected?
        raise StartupError, "JsTestDriver already running on #{@host}:#{@port}"
      end

      process.start

      unless long_poller.connected?
        process.stop rescue nil
        raise StartupError, "could not launch JsTestDriver server on #{@host}:#{@port} within #{LAUNCH_TIMEOUT} seconds"
      end
    end

    def restart
      @restarting = true
      Log.info "restarting server"
      stop rescue nil
      @process = nil
      start
      @restarting = false
    end

    def stop
      Log.info "stopping JsTestDriver"
      process.stop

      unless long_poller.closed?
        raise StopError, "could not stop JsTestDriver server on port #{@host}:#{@port} witin #{LAUNCH_TIMEOUT} seconds"
      end
    end

    def running?
      process.alive? && immediate_poller.connected?
    end

    private

    def process
      @process ||= (
        proc = ChildProcess.new("java", "-jar", @jar, "--port", @port.to_s)
        proc.io.inherit! if $DEBUG

        proc
      )
    end

    def long_poller
      @long_poller ||= Selenium::WebDriver::SocketPoller.new(@host, @port, LAUNCH_TIMEOUT)
    end

    def immediate_poller
      @immediate_poller ||= Selenium::WebDriver::SocketPoller.new(@host, @port, 5)
    end

  end
end
