class CreateIsoLanguages < ActiveRecord::Migration
  def change
    create_table :iso_languages do |t|
      t.string :alpha3, :unique => true
      t.string :alpha2, :unique => true, :null => true
      t.string :english_name

      t.timestamps
    end
  end
end
