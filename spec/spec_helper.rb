require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "zipcoder"

class RedisStub

  def initialize
    @cache = {}
  end

  def set(key, value)
    @cache[key] = value
  end

  def get(key)
    @cache[key]
  end

  def keys(filter=nil)
    if filter == nil
      @cache.keys
    else
      wildcard_start = false
      wildcard_end = false

      if filter.start_with? '*'
        wildcard_start = true
        filter = filter[1..-1]
      end

      if filter.end_with? '*'
        wildcard_end = true
        filter = filter[0..-2]
      end

      keys = []
      @cache.keys.each do |key|
        if wildcard_start and wildcard_end
          keys << key if key.include? filter
        elsif wildcard_start
          keys << key if key.end_with? filter
        elsif wildcard_end
          keys << key if key.start_with? filter
        elsif filter == key
          keys << key
        end
      end

      keys
    end
  end

  def del(*keys)
    keys.each do |key|
      @cache.delete(key)
    end
  end

end

