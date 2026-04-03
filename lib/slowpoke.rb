# frozen_string_literal: true

require_relative "slowpoke/version"
require_relative "slowpoke/configuration"
require_relative "slowpoke/tracker"
require_relative "slowpoke/reporter"

module Slowpoke
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def tracker
      @tracker ||= Tracker.new(configuration)
    end

    def reset!
      @configuration = nil
      @tracker = nil
    end
  end
end
