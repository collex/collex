class CreateTransactions < ActiveRecord::Migration
  def self.up
  	create_table :transactions do |t|
  	  t.column :process_id,	:integer,	:null => false
  	  t.column :item, 		:string, 	:null => false
  	  t.column :uri,		:string, 	:null => false
  	  t.column :stamp,		:datetime,	:null => false
  	  end
  end

  def self.down
  	drop_table :transactions
  end
end
