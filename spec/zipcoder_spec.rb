require "spec_helper"

describe Zipcoder do
  before(:all) do
    Zipcoder.load_cache
  end

  after(:all) {
    Zipcoder.config do |config|
      config.data = nil
      config.cacher = nil
    end
  }

  it "has a version number" do
    expect(Zipcoder::VERSION).not_to be nil
  end

  describe "#states" do
    it "returns the states" do
      states = described_class.states
      expect(states.count).to eq(54)
      expect(states[0]).to eq("AK")
      expect(states[1]).to eq("AL")
    end
  end

  describe "#zip_info" do
    it "returns the info for a particular zip_code" do
      zip_info = described_class.zip_info "78748"
      expect(zip_info[:city]).to eq("Austin")
      expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "returns the info for a particular zip_code" do
      zip_info = described_class.zip_info 78748
      expect(zip_info[:city]).to eq("Austin")
      expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "zero pads the zip code when using an integer" do
      zip_info = described_class.zip_info 705
      expect(zip_info[:city]).to eq("Aibonito")
    end

    describe "keys filter" do
      it "only returns specified keys" do
        zip_info = described_class.zip_info "78748", keys: [:city, :state]
        expect(zip_info[:city]).to eq("Austin")
        expect(zip_info[:county]).to be_nil
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to be_nil
        expect(zip_info[:lat]).to be_nil
        expect(zip_info[:long]).to be_nil
      end
    end

    describe "city/state filter" do
      it "returns zip codes that match a particular city" do
        zip_infos = described_class.zip_info city: "Austin"
        expect(zip_infos.count).to eq(54)
      end

      it "returns zip codes that match a particular state" do
        zip_infos = described_class.zip_info state: "TX"
        expect(zip_infos.count).to eq(1745)
      end

      it "returns zip codes that match a particular city and state" do
        zip_infos = described_class.zip_info city: "Austin", state: "TX"
        expect(zip_infos.count).to eq(47)
      end

      it "returns zip codes that match a particular city with spaces and state" do
        zip_infos = described_class.zip_info city: "San Antonio", state: "TX"
        expect(zip_infos.count).to eq(65)
      end
    end

  end

  describe "#city_info" do
    it "raises exception if no ','" do
      expect {
        described_class.city_info "Austin TX"
      }.to raise_error(Zipcoder::ZipcoderError)
    end

    it "returns the normalized city/state value" do
      city_info = described_class.city_info "Austin, TX"
      expect(city_info[:city]).to eq("Austin")
      expect(city_info[:county]).to eq("Travis,Williamson,Hays")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip].start_with?("78701")).to eq(true)
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-97.71)
    end

    it "returns the normalized city/state value with space" do
      city_info = described_class.city_info " San Antonio , TX"
      expect(city_info[:city]).to eq("San Antonio")
      expect(city_info[:county]).to eq("Bexar,Comal")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip].start_with?("78201")).to eq(true)
      expect(city_info[:lat]).to eq(29.435)
      expect(city_info[:long]).to eq(-98.495)
    end

    it "returns the normalized city/state filtered" do
      city_info = described_class.city_info "Austin, TX", keys: [:zip, :lat, :long]
      expect(city_info[:city]).to be_nil
      expect(city_info[:state]).to be_nil
      expect(city_info[:zip].start_with?("78701")).to eq(true)
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-97.71)
    end

    it 'returns nil on mismatch' do
      city_info = described_class.city_info "Bad City, TX"
      expect(city_info).to be_nil
    end

  end

  describe "#state_cities" do
    it "returns the cities for a state" do
      cities = described_class.state_cities "TX"
      expect(cities.count).to eq(1586)

      city_info = cities[0]
      expect(city_info[:city]).to eq("Abbott")
      expect(city_info[:county]).to eq("Hill")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip]).to eq("76621")
      expect(city_info[:lat]).to eq(31.88)
      expect(city_info[:long]).to eq(-97.07)
    end
    it "returns the cities for a state filtered" do
      cities = described_class.state_cities "TX", keys: [:zip, :city]
      expect(cities.count).to eq(1586)

      city_info = cities[0]
      expect(city_info[:city]).to eq("Abbott")
      expect(city_info[:county]).to be_nil
      expect(city_info[:state]).to be_nil
      expect(city_info[:zip]).to eq("76621")
      expect(city_info[:lat]).to be_nil
      expect(city_info[:long]).to be_nil
    end
    it "returns the names of the cities" do
      cities = described_class.state_cities "TX", names_only: true
      expect(cities.count).to eq(1586)

      expect(cities[0]).to eq("Abbott")
    end
  end

  describe "#state_counties" do
    it "returns the names of the counties for a state" do
      counties = described_class.state_counties "TX"
      expect(counties.count).to eq(250)

      expect(counties[0]).to eq("Anderson")
    end
  end

  describe "#zip_cities" do
    it "returns a city for one zip code" do
      zip_cities = "78748".zip_cities
      expect(zip_cities.count).to eq(1)

      zip_info = zip_cities[0]
      expect(zip_info[:city]).to eq("Austin")
      expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78754,78756-78759,78798-78799")
      expect(zip_info[:specified_zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.315)
      expect(zip_info[:long]).to eq(-97.71)
    end

    it "returns multiple cities" do
      zip_cities = "78702-78750,78613".zip_cities
      expect(zip_cities.count).to eq(2)

      zip_info = zip_cities[0]
      expect(zip_info[:city]).to eq("Austin")
      expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78754,78756-78759,78798-78799")
      expect(zip_info[:specified_zip]).to eq("78702-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78750")
      expect(zip_info[:lat]).to eq(30.315)
      expect(zip_info[:long]).to eq(-97.71)

      zip_info = zip_cities[1]
      expect(zip_info[:city]).to eq("Cedar Park")
      expect(zip_info[:county]).to eq("Williamson")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78613")
      expect(zip_info[:specified_zip]).to eq("78613")
      expect(zip_info[:lat]).to eq(30.51)
      expect(zip_info[:long]).to eq(-97.83)
    end

    it "breaks on max" do
      zip_cities = "13601,11223,78748,78613".zip_cities max: 2
      expect(zip_cities.count).to eq(2)
    end

    it "returns just names of cities sorted" do
      zip_cities = "13601,78613,78702-78750".zip_cities names_only: true
      expect(zip_cities).to eq(["Austin, TX", "Cedar Park, TX", "Watertown, NY"])
    end

    context "#grouped" do
      it "returns the cities grouped" do
        zip_cities = "78751,13601,78613,78700-78750".zip_cities grouped: true
        expect(zip_cities.keys.sort).to eq(["13601", "78613", "78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78751"])

        zip_info = zip_cities["78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78751"]
        expect(zip_info[:city]).to eq("Austin")
        expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to eq("78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78754,78756-78759,78798-78799")
        expect(zip_info[:lat]).to eq(30.315)
        expect(zip_info[:long]).to eq(-97.71)

        zip_info = zip_cities["78613"]
        expect(zip_info[:city]).to eq("Cedar Park")
        expect(zip_info[:county]).to eq("Williamson")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to eq("78613")
        expect(zip_info[:lat]).to eq(30.51)
        expect(zip_info[:long]).to eq(-97.83)

        zip_info = zip_cities["13601"]
        expect(zip_info[:city]).to eq("Watertown")
        expect(zip_info[:county]).to eq("Jefferson")
        expect(zip_info[:state]).to eq("NY")
        expect(zip_info[:zip]).to eq("13601-13603")
        expect(zip_info[:lat]).to eq(43.97)
        expect(zip_info[:long]).to eq(-75.91)
      end

      it "returns just names of cities grouped" do
        zip_cities = "78751,13601,78613,78700-78750".zip_cities grouped: true, names_only: true
        expect(zip_cities.keys.sort).to eq(["13601", "78613", "78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78751"])
        expected = {
            "78701-78705,78710,78712,78717,78719,78721-78739,78741-78742,78744-78751" => "Austin, TX",
            "78613" => "Cedar Park, TX",
            "13601" => "Watertown, NY"
        }
        expect(zip_cities).to eq(expected)
      end
    end
  end

  describe "#_parse_zip_string" do
    it "parses the zip_string" do
      [
          ["78703, 78701", ["78701", "78703"]],
          ["78701-78703, 78702", ["78701", "78702", "78703"]],
      ].each do |t|
        zips = described_class._parse_zip_string(t[0])
        expect(zips).to eq(t[1])
      end
    end

    it "raises an error for invalid zip code" do
      expect {
        described_class._parse_zip_string "100"
      }.to raise_error(Zipcoder::ZipcoderError)
    end
  end

  describe("String") do
    describe "zip_info" do
      it "returns the info for a particular zip_code" do
        zip_info = "78748".zip_info
        expect(zip_info[:city]).to eq("Austin")
        expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to eq("78748")
        expect(zip_info[:lat]).to eq(30.26)
        expect(zip_info[:long]).to eq(-97.74)
      end

      it "only returns specified keys" do
        zip_info = "78748".zip_info keys: [:city, :state]
        expect(zip_info[:city]).to eq("Austin")
        expect(zip_info[:county]).to be_nil
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to be_nil
        expect(zip_info[:lat]).to be_nil
        expect(zip_info[:long]).to be_nil
      end
    end

    describe "city_info" do
      it "returns the info for a particular city" do
        city_info = "Austin, TX".city_info
        expect(city_info[:city]).to eq("Austin")
        expect(city_info[:county]).to eq("Travis,Williamson,Hays")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zip].start_with?("78701")).to eq(true)
        expect(city_info[:lat]).to eq(30.315)
        expect(city_info[:long]).to eq(-97.71)
      end

      it "only returns specified keys" do
        city_info = "Austin, TX".city_info keys: [:zip, :city]
        expect(city_info[:city]).to eq("Austin")
        expect(city_info[:county]).to be_nil
        expect(city_info[:state]).to be_nil
        expect(city_info[:zip].start_with?("78701")).to eq(true)
        expect(city_info[:lat]).to be_nil
        expect(city_info[:long]).to be_nil
      end

      it "only returns the zip codes" do
        zip_codes = "Austin, TX".city_info zips_only: true
        expect(zip_codes.count).to eq(47)
        expect(zip_codes[0]).to eq('78701')
        expect(zip_codes[-1]).to eq('78799')
      end

      it "returns the specified zip codes in the filter" do
        city_info = "Austin, TX".city_info filter: "78701-78704,78748,13601"
        expect(city_info[:city]).to eq("Austin")
        expect(city_info[:county]).to eq("Travis,Williamson,Hays")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:specified_zip]).to eq("78701-78704,78748")
        expect(city_info[:zip].start_with?("78701")).to eq(true)
        expect(city_info[:lat]).to eq(30.315)
        expect(city_info[:long]).to eq(-97.71)
      end

      it "returns the specified zip codes in the filter with space" do
        city_info = "Austin, TX".city_info filter: " 78701 "
        expect(city_info[:city]).to eq("Austin")
        expect(city_info[:county]).to eq("Travis,Williamson,Hays")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:specified_zip]).to eq("78701")
        expect(city_info[:zip].start_with?("78701")).to eq(true)
        expect(city_info[:lat]).to eq(30.315)
        expect(city_info[:long]).to eq(-97.71)
      end

      it "returns nil if it cant find the city" do
        city_info = "Aus, TX".city_info filter: "78701-78704,78748,13601"
        expect(city_info).to be_nil
      end

      it "returns an nil when the city state is non-existent" do
        zip_codes = ", ".city_info
        expect(zip_codes).to be_nil
      end

      it "returns the info for an acceptable city" do
        city_info = "West Lake Hills, TX".city_info
        expect(city_info[:city]).to eq("West Lake Hills")
        expect(city_info[:county]).to eq("Travis")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zip]).to eq("78746")
        expect(city_info[:lat]).to eq(30.26)
        expect(city_info[:long]).to eq(-97.74)
      end
    end

    describe "state_cities" do
      it "returns the cities for a state" do
        cities = "TX".state_cities
        expect(cities.count).to eq(1586)

        city_info = cities[0]
        expect(city_info[:city]).to eq("Abbott")
        expect(city_info[:county]).to eq("Hill")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zip]).to eq("76621")
        expect(city_info[:lat]).to eq(31.88)
        expect(city_info[:long]).to eq(-97.07)
      end
      it "returns the cities for a state filtered" do
        cities = "TX".state_cities keys: [:zip, :city]
        expect(cities.count).to eq(1586)

        city_info = cities[0]
        expect(city_info[:city]).to eq("Abbott")
        expect(city_info[:county]).to be_nil
        expect(city_info[:state]).to be_nil
        expect(city_info[:zip]).to eq("76621")
        expect(city_info[:lat]).to be_nil
        expect(city_info[:long]).to be_nil
      end

      it "has secondary cities" do
        contains_acceptable = false
        "TX".state_cities.each do |info|
          if info[:city] == "West Lake Hills"
            contains_acceptable = true
            break
          end
        end

        expect(contains_acceptable).to eq(true)
      end
    end

    describe "#state_counties" do
      it "returns the names of the counties for a state" do
        counties = "TX".state_counties
        expect(counties.count).to eq(250)

        expect(counties[0]).to eq("Anderson")
      end
    end
  end

  describe("Integer") do
    it "returns the info for a particular zip_code" do
      zip_info = 78748.zip_info
      expect(zip_info[:city]).to eq("Austin")
      expect(zip_info[:county]).to eq("Travis,Williamson,Hays")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "zero pads the zip code when using an integer" do
      zip_info = 705.zip_info
      expect(zip_info[:city]).to eq("Aibonito")
    end
  end
end
