# frozen_string_literal: true

module Slowpoke
  class Reporter
    def initialize(tracker, configuration)
      @tracker = tracker
      @config = configuration
    end

    def report
      return unless @tracker.any_slow?

      out = @config.output
      out.puts header
      @tracker.slow_tests.each { |t| out.puts format_test(t) }
      out.puts footer
    end

    private

    def header
      count = @tracker.results.size
      shown = @tracker.slow_tests.size
      threshold_ms = (@config.threshold * 1000).to_i
      label = "#{count} slow test#{"s" unless count == 1} (>#{threshold_ms}ms)"
      label += " — showing top #{shown}" if shown < count
      "\n#{paint("🐌 Slowpoke found #{label}:", :yellow)}\n"
    end

    def format_test(test)
      ms = (test[:duration] * 1000).round(1)
      color = ms > (@config.threshold * 2000) ? :red : :yellow
      "  #{paint("#{ms}ms", color)}  #{test[:name]}\n         #{paint(test[:location], :dim)}"
    end

    def footer
      ""
    end

    def paint(text, color)
      return text unless @config.color

      code = case color
             when :red then "\e[31m"
             when :yellow then "\e[33m"
             when :dim then "\e[2m"
             else ""
             end
      "#{code}#{text}\e[0m"
    end
  end
end
