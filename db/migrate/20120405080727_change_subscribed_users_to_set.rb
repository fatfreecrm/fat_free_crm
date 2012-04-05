class ChangeSubscribedUsersToSet < ActiveRecord::Migration
  def up
    contacts = connection.select_all %Q{
      SELECT id, subscribed_users
      FROM contacts
      WHERE subscribed_users IS NOT NULL
    }

    sql = contacts.map do |contact|
      subscribed_users_set = Set.new(YAML.load(contact["subscribed_users"]))
      %Q{
        UPDATE contacts
        SET subscribed_users = '#{subscribed_users_set.to_yaml}'
        WHERE id = #{contact["id"]}
      }
    end

    if sql.any?
      puts "Converting #{contacts.size} subscribed_users arrays into sets..."
      connection.execute sql.join(";")
    end
  end
end
