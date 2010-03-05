class DaemonActivity < ActiveRecord::Base
	def self.log_activity(name, status)
		if (status[:activity])
			DaemonActivity.update_activity(name, status[:message])
		else
			DaemonActivity.update_wakeup(name)
		end
	end

	def self.started(name)
		now = Time.now
		ActiveRecord::Base.logger.info "---- Started #{name} at #{now}.\n"
		rec = DaemonActivity.find_by_name(name)
		if rec
			rec.update_attributes({ :started_at => now })
		else
			DaemonActivity.create({ :name => name, :started_at => now })
		end
	end

	def self.ended(name)
		now = Time.now
		ActiveRecord::Base.logger.info "---- Ended #{name} at #{now}.\n"
		rec = DaemonActivity.find_by_name(name)
		if rec
			rec.update_attributes({ :ended_at => now })
		else
			DaemonActivity.create({ :name => name, :ended_at => now })
		end
	end

	private
	def self.update_wakeup(name)
		now = Time.now
		ActiveRecord::Base.logger.info "Daemon #{name} woke up at #{Time.now}.\n"
		rec = DaemonActivity.find_by_name(name)
		if rec
			rec.update_attributes({ :last_wake_up => now })
		else
			DaemonActivity.create({ :name => name, :last_wake_up => now })
		end
	end
	
	def self.update_activity(name, message)
		now = Time.now
		ActiveRecord::Base.logger.info "Daemon #{name} did work at #{Time.now}.\n"
		rec = DaemonActivity.find_by_name(name)
		if rec
			rec.update_attributes({ :last_activity => now, :last_message => message })
		else
			DaemonActivity.create({ :name => name, :last_activity => now, :last_message => message })
		end
	end
end
