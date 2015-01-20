class ActivitiesToVersions < ActiveRecord::Migration
  def up
    events = {
      'created'     => 'create',
      'viewed'      => 'view',
      'updated'     => 'update',
      'deleted'     => 'destroy',
      'rejected'    => 'reject',
      'won'         => 'won',
      'completed'   => 'complete',
      'reassigned'  => 'reassign',
      'rescheduled' => 'reschedule'
    }

    activities = connection.select_all 'SELECT * FROM activities'
    activities.each do |activity|
      # commented and email activities don't translate well so ignore them
      if event = events[activity['action']]
        attributes = {
          item_id: activity['subject_id'],
          item_type: activity['subject_type'],
          whodunnit: activity['user_id'],
          event: event,
          created_at: activity['created_at']
        }
        version = Version.new
        attributes.each { |k, v| version.send("#{k}=", v) }
        version.save!
      end
    end
  end

  def down
  end
end
