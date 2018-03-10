# Zipcoder
[![Gem Version](https://badge.fury.io/rb/zipcoder.svg)](https://badge.fury.io/rb/zipcoder)
[![Circle CI](https://circleci.com/gh/ericchapman/zipcoder/tree/master.svg?&style=shield&circle-token=92813c17f9c9510c4c644e41683e7ba2572e0b2a)](https://circleci.com/gh/ericchapman/zipcoder/tree/master)
[![Codecov](https://img.shields.io/codecov/c/github/ericchapman/zipcoder/master.svg)](https://codecov.io/github/ericchapman/zipcoder)

Gem for performing zip code lookup operations

## Revision History

 - v0.1.0:
   - Initial Revision

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zipcoder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zipcoder

## Usage

### Setup

By default, the library will lazy-load the data structures when you first try
to use it.  If you would like to have the data structures already loaded
when application is loaded, you can do the following RAILS example

**config/initializers/zipcoder.rb:**

``` ruby
require 'zipcoder'
Zipcoder.load_data
```

This will immediately load the data structures

### Methods

The library overrides the String (and in some instances Integer) class to 
provide the following methods

#### Lookup Zip Code

This will return information about the zip code

``` ruby
require 'zipcoder'

puts "78748".zip_info
# > {:zip=>"78748", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}
```

Note that this also works with Integer zip codes, for example

``` ruby
require 'zipcoder'

puts 78748.zip_info
# > {:zip=>"78748", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}
```

You can filter the keys that are returned by including the "keys" argument
as shown below

``` ruby
require 'zipcoder'

puts "78748".zip_info(keys: [:city, :state])
# > {:city=>"AUSTIN", :state=>"TX"}
```

#### Lookup City

This will return info about a city

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info
# > {:zips=>["73301", ...], :city=>"AUSTIN", :state=>"TX", :lats=>[30.26, ...], :longs=>[-97.74, ...]}
```

The "zips", "lats", and "longs" are all arrays where each value is representing
the info for a specific zip code.

Note that the library will normalize the key by removing all of the whitespace
and capitalizing the letters.  So for example, "Austin, TX" becomes "AUSTIN,TX".

You can filter the keys that are returned by including the "keys" argument
as shown below

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info(keys: [:zips])
# > {:zips=>["73301", ...]}
```

### Updating Data

The library is using the free public zip code data base located [here](http://federalgovernmentzipcodes.us/).
To update the database, run the following at command line from the top directory

```
%> rake zipcoder:update  # Pulls the latest CSV file from the website
%> rake zipcoder:convert  # Updates the zipcoder data structures
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ericchapman/zipcoder.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

