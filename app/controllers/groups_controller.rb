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

class GroupsController < ApplicationController
  before_filter :init_view_options

  private
  def init_view_options
    @site_section = :shared
    return true
  end
  public

	def get_all_groups
		groups = Group.all()
    ret = []
		groups.each { |group|
			obj = {}
			obj[:id] = group.get_visible_id()
			obj[:img] = self.class.helpers.get_group_image_url(group)
			obj[:title] = group.id
			obj[:strFirstLine] = group.name
			if group.show_admins == 'all'
				editors = group.get_all_editors()
				editor_label = "Administrator#{'s' if editors.length > 1}: "
				for editor in editors
					editor_label += User.find(editor).fullname + ' '
				end
				editor_label += "<br />"
			else
				editor_label = ""
			end

			obj[:strSecondLine] = "#{editor_label}Established: #{group.created_at.strftime("%b %d, %Y")}<br/>#{Group.type_to_friendly(group.group_type)} -- #{self.class.helpers.pluralize(group.get_number_of_members(), 'member')}"
			ret.push(obj)
		}
	ret = ret.sort { |a,b|
		a[:strFirstLine].downcase <=> b[:strFirstLine].downcase
	}
    render :text => ret.to_json()
	end

	def check_url
		url = params[:group]['visible_url']
		if url == nil || url.length == 0
			render :text => "No URL given. Please enter one.", :status => :bad_request
			return
		end
		url_int = url.to_i
		if url_int > 0
			render :text => "Numbers are not allowed as URLs.", :status => :bad_request
			return
		end
		if url.index(/\W/) != nil
			render :text => "Only letters, numbers, and underscores are allowed as URLs.", :status => :bad_request
			return
		end

		id = params[:id]
		group = Group.find_by_visible_url(url)
		if group != nil && group.id != id.to_i
			render :text => 'The URL matches another group. Choose a different one.', :status => :bad_request
		else
			render :text => 'The URL is accepted. Please wait.'
		end
	end

	def sort_cluster
		session[:sort_cluster] = params[:sort]
		group_exhibits_list()
	end

	def sort_exhibits
		session[:sort_exhibit] = params[:sort]
		group_exhibits_list()
	end

	def pending_requests
		items = params[:group]
		group_id = params[:id]
		items.each { |key, val|
			if val == 'accept'
				GroupsUser.accept_request(key)
			elsif val == 'deny'
				GroupsUser.decline_request(key)
			end
		}
		render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => get_curr_user_id() }
	end

	# The following 4 calls can come from either the web or the email link. We have to go to
	# different pages in the two cases. The way to tell is the email link is GET and the web is POST.
	def accept_request
		from_web = request.request_method == :'POST'

		success = GroupsUser.accept_request(params[:id])
		if !success
			redirect_to :action => 'stale_request'
		else
			group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
			user_id = GroupsUser.get_user_from_obfuscated_id(params[:id])
			GroupsUser.email_hook("membership", group_id, "Member joined #{Group.find(group_id).name}", "The user #{User.find(user_id).fullname} was accepted.", url_for(:controller => 'home', :action => 'index', :only_path => false))
			if from_web
				render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => get_curr_user_id() }
			else
				redirect_to :action => 'acknowledge_notification', :type => 'accept_request', :success => success, :group_id => group_id
			end
		end
	end

	def decline_request
		from_web = request.request_method == 'POST'

		group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
		user_id = GroupsUser.get_user_from_obfuscated_id(params[:id])
		success = GroupsUser.decline_request(params[:id])
		if !success
			redirect_to :action => 'stale_request'
		else
			GroupsUser.email_hook("membership", group_id, "Member #{User.find(user_id).fullname} rejected from joining #{Group.find(group_id).name}", "The member #{User.find(user_id).fullname} was not allowed to join.", url_for(:controller => 'home', :action => 'index', :only_path => false))
			if from_web
				render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => get_curr_user_id() }
			else
				redirect_to :action => 'acknowledge_notification', :type => 'decline_request', :success => success, :group_id => group_id
			end
		end
	end

	def accept_invitation
		from_web = request.request_method == 'POST'
		from_web = false if params[:from_create]	# we can also be redirected here from the create user id page.

		begin
			has_login = GroupsUser.has_login(params[:id])
		rescue
			redirect_to :action => 'stale_request'
			return
		end
			if has_login
				success = GroupsUser.join_group(params[:id])
				group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
				user_id = User.find(GroupsUser.find(Group.id_retriever(params[:id])).user_id)
				user = User.find(user_id)
				set_current_user({ :email => user.email, :fullname => user.fullname, :username => user.username, :role_names => user.role_names })
				group = Group.find(group_id)
				GroupsUser.email_hook("membership", group_id, "New member, #{user.fullname}, in #{group.name}", "#{user.fullname} has joined the group #{group.name}. Visit the group at #{ActionMailer::Base.default_url_options[:host]}/groups/#{group.get_visible_id()}", url_for(:controller => 'home', :action => 'index', :only_path => false))
				if from_web
					render :partial => 'group_details', :locals => { :group => group, :user_id => get_curr_user_id() }
				else
					redirect_to :action => 'acknowledge_notification', :type => 'join_group', :success => success, :group_id => group_id
				end
			else
				redirect_to :action => 'create_login', :id => Group.id_retriever(params[:id]), :message => ''
			end
	end

	def decline_invitation
		from_web = request.request_method == 'POST'

		group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
		begin
			success = GroupsUser.decline_group(params[:id])
		rescue
			redirect_to :action => 'stale_request'
			return
		end
		GroupsUser.email_hook("membership", group_id, "#{user.fullname} declined membership to #{Group.find(group_id).name}", "The user, #{user.fullname}, declined to join.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		if from_web
			render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => get_curr_user_id() }
		else
			redirect_to :action => 'acknowledge_notification', :type => 'decline_group', :success => success, :group_id => group_id
		end
	end

	def acknowledge_notification
		if params == nil || params[:group_id] == nil || params[:type] == nil
			render_422
		end
	end

	def create_login
		if params == nil || params[:id] == nil
			render_422
		end
	end

	def create_login_create
		gu_id = params[:id]
		user_name = params[:user_name]
		if params[:id] == nil || params[:user_name] == nil # this call was made without parameters. That is an error, probably made by a bot.
			redirect_to :action => 'create_login', :id => params[:id], :message => 'Illegal call.'
			return
		end
		gu = GroupsUser.find(gu_id)
		email = gu.email
		password = params[:password]
		password2 = params[:password2]
		if user_name.length == 0
			redirect_to :action => 'create_login', :id => params[:id], :message => 'Please enter a user name.'
			return
		end
		user = User.find_by_username(user_name)
		if user != nil # there is a user with that name
			redirect_to :action => 'create_login', :id => params[:id], :message => 'There is already a user with that name. Please try another.'
			return
		end
		if password.length == 0 && password.strip.length == 0
			redirect_to :action => 'create_login', :id => params[:id], :message => 'Please enter a password.'
			return
		end
		if password != password2
			redirect_to :action => 'create_login', :id => params[:id], :message => 'Your passwords didn\'t match. Please try again.'
			return
		end

		set_current_user(User.create_user(user_name, password.strip, email))
		params[:id] = Group.id_obfuscator(gu_id)
		params[:from_create] = true
		accept_invitation()
	end

	 def leave_group
		 group_id = params[:group_id]
		 user_id = params[:user_id]
		 GroupsUser.leave_group(group_id, user_id)
		GroupsUser.email_hook("membership", group_id, "#{User.find(user_id).fullname} left #{Group.find(group_id).name}", "The member #{User.find(user_id).fullname} left the group.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		 redirect_to :back
	 end

	 def request_join
		 group_id = params[:group_id]
		 user_id = params[:user_id]
		 url_accept = url_for(:controller => 'groups', :action => 'accept_request', :id => "PUT_ID_HERE", :only_path => false)
		 url_decline = url_for(:controller => 'groups', :action => 'decline_request', :id => "PUT_ID_HERE", :only_path => false)
		 url_home = url_for(:controller => 'home', :action => 'index', :only_path => false)
		 GroupsUser.request_join(group_id, user_id, url_accept, url_decline, url_home)
		 render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => user_id }
	 end

	 def accept_as_peer_reviewed
		 exhibit_id = params[:exhibit_id]
		 exhibit = Exhibit.find(exhibit_id)
		 params[:exhibit][:cluster_id] = nil if params[:exhibit][:cluster_id] == '0'
		 exhibit.update_attributes(params[:exhibit])
		 if exhibit.is_published == 1
			 exhibit.adjust_indexing(:publishing, true)
		 end
		 #cluster = exhibit.cluster_id == nil ? nil : Cluster.find(exhibit.cluster_id)
		 render :partial => 'group_exhibits_list', :locals => { :group => Group.find(exhibit.group_id), :cluster => nil, :user_id => get_curr_user_id() }
	 end

	def unpublish_exhibit
		comment = params[:comment]
		exhibit_id = params[:exhibit_id]
		exhibit = Exhibit.find(exhibit_id)
		exhibit.adjust_indexing(:unpublishing, true)
		exhibit.is_published = 0
		exhibit.save!
	
		user = exhibit.get_apparent_author()
		editor = current_user
		group = Group.find(exhibit.group_id)
		GenericMailer.generic(editor.fullname, editor.email, user.fullname, user.email, "#{group.get_exhibits_label()} \"#{exhibit.title}\" Unpublished",
			"The editors of #{group.name} have unpublished your #{group.get_exhibits_label()} with suggested revisions, listed below. Please log into your account and review them at your earliest convenience.\n\n#{comment}",
			 url_for(:controller => 'home', :action => 'index', :only_path => false), "").deliver
		GroupsUser.email_hook("exhibit", group.id, "#{group.get_exhibits_label()} unpublished in #{group.name}", "#{editor.fullname} has unpublished the #{group.get_exhibits_label()} #{exhibit.title}.", url_for(:controller => 'home', :action => 'index', :only_path => false))

		cluster = exhibit.cluster_id == nil ? nil : Cluster.find(exhibit.cluster_id)
		render :partial => 'group_exhibits_list', :locals => { :group => group, :cluster => cluster, :user_id => get_curr_user_id() }
	end

	def limit_exhibit
		 exhibit_id = params[:exhibit_id]
		 exhibit = Exhibit.find(exhibit_id)
		exhibit.adjust_indexing(:limit_to_group, true)
		 exhibit.editor_limit_visibility = 'group'
		 exhibit.save!
		group = Group.find(exhibit.group_id)
		GroupsUser.email_hook("exhibit", group.id, "#{group.get_exhibits_label()} visibility limited in #{group.name}", "#{get_curr_user_name} limited the exhibit #{exhibit.title} to group visibility.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		 cluster = exhibit.cluster_id == nil ? nil : Cluster.find(exhibit.cluster_id)
		 render :partial => 'group_exhibits_list', :locals => { :group => Group.find(exhibit.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

	def unlimit_exhibit
		 exhibit_id = params[:exhibit_id]
		 exhibit = Exhibit.find(exhibit_id)
		exhibit.adjust_indexing(:limit_to_everyone, true)
		 exhibit.editor_limit_visibility = 'www'
		 exhibit.save!
		group = Group.find(exhibit.group_id)
		GroupsUser.email_hook("exhibit", group.id, "#{group.get_exhibits_label()} visibility not limited in #{group.name}", "#{get_curr_user_name} removed the visibility limitation on the #{group.get_exhibits_label()} #{exhibit.title}.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		 cluster = exhibit.cluster_id == nil ? nil : Cluster.find(exhibit.cluster_id)
		 render :partial => 'group_exhibits_list', :locals => { :group => Group.find(exhibit.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

	 def reject_as_peer_reviewed
		 comment = params[:comment]
		 exhibit_id = params[:exhibit_id]
		 exhibit = Exhibit.find(exhibit_id)
		 exhibit.is_published = 4
		 exhibit.save!
		group = Group.find(exhibit.group_id)
		GroupsUser.email_hook("exhibit", group.id, "#{group.get_exhibits_label()} \"#{exhibit.title}\" in \"#{group.name}\" needs revision.",
			"#{get_curr_user_name} returned the #{group.get_exhibits_label()} \"#{exhibit.title}\" for further revisions before being accepted as peer-reviewed.\n\nThe Editors included this message in their review:\n\n#{comment}",
			url_for(:controller => 'home', :action => 'index', :only_path => false))

		 user = exhibit.get_apparent_author()
		 editor = current_user
		 group = Group.find(exhibit.group_id)
		 GenericMailer.generic(editor.fullname, editor.email, user.fullname, user.email, "Revisions Needed to #{group.get_exhibits_label()} \"#{exhibit.title}\"",
			 "The editors of #{group.name} have returned your #{group.get_exhibits_label()} with suggested revisions, listed below. Please log into your account and review them at your earliest convenience.\n\n#{comment}",
			 url_for(:controller => 'home', :action => 'index', :only_path => false), "").deliver

		 cluster = exhibit.cluster_id == nil ? nil : Cluster.find(exhibit.cluster_id)
		 render :partial => 'group_exhibits_list', :locals => { :group => group, :cluster => cluster, :user_id => get_curr_user_id() }
	 end

	def notifications
		levels = params[:notifications]
		group_id = params[:group_id]
		notes = []
		levels.each {|key, val|
			notes.push(key) if val == "true"
		}
		user_id = get_curr_user_id()
		GroupsUser.set_notifications(group_id, user_id, notes)
		render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => user_id }
	end

	def edit_membership
		show_membership = params[:show_membership]
		change_owner = params[:change_owner]
		member_list = params[:group]
		group_id = params[:id]
		if member_list
			member_list.each {|id,value|
				gu = GroupsUser.find(id)
				if value['delete'] == 'true'
					gu.destroy
				else
					role = value['editor'] == 'true' ? 'editor' : 'member'
					if gu.role != role
						gu.role = role
						if role == 'editor'
							gu.notifications = "editor;membership"
						else
							gu.notifications = ""
						end
						gu.save!
					end
				end
			}
		end
		group = Group.find(group_id)
		group.show_membership = show_membership == 'Yes'
		if change_owner && change_owner != '0'
			gu = GroupsUser.find_by_group_id_and_user_id(group.id, change_owner)
			if gu
				gu.user_id = group.owner
				gu.email = User.find(group.owner).email

				notifications = group.notifications
				group.notifications = gu.notifications
				gu.notifications = notifications
				gu.save

				group.owner = change_owner
			end
		end
		group.save!
		GroupsUser.email_hook("membership", group.id, "The membership in #{group.name} has changed", "The membership in #{group.name} has changed.", url_for(:controller => 'home', :action => 'index', :only_path => false))

		render :partial => 'group_details', :locals => { :group => Group.find(group_id), :user_id => get_curr_user_id() }
	end

	def render_license
		@group = Group.find(params[:id])
		render :partial => 'group_license', :locals => { :group => @group, :user_id => get_curr_user_id() }
	end
	
	def remove_profile_picture
		id = params[:id]
		group = Group.find(id)
		group.image = nil
		group.save
		GroupsUser.email_hook("group", group.id, "Thumbnail removed from #{group.name}", "#{get_curr_user_name} has removed the thumbnail image from #{group.name}.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		redirect_to :back
	end

	def edit_thumbnail
		group_id = params[:id]
		group = Group.find(group_id)
		err = Image.save_image(params['image'], group)
		case err[:status]
		when :error then
			flash = err[:user_error]
			logger.error(err[:log_error])
		when :saved then
			flash = "OK:Thumbnail updated"
			GroupsUser.email_hook("group", group.id, "Group updated: #{group.name}", "The group was updated.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		when :no_image then
			flash = "ERROR: No image specified"
		end
#		image = params['image']
#		if image && image
#			image = Image.new({ :uploaded_data => image })
#		end
#		begin
#			group.image = image
#			if group.save
#				group.image.save! if group.image
#				GroupsUser.email_hook("group", group.id, "Group updated: #{group.name}", "The group was updated.", url_for(:controller => 'home', :action => 'index', :only_path => false))
#				flash = "OK:Thumbnail updated"
#			else
#				flash = "Error updating thumbnail"
#			end
#		rescue
#			flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#		end
    render :text => respond_to_file_upload("stopEditGroupThumbnailUpload", flash) # This is loaded in the iframe and tells the dialog that the upload is complete.
	end

	def verify_group_title
    creator = current_user
    if creator.nil?
      render :text => "Your session has expired. Please log in and try again.", :status => :bad_request
    else
      title = params[:name]
      group = Group.find_by_name(title)
      if group == nil
        render :text => "ok"
      else
        render :text => "There is already a group with this title.", :status => :bad_request
      end
    end
	end

  # GET /groups
  # GET /groups.xml
#  def index
#    @groups = Group.all
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @groups }
#    end
#  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
		@group = Group.find_by_visible_url(params[:id])
		if @group == nil
			@group = Group.find_by_id(params[:id])
		end
		if @group == nil
			#redirect_to "/404.html"
			render_404
			return
		end

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @group }
		end
	end

  # GET /groups/new
  # GET /groups/new.xml
#  def new
#    @group = Group.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @group }
#    end
#  end

  # GET /groups/1/edit
#  def edit
#    @group = Group.find(params[:id])
#  end

#	def show_cluster
#			@cluster = Cluster.find(params[:id])
#			@group = Group.find(@cluster.group_id)
#
#	end

# TODO-PER: I think this is not called.
#	def create_cluster
#		begin
#			if params['image'] && params['image'].length > 0
#				image = Image.new({ :uploaded_data => params['image'] })
#			end
#			cluster = Cluster.new(params[:cluster])
#			cluster.image = image
#			err = false
#			if cluster.save
#				begin
#					cluster.image.save! if cluster.image
#				rescue
#					err = true
#					cluster.delete
#					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#				end
#				if err == false
#					GroupsUser.email_hook("group", cluster.group.id, "Group updated: #{Group.find(cluster.group_id).name}", "The group was updated.", url_for(:controller => 'home', :action => 'index', :only_path => false))
#					flash = "OK:#{cluster.group_id}"
#				end
#			else
#				flash = "Error creating cluster"
#			end
#		rescue
#			flash = "Server error when creating cluster."
#		end
#    render :text => "<script type='text/javascript'>window.top.window.stopNewClusterUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
#	end

	def group_exhibits_list
		if params[:cluster_id] && params[:cluster_id].length > 0
			cluster = Cluster.find(params[:cluster_id])
			render :partial => '/groups/group_exhibits_list', :locals => { :group => Group.find(cluster.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
		else
			render :partial => '/groups/group_exhibits_list', :locals => { :group => Group.find(params[:id]), :user_id => get_curr_user_id() }
		end
	end

  # POST /groups
  # POST /groups.xml
  def create
    begin
      if params[:emails]
        err_msg = validate_email_list(params[:emails])
        if !err_msg.nil?
          render :text => respond_to_file_upload("stopNewGroupUpload", err_msg)  # This is loaded in the iframe and tells the dialog that the upload is complete.
          return
        end
      end

      params[:group][:show_membership] = true if params[:group][:show_membership] == 'Yes'
      params[:group][:show_membership] = false if params[:group][:show_membership] == 'No'
      params[:group][:exhibit_visibility] = 'www'
      params[:group][:forum_permissions] = 'full'
      send_email = false
      if params[:group][:group_type] == 'peer-reviewed'
        params[:group][:group_type] = 'community'
        send_email = true
      end
      @group = Group.new(params[:group])
      @group.header_font_name = 'Arial'
      @group.header_font_size = '24'
      @group.text_font_name = 'Times New Roman'
      @group.text_font_size = '18'
      @group.illustration_font_name = 'Trebuchet MS'
      @group.illustration_font_size = '14'
      @group.caption1_font_name = 'Trebuchet MS'
      @group.caption1_font_size = '14'
      @group.caption2_font_name = 'Trebuchet MS'
      @group.caption2_font_size = '14'
      @group.endnotes_font_name = 'Times New Roman'
      @group.endnotes_font_size = '16'
      @group.footnote_font_name = 'Times New Roman'
      @group.footnote_font_size = '16'
      @group.use_styles = 0
      @group.image_id = nil
      @group.exhibits_label = "Exhibit"
      @group.clusters_label = "Cluster"
      @group.show_admins = 'all'
      @group.notifications = "exhibit;membership"
      err = false
      if @group.save
        begin
          @group.image.save! if @group.image
        rescue
          err = true
          @group.delete
          flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
        end
        if err == false
          flash = "OK:#{@group.id}"
          invitor = current_user
          url_accept = url_for(:controller => 'groups', :action => 'accept_invitation', :id => "PUT_ID_HERE", :only_path => false)
          url_decline = url_for(:controller => 'groups', :action => 'decline_invitation', :id => "PUT_ID_HERE", :only_path => false)
          url_home = url_for(:controller => 'home', :action => 'index', :only_path => false)
          @group.invite_members(invitor.fullname, invitor.email, params[:emails], params[:usernames], url_accept, url_decline, url_home)
        end
      else
        flash = "Error creating group"
      end
    rescue Exception => msg
      logger.error("**** ERROR: Can't create group: " + msg.message)
      flash = "Server error when creating group."
    end
    if send_email
      peer_review_request()
    end
    render :text => respond_to_file_upload("stopNewGroupUpload", flash)  # This is loaded in the iframe and tells the dialog that the upload is complete.
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
		if params[:group]
			params[:group][:show_membership] = true if params[:group][:show_membership] == 'Yes'
			params[:group][:show_membership] = false if params[:group][:show_membership] == 'No'
			if params[:group][:group_type] == 'peer-reviewed'
				params[:group][:group_type] = 'community'
				peer_review_request()
			elsif params[:group][:group_type] == 'classroom'
				@group.university = @group.name if (@group.university.length == 0)
				@group.course_name = @group.name if (@group.course_name.length == 0)
				@group.course_mnemonic = @group.name if (@group.course_mnemonic.length == 0)
			end
			@group.update_attributes(params[:group])
		end

    err_msg = nil
    if params[:emails] 
      err_msg = validate_email_list(params[:emails])
      if !err_msg.nil?
        render :text => err_msg, :status => :bad_request
        return
      end
    end
		
		if params[:emails] || params[:usernames]
			invitor = current_user()
			if invitor.nil?
			  err_msg = "You must be logged in to invite users"
			else
				url_accept = url_for(:controller => 'groups', :action => 'accept_invitation', :id => "PUT_ID_HERE", :only_path => false)
				url_decline = url_for(:controller => 'groups', :action => 'decline_invitation', :id => "PUT_ID_HERE", :only_path => false)
				url_home = url_for(:controller => 'home', :action => 'index', :only_path => false)
				err_msg = @group.invite_members(invitor.fullname, invitor.email, params[:emails], params[:usernames], url_accept, url_decline, url_home)
			end
		end

	  if params[:group] # this may be nil if we are just inviting people.
  		which = params[:group].keys.join(" and ")
  		values = self.class.helpers.strip_tags(params[:group].values.to_a().join("\n\n"))
  		GroupsUser.email_hook("group", @group.id, "Group updated: #{@group.name}", "#{get_curr_user_name} has updated the field \"#{which}\" in \"#{@group.name}\".\n#{values}", url_for(:controller => 'home', :action => 'index', :only_path => false))
	  end

		if err_msg == nil
			if params[:group] && params[:group][:forum_permissions] != nil
				render :partial => 'group_discussions_list', :locals => { :group => @group, :user_id => get_curr_user_id }
			else
				render :partial => 'group_details', :locals => { :group => @group, :user_id => get_curr_user_id }
			end
		else
			render :text => err_msg, :status => :bad_request
		end
  end
  
  # take a newline separated list of emails and make sure each is well formed
  # if any errors are found this will return an error string. if all is well,
  # nil will be retuned
  #
  private
  def validate_email_list(emails)
    err_msg = nil
    email_regexp = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/i
    bad_emails = []
    emails.split(/\n/).each do |email|
      bad_emails << email unless !(email =~ email_regexp).nil?
    end

    if bad_emails.size > 0
      err_msg = "<br/>The following email addresses are invalid:<br/>"
      bad_emails.each do |bad|
        err_msg << "&nbsp;&nbsp;&nbsp;&nbsp;" << bad << "<br/>"
      end
    end
    return err_msg
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  public
  def destroy
		@group = Group.find(params[:id])
		GroupsUser.email_hook("group", @group.id, "Group deleted: #{@group.name}", "The group was deleted.", url_for(:controller => 'home', :action => 'index', :only_path => false))
		typ = @group.group_type
		@group.destroy

		# Also remove the exhibits and discussions from being in the group.
		exhibits = Exhibit.where({group_id: params[:id]})
		exhibits.each { |exhibit|
			exhibit.adjust_indexing(:leave_group, true)
			exhibit.group_id = nil
			exhibit.save!
		}
		threads = DiscussionThread.where({group_id: params[:id]})
		threads.each { |thread|
			thread.group_id = nil
			thread.save!
		}
		groupsusers = GroupsUser.where({group_id: params[:id]})
		groupsusers.each { |gu|
			gu.destroy
		}
		clusters = Cluster.where({group_id: params[:id]})
		clusters.each { |cluster|
			cluster.destroy
		}
		redirect_to self.class.helpers.make_group_home_link(typ)
  end

	# TODO-PER: What is the real rails way of doing this?
	class RolesUser < ActiveRecord::Base
	end

	private
	def peer_review_request
		roles = RolesUser.where({role_id: 1})
		admins = []
		roles.each { |role|
			user = User.find(role.user_id)
			admins.push({ :name => user.fullname, :email => user.email })
		}
		begin
			curr_user = current_user
			admins.each { |ad|
				body = "#{curr_user.fullname} mailto:#{curr_user.email} #{ "from #{curr_user.institution}" if curr_user.institution && curr_user.institution.length > 0 } has requested to make the group #{ @group.name } into a peer-reviewed group.\n\n"
				body += "Please log in as administrator to #{Setup.site_name()} to change the group.\n\n"
				GenericMailer.generic(curr_user.fullname, curr_user.email, ad[:name], ad[:email], 
				  "Request to create peer-reviewed group", body, url_for(:controller => 'home', 
				  :action => 'index', :only_path => false), "").deliver
			}
		rescue Exception => msg
			logger.error("**** ERROR: Can't send email: " + msg.message)
		end
	end
end
