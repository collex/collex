class CreateCommentReports < ActiveRecord::Migration
  def self.up
    create_table :comment_reports do |t|
      t.integer :discussion_comment_id
      t.string :reason
      t.integer :reporter_id
      t.datetime :reported_on
    end
  end

  def self.down
    drop_table :comment_reports
  end
end
