class DropLogs < ActiveRecord::Migration
  def self.up
	  drop_table :logs
  end

  def self.down
    create_table :logs do |t|
      t.string :user
      t.string :request_method
      t.text :request_uri
      t.text :http_referer
      t.text :params

      t.timestamps
	end
  end
end
