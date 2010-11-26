require 'spec_helper'

module JstdRunner
  describe Monitorable do
    let(:object) {
      obj = Object.new

      class << obj
        attr_accessor :restarting, :running
        include Monitorable

        def running?
          @running
        end
      end

      obj
    }

    before { EM.should_receive(:add_periodic_timer).and_yield }
    after { JstdRunner.shutting_down = false }

    it "yields if self is not running" do
      did_yield = false

      object.running = false
      object.monitor(1) { did_yield = true }

      did_yield.should be_true
    end

    it "does not yield when self is running" do
      did_yield = false

      object.running = true
      object.monitor(1) { did_yield = true }

      did_yield.should be_false
    end

    it "does not check when we're shutting down" do
      JstdRunner.shutting_down = true
      object.should_not_receive :running?

      object.monitor(1) {}
    end

    it "does not check when self is restarting" do
      object.restarting = true
      object.should_not_receive :running?

      object.monitor(1) {}
    end

  end
end
