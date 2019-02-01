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

    def download(url, output)
      puts "Downloading data from '#{url}'"
      puts "   writing to the file '#{output}'"

      # Download the file
      uri = URI(url)
      doc = Net::HTTP.get(uri)

      # Write the file to the file system
      File.open(output, 'w') { |file| file.write(doc.to_s) }
    end

    # Fetch the latest zip code file
    download "http://federalgovernmentzipcodes.us/free-zipcode-database.csv", "lib/data/zipcode.csv"

    # Fetch the latest county file
    download "https://raw.githubusercontent.com/grammakov/USA-cities-and-states/master/us_cities_states_counties.csv", "lib/data/county.csv"
  end

  desc "Converts the database file into the formats expected for the library"
  task :convert do

    def open_file(filename)
      puts "Importing data from '#{filename}'"
      File.read(filename)
    end

    # Open the county files
    county_csv_text = open_file "lib/data/county.csv"
    city_county = {}
    county_csv_text.split("\n").each do |line|
      components = line.split("|")
      next if components.length < 5
      state = components[1]
      county = components[3]
      city = components[4]

      key = "#{city.upcase},#{state}"
      counties = city_county[key] || []
      counties << county.capitalize
      city_county[key] = counties.uniq
    end

    # Open the zip file
    zip_csv_text = open_file "lib/data/zipcode.csv"

    # Import the CSV file and build the data structure
    zip_lookup_data = {}
    zip_csv = CSV.parse(zip_csv_text, :headers => true)
    zip_csv.each do |row|
      next if row["ZipCodeType"] != "STANDARD" or not (["PRIMARY", "ACCEPTABLE"].include? row["LocationType"])

      zip_code = row["Zipcode"]
      primary = row["LocationType"] == "PRIMARY"
      city = row["City"]
      state = row["State"]
      lat = row["Lat"].to_f
      long = row["Long"].to_f

      # Pull the county
      key = "#{city.upcase},#{state}"
      county = (city_county[key] || []).join(",")

      # Write the zip_lookup_data
      areas = zip_lookup_data[zip_code] || []
      areas << { zip: zip_code, city: city, county: county, state: state, lat: lat, long: long, primary: primary }
      zip_lookup_data[zip_code] = areas
    end

    # Write the data to the yaml file
    zip_data = "lib/data/zip_data.yml"
    puts "Writing data to '#{zip_data}'"
    File.open(zip_data, 'w') {|file| file.write zip_lookup_data.to_yaml }
  end
end
