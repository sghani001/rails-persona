require "persona/version"
require "persona/railtie" if defined?(Rails)
require "persona/configuration"
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
