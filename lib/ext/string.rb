require_relative "../zipcoder"

class String

  def zip_info(**kwargs)
    Zipcoder.zip_info self, **kwargs
  end

  def city_info(**kwargs)
    Zipcoder.city_info self, **kwargs
  end

  def cities(**kwargs)
    Zipcoder.cities self, **kwargs
  end

  def to_zip
    self
  end

end