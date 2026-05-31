class PersonaEvent < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true

  validates :action, presence: true

  # ---- Scopes ---------------------------------------------------------------
  scope :for_action,  ->(action) { where(action: action.to_s) }
  scope :recent,      ->(n = 10) { order(created_at: :desc).limit(n) }
  scope :oldest,      ->         { order(created_at: :asc) }
  scope :since,       ->(time)   { where("created_at >= ?", time) }
  scope :before,      ->(time)   { where("created_at < ?", time) }
  scope :on_day,      ->(date)   { where(created_at: date.all_day) }
  scope :this_week,   ->         { since(1.week.ago) }
  scope :this_month,  ->         { since(1.month.ago) }

  # ---- Serialization --------------------------------------------------------
  def metadata
    val = super
    val.is_a?(String) ? JSON.parse(val) : val
  rescue JSON::ParserError
    {}
  end
end
