class CreateErrors < ActiveRecord::Migration
  def self.up
  	create_table :errors do |t|
  	  t.column :process_id,	:integer,	:null => false
  	  t.column :item, 		:string, 	:null => false			  
  	  t.column :uri,		:string, 	:null => false
  	  t.column :stamp,		:datetime,	:null => false
  	  end
  end

  def self.down
  	drop_table :errors
  end
end
