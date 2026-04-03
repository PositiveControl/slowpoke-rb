# frozen_string_literal: true

require_relative "lib/slowpoke/version"

Gem::Specification.new do |spec|
  spec.name = "slowpoke-rb"
  spec.version = Slowpoke::VERSION
  spec.authors = ["Mark Evans"]
  spec.summary = "Find your slow tests. Fast."
  spec.description = "A stupid-lightweight gem that identifies slow tests across Minitest, RSpec, and more."
  spec.homepage = "https://github.com/PositiveControl/slowpoke"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies. That's the point.
end
