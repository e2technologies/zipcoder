require "zipcoder/version"
require "zipcoder/cacher/base"
require "ext/string"
require "ext/integer"
require "yaml"

module Zipcoder

  @@cacher = nil
  def self.cacher
    if @@cacher == nil
      self.load_cache
    end
    @@cacher
  end

  # Loads the data into memory
  def self.load_cache(cacher=nil)
    @@cacher = cacher || Cacher::Base.new
    self.cacher.load
  end

  # Looks up zip code information
  def self.zip_info(zip=nil, **kwargs)

    # If zip is not nil, then we are returning a single value
    if zip != nil
      # Get the info
      info = self.cacher.read_zip_cache(zip.to_zip)

      # Filter to the included keys
      self._filter_hash_args info, kwargs[:keys]
    else
      # If zip is nil, then we are returning an array of values
      city_filter = kwargs[:city] != nil ? kwargs[:city].upcase : nil
      state_filter = kwargs[:state] != nil ? kwargs[:state].upcase : nil

      # Iterate through and only add the ones that match the filters
      infos = []
      self.cacher.iterate_zips do |info|
        if (city_filter == nil or info[:city] == city_filter) and
            (state_filter == nil or info[:state] == state_filter)
          infos << self._filter_hash_args(info, kwargs[:keys])
        end
      end

      infos
    end
  end

  # Looks up city information
  def self.city_info(city_state, **kwargs)
    # Get the city from the cache
    cache_key = self._cache_key(city_state)
    cached_value = self.cacher.read_city_cache(cache_key)

    # Return it
    self._filter_hash_args cached_value, kwargs[:keys]
  end

  # Returns the cities in a state
  def self.cities(state, **kwargs)
    state = state.strip.upcase

    # Filter the returned cities
    infos = []
    self.cacher.read_state_cache(state).each { |city|
      infos << self.city_info("#{city}, #{state}", **kwargs)
    }

    infos
  end

  # Filters arguments in return hash
  def self._filter_hash_args(hash, keys)
    return nil if hash == nil

    if keys != nil
      new_hash = {}
      keys.each { |k| new_hash[k] = hash[k] }
      hash = new_hash
    end
    hash
  end

  # Returns a cache key
  def self._cache_key(city_state)
    unless city_state.include? ','
      raise Exception, "city/state must include ','"
    end

    components = city_state.split(',')
    city = components[0].strip.upcase
    state = components[1].strip.upcase

    "#{city},#{state}"
  end


end
