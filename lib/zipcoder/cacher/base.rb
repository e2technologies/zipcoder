require_relative '../ext/array'

=begin

The ZipCoder::Cacher::Base class generates different data structures and then stores
them for later access based on whichever cacher is selected.  For example, they could
be stored in memory, Redis, etc.

The generated data structures are as follows

## zipcoder:zip:ZIP

Information for each zip code

 - zip: zip code (e.g. "55340")
 - city: city name (e.g. "Hamel")
 - county: County(s) for the zip code (e.g. ["Travis"])
 - state: state (e.g. "MN")
 - lat: latitude for the city (e.g. "45.07")
 - long: longitude for the city (e.g. "-93.58")

## zipcoder:city:CITY,STATE

Information for each city

 - city: city name (e.g. "Anderson")
 - county: city county(s) (e.g. ["Travis"])
 - state: city state (e.g. "IN")
 - zip: list of zip codes for the city (e.g. "46011-46013,46016-46017")
 - lat: latitude for the city (e.g. "40.09")
 - long: longitude for the city (e.g. "-85.68")

## zipcoder:county:COUNTY,STATE

Information for each county

 - county: county name
 - cities: cities in the county
 - state: county state
 - zip: list of zip codes for the county (e.g. "46011-46013,46016-46017")
 - lat: latitude for the county (e.g. "40.09")
 - long: longitude for the county (e.g. "-85.68")

## zipcoder:state:cities:STATE

List of cities in the state

## zipcoder:state:counties:STATE

List of counties in the state

## zipcoder:states

List of the states in the US

=end

module Zipcoder
  module Cacher
    class Base
      attr_accessor :loaded

      KEY_BASE = "zipcoder"
      KEY_ZIP = "#{KEY_BASE}:zip"
      KEY_CITY = "#{KEY_BASE}:city"
      KEY_COUNTY = "#{KEY_BASE}:county"
      KEY_STATE_CITIES = "#{KEY_BASE}:state:cities"
      KEY_STATE_COUNTIES = "#{KEY_BASE}:state:counties"
      KEY_STATES = "#{KEY_BASE}:states"

      #region Override These
      def _init_cache(**kwargs)
        # Override ME
      end

      def _empty_cache
        # Override ME
      end

      def _write_cache(key, value)
        # Override ME
      end

      def _read_cache(key)
        # Override ME
      end

      def _iterate_keys(**kwargs, &block)
        # Override ME
      end

      #endregion

      def initialize(**kwargs)
        self._init_cache **kwargs
        self.loaded = false
      end

      def load(data: nil)
        return if self.loaded

        start_time = Time.now

        # Load zip cache from file
        if data != nil
          zip_data = File.open(data)
        else
          this_dir = File.expand_path(File.dirname(__FILE__))
          zip_data = File.join(this_dir, '..', '..', 'data', 'data.yml' )
        end
        zip_codes = YAML.load(File.open(zip_data))

        # Initialize
        _empty_cache
        city_states = {}
        state_cities_lookup = {}
        state_counties_lookup = {}

        # Add the zip codes to the cache
        zip_codes.each do |zip, cities|
          cities.each do |info|
            city = info[:city]
            state = info[:state]

            # For the zip codes, only store the primary
            if info[:primary]
              _write_cache _zip_cache(zip), info
            end

            # Create the city lookups
            city_state = "#{city.upcase},#{state.upcase}"
            infos = city_states[city_state] || []
            infos << info
            city_states[city_state] = infos
          end
        end

        # Normalize each city and populate the state cache
        city_states.each do |city_state, infos|
          city = infos[0][:city]
          state = infos[0][:state]

          # Populate the City Cache
          normalized = _normalize_city(infos)
          _write_cache _city_cache(city_state), normalized

          # Populate the State City Cache
          cities = state_cities_lookup[state] || []
          cities << city
          state_cities_lookup[state] = cities

          # Populate the State Counties Cache
          counties = state_counties_lookup[state] || []
          counties += normalized[:county].split(",")
          state_counties_lookup[state] = counties
        end

        # Set the cities cache
        state_cities_lookup.each do |state, cities|
          _write_cache _state_cities_cache(state), cities.sort
        end

        # Set the cities cache
        state_counties_lookup.each do |state, counties|
          _write_cache _state_counties_cache(state), counties.sort.uniq
        end

        # Set the states cache
        self._write_cache _states, state_cities_lookup.keys.sort

        # Print the alpsed time
        puts "ZipCoder initialization time: #{Time.now-start_time}"

        self.loaded = true
      end

      def read_zip_cache(zip)
        _read_cache _zip_cache(zip)
      end

      def read_city_cache(city_state)
        _read_cache _city_cache(city_state)
      end

      def read_state_cities_cache(state)
        _read_cache _state_cities_cache(state)
      end

      def read_state_counties_cache(state)
        _read_cache _state_counties_cache(state)
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
        "#{KEY_ZIP}:#{zip}"
      end

      def _city_cache(city_state)
        "#{KEY_CITY}:#{city_state}"
      end

      def _state_cities_cache(state)
        "#{KEY_STATE_CITIES}:#{state}"
      end

      def _state_counties_cache(state)
        "#{KEY_STATE_COUNTIES}:#{state}"
      end

      def _states
        KEY_STATES
      end

      # Normalizes the values
      def _normalize_city(infos)
        # Values
        zips = []
        counties = []
        lat_min = 200
        lat_max = -200
        long_min = 200
        long_max = -200

        # Iterate through the info and get min/max of zip/lat/long
        infos.each do |info|
          if info[:primary]
            lat_min = info[:lat] if info[:lat] < lat_min
            lat_max = info[:lat] if info[:lat] > lat_max
            long_min = info[:long] if info[:long] < long_min
            long_max = info[:long] if info[:long] > long_max
          end
          zips << info[:zip]
          counties += info[:county].split(",")
        end

        # Create the normalized value
        if infos.count == 0
          normalized = nil
        elsif infos.count == 1
          normalized = {
              city: infos[0][:city],
              county: infos[0][:county],
              state: infos[0][:state],
              zip: infos[0][:zip],
              lat: infos[0][:lat],
              long: infos[0][:long],
          }
        else
          normalized = {
              city: infos[0][:city],
              county: counties.uniq.join(","),
              state: infos[0][:state],
              zip: zips.combine_zips,
              lat: ((lat_min+lat_max)/2).round(4),
              long: ((long_min+long_max)/2).round(4)
          }
        end

        normalized
      end

    end
  end
end
