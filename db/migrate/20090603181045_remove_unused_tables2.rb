class RemoveUnusedTables2 < ActiveRecord::Migration
  def self.up
   #drop_table :exhibit_page_types
   #drop_table :exhibit_section_types
   #drop_table :exhibit_section_types_exhibit_types
   #drop_table :exhibit_types
   drop_table :exhibit_sections
   #drop_table :exhibited_pages
   #drop_table :exhibited_properties
   #drop_table :exhibited_sections
   #drop_table :exhibited_items

   drop_table :old_exhibit_page_types
   drop_table :old_exhibit_section_types
   drop_table :old_exhibit_section_types_exhibit_types
   drop_table :old_exhibit_types
   drop_table :old_exhibited_items
   drop_table :old_exhibited_pages
   drop_table :old_exhibited_properties
   drop_table :old_exhibited_sections
   drop_table :old_exhibits

   drop_table :licenses
  end

  def self.down
    create_table :exhibit_page_types do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :template, :string
      t.column :min_sections,  :integer
      t.column :max_sections,  :integer
      t.column :exhibit_type_id,  :integer
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :exhibit_section_types do |t|
      t.column :description, :string
      t.column :template, :string
      t.column :name, :string
      t.column :exhibit_page_type_id,  :integer
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :exhibit_section_types_exhibit_types, :id => false do |t|
      t.column :exhibit_type_id,  :integer
      t.column :exhibit_section_type_id,  :integer
    end
  
    create_table :exhibit_types do |t|
      t.column :description, :string
      t.text   :template
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :exhibit_sections do |t|
      t.column :exhibit_page_id,  :integer
      t.column :position,  :integer
      t.column :has_border,  :integer
      t.timestamps
    end

    create_table :exhibited_pages do |t|
      t.column :exhibit_id,  :integer
      t.column :exhibit_page_type_id,  :integer
      t.column :position,  :integer
      t.column :title, :string
      t.text    :annotation
    end
  
    create_table :exhibited_properties do |t|
      t.column :exhibited_resource_id,  :integer
      t.column :name, :string
      t.column :value, :string
    end
  
    create_table :exhibited_sections do |t|
      t.column :exhibited_page_id,  :integer
      t.column :exhibit_section_type_id,  :integer
      t.column :position,  :integer
      t.column :title, :string
      t.text    :annotation
    end
  
    create_table :exhibited_items do |t|
      t.integer :exhibited_section_id
      t.string  :citation
      t.text    :annotation
      t.integer :position
      t.string  :uri
      t.string  :type
    end
  
    create_table :old_exhibit_page_types do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :template, :string
      t.column :min_sections,  :integer
      t.column :max_sections,  :integer
      t.column :exhibit_type_id,  :integer
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :old_exhibit_section_types do |t|
      t.column :description, :string
      t.column :template, :string
      t.column :name, :string
      t.column :exhibit_page_type_id,  :integer
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :old_exhibit_section_types_exhibit_types do |t|
      t.column :exhibit_type_id,  :integer
      t.column :exhibit_section_type_id,  :integer
    end
  
    create_table :old_exhibit_types do |t|
      t.column :description, :string
      t.text   :template
      t.column :title_message, :string
      t.column :annotation_message, :string
    end
  
    create_table :old_exhibited_items do |t|
      t.column :exhibited_section_id,  :integer
      t.column :citation, :string
      t.text    :annotation
      t.column :position,  :integer
      t.column :uri, :string
      t.column :type, :string
    end
  
    create_table :old_exhibited_pages do |t|
      t.column :exhibit_id,  :integer
      t.column :exhibit_page_type_id,  :integer
      t.column :position,  :integer
      t.column :title, :string
      t.text    :annotation
    end
  
    create_table :old_exhibited_properties do |t|
      t.column :exhibited_resource_id,  :integer
      t.column :name, :string
      t.column :value, :string
    end
  
    create_table :old_exhibited_sections do |t|
      t.column :exhibited_page_id,  :integer
      t.column :exhibit_section_type_id,  :integer
      t.column :position,  :integer
      t.column :title, :string
      t.text    :annotation
    end
  
    create_table :old_exhibits do |t|
      t.column :user_id,  :integer
      t.column :license_id,  :integer
      t.column :title, :string
      t.column :exhibit_type_id,  :integer
      t.text    :annotation
      t.boolean :shared
      t.boolean :published
      t.column :uri, :string
      t.column :thumbnail, :string
    end
  
    create_table :licenses do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :button_url, :string
    end
  
  end
end
