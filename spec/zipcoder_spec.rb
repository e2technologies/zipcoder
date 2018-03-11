require "spec_helper"

describe Zipcoder do
  before(:all) do
    described_class.load_data
  end

  before(:each) do
    described_class.city_cache.clear
  end

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

      it "returns zip codes that match a particular city/state" do
        zip_infos = described_class.zip_info city: "Austin", state: "TX"
        expect(zip_infos.count).to eq(47)
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

    it "returns the normalized city/state filtered" do
      city_info = described_class.city_info "Austin, TX", keys: [:zip, :lat, :long]
      expect(city_info[:city]).to be_nil
      expect(city_info[:state]).to be_nil
      expect(city_info[:zip]).to eq("78701-78799")
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-48.87)
    end

    it "caches the unfiltered value" do
      expect {
        described_class.city_info "Austin, TX", keys: [:zip, :lat, :long]
      }.to change{ described_class.city_cache.values.count }.by(1)

      expect {
        described_class.city_info "Austin, TX"
      }.to change{ described_class.city_cache.values.count }.by(0)

      city_info = described_class.city_info "Austin, TX"
      expect(city_info[:city]).to eq("AUSTIN")
      expect(city_info[:state]).to eq("TX")
      expect(city_info[:zip]).to eq("78701-78799")
      expect(city_info[:lat]).to eq(30.315)
      expect(city_info[:long]).to eq(-48.87)
    end
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
        zip_info = "78748".zip_info keys: [:city, :state]
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
