# frozen_string_literal: true

require_relative "test_helper"
require "json"
require "tmpdir"

class HistoryTest < Minitest::Test
  def setup
    @config = Slowpoke::Configuration.new
    @config.threshold = 0.5
    @tracker = Slowpoke::Tracker.new(@config)
    @tmpdir = Dir.mktmpdir
    @path = File.join(@tmpdir, "slowpoke.json")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_writes_json_file
    @tracker.record(name: "SlowTest#test_thing", location: "test.rb:10", duration: 1.234)
    history = Slowpoke::History.new(@path)
    history.write(@tracker)

    assert File.exist?(@path)
    data = JSON.parse(File.read(@path))

    assert_equal 1, data["count"]
    assert_equal 500, data["threshold_ms"]
    assert data["timestamp"]

    test_entry = data["tests"].first
    assert_equal "SlowTest#test_thing", test_entry["name"]
    assert_equal "test.rb:10", test_entry["location"]
    assert_equal 1234.0, test_entry["duration_ms"]
  end

  def test_creates_directory_if_missing
    nested_path = File.join(@tmpdir, "subdir", "slowpoke.json")
    @tracker.record(name: "test", location: "test.rb:1", duration: 1.0)
    history = Slowpoke::History.new(nested_path)
    history.write(@tracker)

    assert File.exist?(nested_path)
  end

  def test_respects_max_results
    @config.max_results = 1
    @tracker.record(name: "slow", location: "a.rb:1", duration: 2.0)
    @tracker.record(name: "slower", location: "b.rb:1", duration: 3.0)
    history = Slowpoke::History.new(@path)
    history.write(@tracker)

    data = JSON.parse(File.read(@path))
    assert_equal 1, data["tests"].size
    assert_equal "slower", data["tests"].first["name"]
  end
end
