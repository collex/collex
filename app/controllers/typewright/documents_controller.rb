# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

class Typewright::DocumentsController < ApplicationController
	layout 'nines'
	before_filter :init_view_options
	
	private
	
	 # the total number of revisions to show 
	 # on one page of the revision history for a text
	EDITS_PER_PAGE = 20   
	
	def init_view_options
		@site_section = :typewright
		return true
	end
	
	public

	# GET /typewright/documents
	def index
	  
	  @primary = nil
	  @features = []
	  
	  # pick the top 5 by date. Be sure primary is always
	  # included and disabled are skipped
    features = Typewright::TwFeaturedObject.find(:all, :conditions => ["disabled=?", 0], :order => "`primary` desc, created_at desc limit 5")
    features.each do | feature |
      if feature.primary && @primary.nil?
        @primary = CachedResource.get_hit_from_uri( feature.uri )
		src = params[:src].to_sym unless params[:src].nil?
		src = :gale if src.nil?
		word_stats = is_admin?
        stats = Typewright::Document.get_stats( feature.uri, src, word_stats )
        doc = Typewright::Document.find_by_uri( feature.uri )
        num_pages = doc.num_pages()
        pages_with_changes = stats.pages_with_changes
        @stats = { :num_pages => num_pages.to_i, :pages_with_changes => pages_with_changes.to_i }
		@id = doc.doc_id
		@title = doc.title
#		@title_abbrev = doc.title_abbrev
		site = COLLEX_PLUGINS['typewright']['web_service_url']
		@thumb = URI::join(site, doc.img_thumb)
      else
        @features.push( CachedResource.get_hit_from_uri( feature.uri ) )
      end
    end
	end

	# GET /typewright/documents/1
	def show

    @site = COLLEX_PLUGINS['typewright']['web_service_url']

		# This goes to the main page of a particular document.
		@hit = []
		user = get_curr_user()
		if user == nil
			redirect_to :action => "not_signed_in"
		else
			@user = Typewright::User.get_or_create_user(Setup.default_federation(), user.id)

			@uri = params[:uri]
			@hit = CachedResource.get_hit_from_uri( @uri )
			doc = Typewright::Document.find_by_uri(@uri)
			if doc == nil
				doc = Typewright::Document.create({ :uri => @uri })
			end
			
			@id = doc.doc_id
			@title = doc.title
			@title_abbrev = doc.title_abbrev
			@thumb = URI::join(@site, doc.img_thumb)
			@num_pages = doc.num_pages
      @src = params[:src].to_sym unless params[:src].nil?
      @src = :gale if @src.nil?
      @sources = doc.ocr_sources
      @sources = %w(gale) if @sources.nil?

		word_stats = is_admin?
      stats = Typewright::Document.get_stats( @uri, @src, word_stats )
      pages_with_changes = stats.pages_with_changes
      total_revisions = stats.total_revisions
		lines_with_changes = stats.lines_with_changes
      @stats = { :num_pages => doc.num_pages.to_i, :pages_with_changes => pages_with_changes.to_i }
        
			ud = Typewright::DocumentUser.find_by_user_id_and_document_id(@user.id, @id)
			if ud == nil
				Typewright::DocumentUser.create({ :user_id => @user.id, :document_id => @id })
			end

			if @title.length == 0
				redirect_to :action => "not_available"
			end
			
			# get a collection of all of the edits to this text
			@edits = []
      @revision_page = params[:revision_page] ? params[:revision_page].to_i : 1
      @num_revision_pages = total_revisions.quo( EDITS_PER_PAGE ).ceil
		@revision_page = 1 if @revision_page < 1
		@revision_page = @num_revision_pages if @revision_page > @num_revision_pages
      start_revision = EDITS_PER_PAGE * (@revision_page-1)
      @edits = Typewright::Line.revisions(@uri, start_revision, EDITS_PER_PAGE, @src)
	
		end
	end
	
  public
	# GET /typewright/documents/1/edit
	def edit
	  
	  @site_section = :typewright_edit
	   
		# This goes to the editing page of a particular document
		id = params[:id]
		doc = Typewright::Document.find_by_id(id)
		if doc == nil
			redirect_to :back
		else
			page = params[:page]
      page = '1' if page.nil?
      @src = params[:src].to_sym unless params[:src].blank?
      @src ||= :gale
      @sources = doc.ocr_sources
      @sources = %w(gale) if @sources.nil?
      @uri = doc.uri
      @site = COLLEX_PLUGINS['typewright']['web_service_url']
			word_stats = is_admin?
			@params = Typewright::Document.get_page(@uri, page, @src, word_stats)
      @thumb = URI::join(@site, @params['img_thumb'])
      @image_full = URI::join(@site, @params['img_full'])
      @params['img_thumb'] = @thumb.to_s
      @params['img_full'] = @image_full.to_s
#			@user = session[:user]
			@debugging = session[:debugging] ? session[:debugging] : false
		end
	end

  # POST /typewrite/documents/1/report?page=n
  def report
    doc_id = params[:id]
    page_num = params[:page]
    src = params[:src]
    @report_form_url = Typewright::Document.get_report_form_url(doc_id, page_num, src)
    render :partial => '/typewright/documents/report'
  end

	def instructions
		render :partial => '/typewright/documents/instructions'
	end
end

