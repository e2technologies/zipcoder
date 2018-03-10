$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "zipcoder"

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
