# Zipcoder
[![Gem Version](https://badge.fury.io/rb/zipcoder.svg)](https://badge.fury.io/rb/zipcoder)
[![Circle CI](https://circleci.com/gh/ericchapman/zipcoder/tree/master.svg?&style=shield&circle-token=a6120adc7b90f211b8c19b16e184da4123de671c)](https://circleci.com/gh/ericchapman/zipcoder/tree/master)
[![Codecov](https://img.shields.io/codecov/c/github/ericchapman/zipcoder/master.svg)](https://codecov.io/github/ericchapman/zipcoder)

Gem for performing zip code lookup operations

## Revision History

 - v0.3.0:
   - API Change!! - intitialization method change from "load_data" to "load_cache"
   - added city and state caches
   - added "cities" call
 - v0.2.0:
   - Internal code rework
   - API Change!! - changed "city,state" to return normalized info rather
     than array of zips, lats, longs
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
Zipcoder.load_cache
```

This will immediately load the data structures.  Currently it takes roughly 3s
to create and import all of the data structures.  I will look at ways to
reduce this later.

### Methods

The library overrides the String (and in some instances Integer) class to 
provide the following methods

#### "zip".zip_info

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

##### "keys" argument

You can filter the keys that are returned by including the "keys" argument
as shown below

``` ruby
require 'zipcoder'

puts "78748".zip_info(keys: [:city, :state])
# > {:city=>"AUSTIN", :state=>"TX"}
```

#### "city, state".city_info

This will return info about a city

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info
# > {:zip=>"78701-78799", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}
```

Notes:

 - the "zip", "lat", "long" are the combined values from all of the 
   individual zip codes
 - the library will normalize the key by removing all of the whitespace
   and capitalizing the letters.  So for example, "Austin, TX" becomes 
   "AUSTIN,TX"
 - the library will cache the normalized cities to improve performance
   on subsequent calls

##### "keys" argument

You can filter the keys that are returned by including the "keys" argument
as shown below

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info(keys: [:zip])
# > {:zip=>"78701-78799"}
```

#### "state".cities

This will return the cities in a state

``` ruby
require 'zipcoder'

puts "TX".cities
# > {:zip=>"78701-7879", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}
```

Notes:

 - the "zip", "lat", "long" are the combined values from all of the 
   individual zip codes
 - the library will normalize the key by removing all of the whitespace
   and capitalizing the letters.  So for example, "Austin, TX" becomes 
   "AUSTIN,TX"
 - the library will cache the normalized cities to improve performance
   on subsequent calls

##### "keys" argument

You can filter the keys that are returned by including the "keys" argument
as shown below

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info(keys: [:zip])
# > {:zip=>"78701-78799"}
```

### Updating Data

The library is using the free public zip code data base located 
[here](http://federalgovernmentzipcodes.us/). To update the database, run the 
following at command line from the top directory

```
%> rake zipcoder:update  # Pulls the latest CSV file from the website
%> rake zipcoder:convert  # Updates the zipcoder data structures
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, 
run `rake spec` to run the tests. You can also run `bin/console` for an interactive 
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To 
release a new version, update the version number in `version.rb`, and then run 
`bundle exec rake release`, which will create a git tag for the version, push 
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ericchapman/zipcoder.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

