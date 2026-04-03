# Slowpoke

Find your slow tests. Fast.

Zero-dependency Ruby gem that identifies slow tests across Minitest, RSpec, and any Ruby test framework. The smoke detector for your test suite.

## Quick Start

```bash
bundle install           # Install dependencies
rake test                # Run gem's own tests
bin/rubocop              # Lint (when added)
```

## Tech Stack

- **Language:** Ruby (>= 3.0)
- **Type:** Gem (library, not application)
- **Dependencies:** Zero runtime. That's the point.
- **Test framework:** Minitest (for the gem's own tests)
- **Linting:** RuboCop with standard config

## Positioning

Slowpoke is the **smoke detector**, not the fire investigation team. It answers "which tests are slow?" instantly with one line of setup. For deep profiling, test-prof exists — Slowpoke complements it, doesn't compete.

| | Slowpoke | test-prof | RSpec --profile |
|---|---|---|---|
| Setup | 1 require | Learn a toolkit | RSpec only, built-in |
| Minitest | First-class | Secondary | N/A |
| CI gating | Built-in | DIY | No |
| Dependencies | Zero | Many (modular) | N/A |
| "Why is it slow?" | v0.2 suggestions | Raw profiling data | No |

## Conventions

### Development Workflow

- **Planning:** Create plan files in `docs/plans/` for non-trivial features before coding
- **Collaborative:** Explain findings and reasoning; stop often for feedback
- **TDD:** Write tests before code. Commit in functional chunks when tests are green.
- **Commits:** Small, focused commits with clear messages
- **Documentation:** Update README.md and docs/ when implementing features

### Code Style

- **DRY:** Extract when patterns repeat 2-3 times
- **Zero dependencies:** Never add runtime dependencies. Dev dependencies only for testing/linting.
- **Modular:** Each integration is a separate file users opt into
- **No monkey-patching:** Use `prepend` for Minitest, hooks for RSpec
- **Frozen string literals:** Every Ruby file
- **Simple data structures:** Hashes and arrays over custom classes unless complexity demands it

### Architecture

```
lib/
├── slowpoke.rb                    # Entry point, module-level config + tracker
└── slowpoke/
    ├── version.rb                 # Semver
    ├── configuration.rb           # Config object with sensible defaults
    ├── tracker.rb                 # Records and filters slow tests
    ├── reporter.rb                # Formats and prints results
    └── integrations/
        ├── minitest.rb            # Minitest via prepend + after_run
        └── rspec.rb               # RSpec via around(:each) + after(:suite)
```

### Design Principles

- **Negligible overhead:** Two `Process.clock_gettime(CLOCK_MONOTONIC)` calls per test. Nothing else in the hot path.
- **Opt-in integrations:** Users require only the integration they need
- **Progressive disclosure:** Works with zero config, customizable when needed
- **ENV overrides:** All config should be overridable via environment variables for CI

### Anti-Patterns to Avoid

- Adding runtime dependencies for any reason
- Wrapping test execution in ways that change behavior or ordering
- Loading integration code eagerly — user must explicitly require it
- Complex class hierarchies — this gem should stay flat and simple
- Feature creep beyond the core mission: find slow tests, explain why, suggest fixes

## Testing

### Running Tests

```bash
rake test                              # All tests
ruby -Ilib:test test/tracker_test.rb   # Single file
```

### Test Patterns

Test the gem's own code with Minitest. Each core class gets its own test file:

```ruby
class TrackerTest < Minitest::Test
  def setup
    @config = Slowpoke::Configuration.new
    @tracker = Slowpoke::Tracker.new(@config)
  end

  def test_records_slow_tests
    @tracker.record(name: "slow_test", location: "test.rb:1", duration: 1.0)
    assert @tracker.any_slow?
  end

  def test_ignores_fast_tests
    @tracker.record(name: "fast_test", location: "test.rb:1", duration: 0.1)
    refute @tracker.any_slow?
  end
end
```

## Roadmap

### v0.1 — POC (current)

- [x] Core: threshold-based slow test detection
- [x] Integration: Minitest
- [x] Integration: RSpec
- [x] Reporter: sorted, colored terminal output
- [ ] CI mode: non-zero exit code when slow tests found
- [ ] Top-N limit: `config.max_results = 10`
- [ ] ENV overrides: `SLOWPOKE_THRESHOLD=1.0` without code changes
- [ ] History: write results to JSON for diffing across runs
- [ ] Minitest plugin autoload: `--slowpoke` flag via plugin system
- [ ] Gem's own test suite

### v0.2 — Slow Test Profiler

- [ ] Categorize: DB-heavy, network, sleep/wait, file I/O, setup bloat
- [ ] Suggestion engine: actionable fixes with references, pros, cons, estimated impact
- [ ] Optional test-prof integration: use its profilers when available, heuristics when not

### v0.3 — CI & Reporting

- [ ] JUnit/JSON output formatters
- [ ] GitHub Actions annotation integration
- [ ] Trend tracking across runs (SQLite or flat file)
- [ ] PR comment bot (via CI)

## Project Structure

```
├── CLAUDE.md              # This file
├── Gemfile                # Dev dependencies only
├── LICENSE.txt            # MIT
├── README.md              # User-facing docs
├── Rakefile               # Test task
├── slowpoke.gemspec       # Gem specification
├── lib/                   # Gem source
│   ├── slowpoke.rb
│   └── slowpoke/
├── test/                  # Gem's own tests (Minitest)
└── docs/                  # Plans, architecture notes
    └── plans/
```
