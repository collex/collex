class ChangeSetupValueToText < ActiveRecord::Migration
  def up
	  change_column :setups, :value, :text
  end

  def down
	  change_column :setups, :value, :string
  end
end
