class Campaign < ActiveRecord::Base
  belongs_to :user
  acts_as_paranoid

  validates_presence_of :name, :message => "^Please specify campaign name."
  validates_uniqueness_of :name, :scope => :user_id
  before_create :set_campaign_status

  # Make sure end date > start date.
  #----------------------------------------------------------------------------
  def validate
    if (self.starts_on && self.ends_on) && (self.starts_on > self.ends_on)
      errors.add(:ends_on, "^Please make sure the campaign end date is after the start date.")
    end
  end

  private
  #----------------------------------------------------------------------------
  def set_campaign_status
    if self.ends_on and (self.ends_on < Date.today)
      self.status = "Completed"
    else
      self.status = self.starts_on && (self.starts_on <= Date.today) ? "Started" : "Planned"
    end
  end

end
