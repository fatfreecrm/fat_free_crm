class ChangeFurtherSubscribedUsersToSet < ActiveRecord::Migration
  def up
    # Change the other tables that were missing from the previous migration
    %w(campaigns opportunities leads tasks accounts).each do |table|
      entities = connection.select_all %Q{
        SELECT id, subscribed_users
        FROM #{table}
        WHERE subscribed_users IS NOT NULL
      }

      sql = entities.map do |entity|
        subscribed_users_set = Set.new(YAML.load(entity["subscribed_users"]))
        %Q{
          UPDATE #{table}
          SET subscribed_users = '#{subscribed_users_set.to_yaml}'
          WHERE id = #{entity["id"]}
        }
      end

      if sql.any?
        puts "#{table}: Converting #{entities.size} subscribed_users arrays into sets..."
        connection.execute sql.join(";")
      end
    end
  end
end
