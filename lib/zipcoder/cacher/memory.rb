require_relative 'base'

module Zipcoder
  module Cacher
    class Memory < Base
      def _init_cache(**kwargs)
        @cache = {}
      end

      def _empty_cache
        @cache.clear
      end

      def _write_cache(key, value)
        @cache[key] = value
      end

      def _read_cache(key)
        @cache[key]
      end

      def _iterate_keys(**kwargs, &block)
        return if block == nil

        start_with = kwargs[:start_with]

        @cache.keys.each do |key|
          if start_with == nil or key.start_with?(start_with)
            block.call(key)
          end
        end
      end
    end
  end
end