module FatFreeCRM
  module InlineForms
    
    private
    #--------------------------------------------------------------------------
    def make_new_account(context = nil)
      @account = Account.new
      @users = User.all_except(@current_user)
      find_parent_object_for(@account, context) if context
    end

    #--------------------------------------------------------------------------
    def make_new_campaign(context = nil)
      @campaign = Campaign.new
      @users = User.all_except(@current_user)
      find_parent_object_for(@campaign, context) if context
    end

    #--------------------------------------------------------------------------
    def make_new_contact(context = nil)
      @contact = Contact.new(:user => @current_user, :access => "Private")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
      find_parent_object_for(@contact, context) if context
    end

    #--------------------------------------------------------------------------
    def make_new_lead(context = nil)
      @lead = Lead.new
      @users = User.all_except(@current_user)
      @campaigns = Campaign.my(@current_user).all(:order => "name")
      find_parent_object_for(@lead, context) if context
    end

    #--------------------------------------------------------------------------
    def make_new_opportunity(context = nil)
      @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
      find_parent_object_for(@opportunity, context) if context
    end

    #--------------------------------------------------------------------------
    def find_parent_object_for(model, context)
      return if context !~ /\d+$/
      parent, id = context.split("_")[-2, 2]
      model.attributes = { parent => parent.capitalize.constantize.find(id) }
    end

  end
end