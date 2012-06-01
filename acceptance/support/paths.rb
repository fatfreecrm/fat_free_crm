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
end

RSpec.configuration.include NavigationHelpers, :type => :acceptance