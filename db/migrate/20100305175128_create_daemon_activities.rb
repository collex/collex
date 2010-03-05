class CreateDaemonActivities < ActiveRecord::Migration
  def self.up
    create_table :daemon_activities do |t|
      t.string :name
      t.datetime :last_wake_up
      t.datetime :last_activity
      t.datetime :started_at
      t.datetime :ended_at
      t.text :last_message

      t.timestamps
    end
  end

  def self.down
    drop_table :daemon_activities
  end
end
