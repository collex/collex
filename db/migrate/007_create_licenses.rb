class CreateLicenses < ActiveRecord::Migration
  class License < ActiveRecord::Base; end
  
  def self.up
    create_table :licenses do |t|
      t.column :description, :string
    end
    
    License.create(:description=>"Creative Commons: Attribution (version 2.5)")
    License.create(:description=>"Creative Commons: Attribution-NonCommercial (version 2.5)")
  end

  def self.down
    drop_table :licenses
  end
end
