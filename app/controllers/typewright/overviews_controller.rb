class Typewright::OverviewsController < Admin::BaseController
	# GET /typewright/overviews
	# GET /typewright/overviews.json
	def index
		@view = params[:view] || 'docs'
		
		# need local filter because @filter is used to display the filter string
		# in the input box on the admin page. The users view changes the text
		# into a comma separated list of matching user ids and it would be bad
		# id this is the info that shows up in the box after filtering.
		@filter = params[:filter]
		local_filter = @filter  
		if @view == 'users'
      if !@filter.nil?	&& !@filter.blank?     	
		    resp =  ::User.find_by_sql( ["select id from users where username like ?", "%#{@filter}%"] )
		    local_filter = ""
		    resp.each do |usr|
		      if local_filter.length > 0
		        local_filter << ","
		      end  
		      local_filter << usr.id.to_s
		    end
		  end
		  @sort_order_class = { 'user'=>nil, 'edited'=>nil, 'modified'=>nil}
      @sort_order_class[ params[:sort] ] = "tw_#{params[:order]}"  
		else
		  @sort_order_class = { 'uri'=>nil, 'title'=>nil, 'percent'=>nil, 'modified'=>nil}
      if  !params[:sort].nil?
        @sort_order_class[ params[:sort] ] = "tw_#{params[:order]}"  
      end  
		end

		@typewright_overviews = Typewright::Overview.all(@view, params[:page], 20, params[:sort], params[:order], local_filter)
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
		@typewright_overview['documents'].each { |document|
			resource = CachedResource.get_hit_from_uri(document['id'])
			document['title'] = resource['title'] if resource.present?
		}

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @typewright_overview }
		end
	end

	def retrieve_doc
		doc = Typewright::Overview.retrieve_doc(params[:uri], params[:type])
		respond_to do |format|
			format.txt { render :text => doc }
			format.xml  { render :text => doc }
		end
	end

  # GET /typewright/overviews/new
  ## GET /typewright/overviews/new.json
  #def new
  #  @typewright_overview = Typewright::Overview.new
  #
  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render json: @typewright_overview }
  #  end
  #end

  # GET /typewright/overviews/1/edit
  #def edit
  #  @typewright_overview = Typewright::Overview.find(params[:id])
  #end

  # POST /typewright/overviews
  # POST /typewright/overviews.json
  #def create
  #  @typewright_overview = Typewright::Overview.new(params[:typewright_overview])
  #
  #  respond_to do |format|
  #    if @typewright_overview.save
  #      format.html { redirect_to @typewright_overview, notice: 'Overview was successfully created.' }
  #      format.json { render json: @typewright_overview, status: :created, location: @typewright_overview }
  #    else
  #      format.html { render action: "new" }
  #      format.json { render json: @typewright_overview.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # PUT /typewright/overviews/1
  # PUT /typewright/overviews/1.json
  #def update
  #  @typewright_overview = Typewright::Overview.find(params[:id])
  #
  #  respond_to do |format|
  #    if @typewright_overview.update_attributes(params[:typewright_overview])
  #      format.html { redirect_to @typewright_overview, notice: 'Overview was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: "edit" }
  #      format.json { render json: @typewright_overview.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /typewright/overviews/1
  # DELETE /typewright/overviews/1.json
  #def destroy
  #  @typewright_overview = Typewright::Overview.find(params[:id])
  #  @typewright_overview.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to typewright_overviews_url }
  #    format.json { head :no_content }
  #  end
  #end
end
