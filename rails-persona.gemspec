require_relative "lib/persona/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-persona"
  spec.version       = Persona::VERSION
  spec.authors       = ["Syed M. Ghani"]
  spec.email         = ["syedghani001@gmail.com"]

  spec.summary       = "Attach behavioral analytics to any Rails model — no external tools needed."
  spec.description   = <<~DESC
    rails-persona lets you track, query, and understand how users interact with
    your app directly from your Rails models. Define trackable actions with a
    clean DSL, then query frequency, recency, inactivity, and full activity logs
    — all stored in your own database.
  DESC

  spec.homepage      = "https://github.com/sghani001/rails-persona"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["lib/**/*", "app/**/*", "db/**/*", "tasks/**/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0"

  spec.add_development_dependency "rspec-rails",   "~> 6.0"
  spec.add_development_dependency "factory_bot",   "~> 6.0"
  spec.add_development_dependency "sqlite3",       "~> 1.4"
  spec.add_development_dependency "rubocop-rails", "~> 2.0"
end
