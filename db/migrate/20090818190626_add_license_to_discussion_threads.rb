class AddLicenseToDiscussionThreads < ActiveRecord::Migration
  def self.up
    add_column :discussion_threads, :license, :decimal

		threads = DiscussionThread.all()
		threads.each { |thread|
			thread.license = 5
			thread.save
		}
  end

  def self.down
    remove_column :discussion_threads, :license
  end
end
