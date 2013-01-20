class ChangeContactContactGroupsToMemberships < ActiveRecord::Migration
  def up
    rename_table :contact_groups_contacts, :memberships
    add_column :memberships, :id, :primary_key
    add_column :memberships, :deleted_at, :datetime
    add_column :memberships, :created_at, :datetime
    add_column :memberships, :updated_at, :datetime
    
    Membership.all.each do |m|
      m.created_at = Time.now
      m.save!
    end

  end

  def down
    remove_columns :memberships, :id, :deleted_at, :created_at, :updated_at
    rename_table :memberships, :contact_groups_contacts
  end
end
