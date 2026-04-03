# frozen_string_literal: true

require "slowpoke"

module Slowpoke
  module Integrations
    module MinitestPlugin
      def before_setup
        @slowpoke_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        super
      end

      def after_teardown
        super
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @slowpoke_start

        Slowpoke.tracker.record(
          name: "#{self.class}##{name}",
          location: method(name).source_location&.join(":") || "unknown",
          duration: duration
        )
      end
    end
  end
end

Minitest::Test.prepend(Slowpoke::Integrations::MinitestPlugin)

Minitest.after_run do
  Slowpoke::Reporter.new(Slowpoke.tracker, Slowpoke.configuration).report
end
