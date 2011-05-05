class OpportunityObserver < ActiveRecord::Observer

  def after_update(opportunity)
    set_probability_to_100_percent_if_won(opportunity)
    set_probability_to_0_percent_if_lost(opportunity)
  end

  private

  def set_probability_to_100_percent_if_won(opportunity)
    if opportunity.changed.include?("stage") && opportunity.stage == "won"
      opportunity.reload
      opportunity.update_attributes(:probability => 100)
    end
  end

  def set_probability_to_0_percent_if_lost(opportunity)
    if opportunity.changed.include?("stage") && opportunity.stage == "lost"
      opportunity.reload
      opportunity.update_attributes(:probability => 0)
    end
  end

end