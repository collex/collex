# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of
# Virginia
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
require 'rest_client'
require "erb"

include ERB::Util
class Typewright::DocumentsController < ApplicationController
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
      features = Typewright::TwFeaturedObject.all(:conditions => ["disabled=?", 0], :order => "`primary` desc, created_at desc limit 5")
      features.each do | feature |
         if feature.primary && @primary.nil?
            @primary = CachedResource.get_hit_from_uri( feature.uri )
            word_stats = is_admin?
            stats = Typewright::Document.get_stats( feature.uri, word_stats )
            doc = Typewright::Document.find_by_uri( feature.uri )
            if stats.present? && doc.present?
               num_pages = doc.num_pages()
               pages_with_changes = stats.pages_with_changes
               @stats = { :num_pages => num_pages.to_i, :pages_with_changes => pages_with_changes.to_i }
               @id = doc.doc_id
               @title = doc.title
               site = COLLEX_PLUGINS['typewright']['web_service_url']
               @thumb = URI::join(site, doc.img_thumb)
            else
               @stats = { :num_pages => 1, :pages_with_changes => 0 }
               @id = "Not found"
               @title = "Not found"
               @thumb = ""
            end
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
      user = current_user
      if user == nil
         redirect_to :action => "not_signed_in"
      else
         @user = Typewright::User.get_or_create_user(Setup.default_federation(), user.id, user.username)

         @uri = params[:uri]
         @hit = CachedResource.get_hit_from_uri( @uri )
         doc = Typewright::Document.find_by_uri(@uri)
         if doc == nil
            doc = Typewright::Document.create({ :uri => @uri })
         end

         @id = doc.doc_id
         @doc_is_complete = doc.status == 'complete'
         @title = doc.title
         @title_abbrev = doc.title_abbrev
         @thumb = URI::join(@site, doc.img_thumb)
         @num_pages = doc.num_pages

         word_stats = is_admin?
         stats = Typewright::Document.get_stats( @uri, word_stats )
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
         @edits = Typewright::Line.revisions(@uri, start_revision, EDITS_PER_PAGE)
         begin
            last_revision = stats.last_revision.kind_of?(Typewright::Document::LastRevision) ? stats.last_revision.send("user_#{@user.id}") : nil
         rescue
            # the send() call will fail if the user hasn't made any revisions. That is ok.
            last_revision = nil
         end
         @starting_place = last_revision.present? ? { page: last_revision.page, line: last_revision.line } : { }
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
         redirect_to :back and return
      end
      
      if doc.status == 'complete'
         data = { :uri => doc.uri}
         redirect_to data.merge!(:action => :show)
      end
      
      page = params[:page]
      page = '1' if page.nil?
      @is_complete = (doc.status == 'user_complete')
      @uri = doc.uri
      starting_line_number = params[:line]
      @site = COLLEX_PLUGINS['typewright']['web_service_url']
      word_stats = is_admin?
      @params = Typewright::Document.get_page(@uri, page, word_stats)
      user_id = get_curr_user_id()
      if user_id.nil?
         begin
            redirect_to :back
         rescue
            redirect_to "/"
         end
      else
         @src = @params['src']
         typewright_user_id = Typewright::User.get_or_create_user(Setup.default_federation(), user_id, current_user.username)
         token = "#{typewright_user_id.id}/#{Time.now()}"
         @params['token'] = token
         @params['starting_line'] = 0
            
         # correct the format of the original line
         @params['lines'].each_with_index do |line, index|
            if line['actions'].present? && line['actions'].length > 0 && line['actions'][0] == nil
               line['actions'][0] = 'original'
               line['dates'][0] = ''
               line['text'][0] = '' if line['text'][0].blank?
            end
            if line['num'].to_f == starting_line_number.to_f
               @params['starting_line'] = index
            end
         end
         
         @thumb = URI::join(@site, @params['img_thumb'])
         @image_full = URI::join(@site, @params['img_full'])
         @params['img_thumb'] = @thumb.to_s
         @params['img_full'] = @image_full.to_s
         @debugging = session[:debugging] ? session[:debugging] : false
      end
   end

   # Called by an admin to update document status
   # POST /typewrite/documents/d/complete=n
   #
   def update_status
      doc_id = params[:id]
      new_status = params[:new_status]
      doc = Typewright::Document.find_by_id(doc_id)
      old_status =  doc.status
      doc.status = new_status
      if !doc.save
         render :text => doc.errors, :status => :error
      return
      end

      # need special behavior to handle documents that are complete
      # kick off new logic to grab corrected text, and send it to catalog for
      # re-indexing
      if new_status == 'complete'
         # grab corrected text
         fulltext = Typewright::Overview.retrieve_doc(doc.uri, "text")

         # get the solr object for this document
         solr = Catalog.factory_create(false)
         solr_document = solr.get_object(doc.uri)

         # update the important bits
         solr_document['text'] = fulltext
         solr_document['has_full_text'] = "true"
         json_data = ActiveSupport::JSON.encode( solr_document )

         # POST the corrected full text to the catalog so it will be
         # stored there and the results reproducable on the next reindex
         catalog_url = "#{URI.parse(Setup.solr_url())}/corrections"
         private_token = SITE_SPECIFIC['catalog']['private_token']

         begin
            resp = RestClient.post catalog_url, json_data, :'private_token' => private_token, :content_type => "application/json"
            Catalog.reset_cached_data()
            render :text => "OK", :status => :ok
         rescue RestClient::Exception => rest_error
            puts rest_error.response
            doc.status = old_status
            doc.save
            render :text => rest_error.response, :status => rest_error.http_code
         rescue Exception => e
            puts rest_error.response
            doc.status = old_status
            doc.save
            render :text => e, :status => :internal_server_error
         end
      else
         render :text => "OK", :status => :ok
      end
   end

   # Called by a user to mark a document as fully corrected
   # POST /typewrite/documents/d/complete=n
   #
   def page_complete
      doc_id = params[:id]
      doc = Typewright::Document.find_by_id(doc_id)
      doc.status = 'user_complete'
      if !doc.save
         render :text => doc.errors, :status => :error
      return
      end

      # get admin users
      admins = ::User.get_administrators()
      to = ""
      admins.each do | admin |
         if to.length > 0
            to << ","
         end
         to << admin.email
      end

      # send an email to them so they know a document has been marked as complete
      doc_url = "#{get_base_uri()}/typewright/documents/#{doc_id}/edit"
      status_url = "#{get_base_uri()}/typewright/overviews?filter=#{url_encode(doc.uri)}"
      DocumentCompleteMailer.document_complete_email(current_user, doc, doc_url, status_url, to).deliver

      render :text => "OK", :status => :ok
   end

   # POST /typewrite/documents/1/report?page=n
   def report
      doc_id = params[:id]
      page_num = params[:page]
      collex_user = current_user
      if collex_user.blank?
         render :text => 'You must be signed in to report pages. Did your session expire?', :status => :bad_request
      else
         user = Typewright::User.get_or_create_user(Setup.default_federation(), collex_user.id, collex_user.username)
         user_id = user.present? ? user.id : nil
         @report_form_url = Typewright::Document.get_report_form_url(doc_id, user_id, collex_user.fullname, collex_user.email, page_num)
         render :partial => '/typewright/documents/report'
      end
   end

   # PUT /typewrite/documents/1/delete_edits?page=n
   def delete_edits
      doc_id = params[:id]
      page_num = params[:page]

      collex_user = current_user
      if collex_user.blank?
         render :text => 'You must be signed in to delete corrections. Did your session expire?', :status => :bad_request
      else

         tw_url = COLLEX_PLUGINS['typewright']['web_service_url']
         private_token = COLLEX_PLUGINS['typewright']['private_token']
         url = "#{tw_url}/documents/#{doc_id}/delete_corrections?page=#{page_num}"
         begin
            resp = RestClient.put url, :'private_token' => private_token
            # back to the edit page
            doc_url = "#{get_base_uri()}/typewright/documents/#{doc_id}/edit?page=#{page_num}"
            redirect_to doc_url
         rescue RestClient::Exception => rest_error
            render :text => rest_error.response, :status => rest_error.http_code
         rescue Exception => e
            render :text => e, :status => :internal_server_error
         end
      end
   end

   def instructions
      render :partial => '/typewright/documents/instructions'
   end

   private

   def get_base_uri()
      uri = URI.parse( request.url )
      base_uri = "#{uri.scheme}://#{uri.host}"
      if !uri.port.nil?
         if uri.port != 80
            base_uri = "#{uri.scheme}://#{uri.host}:#{uri.port}"
         end
      end
      return base_uri
   end
end

