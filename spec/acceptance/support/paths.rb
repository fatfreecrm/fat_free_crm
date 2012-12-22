module NavigationHelpers
  # Put helper methods related to the paths in your application here.

  def homepage
    "/"
  end

  def accounts_page
    accounts_path
  end

  def leads_page
    leads_path
  end

  def opportunities_page
    opportunities_path
  end

  def contacts_page
    contacts_path
  end

  def campaigns_page
    campaigns_path
  end

  def tasks_page
    tasks_path
  end
  
  def groups_page
    admin_groups_path
  end
  
  def opportunity_overview_page
    opportunities_overview_users_path
  end
  
end

RSpec.configuration.include NavigationHelpers, :type => :request
