# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120314080441)

class AddSubscribedUsersToEntities < ActiveRecord::Migration[4.2]
  def change
    %w[accounts campaigns contacts leads opportunities tasks].each do |table|
      add_column "fat_free_crm_#{table}".to_sym, :subscribed_users, :text
      # Reset the column information of each model
      "FatFreeCrm::#{table.singularize.capitalize}".constantize.reset_column_information
    end

    entity_subscribers = Hash.new(Set.new)

    # Add comment's user to the entity's Set
    FatFreeCrm::Comment.all.each do |comment|
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
