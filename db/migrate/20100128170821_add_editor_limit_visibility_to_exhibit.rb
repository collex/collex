class AddEditorLimitVisibilityToExhibit < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :editor_limit_visibility, :string
		groups = Group.all()
		groups.each { |group|
			if group.exhibit_visibility == 'open'
				group.exhibit_visibility = 'www'
			else
				group.exhibit_visibility = 'group'
			end
			group.save
		}
  end

  def self.down
    remove_column :exhibits, :editor_limit_visibility
  end
end
