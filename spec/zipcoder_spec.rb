require "spec_helper"

describe Zipcoder do
  before(:all) {
    described_class.load_data
  }

  it "has a version number" do
    expect(Zipcoder::VERSION).not_to be nil
  end

  describe("String") do
    describe "zip lookup" do
      it "returns the info for a particular zip_code" do
        zip_info = "78748".zip_info
        expect(zip_info[:city]).to eq("AUSTIN")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to eq("78748")
        expect(zip_info[:lat]).to eq(30.26)
        expect(zip_info[:long]).to eq(-97.74)
      end

      it "only returns specified keys" do
        zip_info = "78748".zip_info(keys: [:city, :state])
        expect(zip_info[:city]).to eq("AUSTIN")
        expect(zip_info[:state]).to eq("TX")
        expect(zip_info[:zip]).to be_nil
        expect(zip_info[:lat]).to be_nil
        expect(zip_info[:long]).to be_nil
      end
    end

    describe "city lookup" do
      it "returns the info for a particular city" do
        city_info = "Austin, TX".city_info
        expect(city_info[:city]).to eq("AUSTIN")
        expect(city_info[:state]).to eq("TX")
        expect(city_info[:zips].count).to eq(81)
        expect(city_info[:lats].count).to eq(81)
        expect(city_info[:longs].count).to eq(81)
      end
      it "only returns specified keys" do
        city_info = "Austin, TX".city_info(keys: [:zips, :city])
        expect(city_info[:city]).to eq("AUSTIN")
        expect(city_info[:state]).to be_nil
        expect(city_info[:zips].count).to eq(81)
        expect(city_info[:lats]).to be_nil
        expect(city_info[:longs]).to be_nil
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
  end
end
