require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'net/http'
require 'csv'
require 'yaml'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :zipcoder do

  namespace :update do

    desc "Pulls the latest data from the default location"
    task :default do

      def download(url)
        puts "Downloading data from '#{url}'"

        # Download the file
        uri = URI(url)
        doc = Net::HTTP.get(uri)

        # Write the file to the file system
        doc.to_s
      end

      def capitalize_all(string)
        string.split(' ').map {|w| w.capitalize }.join(' ')
      end

      # Fetch the latest county file
      county_csv_text = download "https://raw.githubusercontent.com/grammakov/USA-cities-and-states/master/us_cities_states_counties.csv"

      # Open the county files
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

      # Fetch the latest zip code file
      zip_csv_text = download "http://federalgovernmentzipcodes.us/free-zipcode-database.csv"

      # Import the CSV file and build the data structure
      zip_lookup_data = {}
      zip_csv = CSV.parse(zip_csv_text, :headers => true)
      zip_csv.each do |row|
        next if row["ZipCodeType"] != "STANDARD" or not (["PRIMARY", "ACCEPTABLE"].include? row["LocationType"])

        zip_code = row["Zipcode"]
        primary = row["LocationType"] == "PRIMARY"
        city = capitalize_all(row["City"])
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
      zip_data = "lib/data/data.yml"
      puts "Writing data to '#{zip_data}'"
      File.open(zip_data, 'w') {|file| file.write zip_lookup_data.to_yaml }
    end

    desc "Converts data from unitedstateszipcodes.org to the format expected by this library"
    task :unitedstateszipcodes, [:file, :output] do |task, args|
      filename = args[:file]
      puts "Reading unitedstateszipcodes.org data from '#{filename}'"

      # Iterate through the rows and generate the data
      zip_lookup_data = {}
      CSV.parse(File.open(filename, 'r'), :headers => true).each do |row|
        next if row["type"] != "STANDARD" or row["decommissioned"] != "0"

        zip_code = row["zip"]
        primary_city = row["primary_city"]
        state = row["state"]
        county = (row["county"] || "").sub(" County", "")
        lat = row["approximate_latitude"].to_f
        long = row["approximate_longitude"].to_f

        # Write the zip_lookup_data
        areas = zip_lookup_data[zip_code] || []

        # Iterate through the cities
        acceptable_cities = (row["acceptable_cities"] || "").split(", ")
        acceptable_cities << primary_city
        acceptable_cities.each do |city|
          areas << {
              zip: zip_code,
              city: city,
              county: county,
              state: state,
              lat: lat,
              long: long,
              primary: city == primary_city,
          }
        end

        zip_lookup_data[zip_code] = areas
      end

      # Write the data to the yaml file
      output = args[:output]
      puts "Writing data to '#{output}'"
      File.open(output, 'w') {|file| file.write zip_lookup_data.to_yaml }
    end
  end

end
