class CreateCachedDates < ActiveRecord::Migration
  def self.up
    create_table :cached_dates do |t|
      t.column :date, :string
      t.column :cached_document_id, :integer
    end
  end

  def self.down
    drop_table :cached_dates
  end
end
