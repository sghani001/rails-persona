require "active_support/concern"

module Persona
  module Trackable
    extend ActiveSupport::Concern

    included do
      has_many :persona_events, as: :trackable, dependent: :destroy
      include Persona::Query

      class_attribute :_persona_tracked_actions, default: []
      class_attribute :_persona_open_tracking,   default: false
    end

    class_methods do
      # DSL: define which actions are trackable
      #
      #   persona do
      #     track :login
      #     track :export
      #     open_tracking!   # allow any action (no whitelist)
      #   end
      def persona(&block)
        builder = PersonaBuilder.new(self)
        builder.instance_eval(&block)
      end
    end

    # Track an action on this record.
    #
    #   user.track!(:login)
    #   user.track!(:purchase, metadata: { plan: "pro" })
    #   user.track!(:purchase, metadata: { plan: "pro" }, skip_cap: true)
    #
    def track!(action, metadata: {}, skip_cap: false)
      action = action.to_s

      unless self.class._persona_open_tracking
        if self.class._persona_tracked_actions.any? &&
           !self.class._persona_tracked_actions.include?(action.to_sym)
          raise Persona::UntrackedActionError,
                "'#{action}' is not declared on #{self.class.name}. " \
                "Add `track :#{action}` in your persona block, or call `open_tracking!`."
        end
      end

      if Persona.configuration.async && defined?(Sidekiq)
        Persona::AsyncTracker.track(self.class.name, id, action, metadata)
      else
        PersonaEvent.create!(
          trackable: self,
          action:    action,
          metadata:  metadata
        )
        Persona::Pruner.enforce_cap_for(self) unless skip_cap
      end
    end

    # Bulk track multiple actions at once (no cap enforcement between each)
    #
    #   user.bulk_track!([:login, :view_dashboard, :export_report])
    #
    def bulk_track!(actions, metadata: {})
      now = Time.current
      rows = actions.map do |action|
        {
          trackable_type: self.class.name,
          trackable_id:   id,
          action:         action.to_s,
          metadata:       metadata,
          created_at:     now,
          updated_at:     now
        }
      end
      PersonaEvent.insert_all!(rows)
      Persona::Pruner.enforce_cap_for(self)
    end

    # Reset all events for this record
    def reset_persona!
      persona_events.delete_all
    end

    # -------------------------------------------------------------------------
    # Inner DSL builder
    # -------------------------------------------------------------------------
    class PersonaBuilder
      def initialize(klass)
        @klass = klass
      end

      def track(action)
        @klass._persona_tracked_actions =
          (@klass._persona_tracked_actions + [action.to_sym]).uniq
      end

      # Skip whitelist enforcement — any string is valid
      def open_tracking!
        @klass._persona_open_tracking = true
      end
    end
  end

  class UntrackedActionError < StandardError; end
end
