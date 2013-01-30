class AddCommentFieldsToAttendances < ActiveRecord::Migration
  def change
    change_table :attendances do |t|
      t.text :subscribed_users
      t.boolean :rsvp
      t.boolean :attended
      t.datetime    :deleted_at
      t.timestamps
    end
  end
end
