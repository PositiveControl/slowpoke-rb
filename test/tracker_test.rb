# frozen_string_literal: true

require_relative "test_helper"

class TrackerTest < Minitest::Test
  def setup
    @config = Slowpoke::Configuration.new
    @config.threshold = 0.5
    @tracker = Slowpoke::Tracker.new(@config)
  end

  def test_records_slow_test
    @tracker.record(name: "slow_test", location: "test.rb:1", duration: 1.0)

    assert @tracker.any_slow?
    assert_equal 1, @tracker.results.size
  end

  def test_ignores_fast_test
    @tracker.record(name: "fast_test", location: "test.rb:1", duration: 0.1)

    refute @tracker.any_slow?
    assert_empty @tracker.results
  end

  def test_records_test_at_exact_threshold
    @tracker.record(name: "edge_test", location: "test.rb:1", duration: 0.5)

    assert @tracker.any_slow?
  end

  def test_ignores_test_just_below_threshold
    @tracker.record(name: "close_test", location: "test.rb:1", duration: 0.499)

    refute @tracker.any_slow?
  end

  def test_slow_tests_sorted_slowest_first
    @tracker.record(name: "medium", location: "test.rb:1", duration: 1.0)
    @tracker.record(name: "slowest", location: "test.rb:2", duration: 3.0)
    @tracker.record(name: "fast_slow", location: "test.rb:3", duration: 0.6)

    names = @tracker.slow_tests.map { |t| t[:name] }
    assert_equal %w[slowest medium fast_slow], names
  end

  def test_max_results_limits_output
    @config.max_results = 2
    @tracker.record(name: "a", location: "test.rb:1", duration: 3.0)
    @tracker.record(name: "b", location: "test.rb:2", duration: 2.0)
    @tracker.record(name: "c", location: "test.rb:3", duration: 1.0)

    assert_equal 2, @tracker.slow_tests.size
    assert_equal 3, @tracker.results.size
  end

  def test_max_results_zero_means_unlimited
    @config.max_results = 0
    5.times { |i| @tracker.record(name: "test_#{i}", location: "test.rb:#{i}", duration: 1.0) }

    assert_equal 5, @tracker.slow_tests.size
  end

  def test_stores_name_location_duration
    @tracker.record(name: "MyTest#test_something", location: "test/my_test.rb:42", duration: 1.5)

    result = @tracker.results.first
    assert_equal "MyTest#test_something", result[:name]
    assert_equal "test/my_test.rb:42", result[:location]
    assert_equal 1.5, result[:duration]
  end
end
