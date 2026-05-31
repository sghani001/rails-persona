module Persona
  module Query
    # Total count of a specific action
    def action_count(action)
      persona_events.for_action(action).count
    end

    # The action performed most frequently
    def most_frequent_action
      result = persona_events
                 .group(:action)
                 .order("count_all DESC")
                 .count
                 .first
      result&.first&.to_sym
    end

    # The action performed least frequently
    def least_frequent_action
      result = persona_events
                 .group(:action)
                 .order("count_all ASC")
                 .count
                 .first
      result&.first&.to_sym
    end

    # The most recently tracked action
    def last_action
      persona_events.recent(1).first&.action&.to_sym
    end

    # When was the last action performed
    def last_active_at
      persona_events.recent(1).first&.created_at
    end

    # Has the user been inactive for longer than the threshold?
    def inactive_since?(days = Persona.configuration.inactivity_threshold_days)
      return true if last_active_at.nil?
      last_active_at < days.days.ago
    end

    # Full breakdown of all actions and their counts
    def persona_summary
      persona_events
        .group(:action)
        .order("count_all DESC")
        .count
        .transform_keys(&:to_sym)
    end

    # All actions performed in a given time window
    def actions_between(from, to)
      persona_events
        .since(from)
        .before(to)
        .group(:action)
        .count
        .transform_keys(&:to_sym)
    end

    # Has this specific action ever been performed?
    def ever_did?(action)
      persona_events.for_action(action).exists?
    end

    # Most recent N events as a readable log
    def activity_log(limit = 10)
      persona_events.recent(limit).map do |e|
        { action: e.action.to_sym, at: e.created_at, metadata: e.metadata }
      end
    end
  end
end
