class CreateDiscussionVisits < ActiveRecord::Migration
  def self.up
    create_table :discussion_visits do |t|
      t.integer :user_id
      t.integer :discussion_thread_id
      t.datetime :last_visit

      t.timestamps
    end
  end

  def self.down
    drop_table :discussion_visits
  end
end

