# Changelog

## [0.1.0] - 2024-05-31

### Added
- `Persona::Trackable` concern with DSL (`persona do track :action end`)
- `track!` instance method with optional metadata
- Full query API: `action_count`, `most_frequent_action`, `least_frequent_action`,
  `last_action`, `last_active_at`, `inactive_since?`, `ever_did?`,
  `persona_summary`, `actions_between`, `activity_log`
- `Persona::Configuration` with `inactivity_threshold_days` and `max_events_per_record`
- `UntrackedActionError` for safety when tracking undeclared actions
- Database migration with polymorphic `persona_events` table
- Railtie for automatic migration path injection
