class ChangeFurtherSubscribedUsersToSet < ActiveRecord::Migration
  def up
    # Change the other tables that were missing from the previous migration
    %w(campaigns opportunities leads tasks accounts).each do |table|
      entities = connection.select_all %Q{
        SELECT id, subscribed_users
        FROM #{table}
        WHERE subscribed_users IS NOT NULL
      }
      
      puts "#{table}: Converting #{entities.size} subscribed_users arrays into sets..." unless entities.empty?
      
      # Run as one atomic action.
      ActiveRecord::Base.transaction do
        for entity in entities
          subscribed_users_set = Set.new(YAML.load(entity["subscribed_users"]))
          
          connection.execute %Q{
            UPDATE #{table}
            SET subscribed_users = '#{subscribed_users_set.to_yaml}'
            WHERE id = #{entity["id"]}
          }
        end
      end
    end
  end
end
