class AddSubscribedUsersToEntities < ActiveRecord::Migration
  def change
    %w(accounts campaigns contacts leads opportunities tasks).each do |table|
      add_column table.to_sym, :subscribed_users, :text
      # Reset the column information of each model
      table.singularize.capitalize.constantize.reset_column_information
    end

    Comment.all.each do |comment|
      if (entity = comment.commentable) && (user = comment.user)
        subscribed_users = (entity.subscribed_users + [user.id]).uniq
        unless entity.subscribed_users == subscribed_users
          entity.update_attribute :subscribed_users, subscribed_users
        end
      end
    end

  end
end
