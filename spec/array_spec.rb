require "spec_helper"
require "zipcoder/ext/array"


describe Array do
  it 'combines the zip codes' do
    [
        [["12345","12346","12347"], "12345-12347"],
        [["12347","12346","12345"], "12345-12347"],
        [["12346","12347","12345"], "12345-12347"],
        [["12346","12347","12345","78746"], "12345-12347,78746"],
        [["78748","78746","12346","12347","12345"], "12345-12347,78746,78748"],
    ].each do |test|
      expect(test[0].combine_zips).to eq(test[1])
    end
  end
end
