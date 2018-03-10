require_relative "../zipcoder"

class String

  def zip_info(**kwargs)
    info = Zipcoder.zip_lookup[self]

    # Filter to the included keys
    if kwargs[:keys] != nil
      new_info = {}
      kwargs[:keys].each { |k| new_info[k] = info[k] }
      info = new_info
    end

    info
  end

  def city_info(**kwargs)
    # Cleanup "self"
    key = self.delete(' ').upcase

    info = Zipcoder.city_lookup[key]

    # Filter to the included keys
    if kwargs[:keys] != nil
      new_info = {}
      kwargs[:keys].each { |k| new_info[k] = info[k] }
      info = new_info
    end

    info
  end

end