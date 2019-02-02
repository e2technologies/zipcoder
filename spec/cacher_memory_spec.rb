require "spec_helper"
require "zipcoder/cacher/memory"

describe Zipcoder::Cacher::Memory do

  before(:all) {
    new_data = "#{File.dirname(__FILE__)}/fixtures/files/temp_data.yml"

    Zipcoder.config do |config|
      config.data = new_data
    end

    Zipcoder.load_cache
  }

  after(:all) {
    Zipcoder.config do |config|
      config.data = nil
      config.cacher = nil
    end
  }

  it "allows the default data file to be overridden" do
    # Check that it was loaded
    expect(Zipcoder.states.count).to eq(1)
    expect("PR".state_cities.count).to eq(3)

    # Empty the cache
    Zipcoder.cacher._empty_cache
  end
end
