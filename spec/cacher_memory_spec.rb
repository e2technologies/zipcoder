require "spec_helper"
require "zipcoder/cacher/memory"

describe Zipcoder::Cacher::Memory do

  it "allows the default data file to be overridden" do

    # Load the new data
    new_data = "#{File.dirname(__FILE__)}/fixtures/files/temp_data.yml"
    Zipcoder.load_cache data: new_data

    # Check that it was loaded
    expect(Zipcoder.states.count).to eq(1)
    expect("PR".state_cities.count).to eq(3)

    # Empty the cache
    Zipcoder.cacher._empty_cache
  end
end
