# rails-persona 🎭

> Model-level behavioral analytics for Rails — own your data, zero external services.

[![Gem Version](https://badge.fury.io/rb/rails-persona.svg)](https://badge.fury.io/rb/rails-persona)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**rails-persona** is a lightweight Rails gem that adds first-class behavioral tracking directly to your ActiveRecord models. Unlike [ahoy](https://github.com/ankane/ahoy), which is focused on HTTP visit and page-view tracking, rails-persona is built for **model-level action tracking** — understanding *what your users actually do* in your app, not just what pages they visit.

---

## Why rails-persona over ahoy?

| | ahoy | rails-persona |
|---|---|---|
| Focus | HTTP visits + page views | Model actions + user behavior |
| Setup | Controllers + JS snippet | Pure Ruby — one concern |
| Async | Manual Sidekiq setup | Built-in (`async: true`) |
| Bulk tracking | ❌ | ✅ `bulk_track!` with `insert_all!` |
| Class-level analytics | ❌ | ✅ Leaderboards, class summaries |
| Open tracking mode | ❌ | ✅ No whitelist required |
| Streak / pattern queries | ❌ | ✅ `daily_activity`, `peak_hour` |
| Cookies / sessions | Required | Never needed |
| Works on non-User models | Awkward | First-class |

---

## Installation

```ruby
gem "rails-persona"
```

```bash
bundle install
rails db:migrate
```

---

## Quick start

### 1. Include in any model

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

### 2. Track actions in your app

```ruby
# In a controller, service, or job:
current_user.track!(:login)
current_user.track!(:upgrade_plan, metadata: { plan: "pro", amount: 49 })
```

### 3. Query behavior

```ruby
user.action_count(:login)          # => 42
user.most_frequent_action          # => :login
user.least_frequent_action         # => :upgrade_plan
user.top_actions(3)                # => { login: 42, view_dashboard: 18, export_report: 5 }
user.last_action                   # => :export_report
user.last_active_at                # => 2024-05-30 14:22 UTC
user.first_action                  # => :login
user.first_active_at               # => 2023-01-10 08:00 UTC
user.inactive_since?               # => false  (default threshold: 30 days)
user.inactive_since?(7)            # => false  (custom: 7 days)
user.days_since_last_activity      # => 2
user.ever_did?(:export_report)     # => true
user.never_did?(:upgrade_plan)     # => false
user.action_share(:login)          # => 64.6  (% of all events)
user.total_events                  # => 65

user.persona_summary
# => { login: 42, view_dashboard: 18, export_report: 5, upgrade_plan: 1 }

user.actions_between(1.week.ago, Time.current)
# => { login: 7, view_dashboard: 3 }

user.activity_log(5)
# => [
#      { action: :export_report, at: 2024-05-30 14:22:00, metadata: {} },
#      { action: :login,         at: 2024-05-30 09:01:00, metadata: {} },
#    ]

user.daily_activity(30)
# => { "2024-05-28" => 4, "2024-05-29" => 7, "2024-05-30" => 2 }

user.peak_hour
# => 14  (2pm is when this user is most active)
```

---

## Class-level analytics

```ruby
# Top 10 most active users
User.persona_leaderboard(limit: 10)
# => [
#      { record: #<User id=4>, total_events: 128 },
#      { record: #<User id=9>, total_events: 97 },
#    ]

# App-wide breakdown of all user actions
User.persona_class_summary
# => { login: 8420, view_dashboard: 5210, export_report: 820 }
```

---

## Bulk tracking (high-performance)

Uses `insert_all!` — no N+1, no per-row callbacks:

```ruby
user.bulk_track!([:login, :view_dashboard, :export_report])
user.bulk_track!([:login, :login, :login])  # track repeated actions
```

---

## Async tracking (Sidekiq)

```ruby
# config/initializers/persona.rb
Persona.configure do |config|
  config.async = true   # fires a Sidekiq job instead of writing inline
end
```

Requires the `sidekiq` gem. Falls back to synchronous if Sidekiq is not available.

---

## Open tracking (no whitelist)

If you want to track arbitrary actions without declaring them:

```ruby
class Post < ApplicationRecord
  include Persona::Trackable

  persona do
    open_tracking!  # any string is valid — no UntrackedActionError raised
  end
end

post.track!("custom_#{SecureRandom.hex(4)}")  # works fine
```

---

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
post.action_count(:viewed)     # => 128
post.most_frequent_action      # => :viewed
Post.persona_class_summary     # => { viewed: 50_420, shared: 890, bookmarked: 210 }
```

---

## Configuration

```ruby
# config/initializers/persona.rb
Persona.configure do |config|
  config.inactivity_threshold_days = 14     # default: 30
  config.max_events_per_record     = 500    # default: nil (unlimited)
  config.async                     = true   # default: false
  config.auto_prune_after_days     = 90     # default: nil (no auto-prune)
end
```

---

## Manual pruning

```ruby
# Delete events older than 60 days for all records
Persona::Pruner.prune_older_than(60)
```

Add to a scheduled job (e.g. `whenever` or Sidekiq-Cron):

```ruby
# lib/tasks/persona.rake
namespace :persona do
  desc "Prune old persona events"
  task prune: :environment do
    Persona::Pruner.prune_older_than(Persona.configuration.auto_prune_after_days || 90)
    puts "Pruned old persona events"
  end
end
```

---

## Comparison with other gems

| Gem | Tracks | rails-persona advantage |
|---|---|---|
| **ahoy** | HTTP visits, JS events | Model actions, no JS needed, async built-in |
| **paper_trail** | Model attribute changes | Behavioral patterns, not diffs |
| **audited** | CRUD audit logs | Who *acted*, not what *changed* |
| **mixpanel-ruby** | Remote SaaS events | Your DB, no 3rd party, no cost |

---

## API reference

| Method | Description |
|--------|-------------|
| `track!(action, metadata: {})` | Record an action (sync or async) |
| `bulk_track!(actions)` | Record multiple actions via `insert_all!` |
| `reset_persona!` | Delete all events for this record |
| `action_count(action)` | Count of a specific action |
| `total_events` | Total event count |
| `most_frequent_action` | Most-performed action |
| `least_frequent_action` | Least-performed action |
| `top_actions(n)` | Top N actions by count |
| `last_action` | Most recent action symbol |
| `last_active_at` | Timestamp of last action |
| `first_action` | Earliest action symbol |
| `first_active_at` | Timestamp of first action |
| `inactive_since?(days)` | True if no action in N days |
| `days_since_last_activity` | Integer days since last event |
| `ever_did?(action)` | True if action occurred |
| `never_did?(action)` | True if action never occurred |
| `action_share(action)` | % of all events this action represents |
| `persona_summary` | Full action → count hash |
| `actions_between(from, to)` | Actions in a time window |
| `activity_log(limit)` | Recent events as array of hashes |
| `daily_activity(days)` | Events grouped by day |
| `peak_hour` | Hour (0-23) with most activity |
| `User.persona_leaderboard(limit:)` | Top N most active records |
| `User.persona_class_summary` | App-wide action breakdown |

---

## Contributing

Bug reports and pull requests welcome at https://github.com/sghani001/rails-persona.

## License

MIT — © Syed M. Ghani
