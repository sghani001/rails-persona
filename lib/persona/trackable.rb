require "active_support/concern"

module Persona
  module Trackable
    extend ActiveSupport::Concern

    included do
      has_many :persona_events, as: :trackable, dependent: :destroy
      include Persona::Query

      class_attribute :_persona_tracked_actions, default: []
    end

    class_methods do
      # DSL: define which actions are trackable on this model
      #
      # Usage:
      #   persona do
      #     track :login
      #     track :export_report
      #     track :view_dashboard
      #   end
      def persona(&block)
        builder = PersonaBuilder.new(self)
        builder.instance_eval(&block)
      end
    end

    # Track an action on this record
    #
    # Usage:
    #   user.track!(:login)
    #   user.track!(:purchase, metadata: { plan: "pro", amount: 49 })
    def track!(action, metadata: {})
      action = action.to_s

      if self.class._persona_tracked_actions.any? &&
         !self.class._persona_tracked_actions.include?(action.to_sym)
        raise Persona::UntrackedActionError,
              "'#{action}' is not a declared persona action for #{self.class.name}. " \
              "Add `track :#{action}` inside your persona block."
      end

      event = persona_events.create!(
        action:   action,
        metadata: metadata
      )

      # Enforce max_events cap if configured
      cap = Persona.configuration.max_events_per_record
      if cap && persona_events.count > cap
        persona_events.oldest.limit(persona_events.count - cap).destroy_all
      end

      event
    end

    # -----------------------------------------------------------------------
    # Inner DSL builder
    # -----------------------------------------------------------------------
    class PersonaBuilder
      def initialize(klass)
        @klass = klass
      end

      def track(action)
        @klass._persona_tracked_actions =
          (@klass._persona_tracked_actions + [action.to_sym]).uniq
      end
    end
  end

  # Custom error raised when an undeclared action is tracked
  class UntrackedActionError < StandardError; end
end
