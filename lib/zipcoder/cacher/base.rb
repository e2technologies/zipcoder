module Cacher
  # The cacher base class places all of the objects in memory.  The
  # abstraction will later allow us to override for MemCacher and
  # Redis implementations
  class Base

    #region Override These
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

    #endregion

    def initialize(**kwargs)
      self._init_cache **kwargs
    end

    def load
      this_dir = File.expand_path(File.dirname(__FILE__))

      # Load zip cache from file
      zip_data = File.join(this_dir, '..', '..', 'data', 'zip_data.yml')
      zip_codes = YAML.load(File.open(zip_data))

      # Initialize
      _empty_cache
      city_states = {}
      state_lookup = {}

      # Add the zip codes to the cache
      zip_codes.each do |zip, info|

        # Iterate through the zip codes and add them to the zip cache
        _write_cache _zip_cache(zip), info

        # Populate City Cache
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
        city = infos[0][:city]
        state = infos[0][:state]

        # Populate the City Cache
        normalized = _normalize_city(infos)
        _write_cache _city_cache(city_state), normalized

        # Populate the State Cache
        cities = state_lookup[state] || []
        cities << city
        state_lookup[state] = cities
      end

      # Set the cities cache
      state_lookup.each do |state, cities|
        _write_cache _state_cache(state), cities.sort
      end

      # Set the states cache
      self._write_cache _states, state_lookup.keys.sort
    end

    def read_zip_cache(zip)
      _read_cache _zip_cache(zip)
    end

    def read_city_cache(city_state)
      _read_cache _city_cache(city_state)
    end

    def read_state_cache(state)
      _read_cache _state_cache(state)
    end

    def read_states
      _read_cache _states
    end

    def iterate_zips(&block)
      return if block == nil
      _iterate_keys(start_with: "zipcoder:zip") do |key|
        info = _read_cache(key)
        block.call(info) if block != nil
      end
    end

    def iterate_cities(&block)
      return if block == nil
      _iterate_keys(start_with: "zipcoder:city") do |key|
        info = _read_cache(key)
        block.call(info) if block != nil
      end
    end

    private

    def _zip_cache(zip)
      "zipcoder:zip:#{zip}"
    end

    def _city_cache(city_state)
      "zipcoder:city:#{city_state}"
    end

    def _state_cache(state)
      "zipcoder:state:#{state}"
    end

    def _states
      "zipcoder:states"
    end

    # Normalizes the values
    def _normalize_city(infos)
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
            city: infos[0][:city],
            state: infos[0][:state],
            zip: infos[0][:zip],
            lat: infos[0][:lat],
            long: infos[0][:long],
        }
      else
        normalized = {
            city: infos[0][:city],
            state: infos[0][:state],
            zip: "#{zip_min.to_zip}-#{zip_max.to_zip}",
            lat: (lat_min+lat_max)/2,
            long: (long_min+long_max)/2
        }
      end

      normalized
    end

  end
end