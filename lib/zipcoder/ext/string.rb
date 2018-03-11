class String

  def zip_info(**kwargs)
    Zipcoder.zip_info self, **kwargs
  end

  def zip_cities(**kwargs)
    Zipcoder.zip_cities self, **kwargs
  end

  def city_info(**kwargs)
    Zipcoder.city_info self, **kwargs
  end

  def state_cities(**kwargs)
    Zipcoder.state_cities self, **kwargs
  end

  def to_zip
    self
  end

end