require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'net/http'
require 'csv'
require 'yaml'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :zipcoder do

  desc "Pulls the latest zip code data base file"
  task :update do

    # Fetch the latest database file
    uri = URI("http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv")
    puts "Downloading newest zip codes from '#{uri.to_s}'"
    doc = Net::HTTP.get(uri)

    # Write the file to the file system
    filename = "lib/data/zipcode.csv"
    puts "Writing to the file '#{filename}'"
    File.open(filename, 'w') { |file| file.write(doc.to_s) }
  end

  desc "Converts the database file into the formats expected for the library"
  task :convert do

    # Open the file
    filename = "lib/data/zipcode.csv"
    puts "Opening the file '#{filename}'"
    csv_text = File.read(filename)

    # Import the CSV file and build the data structure
    zip_lookup_data = {}
    city_lookup_data = {}
    csv = CSV.parse(csv_text, :headers => true)
    puts "Importing data from '#{filename}'"
    csv.each do |row|
      zip_code = row["Zipcode"]
      city = row["City"]
      state = row["State"]
      lat = row["Lat"].to_f
      long = row["Long"].to_f

      # Write the zip_lookup_data
      zip_lookup_data[zip_code] = { zip: zip_code, city: city, state: state, lat: lat, long: long }

      # Write the city_lookup_data
      city_key = "#{city},#{state}"
      city_data = city_lookup_data[city_key] || {}

      zips = city_data[:zips] || []
      zips << zip_code

      lats = city_data[:lats] || []
      lats << lat

      longs = city_data[:longs] || []
      longs << long

      city_lookup_data[city_key] = { zips: zips, city: city, state: state, lats: lats, longs: longs }
    end

    # Write the data to the yaml file
    zip_lookup = "lib/data/zip_lookup.yml"
    puts "Writing data to '#{zip_lookup}'"
    File.open(zip_lookup, 'w') {|file| file.write zip_lookup_data.to_yaml }

    # Write the city lookup data
    city_lookup = "lib/data/city_lookup.yml"
    puts "Writing data to '#{city_lookup}'"
    File.open(city_lookup, 'w') {|file| file.write city_lookup_data.to_yaml }

  end
end
