class CreateGroupsUsers < ActiveRecord::Migration
  def self.up
    create_table :groups_users do |t|
      t.decimal :group_id
      t.decimal :user_id
      t.string :email
      t.string :role
      t.boolean :pending_invite
      t.boolean :pending_request

      t.timestamps
    end
  end

  def self.down
    drop_table :groups_users
  end
end
