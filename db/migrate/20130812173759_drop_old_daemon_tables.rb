class DropOldDaemonTables < ActiveRecord::Migration
   def self.down
    create_table :email_waitings do |t|
      t.string :to_email
      t.string :subject
      t.text :body
      t.timestamps
    end
    
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

  def self.up
    drop_table :daemon_activities
    drop_table :email_waitings
  end
end
