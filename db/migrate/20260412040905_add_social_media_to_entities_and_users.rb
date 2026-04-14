class AddSocialMediaToEntitiesAndUsers < ActiveRecord::Migration[7.1]
  def change
    %i[contacts leads].each do |table|
      change_table table do |t|
        t.string :zoom, limit: 128
        t.string :teams, limit: 128
        t.string :signal, limit: 128
        t.string :instagram, limit: 128
        t.string :mastodon, limit: 128
        t.string :bluesky, limit: 128
      end
    end

    change_table :users do |t|
      t.string :zoom, limit: 128
      t.string :teams, limit: 128
      t.string :signal, limit: 128
      t.string :instagram, limit: 128
      t.string :facebook, limit: 128
      t.string :mastodon, limit: 128
      t.string :bluesky, limit: 128
    end
  end
end
