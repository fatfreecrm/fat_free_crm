require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunityObserver do

  describe "after_update" do
    context "stage is changed to 'won'" do
      it "should set the probability to 100%" do
        opp = Factory(:opportunity, :stage => "prospecting", :probability => 75)
        opp.update_attributes(:stage => "won")
        opp.probability.should == 100
      end
    end
    context "stage is changed to 'lost'" do
      it "should not change the probability" do
        opp = Factory(:opportunity, :stage => "prospecting", :probability => 25)
        opp.update_attributes(:stage => "lost")
        opp.reload
        opp.probability.should == 25
      end
    end
  end

end