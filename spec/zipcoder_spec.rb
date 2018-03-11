require "spec_helper"
require 'benchmark'

describe Zipcoder do
  it "has a version number" do
    expect(Zipcoder::VERSION).not_to be nil
  end

  describe "#zip_info" do
    it "returns the info for a particular zip_code" do
      zip_info = described_class.zip_info "78748"
      expect(zip_info[:city]).to eq("AUSTIN")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "returns the info for a particular zip_code" do
      zip_info = described_class.zip_info 78748
      expect(zip_info[:city]).to eq("AUSTIN")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "zero pads the zip code when using an integer" do
      zip_info = described_class.zip_info 705
      expect(zip_info[:city]).to eq("AIBONITO")
    end

    describe "keys filter" do
      it "only returns specified keys" do
        zip_info = described_class.zip_info "78748", keys: [:city, :state]
        expect(zip_info[:city]).to eq("AUSTIN")
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
      }.to raise_error(Exception)
    end

    it "returns the normalized city/state value" do
      city_info = described_class.city_info "Austin, TX"
      expect(city_info[:city]).to eq("AUSTIN")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip]).to eq("78701-78799")
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-48.87)
    end

    it "returns the normalized city/state value with space" do
      city_info = described_class.city_info "San Antonio, TX"
      expect(city_info[:city]).to eq("SAN ANTONIO")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip]).to eq("78201-78285")
      expect(city_info[:lat]).to eq(29.435000000000002)
      expect(city_info[:long]).to eq(-49.25)
    end

    it "returns the normalized city/state filtered" do
      city_info = described_class.city_info "Austin, TX", keys: [:zip, :lat, :long]
      expect(city_info[:city]).to be_nil
      expect(city_info[:state]).to be_nil
      expect(city_info[:zip]).to eq("78701-78799")
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-48.87)
    end

    it 'returns nil on mismatch' do
      city_info = described_class.city_info "Bad City, TX"
      expect(city_info).to be_nil
    end

  end

  describe "#cities" do
    it "returns the cities for a state" do
      cities = described_class.cities "TX"
      expect(cities.count).to eq(1170)

      city_info = cities[0]
      expect(city_info[:city]).to eq("ABBOTT")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip]).to eq("76621")
      expect(city_info[:lat]).to eq(31.88)
      expect(city_info[:long]).to eq(-97.07)
    end
    it "returns the cities for a state filtered" do
      cities = described_class.cities "TX", keys: [:zip, :city]
      expect(cities.count).to eq(1170)

      city_info = cities[0]
      expect(city_info[:city]).to eq("ABBOTT")
      expect(city_info[:state]).to be_nil
      expect(city_info[:zip]).to eq("76621")
      expect(city_info[:lat]).to be_nil
      expect(city_info[:long]).to be_nil
    end
  end

  describe("String") do
    describe "zip_info" do
      it "returns the info for a particular zip_code" do
        zip_info = "78748".zip_info
        expect(zip_info[:city]).to eq("AUSTIN")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to eq("78748")
        expect(zip_info[:lat]).to eq(30.26)
        expect(zip_info[:long]).to eq(-97.74)
      end

      it "only returns specified keys" do
        zip_info = "78748".zip_info keys: [:city, :state]
        expect(zip_info[:city]).to eq("AUSTIN")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to be_nil
        expect(zip_info[:lat]).to be_nil
        expect(zip_info[:long]).to be_nil
      end
    end

    describe "city_info" do
      it "returns the info for a particular city" do
        city_info = "Austin, TX".city_info
        expect(city_info[:city]).to eq("AUSTIN")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zip]).to eq("78701-78799")
        expect(city_info[:lat]).to eq(30.315)
        expect(city_info[:long]).to eq(-48.87)
      end
      it "only returns specified keys" do
        city_info = "Austin, TX".city_info keys: [:zip, :city]
        expect(city_info[:city]).to eq("AUSTIN")
        expect(city_info[:state]).to be_nil
        expect(city_info[:zip]).to eq("78701-78799")
        expect(city_info[:lat]).to be_nil
        expect(city_info[:long]).to be_nil
      end
    end

    describe "cities" do
      it "returns the cities for a state" do
        cities = "TX".cities
        expect(cities.count).to eq(1170)

        city_info = cities[0]
        expect(city_info[:city]).to eq("ABBOTT")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zip]).to eq("76621")
        expect(city_info[:lat]).to eq(31.88)
        expect(city_info[:long]).to eq(-97.07)
      end
      it "returns the cities for a state filtered" do
        cities = "TX".cities keys: [:zip, :city]
        expect(cities.count).to eq(1170)

        city_info = cities[0]
        expect(city_info[:city]).to eq("ABBOTT")
        expect(city_info[:state]).to be_nil
        expect(city_info[:zip]).to eq("76621")
        expect(city_info[:lat]).to be_nil
        expect(city_info[:long]).to be_nil
      end
    end
  end

  describe("Integer") do
    it "returns the info for a particular zip_code" do
      zip_info = 78748.zip_info
      expect(zip_info[:city]).to eq("AUSTIN")
      expect(zip_info[:state]).to eq("TX")
      expect(zip_info[:zip]).to eq("78748")
      expect(zip_info[:lat]).to eq(30.26)
      expect(zip_info[:long]).to eq(-97.74)
    end

    it "zero pads the zip code when using an integer" do
      zip_info = 705.zip_info
      expect(zip_info[:city]).to eq("AIBONITO")
    end
  end
end
