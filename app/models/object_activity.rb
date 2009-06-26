class ObjectActivity < ActiveRecord::Base
	def self.record_collect(user, uri)
		ObjectActivity.create({ :username => user.username, :action => 'collect', :uri => uri, :tagname => nil })
	end

	def self.record_uncollect(user, uri)
		ObjectActivity.create({ :username => user.username, :action => 'uncollect', :uri => uri, :tagname => nil })
	end

	def self.record_tag(user, uri, tag)
		ObjectActivity.create({ :username => user.username, :action => 'tag', :uri => uri, :tagname => tag })
	end

	def self.record_untag(user, uri, tag)
		ObjectActivity.create({ :username => user.username, :action => 'untag', :uri => uri, :tagname => tag })
	end

	def self.get_stats()
		day = 1.day.ago
		week = 1.week.ago
		month = 30.days.ago
		year = 1.year.ago
		objects_collected_today = self.num_recs('collect', day)
		objects_collected_this_week = self.num_recs('collect', week)
		objects_collected_this_month = self.num_recs('collect', month)
		objects_collected_this_year = self.num_recs('collect', year)
		objects_tagged_today = self.num_recs('tag', day)
		objects_tagged_this_week = self.num_recs('tag', week)
		objects_tagged_this_month = self.num_recs('tag', month)
		objects_tagged_this_year = self.num_recs('tag', year)
		num_users_with_tags = self.get_num_uniq_users('tag')
		ave_num_tags_per_user = num_users_with_tags > 0 ? self.get_total('tag') / num_users_with_tags : 0
		num_users_with_collect = self.get_num_uniq_users('collect')
		ave_num_collect_per_user = num_users_with_collect > 0 ? self.get_total('collect') / num_users_with_collect : 0

		return { :objects_collected_today => objects_collected_today, :objects_collected_this_week => objects_collected_this_week,
			:objects_collected_this_month => objects_collected_this_month, :objects_collected_this_year => objects_collected_this_year,
			:objects_tagged_today => objects_tagged_today, :objects_tagged_this_week => objects_tagged_this_week,
			:objects_tagged_this_month => objects_tagged_this_month, :objects_tagged_this_year => objects_tagged_this_year,

			:num_users_with_tags => num_users_with_tags, :ave_num_tags_per_user => ave_num_tags_per_user,
			:num_users_with_collect => num_users_with_collect, :ave_num_collect_per_user => ave_num_collect_per_user
		}
	end

	private
	def self.num_recs(action, period)
		recs = ObjectActivity.all(:conditions => [ 'action = ? AND updated_at > ?', action,  period])
		return recs.length
	end

	def self.get_num_uniq_users(action)
		recs = ObjectActivity.all(:conditions => [ 'action = ?', action])
		results = {}
		recs.each { |rec| results[rec.username] = true }
		return results.length
	end

	def self.get_total(action)
		recs = ObjectActivity.all(:conditions => [ 'action = ?', action])
		return recs.length
	end
end
