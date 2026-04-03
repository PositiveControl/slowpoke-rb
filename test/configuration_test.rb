# frozen_string_literal: true

require_relative "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @config = Slowpoke::Configuration.new
  end

  def test_default_threshold
    assert_equal 0.5, @config.threshold
  end

  def test_default_max_results
    assert_equal 0, @config.max_results
  end

  def test_default_ci
    assert_equal false, @config.ci
  end

  def test_default_color
    assert_equal true, @config.color
  end

  def test_default_sort
    assert_equal :slowest_first, @config.sort
  end

  def test_default_output
    assert_equal $stdout, @config.output
  end

  def test_default_history_path
    assert_nil @config.history_path
  end

  def test_threshold_is_settable
    @config.threshold = 1.0
    assert_equal 1.0, @config.threshold
  end

  def test_env_override_threshold
    ENV["SLOWPOKE_THRESHOLD"] = "2.0"
    config = Slowpoke::Configuration.new
    assert_equal 2.0, config.threshold
  ensure
    ENV.delete("SLOWPOKE_THRESHOLD")
  end

  def test_env_override_max_results
    ENV["SLOWPOKE_MAX_RESULTS"] = "5"
    config = Slowpoke::Configuration.new
    assert_equal 5, config.max_results
  ensure
    ENV.delete("SLOWPOKE_MAX_RESULTS")
  end

  def test_env_override_ci
    ENV["SLOWPOKE_CI"] = "true"
    config = Slowpoke::Configuration.new
    assert_equal true, config.ci
  ensure
    ENV.delete("SLOWPOKE_CI")
  end

  def test_env_override_history
    ENV["SLOWPOKE_HISTORY"] = "tmp/custom.json"
    config = Slowpoke::Configuration.new
    assert_equal "tmp/custom.json", config.history_path
  ensure
    ENV.delete("SLOWPOKE_HISTORY")
  end
end
