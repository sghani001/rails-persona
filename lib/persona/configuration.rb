module Persona
  class Configuration
    # How many events to keep per trackable record (nil = unlimited)
    attr_accessor :max_events_per_record

    # How many days before a user is considered "inactive"
    attr_accessor :inactivity_threshold_days

    # Whether to store events asynchronously via Sidekiq (if available)
    attr_accessor :async

    def initialize
      @max_events_per_record    = nil
      @inactivity_threshold_days = 30
      @async                    = false
    end
  end
end
