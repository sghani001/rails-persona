module Persona
  class Configuration
    # Max events stored per trackable record (nil = unlimited)
    attr_accessor :max_events_per_record

    # Days of inactivity before inactive_since? returns true
    attr_accessor :inactivity_threshold_days

    # Use Sidekiq for async tracking (requires sidekiq gem)
    attr_accessor :async

    # Auto-prune events older than N days on each track! call (nil = off)
    attr_accessor :auto_prune_after_days

    def initialize
      @max_events_per_record     = nil
      @inactivity_threshold_days = 30
      @async                     = false
      @auto_prune_after_days     = nil
    end
  end
end
