class ChangeFieldToFieldxInConstraints < ActiveRecord::Migration
  def self.up
	rename_column :constraints, :field, :fieldx
  end

  def self.down
	rename_column :constraints, :fieldx, :field
  end
end
