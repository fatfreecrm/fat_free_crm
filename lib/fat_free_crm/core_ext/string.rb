class String
  
  alias :- :delete


  def shorten(length = 16) # truncate() helper sucks.
    if self.size > length
      self[0 .. length - 3].strip + "..."
    else
      self
    end
  end


  def n2br
    self.strip.gsub("\n", "<br />")
  end


  def digitize
    gsub /[^\d]/, ""  # "$100,000".digitize # => 100000
  end

end