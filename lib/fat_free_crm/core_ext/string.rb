class String
  
  alias :- :delete

  def n2br
    self.strip.gsub("\n", "<br />")
  end

end