require "zipcoder/version"
require "ext/string"
require "ext/integer"
require "yaml"

module Zipcoder

  # Data Structure Load and Lookup
  @@zip_cache = nil
  def self.zip_cache
    if @@zip_cache == nil
      self.load_cache
    end
    @@zip_cache
  end

  @@city_cache = {}
  def self.city_cache
    @@city_cache
  end

  @@state_cache = {}
  def self.state_cache
    @@state_cache
  end

  # Loads the data into memory
  def self.load_cache
    this_dir = File.expand_path(File.dirname(__FILE__))

    # Load zip cache from file
    zip_data = File.join(this_dir, 'data', 'zip_data.yml')
    @@zip_cache = YAML.load(File.open(zip_data))

    # Iterate through zip codes to populate city and state data
    city_states = {}
    self.zip_cache.values.each do |info|
      city = info[:city]
      state = info[:state]

      # Create the city lookups
      city_state = "#{city},#{state}"
      infos = city_states[city_state] || []
      infos << info
      city_states[city_state] = infos
    end

    # Normalize each city and populate the state cache
    city_states.each do |city_state, infos|
      state = infos[0][:state]

      # Populate the City Cache
      normalized = self.city_info(city_state, infos)
      self.city_cache[city_state] = normalized

      # Populate the State Cache
      cities = self.state_cache[state] || []
      cities << normalized
      self.state_cache[state] = cities
    end

    # Sort the city arrays
    self.state_cache.keys.each do |state|
      infos = self.state_cache[state]
      new_infos = infos.sort_by { |hsh| hsh[:city] }
      self.state_cache[state] = new_infos
    end
  end

  # Looks up zip code information
  def self.zip_info(zip=nil, **kwargs, &block)

    # If zip is not nil, then we are returning a single value
    if zip != nil
      # Get the info
      info = self.zip_cache[zip.to_zip]

      # Inform callback that we have a match
      block.call(info) if block != nil

      # Filter to the included keys
      self._filter_hash_args info, kwargs[:keys]
    else
      # If zip is nil, then we are returning an array of values

      city_filter = kwargs[:city] != nil ? kwargs[:city].upcase : nil
      state_filter = kwargs[:state] != nil ? kwargs[:state].upcase : nil

      # Iterate through and only add the ones that match the filters
      infos = []
      self.zip_cache.values.each { |info|
        if (city_filter == nil or info[:city] == city_filter) and
            (state_filter == nil or info[:state] == state_filter)
          infos << self._filter_hash_args(info, kwargs[:keys])

          # Inform callback that we have a match
          block.call(info) if block != nil
        end
      }

      infos
    end
  end

  # Looks up city information
  def self.city_info(city_state, infos=nil, **kwargs)
    unless city_state.include? ','
      raise Exception, "city/state must include ','"
    end

    # Check the cache
    cache_key = city_state.delete(' ').upcase
    cached_value = self.city_cache[cache_key]
    if cached_value != nil
      return self._filter_hash_args cached_value, kwargs[:keys]
    end

    # Cleanup city/state
    components = city_state.split(",")
    city = components[0].strip.upcase
    state = components[1].strip.upcase

    # Get the infos
    infos ||= self.zip_info(city: city, state: state)
    info = self._normalize_city(infos)
    if info != nil
      info[:city] = city
      info[:state] = state
    end

    # Cache the value
    self.city_cache[cache_key] = info if info != nil

    # Filter the args
    self._filter_hash_args info, kwargs[:keys]
  end

  # Returns the cities in a state
  def self.cities(state, **kwargs)
    state = state.strip.upcase

    # Filter the returned cities
    infos = []
    self.state_cache[state].each { |info|
      infos << self._filter_hash_args(info, kwargs[:keys])
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

  # Normalizes the values
  def self._normalize_city(infos)
    # Values
    zip_min = 100000
    zip_max = 0
    lat_min = 200
    lat_max = 0
    long_min = 200
    long_max = 0

    # Iterate through the info and get min/max of zip/lat/long
    infos.each do |info|
      zip = info[:zip].to_i
      zip_min = zip if zip < zip_min
      zip_max = zip if zip > zip_max
      lat_min = info[:lat] if info[:lat] < lat_min
      lat_max = info[:lat] if info[:lat] > lat_max
      long_min = info[:long] if info[:long] < long_min
      long_max = info[:long] if info[:long] > long_max
    end

    # Create the normalized value
    if infos.count == 0
      normalized = nil
    elsif infos.count == 1
      normalized = {
          zip: infos[0][:zip],
          lat: infos[0][:lat],
          long: infos[0][:long],
      }
    else
      normalized = {
          zip: "#{zip_min.to_zip}-#{zip_max.to_zip}",
          lat: (lat_min+lat_max)/2,
          long: (long_min+long_max)/2
      }
    end

    normalized
  end

end
