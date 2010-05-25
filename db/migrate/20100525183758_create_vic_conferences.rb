class CreateVicConferences < ActiveRecord::Migration
  def self.up
    create_table :vic_conferences do |t|
      t.string :price
      t.string :first_name
      t.string :last_name
      t.string :university
      t.string :phone
      t.string :email
      t.string :title
      t.text :accessibility
      t.text :audio_visual
      t.string :rare_book_school_1
      t.string :rare_book_school_2
      t.string :lunch_friday
      t.string :lunch_saturday
      t.string :lunch_vegetarian
      t.string :parking
      t.string :transaction_id
      t.string :amt_paid
      t.string :auth_status
      t.string :auth_code
      t.string :avs_code
      t.text :error_txt

      t.timestamps
    end
  end

  def self.down
    drop_table :vic_conferences
  end
end
