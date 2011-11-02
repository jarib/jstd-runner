require "spec_helper"

module JstdRunner
  describe Browser do
    let(:browser) { Browser.new }

    it "launches the the browser" do
      Selenium::WebDriver.should_receive(:for).once

      browser.start
    end

    it "captures the browser" do
      mock_driver = mock(Selenium::WebDriver::Driver)

      Selenium::WebDriver.should_receive(:for).and_return(mock_driver)
      mock_driver.should_receive(:get).with("http://localhost:4224/capture")

      browser.capture "localhost", 4224
    end

    it "stops the browser" do
      mock_driver = mock(Selenium::WebDriver::Driver)

      Selenium::WebDriver.should_receive(:for).and_return(mock_driver)
      mock_driver.should_receive(:quit)

      browser.start
      browser.stop
    end

    it "restarts the browser" do
      browser.should_receive(:stop).once
      browser.should_receive(:start).once

      browser.restart
    end

    it "restarts the browser if it was already stopped" do
      browser.should_receive(:stop).once.and_raise("foo")
      browser.should_receive(:start).once

      browser.restart
    end

    it "knows if the browser is running" do
      browser.stub!(:status_spans).and_return([mock(:text => "Waiting...")])
      browser.should be_running
    end

    it "knows if the browser is not running" do
      # if we can't get the span, we assume it's dead
      browser.stub!(:status_span).and_raise(Errno::ECONNREFUSED)
      browser.should_not be_running
    end
  end
end