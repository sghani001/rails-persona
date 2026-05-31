require "spec_helper"

RSpec.describe Persona::Trackable do
  # Assume a User model with Persona::Trackable included
  let(:user) { User.create!(name: "Syed") }

  before do
    user.track!(:login)
    user.track!(:login)
    user.track!(:login)
    user.track!(:export_report)
    user.track!(:view_dashboard, metadata: { page: "home" })
  end

  describe "#track!" do
    it "creates a persona_event record" do
      expect { user.track!(:login) }.to change(PersonaEvent, :count).by(1)
    end

    it "raises UntrackedActionError for undeclared actions" do
      expect { user.track!(:unknown_action) }.to raise_error(Persona::UntrackedActionError)
    end

    it "stores metadata" do
      event = user.track!(:export_report, metadata: { format: "csv" })
      expect(event.metadata["format"]).to eq("csv")
    end
  end

  describe "#action_count" do
    it "returns correct count for an action" do
      expect(user.action_count(:login)).to eq(3)
    end

    it "returns 0 for an action never performed" do
      expect(user.action_count(:upgrade_plan)).to eq(0)
    end
  end

  describe "#most_frequent_action" do
    it "returns the action with the highest count" do
      expect(user.most_frequent_action).to eq(:login)
    end
  end

  describe "#least_frequent_action" do
    it "returns the action with the lowest count" do
      expect(user.least_frequent_action).to eq(:view_dashboard)
    end
  end

  describe "#last_action" do
    it "returns the most recently tracked action" do
      expect(user.last_action).to eq(:view_dashboard)
    end
  end

  describe "#last_active_at" do
    it "returns a timestamp" do
      expect(user.last_active_at).to be_a(Time)
    end
  end

  describe "#inactive_since?" do
    it "returns false when recently active" do
      expect(user.inactive_since?(30)).to be false
    end
  end

  describe "#ever_did?" do
    it "returns true for actions that occurred" do
      expect(user.ever_did?(:login)).to be true
    end

    it "returns false for actions that never occurred" do
      expect(user.ever_did?(:upgrade_plan)).to be false
    end
  end

  describe "#persona_summary" do
    it "returns a hash of action counts" do
      summary = user.persona_summary
      expect(summary[:login]).to eq(3)
      expect(summary[:export_report]).to eq(1)
      expect(summary[:view_dashboard]).to eq(1)
    end
  end

  describe "#activity_log" do
    it "returns recent events as hashes" do
      log = user.activity_log(2)
      expect(log.length).to eq(2)
      expect(log.first).to include(:action, :at, :metadata)
    end
  end

  describe "#actions_between" do
    it "returns actions within a time range" do
      result = user.actions_between(1.hour.ago, Time.current)
      expect(result[:login]).to eq(3)
    end
  end
end
