class Typewright::OverviewsController < Admin::BaseController
	# GET /typewright/overviews
	# GET /typewright/overviews.json
	def index
		@view = params[:view] || 'docs'
		@filter = params[:filter]
		@typewright_overviews = Typewright::Overview.all(@view, params[:page], 10, params[:sort], params[:filter])
		if @view == 'docs'
			@typewright_overviews.each { |document|
				resource = CachedResource.get_hit_from_uri(document['uri'])
				document['title'] = resource['title']
			}
		else
			@typewright_overviews.each { |user|
				user['documents'].each { |document|
					resource = CachedResource.get_hit_from_uri(document['id'])
					document['title'] = resource['title'] if resource.present?
				}
			}
		end
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
