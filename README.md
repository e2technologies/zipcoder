# Zipcoder
[![Gem Version](https://badge.fury.io/rb/zipcoder.svg)](https://badge.fury.io/rb/zipcoder)
[![Circle CI](https://circleci.com/gh/ericchapman/zipcoder/tree/master.svg?&style=shield&circle-token=a6120adc7b90f211b8c19b16e184da4123de671c)](https://circleci.com/gh/ericchapman/zipcoder/tree/master)
[![Codecov](https://img.shields.io/codecov/c/github/ericchapman/zipcoder/master.svg)](https://codecov.io/github/ericchapman/zipcoder)

Gem for performing zip code lookup operations

## Revision History

 - v0.5.0:
   - added Redis backend support
 - v0.4.2:
   - updated paths to fix RAILS require issue
 - v0.4.1:
   - bug fix for "capitalize_all"
 - v0.4.0:
   - abstracted "cacher" object to later support "redis" and "memcacher"
   - API Change!! - changed name of "cities" to "state_cities"
   - added "names_only" option to "state_cities"
   - added "states" method that returns list of states
   - added "zip_cities" method that returns the cities associated with a
     list of zip codes
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

#### Redis Support

To use Redis as the cache for zipcoder rather than memory, you must do the
following

**install the 'redis' Gem (or add to your Gemfile if using Rails):**

```ruby
gem 'redis'
```

*Note that this Gem supports Ruby >= 2.0 so I could NOT use the latest Redis
version.  I had to use v3.3.5 to test.*

**create a redis cacher and pass it to the "load_cache" method:**

```ruby
require 'zipcoder'
require 'zipcoder/cacher/redis'

cacher = Zipcoder::Cacher::Redis.new(**args)
Zipcoder.load_cache(cacher)
```

Please check [here](https://github.com/redis/redis-rb) for the different options 
to use when instantiating the "Redis" client.

### Methods

The library overrides the String (and in some instances Integer) class to 
provide the following methods

#### Method: Zipcoder.zip_info(zip, **args)

Returns the info for the "zip"

**variations:**

 - ```Zipcoder.zip_info(78748, **args)```
 - ```Zipcoder.zip_info("78748", **args)```
 - ```"78748".zip_info(**args)```
 - ```78748.zip_info(**args)```

**parameters:**

 - zip [String, Integer] - a string or integer representing a single zip code
 - **return** [Hash] - zip object

**arguments:**

 - keys [Array] - array of keys to include (filters out the others)

**notes:**

 - none
 
**examples:**

``` ruby
require 'zipcoder'

# Looks up a zip code by string
puts "78748".zip_info
# > {:zip=>"78748", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}

# Looks up a zip code by integer
puts 78748.zip_info
# > {:zip=>"78748", :city=>"Austin", :state=>"TX", :lat=>30.26, :long=>-97.74}

```

#### Method: Zipcoder.zip_cities(zip_string, **args)

Returns the cities that are covered by the "zip_string"

**variations:**

 - ```Zipcoder.zip_cities("78701-78799,78613", **args)```
 - ```"78701-78799,78613".zip_cities(**args)```

**parameters:**

 - zip_string [String] - a string containing comma delimited list of
   zip codes and zip code ranges (ex. "78701-78750, 78613")
 - **return** [Array] - array of zip objects or names (if "names_only"
   is specified)

**arguments:**

 - keys [Array] - array of keys to include (filters out the others)
 - names_only [Bool] - set to "true" if you only want the city names returned
 - max [Integer] - maximum number of cities to return
 
**notes:**

 - none
 
**examples:**

``` ruby
require 'zipcoder'

# Returns the cities for a zip_code
puts "78701-78750,78613".zip_cities
# > [{:zip=>"78748", :city=>"Austin", :state=>"TX", :lat=>30.26, :long=>-97.74}, ...

# Returns just the name of the cities
puts "78701-78750,78613".zip_cities names_only: true
# > ["Austin", "Cedar Park"]
```

#### Method: Zipcoder.city_info(city_state, **args)

Returns the zip object for a city

**variations:**

 - ```Zipcoder.city_info("Atlanta, GA", **args)```
 - ```"Atlanta, GA".city_info(**args)```

**parameters:**

 - city_state [String] - a string "city, state"
 - **return** [Hash] - zip object

**arguments:**

 - keys [Array] - array of keys to include (filters out the others)
 
**notes:**

 - the "zip", "lat", "long" are the combined values from all of the 
   individual zip codes
 - the library will normalize the key by removing all of the whitespace
   and capitalizing the letters.  So for example, " Los Angeles , CA " becomes 
   "LOS ANGELES,CA"

**examples:**

``` ruby
require 'zipcoder'

puts "Austin, TX".city_info
# > {:zip=>"78701-78799", :city=>"AUSTIN", :state=>"TX", :lat=>30.26, :long=>-97.74}
```

#### Method: Zipcoder.state_cities(state, **args)

This will return the cities in a state

**variations:**

 - ```Zipcoder.state_cities("GA", **args)```
 - ```"GA".state_cities(**args)```
 
**parameters:**

 - state [String] - the 2 letter state abbreviation
 - **return** [Array] - list of zip objects (or city names if "names_only")
   is set

**arguments:**

 - keys [Array] - array of keys to include (filters out the others)
 - names_only [Bool] - set to "true" if you only want the city names returned
 
**examples:**

``` ruby
require 'zipcoder'

# Returns Objects
puts "TX".state_cities
# > [{:city=>"Abbott", :state=>"TX" ...

# Returns List
puts "TX".state_cities names_only: true
# > ["Abbott", ...
```

#### Method: Zipcoder.states

This will return the states in the US

**variations:**

 - ```Zipcoder.states```
 
**parameters:**

 - none

**arguments:**

 - none
 
**examples:**

``` ruby
require 'zipcoder'

puts Zipcoder.states
# > ["AK", "AL", ...
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

