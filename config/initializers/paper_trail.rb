require 'paper_trail'

class Version < ActiveRecord::Base
  attr_accessible :related
  belongs_to :related, :polymorphic => true

  def self.history(object)
    where("(item_id = :id AND item_type = :type) OR (related_id = :id AND related_type = :type)", :id => object.id, :type => object.class.name).order('created_at DESC')
  end
end
