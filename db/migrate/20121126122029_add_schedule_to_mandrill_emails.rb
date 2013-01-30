class AddScheduleToMandrillEmails < ActiveRecord::Migration
  def up
    change_table :mandrill_emails do |t|
      t.boolean :scheduled, :default => false
      t.datetime :scheduled_at
      t.string :delayed_job_id
      t.string :response
    end
  end
  
  def down
    remove_columns :mandrill_emails, :scheduled, :scheduled_at, :delayed_job_id, :response
  end
end
