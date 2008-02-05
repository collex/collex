class CreateCachedAgents < ActiveRecord::Migration
  def self.up
    create_table :cached_agents do |t|
      t.column :name, :string
      t.column :agent_type_id, :integer
      t.column :cached_document_id, :integer
    end
  end

  def self.down
    drop_table :cached_agents
  end
end
