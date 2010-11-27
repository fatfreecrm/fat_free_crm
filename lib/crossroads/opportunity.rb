Opportunity.class_eval do
  # Opportunity names are displayed as '#1234 Opportunity Name'
  def name; super; end
  def name_with_id
    if self.new_record?
      name_without_id
    else
      "##{id} #{name_without_id}" unless name_without_id.blank?
    end
  end
  alias_method_chain :name, :id
end
