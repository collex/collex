class CreateApprovalsTable < ActiveRecord::Migration
  def self.up
  	create_table :approvals do |t|
	  t.column :task_id, 		:integer,	:null => false
  	  t.column :uri,			:string,	:null => false
  	  t.column :xml,			:text, 		:null => false
  	  end
  end

  def self.down
  	drop_table :approvals
  end
end