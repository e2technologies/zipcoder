require_relative 'base'
require 'redis'
require 'json'

module Zipcoder
  module Cacher
    class Redis < Base

      # This is here for stubbing
      def self._create_redis_client(**kwargs)
        ::Redis.new(**kwargs)
      end

      def _init_cache(**kwargs)
        @redis = self.class._create_redis_client(**kwargs)
      end

      def _empty_cache
        keys = @redis.keys("#{KEY_BASE}*")
        @redis.del(*keys) unless keys.empty?
      end

      def _write_cache(key, value)
        return if value == nil
        @redis.set(key, value.to_json)
      end

      def _read_cache(key)
        data = @redis.get(key)
        data == nil ? nil : JSON.parse(data, :symbolize_names => true)
      end

      def _iterate_keys(**kwargs, &block)
        return if block == nil

        start_with = kwargs[:start_with] || KEY_BASE

        # Redis "keys" command will pre-filter the keys for us so no
        # need for "if" statement
        @redis.keys("#{start_with}*").each do |key|
          block.call(key)
        end
      end
    end
  end
end
