require 'rest-client'

class Typewright::OverviewsController < Admin::BaseController
	# GET /typewright/overviews
	# GET /typewright/overviews.json
	def index
		@view = params[:view] || 'docs'
		@status_filter = params[:status_filter]
		@filter = params[:filter]
		if @view == 'users'
		  @sort_order_class = { 'user'=>nil, 'edited'=>nil, 'modified'=>nil}
      @sort_order_class[ params[:sort] ] = "tw_#{params[:order]}"  
		else
		  @sort_order_class = { 'uri'=>nil, 'title'=>nil, 'percent'=>nil, 'modified'=>nil}
      if  !params[:sort].nil?
        @sort_order_class[ params[:sort] ] = "tw_#{params[:order]}"  
      end  
		end

		@typewright_overviews = Typewright::Overview.all(@view, params[:page], 20, params[:sort], params[:order], @filter, @status_filter)
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @typewright_overviews }
		end
	end

	# GET /typewright/overviews/1
	# GET /typewright/overviews/1.json
	def show
		# this gets the info for a particular user
		@typewright_overview = Typewright::Overview.find(params[:id])
		@typewright_overview[:user] = Typewright::User.get_author_native_rec(@typewright_overview['federation'], @typewright_overview['id'])

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @typewright_overview }
		end
	end

	def retrieve_doc
	  if !user_signed_in? || !is_admin?
	     render :text => "401 Unauthorized", :status => :unauthorized
	     return   
	  end 
	  token = params[:token]
	  if token.nil? || token.blank?
	     render :text => "401 Unauthorized", :status => :unauthorized
       return   
	  end
	  ts = token.to_i
	  tn = Time.now.to_i
	  if ts+30 < tn
	     render :text => "401 Unauthorized", :status => :unauthorized
       return      
	  end
	  
		tw_url = COLLEX_PLUGINS['typewright']['web_service_url']
		private_token = COLLEX_PLUGINS['typewright']['private_token']
		url = "#{tw_url}/documents/retrieve?uri=#{params[:uri]}&type=#{params[:type]}"
		begin
		   doc = RestClient.get url, :'x-auth-key' => private_token
		   final_fmt = "text/plain"
		   final_fmt = "text/xml" if params[:format] != "txt"
		   send_data doc, :type => final_fmt, :disposition => "inline"  
		rescue RestClient::Exception => rest_error
       puts rest_error.response
       render :text => rest_error.response, :status => rest_error.http_code
    rescue Exception => e
       puts e.to_s
       render :text => e, :status => :internal_server_error
    end
    
		cookies[:fileDownloadToken] = { :value => "#{token}", :expires => Time.now + 5}
	end
end
