class CreateTasks < ActiveRecord::Migration
  def self.up
  	create_table :tasks do |t|
  	  t.column :archive_name,	:string, :null => false
  	  t.column :file_name, 		:string, :null => false
  	  end
  end

  def self.down
 	drop_table :tasks
  end
end
