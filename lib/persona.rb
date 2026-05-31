require "persona/version"
require "persona/configuration"
require "persona/railtie" if defined?(Rails)
require "persona/pruner"
require "persona/async_tracker"
require "persona/summary"
require "persona/query"
require "persona/trackable"

module Persona
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
