module Persona
  module Query
    # ---- Counts ---------------------------------------------------------------

    def action_count(action)
      persona_events.for_action(action).count
    end

    def total_events
      persona_events.count
    end

    # ---- Frequency ------------------------------------------------------------

    def most_frequent_action
      persona_events.group(:action).order("count_all DESC").count.keys.first&.to_sym
    end

    def least_frequent_action
      persona_events.group(:action).order("count_all ASC").count.keys.first&.to_sym
    end

    def top_actions(limit = 3)
      persona_events.group(:action).order("count_all DESC").limit(limit).count
                    .transform_keys(&:to_sym)
    end

    # ---- Recency --------------------------------------------------------------

    def last_action
      persona_events.recent(1).first&.action&.to_sym
    end

    def last_active_at
      persona_events.recent(1).first&.created_at
    end

    def first_action
      persona_events.oldest.first&.action&.to_sym
    end

    def first_active_at
      persona_events.oldest.first&.created_at
    end

    # ---- Inactivity -----------------------------------------------------------

    def inactive_since?(days = Persona.configuration.inactivity_threshold_days)
      return true if last_active_at.nil?
      last_active_at < days.days.ago
    end

    def days_since_last_activity
      return nil if last_active_at.nil?
      ((Time.current - last_active_at) / 1.day).to_i
    end

    # ---- Presence -------------------------------------------------------------

    def ever_did?(action)
      persona_events.for_action(action).exists?
    end

    def never_did?(action)
      !ever_did?(action)
    end

    # ---- Summaries ------------------------------------------------------------

    def persona_summary
      persona_events.group(:action).order("count_all DESC").count
                    .transform_keys(&:to_sym)
    end

    def actions_between(from, to)
      persona_events.since(from).before(to).group(:action).count
                    .transform_keys(&:to_sym)
    end

    def activity_log(limit = 10)
      persona_events.recent(limit).map do |e|
        { action: e.action.to_sym, at: e.created_at, metadata: e.metadata }
      end
    end

    # ---- Streaks / Patterns ---------------------------------------------------

    # Actions grouped by day for the last N days
    def daily_activity(days = 30)
      persona_events
        .since(days.days.ago)
        .group("DATE(created_at)")
        .order("DATE(created_at) ASC")
        .count
    end

    # Peak hour (0-23) when this record is most active
    def peak_hour
      persona_events
        .group("EXTRACT(HOUR FROM created_at)::int")
        .order("count_all DESC")
        .count
        .keys
        .first
    end

    # What % of activity is a specific action?
    def action_share(action)
      total = total_events
      return 0.0 if total.zero?
      (action_count(action).to_f / total * 100).round(1)
    end

    # ---- Class-level helpers (call on the class, not an instance) ------------
    module ClassMethods
      def persona_leaderboard(limit: 10)
        Persona::Summary.leaderboard(self, limit: limit)
      end

      def persona_class_summary
        Persona::Summary.class_summary(self)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
