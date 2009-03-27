class String
  
  alias :- :delete


  def shorten(length = 16) # truncate() heler sucks.
    if self.size > length
      self[0 .. length - 3].strip + "..."
    else
      self
    end
  end


  def n2br
    self.strip.gsub("\n", "<br />")
  end

end