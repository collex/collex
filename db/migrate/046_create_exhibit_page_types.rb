class CreateExhibitPageTypes < ActiveRecord::Migration
  def self.up
    create_table :exhibit_page_types do |t|
      t.column :name,                 :string
      t.column :description,          :string
      t.column :template,             :string
      t.column :min_sections,         :integer
      t.column :max_sections,         :integer
      t.column :exhibit_type_id,      :integer
    end
  end

  def self.down
    drop_table :exhibit_page_types
  end
end
