module JstdRunner
  class Browser
    include Monitorable

    def initialize(type = :firefox)
      @type     = type
      @switched = @restarting = false
    end

    def start
      Log.info "starting browser - #{@type}"
      @browser = Selenium::WebDriver.for @type
    end

    def capture(host, port)
      @restarting = true
      @switched = false
      start unless @browser
      @browser.get "http://#{host}:#{port}/capture"
      @restarting = false
    end

    def restart
      @restarting = true
      Log.info "restarting browser - #{@type}"
      stop rescue nil
      @switched = false
      start
      @restarting = false
    end

    def stop
      Log.info "stopping browser - #{@type}"
      @browser.quit if @browser
    rescue Errno::ECONNREFUSED
      # looks like we're not running
    end

    def running?
      Log.info "browser state: #{status}"
      true
    rescue
      false
    end

    def status
      status_span.text
    end

    private

    def status_span
      unless @switched
        @browser.switch_to.frame("0")
        @switched = true
      end

      @browser.find_element(:tag_name => "span")
    end

  end
end
