class RedoLicenseTableForCreativeCommons < ActiveRecord::Migration
  def self.up
    drop_table :licenses
    create_table :licenses do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :button_url, :string
    end
  end

  def self.down
    drop_table   :licenses
    create_table :licenses do |t|
      t.column :description, :string
    end
    
    License.create(:description=>"Creative Commons: Attribution (version 2.5)")
    License.create(:description=>"Creative Commons: Attribution-NonCommercial (version 2.5)")
  end
end
