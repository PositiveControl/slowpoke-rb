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
    Slowpoke::Reporter.new(Slowpoke.tracker, Slowpoke.configuration).report
  end
end
