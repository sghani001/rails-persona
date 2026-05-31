module Persona
  class Pruner
    # Prune events older than N days globally
    def self.prune_older_than(days)
      PersonaEvent.where("created_at < ?", days.days.ago).delete_all
    end

    # Prune per-record if max_events_per_record is set
    def self.enforce_cap_for(record)
      cap = Persona.configuration.max_events_per_record
      return unless cap

      count = record.persona_events.count
      return unless count > cap

      oldest_ids = record.persona_events
                         .order(created_at: :asc)
                         .limit(count - cap)
                         .pluck(:id)
      PersonaEvent.where(id: oldest_ids).delete_all
    end
  end
end
