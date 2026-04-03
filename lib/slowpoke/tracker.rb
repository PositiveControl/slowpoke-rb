# frozen_string_literal: true

module Slowpoke
  class Tracker
    attr_reader :results

    def initialize(configuration)
      @configuration = configuration
      @results = []
    end

    def record(name:, location:, duration:)
      return unless duration >= @configuration.threshold

      @results << { name: name, location: location, duration: duration }
    end

    def slow_tests
      sorted = case @configuration.sort
               when :slowest_first then @results.sort_by { |r| -r[:duration] }
               else @results
               end

      max = @configuration.max_results
      max.positive? ? sorted.first(max) : sorted
    end

    def any_slow?
      @results.any?
    end
  end
end
