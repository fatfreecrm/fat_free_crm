class ChangeSubscribedUsersToSet < ActiveRecord::Migration
  def up
    contacts = connection.select_all %Q{
      SELECT id, subscribed_users
      FROM contacts
      WHERE subscribed_users IS NOT NULL
    }
    
    puts "Converting #{contacts.size} subscribed_users arrays into sets..." unless contacts.empty?
    
    # Run as one atomic action.
    ActiveRecord::Base.transaction do
      for contact in contacts
        subscribed_users_set = Set.new(YAML.load(contact["subscribed_users"]))
      
        connection.execute %Q{
          UPDATE contacts
          SET subscribed_users = '#{subscribed_users_set.to_yaml}'
          WHERE id = #{contact["id"]}
        }
      end
    end
  end
end
