class AddObjTypeToSearchUserContent < ActiveRecord::Migration
	def self.up
		add_column :search_user_contents, :obj_type, :string
		change_column :search_user_contents, :seconds_spent_indexing, :decimal, {precision: 10, scale: 3}
	end

	def self.down
		remove_column :search_user_contents, :obj_type
	end
end
