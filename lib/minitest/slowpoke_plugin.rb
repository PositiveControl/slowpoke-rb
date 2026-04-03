# frozen_string_literal: true

# Minitest plugin autoload convention.
# When slowpoke is in the Gemfile, Minitest discovers this file automatically.
# Users can also pass --slowpoke on the command line.

module Minitest
  def self.plugin_slowpoke_options(opts, options)
    opts.on("--slowpoke", "Enable Slowpoke slow test reporting") do
      options[:slowpoke] = true
    end

    opts.on("--slowpoke-threshold SECONDS", Float, "Slow test threshold in seconds (default: 0.5)") do |val|
      options[:slowpoke] = true
      options[:slowpoke_threshold] = val
    end
  end

  def self.plugin_slowpoke_init(options)
    return unless options[:slowpoke] || ENV["SLOWPOKE"] == "1"

    Slowpoke.configuration.threshold = options[:slowpoke_threshold] if options[:slowpoke_threshold]

    require "slowpoke/integrations/minitest"
  end
end
