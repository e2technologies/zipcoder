require_relative 'string'

class Array
  def combine_zips
    zips = []
    start = nil
    last = nil

    self.sort.each do |zip|
      zip_int = zip.to_i

      if start == nil
        start = zip_int
        last = zip_int
      else
        if zip_int == last+1
          last = zip_int
        else
          if last == start
            zips << start.to_zip
          else
            zips << "#{start.to_zip}-#{last.to_zip}"
          end
          start = zip_int
          last = zip_int
        end
      end

    end

    if last == start
      zips << start.to_zip
    else
      zips << "#{start.to_zip}-#{last.to_zip}"
    end

    zips.join ","
  end
end