# frozen_string_literal: true

require_relative "test_helper"
require "stringio"

class ReporterTest < Minitest::Test
  def setup
    @config = Slowpoke::Configuration.new
    @config.threshold = 0.5
    @config.color = false
    @output = StringIO.new
    @config.output = @output
    @tracker = Slowpoke::Tracker.new(@config)
  end

  def test_no_output_when_no_slow_tests
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    assert_empty @output.string
  end

  def test_reports_slow_tests
    @tracker.record(name: "SlowTest#test_thing", location: "test/slow_test.rb:10", duration: 1.0)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    output = @output.string
    assert_includes output, "Slowpoke found 1 slow test"
    assert_includes output, "1000.0ms"
    assert_includes output, "SlowTest#test_thing"
    assert_includes output, "test/slow_test.rb:10"
  end

  def test_pluralizes_correctly
    @tracker.record(name: "test_a", location: "a.rb:1", duration: 1.0)
    @tracker.record(name: "test_b", location: "b.rb:1", duration: 2.0)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    assert_includes @output.string, "2 slow tests"
  end

  def test_shows_threshold_in_header
    @config.threshold = 1.0
    @tracker.record(name: "test_a", location: "a.rb:1", duration: 1.5)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    assert_includes @output.string, ">1000ms"
  end

  def test_shows_top_n_label_when_truncated
    @config.max_results = 1
    @tracker.record(name: "test_a", location: "a.rb:1", duration: 2.0)
    @tracker.record(name: "test_b", location: "b.rb:1", duration: 1.0)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    output = @output.string
    assert_includes output, "showing top 1"
    assert_includes output, "test_a"
    refute_includes output, "test_b"
  end

  def test_color_output
    @config.color = true
    @tracker.record(name: "test_a", location: "a.rb:1", duration: 1.5)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    assert_includes @output.string, "\e[31m" # red for >2x threshold
  end

  def test_yellow_for_near_threshold
    @config.color = true
    @tracker.record(name: "test_a", location: "a.rb:1", duration: 0.6)
    reporter = Slowpoke::Reporter.new(@tracker, @config)
    reporter.report

    assert_includes @output.string, "\e[33m" # yellow for near threshold
  end
end
