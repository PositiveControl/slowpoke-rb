# frozen_string_literal: true

module Slowpoke
  class Configuration
    attr_accessor :threshold, :output, :color, :sort, :max_results, :ci, :history_path

    def initialize
      @threshold = Float(ENV.fetch("SLOWPOKE_THRESHOLD", 0.5))
      @max_results = Integer(ENV.fetch("SLOWPOKE_MAX_RESULTS", 0)) # 0 = unlimited
      @ci = ENV.fetch("SLOWPOKE_CI", "false") == "true"
      @history_path = ENV.fetch("SLOWPOKE_HISTORY", nil)
      @output = $stdout
      @color = true
      @sort = :slowest_first
    end
  end
end
