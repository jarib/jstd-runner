module JstdRunner
  module Monitorable
    def monitor(interval, &failure_callback)
      EM.add_periodic_timer(interval) {
        next if JstdRunner.shutting_down || @restarting
        if running?
          Log.info "ok: #{self}"
        else
          Log.info "dead: #{self}"
          failure_callback.call
        end
      }
    end
  end
end
