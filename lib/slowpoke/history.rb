# frozen_string_literal: true

require "json"

module Slowpoke
  class History
    DEFAULT_PATH = "tmp/slowpoke.json"

    def initialize(path = nil)
      @path = path || DEFAULT_PATH
    end

    def write(tracker)
      results = tracker.slow_tests.map do |t|
        { name: t[:name], location: t[:location], duration_ms: (t[:duration] * 1000).round(1) }
      end

      data = {
        timestamp: Time.now.iso8601,
        threshold_ms: (Slowpoke.configuration.threshold * 1000).to_i,
        count: results.size,
        tests: results
      }

      dir = File.dirname(@path)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      File.write(@path, JSON.pretty_generate(data))
    end
  end
end
