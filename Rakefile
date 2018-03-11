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
      next if row["ZipCodeType"] != "STANDARD"

      zip_code = row["Zipcode"]
      city = row["City"]
      state = row["State"]
      lat = row["Lat"].to_f
      long = row["Long"].to_f

      # Write the zip_lookup_data
      zip_lookup_data[zip_code] = { zip: zip_code, city: city, state: state, lat: lat, long: long }
    end

    # Write the data to the yaml file
    zip_data = "lib/data/zip_data.yml"
    puts "Writing data to '#{zip_data}'"
    File.open(zip_data, 'w') {|file| file.write zip_lookup_data.to_yaml }
  end
end
