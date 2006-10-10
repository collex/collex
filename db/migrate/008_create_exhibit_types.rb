class CreateExhibitTypes < ActiveRecord::Migration
  def self.up
    create_table :exhibit_types do |t|
      t.column :description, :string
    end
    
    ExhibitType.create(:description=>"Course syllabus or annotated bibliography")
  end

  def self.down
    drop_table :exhibit_types
  end
end
