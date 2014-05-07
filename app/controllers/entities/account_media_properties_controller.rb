class AccountMediaPropertiesController < EntitiesController
  def index
    
  end
  
  def show
    
  end
  
  def new
    @account_media_property.attributes = {:account_id => current_user.id, :access => Setting.default_access, :assigned_to => nil}
    @account = Account.new(:user => current_user)

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end
    
    respond_with(@account_media_property)
  end
  
  def edit
    
  end
  
  def create
    respond_with(@account_media_property) do |format|
      @account_media_property.account_id = current_user.id
      @account_media_property.save(params)
    end
  end
  
  def update
    
  end
  
  def destroy
    @account_media_property.destroy

    respond_with(@account_media_property) do |format|
      format.html
      format.js
    end
  end
  
end