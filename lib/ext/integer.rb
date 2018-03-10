class Integer

  def zip_info(**kwargs)
    string = self.to_s.rjust(5, '0')
    string.zip_info(**kwargs)
  end

end