class Timeline
  def self.find(asset)
    timeline = asset.comments + asset.emails
    timeline.sort! { |x, y| y.updated_at <=> x.updated_at }
  end
end