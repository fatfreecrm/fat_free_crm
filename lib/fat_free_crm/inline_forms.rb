module FatFreeCRM
  module InlineForms
    
    private

    #--------------------------------------------------------------------------
    def make_new_account
      @account = Account.new
      @users = User.all_except(@current_user)
    end

    #--------------------------------------------------------------------------
    def make_new_campaign
      @campaign = Campaign.new
      @users = User.all_except(@current_user)
    end

    #--------------------------------------------------------------------------
    def make_new_contact
      @contact = Contact.new(:user => @current_user, :access => "Private")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
    end

    #--------------------------------------------------------------------------
    def make_new_lead
      @lead = Lead.new
      @users = User.all_except(@current_user)
      @campaigns = Campaign.my(@current_user).all(:order => "name")
    end

    #--------------------------------------------------------------------------
    def make_new_opportunity
      @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
    end

  end
end