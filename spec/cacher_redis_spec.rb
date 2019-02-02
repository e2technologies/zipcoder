require "spec_helper"
require "zipcoder/cacher/redis"


describe Zipcoder::Cacher::Redis do
  stub_redis_once = false

  before(:each) do
    unless stub_redis_once
      allow(Zipcoder::Cacher::Redis).to receive(:_create_redis_client) do
        RedisStub.new
      end
      Zipcoder.config do |config|
        config.cacher = Zipcoder::Cacher::Redis.new
      end

      Zipcoder.load_cache
    end

    stub_redis_once = true
  end

  after(:each) {
    Zipcoder.config do |config|
      config.data = nil
      config.cacher = nil
    end
  }

  describe "#zip_info" do
    it "match" do
      info = "78748".zip_info
      expect(info[:city]).to eq("Austin")
    end

    it "matches city" do
      zips = Zipcoder.zip_info city: "Austin", state: "TX"
      expect(zips.count).to eq(47)
    end

    it "no match" do
      info = "78706".zip_info
      expect(info).to be_nil
    end
  end

  describe "#zip_cities" do
    it "match" do
      cities = "78748".zip_cities
      expect(cities.count).to eq(1)
      expect(cities[0][:city]).to eq("Austin")
    end

    it "no match" do
      cities = "78706".zip_cities
      expect(cities.count).to eq(0)
    end
  end
end
