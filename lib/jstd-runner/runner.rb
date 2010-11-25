module JstdRunner
  class Runner

    DEFAULT_OPTIONS = {
      :port             => 4224,
      :vnc              => false,
      :monitor_interval => 10,
      :browser          => :firefox,
      :daemonize        => false
    }

    attr_reader :options

    def initialize
      @options = DEFAULT_OPTIONS.dup
      @shutting_down = @clean_shutdown = false
      @server_restarting = @browser_restarting = false
    end

    def run
      EM.run {
        configure_mailer
        trap_signals
        daemonize if options[:daemonize]
        shutdown_hook
        start_server
        start_browser
        capture_browser
      }
    end

    private

    def trap_signals
      trap_signal "INT"
      trap_signal "TERM"
    end

    def trap_signal(sig)
      trap(sig) {
        trap sig, "DEFAULT"
        Log.info "received #{sig}, shutting down"
        stop
      }
    end

    def shutting_down?
      @shutting_down
    end

    def server_restarting?
      @server_restarting
    end

    def browser_restarting?
      @browser_restarting
    end

    def clean_shutdown?
      @clean_shutdown
    end

    def shutdown_hook
      at_exit {
        unless clean_shutdown?
          body = $! ? [$!.message, $!.backtrace].flatten.join("\n") : '(empty)'
          notify "exiting @ #{Time.now}", body
        end
      }
    end

    def stop
      JstdRunner.shutting_down = true

      stop_browser
      stop_server

      EM.stop

      @clean_shutdown = true
    end

    def start_server
      server.start
      server.monitor(options[:monitor_interval]) {
        server.restart
        capture_browser
      }
    end

    def stop_server
      server.stop
    end

    def start_browser
      start_vnc if options[:vnc]
      browser.start
      browser.monitor(options[:monitor_interval]) {
        browser.restart
        capture_browser
      }
    end

    def capture_browser
      Log.info "capturing #{browser.inspect}"
      browser.capture(server.host, server.port)
    end

    def stop_browser
      stop_vnc if options[:vnc]
      browser.stop
    end

    def start_vnc
      vnc.start
      ENV['DISPLAY'] = vnc.display
    end

    def stop_vnc
      vnc.stop
    end

    def daemonize
      log_file = options[:daemonize]
      FileUtils.touch log_file

      Daemonize.daemonize(log_file, "#{$PROGRAM_NAME}-daemonized")
    end

    def server
      @server ||= Server.new(options[:port])
    end

    def browser
      @browser ||= Browser.new(options[:browser])
    end

    def vnc
      @vnc ||= VncControl.new
    end

    def configure_mailer
      return unless options[:smtp]

      uri = URI.parse(options[:smtp])
      Mail.defaults {
        delivery_method(uri.scheme.to_sym, :address => uri.host, :port => uri.port)
      }
    end

    def notify(subject, body)
      return unless recipients = options[:emails]

      Mail.deliver {
        from    [Etc.getlogin, Socket.gethostname].join("@")
        to      recipients
        subject "JstdRunner @ #{Socket.gethostname}: #{subject}"
        body    body
      }
    end

    def monitor(&blk)
      EM.add_periodic_timer(@options[:monitor_interval], &blk)
    end

  end # Runner
end # JstdRunner
