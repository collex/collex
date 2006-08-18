class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => false do |t|
      t.column :username, :string
      t.column :password_hash, :string
      t.column :fullname, :string
      t.column :email, :string
    end
  end

  def self.down
    drop_table :users
  end
end
