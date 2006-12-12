class RenameErrorsProcessId < ActiveRecord::Migration
  def self.up
  	rename_column :errors, :process_id, :task_id
  end

  def self.down
  	rename_column :errors, :task_id, :process_id
  end
end
