# frozen_string_literal: true

require_relative "test_helper"

class SlowpokeTest < Minitest::Test
  def teardown
    Slowpoke.reset!
  end

  def test_configure_block
    Slowpoke.configure do |config|
      config.threshold = 2.0
    end

    assert_equal 2.0, Slowpoke.configuration.threshold
  end

  def test_tracker_uses_configuration
    Slowpoke.configure { |c| c.threshold = 1.0 }
    Slowpoke.tracker.record(name: "fast", location: "test.rb:1", duration: 0.5)

    refute Slowpoke.tracker.any_slow?
  end

  def test_reset_clears_state
    Slowpoke.configure { |c| c.threshold = 9.0 }
    Slowpoke.tracker.record(name: "test", location: "test.rb:1", duration: 10.0)

    Slowpoke.reset!

    assert_equal 0.5, Slowpoke.configuration.threshold
    refute Slowpoke.tracker.any_slow?
  end

  def test_version_exists
    assert Slowpoke::VERSION
  end
end
