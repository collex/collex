class CreateEmailWaitings < ActiveRecord::Migration
  def self.up
    create_table :email_waitings do |t|
      t.string :to_email
      t.string :subject
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :email_waitings
  end
end
