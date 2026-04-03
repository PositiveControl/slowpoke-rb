# frozen_string_literal: true

require "slowpoke"

RSpec.configure do |config|
  config.around(:each) do |example|
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    example.run
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    Slowpoke.tracker.record(
      name: example.full_description,
      location: example.location,
      duration: duration
    )
  end

  config.after(:suite) do
    tracker = Slowpoke.tracker
    sp_config = Slowpoke.configuration

    Slowpoke::Reporter.new(tracker, sp_config).report

    if sp_config.history_path && tracker.any_slow?
      Slowpoke::History.new(sp_config.history_path).write(tracker)
    end

    if sp_config.ci && tracker.any_slow?
      count = tracker.results.size
      $stderr.puts "Slowpoke: #{count} slow test#{"s" unless count == 1} found, failing build."
      exit 1
    end
  end
end
