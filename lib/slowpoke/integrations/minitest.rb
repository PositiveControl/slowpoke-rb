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
  tracker = Slowpoke.tracker
  config = Slowpoke.configuration

  Slowpoke::Reporter.new(tracker, config).report

  if config.history_path && tracker.any_slow?
    Slowpoke::History.new(config.history_path).write(tracker)
  end

  if config.ci && tracker.any_slow?
    count = tracker.results.size
    $stderr.puts "Slowpoke: #{count} slow test#{"s" unless count == 1} found, failing build."
    exit 1
  end
end
