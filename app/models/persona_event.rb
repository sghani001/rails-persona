class PersonaEvent < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true

  validates :action, presence: true

  scope :for_action,  ->(action) { where(action: action.to_s) }
  scope :recent,      ->(n = 10)  { order(created_at: :desc).limit(n) }
  scope :oldest,      ->          { order(created_at: :asc) }
  scope :since,       ->(time)    { where("created_at >= ?", time) }
  scope :before,      ->(time)    { where("created_at < ?", time) }
end
