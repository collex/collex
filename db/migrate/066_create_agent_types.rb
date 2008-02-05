class CreateAgentTypes < ActiveRecord::Migration
  def self.up
    create_table :agent_types do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :agent_types
  end
end
