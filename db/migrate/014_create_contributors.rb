class CreateContributors < ActiveRecord::Migration
  def self.up
    create_table :contributors do |t|
      t.column :archive_name,	:string, :null => false
      t.column :email,			:string, :null => false
      t.column :contact,		:string, :null => false
    end
  end

  def self.down
  	drop_table :contributors
  end
end
