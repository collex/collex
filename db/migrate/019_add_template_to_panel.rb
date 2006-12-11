class AddTemplateToPanel < ActiveRecord::Migration
  def self.up
    add_column :panel_types, :template, :text
  end

  def self.down
    remove_column :panel_types, :template
  end
end
