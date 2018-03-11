class Integer

  def zip_info(**kwargs)
    Zipcoder.zip_info self, **kwargs
  end

  def to_zip
    self.to_s.rjust(5, '0')
  end

end