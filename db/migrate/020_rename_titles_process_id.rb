class RenameTitlesProcessId < ActiveRecord::Migration
  def self.up
  	rename_column :titles, :process_id, :task_id
  end

  def self.down
  	rename_column :titles, :task_id, :process_id
  end
end
