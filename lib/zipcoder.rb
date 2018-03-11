require "zipcoder/version"
require "ext/string"
require "ext/integer"
require "yaml"

module Zipcoder

  # Data Structure Load and Lookup
  @@zip_data = nil
  def self.zip_data
    self.load_data if @@zip_data == nil
    @@zip_data
  end

  @@city_cache = {}
  def self.city_cache
    @@city_cache
  end

  # Loads the data into memory
  def self.load_data
    this_dir = File.expand_path(File.dirname(__FILE__))

    zip_data = File.join(this_dir, 'data', 'zip_data.yml')
    @@zip_data = YAML.load(File.open(zip_data))
  end

  # Looks up zip code information
  def self.zip_info(zip=nil, **kwargs, &block)

    # If zip is not nil, then we are returning a single value
    if zip != nil
      # Get the info
      info = self.zip_data[zip.to_zip]

      # Inform callback that we have a match
      block.call(info) if block != nil

      # Filter to the included keys
      self._filter_hash_args info, kwargs[:keys]
    else
      # If zip is nil, then we are returning an array of values

      infos = []
      city_filter = kwargs[:city] != nil ? kwargs[:city].upcase : nil
      state_filter = kwargs[:state] != nil ? kwargs[:state].upcase : nil

      # Iterate through and only add the ones that match the filters
      self.zip_data.values.each { |info|
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
  def self.city_info(city_state, **kwargs)
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

    # Normalize response
    zip_min = 100000
    zip_max = 0
    lat_min = 200
    lat_max = 0
    long_min = 200
    long_max = 0

    # Get the infos associated with this city/state.  While
    # getting those, store the min/max so we can create a
    # normalized version of this object
    infos = self.zip_info(city: city, state: state) do |info|
      zip = info[:zip].to_i
      zip_min = zip if zip < zip_min
      zip_max = zip if zip > zip_max
      lat_min = info[:lat] if info[:lat] < lat_min
      lat_max = info[:lat] if info[:lat] > lat_max
      long_min = info[:long] if info[:long] < long_min
      long_max = info[:long] if info[:long] > long_max
    end

    if infos.count == 0
      # If there were no matches, return 0
      info = nil
    elsif infos.count == 1
      # If there was 1 match, return it
      info = infos[0]
    else
      # Create normalized object
      info = {
          zip: "#{zip_min.to_zip}-#{zip_max.to_zip}",
          city: city,
          state: state,
          lat: (lat_min+lat_max)/2,
          long: (long_min+long_max)/2
      }
    end

    # Cache the value
    self.city_cache[cache_key] = info if info != nil

    # Filter the args
    self._filter_hash_args info, kwargs[:keys]
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

end
