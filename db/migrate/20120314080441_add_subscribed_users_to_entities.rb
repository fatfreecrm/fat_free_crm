class AddSubscribedUsersToEntities < ActiveRecord::Migration
  def change
    %w(accounts campaigns contacts leads opportunities).each do |table|
      add_column table.to_sym, :subscribed_users, :text
      # Reset the column information of each model
      table.singularize.capitalize.constantize.reset_column_information
    end

    Comment.all.each do |comment|
      entity = comment.commentable
      subscribed_users = (entity.subscribed_users + [comment.user.id]).uniq
      entity.update_attribute :subscribed_users, subscribed_users
    end

  end
end
