module Persona
  module Summary
    # Compare two records side by side
    def self.compare(record_a, record_b)
      actions = (record_a.persona_summary.keys + record_b.persona_summary.keys).uniq

      actions.each_with_object({}) do |action, hash|
        hash[action] = {
          record_a.class.name.downcase + "_#{record_a.id}" => record_a.action_count(action),
          record_b.class.name.downcase + "_#{record_b.id}" => record_b.action_count(action)
        }
      end
    end

    # Top N most active records of a given class
    def self.leaderboard(klass, limit: 10)
      PersonaEvent
        .where(trackable_type: klass.name)
        .group(:trackable_id)
        .order("count_all DESC")
        .limit(limit)
        .count
        .map do |id, count|
          { record: klass.find(id), total_events: count }
        end
    end

    # Class-wide action breakdown
    def self.class_summary(klass)
      PersonaEvent
        .where(trackable_type: klass.name)
        .group(:action)
        .order("count_all DESC")
        .count
        .transform_keys(&:to_sym)
    end
  end
end
