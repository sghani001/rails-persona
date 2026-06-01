# Changelog

## [0.2.7] - 2026-06-01
### Fixed
- Use `before: :set_autoload_paths` initializer ordering to avoid FrozenError when adding to autoload_paths (fixes #14)

## [0.2.6] - 2026-06-01
### Fixed
- Use `config.before_initialize` instead of initializer for autoload_paths to avoid FrozenError in Rails 7 (fixes #14)

## [0.2.5] - 2026-06-01
### Fixed
- Add gem app/ directory to Rails autoload paths so PersonaEvent is accessible (fixes #12)

## [0.2.4] - 2026-06-01
### Fixed
- Replace `t.jsonb` with `t.text` in migration for SQLite compatibility (fixes #10)

## [0.2.3] - 2026-06-01
### Fixed
- Add `tasks/**/*` to gemspec files list so `persona_tasks.rake` is packaged with the gem (fixes #8)

## [0.2.2] - 2026-06-01
### Fixed
- Correct `File.expand_path` depth in Railtie for both rake task and migrations path (fixes #5)

## [0.2.1] - 2026-06-01
### Fixed
- Replace `config.paths` in Railtie with `File.expand_path` to fix `NoMethodError` on boot (fixes #1)
- Add missing `tasks/persona_tasks.rake` that was referenced but never created (fixes #2)
- Fix rake task load path using `__dir__` instead of relative path

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
