require "zipcoder/version"
require "ext/string"
require "ext/integer"
require "yaml"

module Zipcoder

  # Data Structure Load and Lookup
  @@zip_lookup = nil
  def self.zip_lookup
    self.load_data if @@zip_lookup == nil
    @@zip_lookup
  end

  @@city_lookup = nil
  def self.city_lookup
    self.load_data if @@city_lookup == nil
    @@city_lookup
  end

  # Loads the data into memory
  def self.load_data
    this_dir = File.expand_path(File.dirname(__FILE__))

    zip_lookup = File.join(this_dir, 'data', 'zip_lookup.yml')
    @@zip_lookup = YAML.load(File.open(zip_lookup))

    city_lookup = File.join(this_dir, 'data', 'city_lookup.yml')
    @@city_lookup = YAML.load(File.open(city_lookup))
  end

end
