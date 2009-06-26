class CreateObjectActivities < ActiveRecord::Migration
  def self.up
    create_table :object_activities do |t|
      t.string :username
      t.string :action
      t.string :uri
      t.string :tagname

      t.timestamps
    end
  end

  def self.down
    drop_table :object_activities
  end
end
