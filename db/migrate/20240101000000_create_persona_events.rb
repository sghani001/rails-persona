class CreatePersonaEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :persona_events do |t|
      t.references :trackable, polymorphic: true, null: false, index: true
      t.string     :action,    null: false
      t.text       :metadata,  null: false, default: "{}"

      t.timestamps
    end

    add_index :persona_events, :action
    add_index :persona_events, :created_at
    add_index :persona_events, [:trackable_type, :trackable_id, :action],
              name: "index_persona_events_on_trackable_and_action"
  end
end
