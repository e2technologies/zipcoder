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

  def is_zip?
    self.length == 5
  end

  def breakout_zips
    zips = []
    self.split(',').each do |zip_group|
      if zip_group.include? '-'
        components = zip_group.split('-')
        ((components[0].to_i)...(components[1].to_i)).each do |zip|
          zips.push(zip.to_s)
        end
      else
        zips.push(zip_group)
      end
    end
    zips.sort
  end

end