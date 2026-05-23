# Slowpoke-rb

Find your slow tests. Fast.

A stupid-lightweight Ruby gem that identifies slow tests. Zero dependencies. Works with Minitest, RSpec, and anything that runs in Ruby.

## Why

You don't need a profiler to know *which* tests are slow. You need a one-liner that tells you at the end of every run. That's Slowpoke.

**What it does today (v0.1):** flags tests slower than a threshold (default: 500ms) and prints a sorted report.

**What's coming (v0.2):** ~~profiles~~ suggets *why* your tests are slow ~~and suggests fixes with references, pros, and cons~~.

## Install

```ruby
# Gemfile
gem "slowpoke-rb", group: :test
```

## Setup

### Minitest

```ruby
# test/test_helper.rb
require "slowpoke_rb/integrations/minitest"

# Optional configuration
SlowpokeRb.configure do |config|
  config.threshold = 0.5  # seconds (default: 0.5)
  config.color = true      # ANSI colors (default: true)
  config.sort = :slowest_first
end
```

### RSpec

```ruby
# spec/spec_helper.rb
require "slowpoke_rb/integrations/rspec"

SlowpokeRb.configure do |config|
  config.threshold = 1.0  # be generous, or don't
end
```

## Output

```
🐌 Slowpoke found 3 slow tests (>500ms):

  1203.4ms  UserTest#test_sends_welcome_email
            test/models/user_test.rb:42
  872.1ms   OrderTest#test_calculates_tax_for_international
            test/models/order_test.rb:18
  511.3ms   AuthTest#test_locks_after_failed_attempts
            test/integration/auth_test.rb:7
```

Tests over 2x the threshold show in red. Everything else in yellow.

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `threshold` | `0.5` | Seconds. Tests slower than this get flagged. |
| `color` | `true` | ANSI color output. |
| `sort` | `:slowest_first` | Sort order for the report. |
| `output` | `$stdout` | Where to print. Any IO object works. |

## Design Principles

- **Zero dependencies.** The gem is just Ruby.
- **No monkey-patching.** Uses `prepend` for Minitest, `around` hooks for RSpec.
- **Negligible overhead.** Two `Process.clock_gettime` calls per test. That's it.

## Roadmap

### v0.2 — Slow Test Profiler

Slowpoke will analyze *why* tests are slow and suggest actionable fixes:

- **Database heavy** — too many records, missing fixtures, N+1 in setup
- **Network calls** — unmatched HTTP requests, missing VCR cassettes
- **Sleep/wait** — literal `sleep` calls, Capybara wait timeouts
- **File I/O** — temp files, large fixtures, disk-bound operations
- **Setup bloat** — expensive `before(:each)` that should be `before(:all)`

Each suggestion includes references ~~, pros, cons, and estimated impact~~.

## License

MIT
