require "rails"

module Persona
  class Railtie < Rails::Railtie
    initializer "persona.append_migrations" do |app|
      unless app.root.to_s == File.expand_path("../..", __dir__)
        migrations_path = File.expand_path("../../db/migrate", __dir__)
        app.config.paths["db/migrate"] << migrations_path
      end
    end

    rake_tasks do
      load File.expand_path("../../tasks/persona_tasks.rake", __dir__)
    end
  end
end