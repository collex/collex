# encoding: UTF-8
class Typewright::Overview
	def self.call_web_service(url, format)
		private_token = COLLEX_PLUGINS['typewright']['private_token']
		resp = `curl "#{COLLEX_PLUGINS['typewright']['web_service_url']}/#{url}&private_token=#{private_token}"`
		return resp if format == :xml
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

  def self.all(view, page, page_size, sort_by, sort_order, filter, status_filter)
    page ||= 1
    p = [ 
      "view=#{view}",
      "page=#{page}",
      "page_size=#{page_size}",
      "sort=#{sort_by}",
      "order=#{sort_order}",
      "filter=#{filter}",
      "status_filter=#{status_filter}"
    ]

    resp = self.call_web_service("documents/corrections?#{p.join('&')}", :json)
    if resp.blank?
      resp = []
      total = 0
    else
      total = resp['total']
      resp = resp['results']
      resp.each { |rec|
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
		resp = self.call_web_service("users/#{user_id}/corrections?federation=#{Setup.default_federation()}", :json)
		return {} if resp.blank?

    latest_corr = nil
    if resp['documents'].present?
  		resp['documents'].each do |doc|
  		  if doc['most_recent_correction'].present?
  		     doc['most_recent_correction'] = Time.parse( doc['most_recent_correction']  )
  			   if latest_corr.nil?
  			     latest_corr = doc['most_recent_correction'] 
  			   else
  			     latest_corr = doc['most_recent_correction'] if doc['most_recent_correction'] > latest_corr
  			   end
  			end
  		end
    end
		resp['most_recent_correction'] = latest_corr if !latest_corr.nil?
		return resp
	end

	def self.retrieve_doc(uri, type)
		resp = self.call_web_service("documents/retrieve?uri=#{uri}&type=#{type}", :xml)
		return resp
	end

	def self.unload_doc(token)
		resp = self.call_web_service("documents/unload?token=#{URI.escape(token)}", :xml)
		return resp
	end
end
