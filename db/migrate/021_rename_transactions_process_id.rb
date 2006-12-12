class RenameTransactionsProcessId < ActiveRecord::Migration
  def self.up
  	rename_column :transactions, :process_id, :task_id
  end

  def self.down
  	rename_column :transactions, :task_id, :process_id
  end
end
