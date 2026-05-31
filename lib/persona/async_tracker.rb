module Persona
  class AsyncTracker
    include Sidekiq::Worker if defined?(Sidekiq)

    def self.track(trackable_type, trackable_id, action, metadata)
      if defined?(Sidekiq)
        perform_async(trackable_type, trackable_id, action, metadata)
      else
        perform(trackable_type, trackable_id, action, metadata)
      end
    end

    def self.perform(trackable_type, trackable_id, action, metadata)
      record = trackable_type.constantize.find(trackable_id)
      PersonaEvent.create!(
        trackable: record,
        action:    action,
        metadata:  metadata
      )
    end

    def perform(trackable_type, trackable_id, action, metadata)
      self.class.perform(trackable_type, trackable_id, action, metadata)
    end
  end
end
