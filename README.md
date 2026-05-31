# rails-persona 🎭

> Attach behavioral analytics to any Rails model — no external tools needed.

**rails-persona** lets you track, query, and understand how users (or any model) interact with your app — all stored in your own database. No Mixpanel, no Segment, no third-party dependencies.

## Installation

```ruby
gem "rails-persona"
```

```bash
bundle install
rails db:migrate
```

## Quick Start

### 1. Include in your model

```ruby
class User < ApplicationRecord
  include Persona::Trackable

  persona do
    track :login
    track :export_report
    track :view_dashboard
    track :upgrade_plan
  end
end
```

### 2. Track actions

```ruby
current_user.track!(:login)
current_user.track!(:upgrade_plan, metadata: { plan: "pro", amount: 49 })
```

### 3. Query behavior

```ruby
user.action_count(:login)          # => 42
user.most_frequent_action          # => :login
user.least_frequent_action         # => :upgrade_plan
user.last_action                   # => :export_report
user.last_active_at                # => 2024-05-30 14:22:00 UTC
user.inactive_since?               # => false  (default 30 days)
user.inactive_since?(7)            # => false  (custom 7 days)
user.ever_did?(:export_report)     # => true

user.persona_summary
# => { login: 42, export_report: 5, view_dashboard: 18, upgrade_plan: 1 }

user.actions_between(1.week.ago, Time.current)
# => { login: 7, view_dashboard: 3 }

user.activity_log(5)
# => [
#      { action: :export_report, at: 2024-05-30 14:22:00, metadata: {} },
#      { action: :login,         at: 2024-05-30 09:01:00, metadata: {} },
#    ]
```

## Configuration

```ruby
# config/initializers/persona.rb
Persona.configure do |config|
  config.inactivity_threshold_days = 14    # default: 30
  config.max_events_per_record     = 500   # default: nil (unlimited)
end
```

## Works on any model

```ruby
class Post < ApplicationRecord
  include Persona::Trackable

  persona do
    track :viewed
    track :shared
    track :bookmarked
  end
end

post.track!(:viewed)
post.action_count(:viewed)   # => 128
```

## API Reference

| Method | Description |
|--------|-------------|
| `track!(action, metadata: {})` | Record an action |
| `action_count(action)` | How many times an action occurred |
| `most_frequent_action` | The action done most |
| `least_frequent_action` | The action done least |
| `last_action` | Most recent action symbol |
| `last_active_at` | Timestamp of last action |
| `inactive_since?(days)` | True if no action in N days |
| `ever_did?(action)` | True if action ever occurred |
| `persona_summary` | Hash of all actions + counts |
| `actions_between(from, to)` | Actions in a time window |
| `activity_log(limit)` | Recent events as array of hashes |

## License

MIT — © Syed M. Ghani
