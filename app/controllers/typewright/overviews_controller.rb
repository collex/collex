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
		doc = Typewright::Overview.retrieve_doc(params[:uri], params[:type])
	  token = params[:token]
		respond_to do |format|
			format.txt { render :text => doc }
			format.xml  { render :text => doc }
		end
		cookies[:fileDownloadToken] = { :value => "#{token}", :expires => Time.now + 5}
	end
end
