class AddSubscribedUsersToContactGroups < ActiveRecord::Migration
  def change
    #%w(contact_groups).each do |table|
      add_column :contact_groups, :subscribed_users, :text
      # Reset the column information of each model
      ContactGroup.reset_column_information
    #end

    entity_subscribers = Hash.new(Set.new)

    # Add comment's user to the entity's Set
    Comment.all.each do |comment|
      entity_subscribers[[comment.commentable_type, comment.commentable_id]] += [comment.user_id]
    end

    # Run as one atomic action.
    ActiveRecord::Base.transaction do
      entity_subscribers.each do |entity, user_ids|
        connection.execute "UPDATE #{entity[0].tableize} SET subscribed_users = '#{user_ids.to_a.to_yaml}' WHERE id = #{entity[1]}"
      end
    end
  end
end
