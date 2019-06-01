require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  logger = ActiveSupport::Logger.new(STDOUT)
  config.active_record.logger = logger if ENV["VERBOSE"]
  config.action_mailer.logger = logger if ENV["VERBOSE"]
end
