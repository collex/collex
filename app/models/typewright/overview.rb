class Typewright::Overview
	def self.call_web_service(url)
		private_token = COLLEX_PLUGINS['typewright']['private_token']
		resp = `curl "#{COLLEX_PLUGINS['typewright']['web_service_url']}/#{url}&private_token=#{private_token}"`
		if resp.blank?
			ActiveRecord::Base.logger.info "**** TYPEWRIGHT ERROR: No response from Typewright webservice [Typewright::Overview::all]"
			return nil
		end
		begin
			resp = JSON.parse(resp)
		rescue
			ActiveRecord::Base.logger.info "**** TYPEWRIGHT ERROR: Non-JSON returned. Check Typewright server for error. [Typewright::Overview::all]"
			return nil
		end
		if resp.kind_of?(Hash) && resp['message'].present?
			ActiveRecord::Base.logger.info "**** TYPEWRIGHT ERROR: #{resp['message']} [Typewright::Overview::all]"
			return nil
		end
		return resp
	end

	def self.all(view, page, page_size, sort_by, filter)
		page ||= 1
		p = [ "view=#{view}",
			"page=#{page}",
			"page_size=#{page_size}",
			"sort=#{sort_by}",
			"filter=#{filter}"
		]

		resp = self.call_web_service("documents/corrections?#{p.join('&')}")
		if resp.blank?
			resp = []
			total = 0
		else
			total = resp['total']
			resp = resp['results']
			resp.each { |rec|
				if view == 'users'
				else
					rec['percent_corrected'] = (1.0 * rec['pages_with_changes']) / rec['total_pages']
				end
				rec['most_recent_correction'] = Time.parse(rec['most_recent_correction'])
			}
		end
		resp = WillPaginate::Collection.create(page, page_size) do |pager|
			pager.replace(resp)
			pager.total_entries = total
		end
		return resp
	end

	def self.find(user_id)
		resp = self.call_web_service("users/#{user_id}/corrections?federation=#{Setup.default_federation()}")
		return [] if resp.blank?
		resp['most_recent_correction'] = Time.parse(resp['most_recent_correction'])
		return resp
	end
end
