module FatFreeCRM
  module InlineForms
    
    private
    #--------------------------------------------------------------------------
    def make_new_account(context = nil)
      @account = Account.new
      @users = User.all_except(@current_user)
      find_related_asset_for(@account, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def make_new_campaign(context = nil)
      @campaign = Campaign.new
      @users = User.all_except(@current_user)
      find_related_asset_for(@campaign, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def make_new_contact(context = nil)
      @contact = Contact.new(:user => @current_user, :access => "Private")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
      find_related_asset_for(@contact, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def make_new_lead(context = nil)
      @lead = Lead.new
      @users = User.all_except(@current_user)
      @campaigns = Campaign.my(@current_user).all(:order => "name")
      find_related_asset_for(@lead, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def make_new_opportunity(context = nil)
      @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
      @users = User.all_except(@current_user)
      @account = Account.new(:user => @current_user, :access => "Private")
      @accounts = Account.my(@current_user).all(:order => "name")
      find_related_asset_for(@opportunity, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def make_new_task(context = nil)
      @task = Task.new
      @users = User.all_except(@current_user)
      @due_at_hint = Setting.task_due_at_hint[1..-1] << [ "On Specific Date...", :specific_time ]
      @category = Setting.task_category.invert.sort
      find_related_asset_for(@task, context) if context =~ /\d+$/
    end

    #--------------------------------------------------------------------------
    def find_related_asset_for(model, context)
      parent, id = context.split("_")[-2, 2]
      if parent.pluralize != parent
        # One-to-one or one-to-many -- assign found object instance to the model.
        model.send("#{parent}=", @asset = parent.capitalize.constantize.find(id))
      else
        # Many-to-many -- find the instance but don't assign it.
        parent = parent.singularize
        @asset = parent.capitalize.constantize.find(id)
      end
      instance_variable_set("@#{parent}", @asset)
    end

  end
end