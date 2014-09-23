##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################
#require 'json'

class MyCollexController < ApplicationController
  before_filter :init_view_options

  private
  def init_view_options
    @site_section = :my_collex
	@solr = Catalog.factory_create(session[:use_test_index] == "true")
	@archives = @solr.get_resource_tree()
    return true
  end

  public

  def index
    user = current_user
    if user == nil
      return
    end

    set_cloud_list(user, user.username)

    @results = CachedResource.get_newest_collections(user, 5)
    more_results = CachedResource.get_newest_collections(user, 6)
    @has_more = @results.length < more_results.length
	@collected = view_context.add_non_solr_info_to_results(@results, nil)

	# if COLLEX_PLUGINS['typewright']
	# 	@my_typewright_documents = Typewright::DocumentUser.document_list(Setup.default_federation(), user.id)
	# end

  end

  def get_typewright_documents
	  if COLLEX_PLUGINS['typewright'] && user_signed_in?
		  my_typewright_documents = Typewright::DocumentUser.document_list(Setup.default_federation(), get_curr_user_id())
		  render partial: 'typewright/widgets/my_documents', :locals => {:document_list => my_typewright_documents}
	  else
		  render text: ""
	  end
  end

  def results
    # parameters:
    #  :view => 'all_collected', 'untagged', 'tag' (show all collected objects, show all untagged objects, show a single tag)
    #  :tag => 'tag_name' (if :view => 'tag', then this is the particular tag to show)

    user = current_user
    if user == nil
      return
    end

    session[:tag_zoom] ||= 1
    #do the pagination.
    @page = params[:page] ? params[:page].to_i : 1
	@collected_sort_by = params[:srt] || ''
	@collected_sort_by_direction = params[:dir] || 'asc'
	items_per_page = 30
    
    # we save the view type in the session object in case we are called from a place that shouldn't care which type it is.
    # In other words, if we have the param[:view] parameter, we use it and save it. If we don't, then we retrieve it.
    if params[:view] != nil
      session[:tag_view] = params[:view]
    else
      params[:view] = session[:tag_view]
    end
    
    if params[:tag] != nil
      params[:tag] = params[:tag].gsub("&lt;","<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", '"')
      session[:tag_current] = params[:tag]
    else
      params[:tag] = session[:tag_current]
    end

    set_cloud_list(user, user.username)

		sort_field = nil
		case @collected_sort_by
		when "" then
			sort_field = 'date_collected'
		when "title" then
			sort_field = 'title'
		when "author" then
			sort_field = 'role_AUT'
		when "year" then
			sort_field = 'date_label'	# note: the 'year' field isn't cached, so we can't sort on that. Should we cache it and refresh all objects?
		when "a" then
			sort_field = 'archive'
			else
				sort_field = 'date_collected'
		end

    # This creates an array of hits. Hits is a hash with these members: uri, text, title[0], archive, date_label[...], url[0], role_*[...], genre[...], source[...], alternative[...], license
    case params[:view]
      when 'all_collected'
      ret = CachedResource.get_page_of_hits_by_user(user, @page-1, items_per_page, sort_field, @collected_sort_by_direction)
      @results = ret[:results]
      @total_hits = ret[:total]

      when 'untagged'
      ret = CachedResource.get_page_of_all_untagged(user, @page-1, items_per_page, sort_field, @collected_sort_by_direction)
      @results = ret[:results]
      @total_hits = ret[:total]

      when 'tag'
      ret = CachedResource.get_page_of_hits_for_tag(params[:tag], user, @page-1, items_per_page, sort_field, @collected_sort_by_direction)
      @results = ret[:results]
      @total_hits = ret[:total]

    else
      @results = {}
      @total_hits = @results.length
    end

	@collected = view_context.add_non_solr_info_to_results(@results, nil)
    @num_pages = @total_hits.quo(items_per_page).ceil
  end

	 #adjust the sort order
  # def sort_by
	# 	if params['search'] && params['search']['result_sort']
  #     sort_param = params['search']['result_sort']
	# 		session[:collected_sort_by] = sort_param
	# 	end
	# 	if params['search'] && params['search']['result_sort_direction']
  #     sort_param = params['search']['result_sort_direction']
	# 		session[:collected_sort_by_direction] = sort_param
	# 	end
  #     redirect_to :action => 'results'
	# end

	# This is called from AJAX when a user's link has been clicked.
	def show_profile
		user_id = params[:user]
		render :partial => "/my_collex/profile", :locals => { :user => User.find(user_id), :can_edit => false }
	end

  # This is called from AJAX when the user has finished filling out the form.
  def update_profile
    user = current_user
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?", :status => :bad_request
      return
    end

    if params[:account_email] !~ /\@/
      render :text => "An e-mail address is required", :status => :bad_request
      return
    end
    if params[:account_password] != params[:account_password2]
      render :text => "Passwords do not match", :status => :bad_request
      return
    end
    user.institution = params['institution']
    user.fullname = params['fullname']
    user.email = params['account_email']
    user.hide_email = params['hide_email']
    user.link = params['link']
    user.about_me = params['aboutme']
    #check the link for a javascript attack
    if user.link.downcase.index("javascript:") != nil
      user.link = "invalid link entered"
    end
    user.save

    User.update_user(current_user.username, params[:account_password].strip, params[:account_email])

    render :partial => 'profile', :locals => { :user => user, :can_edit => true }
  end

	def remove_profile_picture
    user = current_user
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?", :status => :bad_request
      return
    end
		user.image = nil
		user.save
    redirect_to :back
	end

  # The file upload is done in a separate call because of ajax limitations.
  def update_profile_upload
    user = current_user
		flash = ''
		if user	# If the session expired while the dlg was on the page, don't go further.
			if  !params['image'].blank?
				err = Image.save_image(params['image'], user)
				if err[:status] == :error
					flash = err[:user_error]
					logger.error(err[:log_error])
				end
			end
#			if params['image'] && params['image'].original_filename.length > 0
#				begin
#					img = Image.new
#					img.photo = params['image']
#					img.save
#					user.image_id = img.id
#					user.save
#				rescue Exception => msg
#					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#					logger.error("**** ERROR: Uploading profile picture: " + msg)
#				end
#			end
		else
			flash = "Your session has expired. Please refresh this page and log in again."
		end
#    old_image = nil
#    if params['image'] != nil && params['image'].length > 0
#      old_image = user.image_id
#      user.image = Image.new({ :uploaded_data => params['image'] })
#      user.image.save!
#    end

      # now we need to figure out what happened with the attachment.
      # If there was an error image_id is set to nil, and we want to reset it to the previous image.
      # If there was no error, and there was a previous image, then we want to delete the previous one from the file system.
#      if old_image != nil
#        if user.image_id == nil
#          user.image = nil
#          user.update_attribute(:image_id, old_image) 
#        else
#          id = old_image.to_s.rjust(4, '0')
#          folder = "#{Rails.root}/public/uploads/0000/#{id}/"
#          d = Dir.new(folder)
#          d.each {|f|
#            if f != '.' && f != '..'
#              File.delete(folder + f)
#            end
#          }
#          Dir.delete(folder)
#        end
#      end
    #      if params['image'].length > 0
    #        folder = "#{Rails.root}/public/images/users/"
    #        image_path = "#{folder}#{user.id}"
    #        Dir.mkdir(folder) unless File.exists?(folder)
    #        File.open(image_path, "wb") { |f| f.write(params['image'].read) }
    #      end
    render :text => respond_to_file_upload("stopUpload", flash)  # This is loaded in the iframe and tells the dialog that the upload is complete.
  end

  private
  def cloud_fragment_key( user )
       "/cloud/#{user}_user/tag"
  end

  def set_cloud_list(user, username)
#    @cloud_fragment_key = cloud_fragment_key(username)
#
#    if is_cache_expired?(@cloud_fragment_key)
      @cloud_info = CachedResource.get_tag_cloud_info(user)
#    end
  end

end
