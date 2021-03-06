require "zipcoder/version"
require "zipcoder/cacher/memory"
require "zipcoder/ext/string"
require "zipcoder/ext/integer"
require "zipcoder/ext/array"
require "yaml"

module Zipcoder

  class ZipcoderError < Exception
  end

  class Config
    attr_accessor :cacher
    attr_accessor :data
  end

  CONFIG = Config.new

  def self.config(&block)
    block.call(CONFIG)
  end

  @@cacher = nil
  def self.cacher
    if @@cacher == nil
      self.load_cache
    end
    @@cacher
  end

  # Loads the data into memory
  def self.load_cache
    @@cacher = CONFIG.cacher || Cacher::Memory.new
    self.cacher.load data: CONFIG.data
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
        if (city_filter == nil or info[:city].upcase == city_filter) and
            (state_filter == nil or info[:state].upcase == state_filter)
          infos << self._filter_hash_args(info, kwargs[:keys])
        end
      end

      infos
    end
  end

  # Returns the cities that contain the zip codes
  def self.zip_cities(zip_string, **kwargs)
    max = kwargs[:max]

    cities = {}
    self._parse_zip_string(zip_string).each do |zip|
      info = zip.zip_info
      key = nil
      if info != nil
        key = "#{info[:city]}, #{info[:state]}"
      end

      if key == nil
        next
      end

      zip_codes = cities[key] || []
      zip_codes << zip
      cities[key] = zip_codes

      if max != nil and cities.keys.count >= max
        break
      end
    end


    if kwargs[:grouped]
      zips = {}
      cities.each do |city, zip_codes|
        key = zip_codes.combine_zips
        if kwargs[:names_only]
          zips[key] = city
        else
          zips[key] = city.city_info(keys: kwargs[:keys])
        end
      end
    else
      sorted_cities = cities.keys.uniq.sort
      if kwargs[:names_only]
        zips = sorted_cities
      else
        zips = []
        sorted_cities.each do |city|
          zip_codes = cities[city]
          city_detail = city.city_info(keys: kwargs[:keys])
          if kwargs[:keys] == nil or kwargs[:keys].include? :specified_zip
            city_detail[:specified_zip] = zip_codes.combine_zips
          end
          zips << city_detail
        end
      end
    end
    zips
  end

  # Looks up city information
  def self.city_info(city_state, **kwargs)
    # Get the city from the cache
    cache_key = self._cache_key(city_state)
    cached_value = self.cacher.read_city_cache(cache_key)

    # Return it
    if cached_value == nil
      nil
    elsif kwargs[:zips_only]
      cached_value[:zip].breakout_zips
    else
      # Clone the object
      cached_value = cached_value.clone

      # If filter specified, create "specified_zip"
      if kwargs[:filter]
        normal_zips = cached_value[:zip].breakout_zips
        filter_zips = kwargs[:filter].breakout_zips
        cached_value[:specified_zip] = (normal_zips & filter_zips).combine_zips
      end

      self._filter_hash_args cached_value, kwargs[:keys]
    end
  end

  # Returns the cities in a state
  def self.state_cities(state, **kwargs)
    state = state.strip.upcase

    names_only = kwargs[:names_only]
    keys = kwargs[:keys]

    # Filter the returned cities
    cities = self.cacher.read_state_cities_cache(state)
    if names_only
      cities
    else
      infos = []
      self.cacher.read_state_cities_cache(state).each { |city|
        infos << self.city_info("#{city}, #{state}", keys: keys)
      }

      infos
    end
  end

  # Returns the counties in a state
  def self.state_counties(state, **kwargs)
    state = state.strip.upcase

    # Return the counties
    self.cacher.read_state_counties_cache(state)
  end

  # Returns the states
  def self.states
    self.cacher.read_states
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
      raise ZipcoderError, "city/state must include ','"
    end

    components = city_state.split(',')
    city = components[0].strip.upcase
    state = components[1].strip.upcase

    "#{city},#{state}"
  end

  # Parses a zip code string and returns all of the zip codes as
  # an array
  def self._parse_zip_string(zip_string)
    zips = []

    zip_string.split(",").each do |zip_component|
      if zip_component.include? "-"
        z = zip_component.split("-")
        (z[0].strip.to_i..z[1].strip.to_i).each do |zip|
          zips << self._check_zip(zip.to_zip)
        end
      else
        zips << self._check_zip(zip_component.strip)
      end
    end

    zips.sort.uniq
  end

  # Check the zip codes
  def self._check_zip(zip)
    unless zip.is_zip?
      raise ZipcoderError, "zip code #{zip} is not 5 characters"
    end
    zip
  end

end
