require "rails"

module Persona
  class Railtie < Rails::Railtie
    initializer "persona.load_app_instance_data" do |app|
      Persona::Railtie.instance_variable_set(:@app, app)
    end

    initializer "persona.append_migrations" do |app|
      unless app.root.to_s == File.expand_path("../..", __dir__)
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end

    rake_tasks do
      load "tasks/persona_tasks.rake"
    end
  end
end
