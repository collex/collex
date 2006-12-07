class CreateTitles < ActiveRecord::Migration
  def self.up
  	create_table :titles do |t|
  	  t.column :title,			:string,	:null => false
  	  t.column :link, 			:string,	:null => false
  	  t.column :date_time,		:datetime,	:null => false
  	  t.column :xml,			:text, 		:null => false
  	  t.column :uri,			:string,	:null => false
	  t.column :process_id, 	:integer,	:null => false
  	  t.column :archive_name,	:string, 	:null => false
  	  end
  end

  def self.down
  	drop_table :titles
  end
end
