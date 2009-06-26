class CreateLoginInfos < ActiveRecord::Migration
  def self.up
    create_table :login_infos do |t|
      t.string :username
      t.string :address
      t.string :action

      t.timestamps
    end
  end

  def self.down
    drop_table :login_infos
  end
end
