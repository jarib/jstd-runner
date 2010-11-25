require "logger"
require "optparse"
require "etc"

module JstdRunner
  Log = Logger.new(STDOUT)
end

require "selenium-webdriver"
require "eventmachine"
require "daemons"
require "socket"
require "mail"
require "fileutils"

require "jstd-runner/cli"
require "jstd-runner/browser"
require "jstd-runner/vnc_control"
require "jstd-runner/server"
require "jstd-runner/runner"


