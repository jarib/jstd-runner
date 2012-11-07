module JstdRunner
  class CLI

    def initialize(args)
      parse args
    end

    def run
      runner.run
    end

    private

    def parse(args)
      OptionParser.new { |op|
        op.banner = "Usage: #{File.basename $PROGRAM_NAME} [options]"
        op.separator ""

        op.on("-p", "--port PORT", Integer) do |port|
          runner.options[:port] = port
        end

        op.on("-x", "--vnc") do
          runner.options[:vnc] = true
        end

        op.on("-m", "--monitor INTERVAL", Integer) do |int|
          runner.options[:monitor_interval] = int
        end

        op.on("-b", "--browser BROWSER", String) do |browser|
          runner.options[:browser] = browser.to_sym
        end

        op.on("-d", "--daemonize LOGFILE", String) do |log|
          runner.options[:daemonize] = log
        end

        op.on("-n", "--notify email1,email2,email3", Array) do |emails|
          runner.options[:emails] = emails
        end

        op.on("-r", "--restart hour:minute") do |hour_minute|
          runner.options[:restart_at] = hour_minute
        end

        op.on('-t', '--traffic-log PATH') do |path|
          runner.options[:traffic_log] = path
        end

        op.on('-j', '--jar PATH') do |path|
          runner.options[:jar] = path
        end
      }.parse!(args)
    end

    def runner
      @runner ||= Runner.new
    end

  end
end
