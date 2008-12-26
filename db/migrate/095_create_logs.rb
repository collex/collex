class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :user
      t.string :request_method
      t.text :request_uri
      t.text :http_referer
      t.text :params

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
