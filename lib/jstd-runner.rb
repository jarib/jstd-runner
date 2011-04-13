require "logger"
require "optparse"
require "etc"
require 'time'

module JstdRunner
  Log = Logger.new(STDOUT)

  class << self
    attr_accessor :shutting_down
  end
end

require "selenium-webdriver"
require "eventmachine"
require "daemons"
require "socket"
require "mail"
require "fileutils"

require "jstd-runner/cli"
require "jstd-runner/monitorable"
require "jstd-runner/browser"
require "jstd-runner/vnc_control"
require "jstd-runner/server"
require "jstd-runner/runner"


module EventMachine
  def self.daily at, &blk
    time = Time.parse(at) - Time.now
    time += 86400 if time < 0

    EM.run do
      run_me = proc{
        EM.add_timer(86400, run_me)
        blk.call
      }
      EM.add_timer(time, run_me)
    end
  end
end