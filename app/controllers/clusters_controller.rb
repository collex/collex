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

class ClustersController < ApplicationController
  before_filter :init_view_options

  private
  def init_view_options
    @site_section = :shared
    return true
  end
  public

	def check_url
		url = params[:cluster]['visible_url']
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
		cluster = Cluster.find(id)
		group_id = cluster.group_id
		cluster = Cluster.find_by_group_id_and_visible_url(group_id, url)
		if cluster != nil
			render :text => "The URL matches another #{Group.get_clusters_label(group_id)}. Choose a different one.", :status => :bad_request
		else
			render :text => 'The URL is accepted. Please wait.'
		end
	end

	def move_exhibit
		if current_user == nil
			render :text => "You are not logged in. Has your session expired?"
			return
		end
		exhibit_id = params[:exhibit_id]
		group_id = params[:group_id]
		cluster_id = params[:cluster_id]
		dest_cluster = params[:dest_cluster]
		exhibit = Exhibit.find(exhibit_id)
		exhibit.cluster_id = dest_cluster == '0' ? nil : dest_cluster
		exhibit.save!
		cluster = cluster_id == '0' ? nil : Cluster.find(cluster_id)
		group = Group.find(group_id)
		GroupsUser.email_hook("exhibit", group_id, "An #{group.get_exhibits_label()} in #{Group.find(group_id).name} has been moved", "#{get_curr_user_name} has moved the #{group.get_exhibits_label()} \"#{exhibit.title}\" to #{Group.get_clusters_label(group_id)} \"#{cluster ? cluster.name : "no #{Group.get_clusters_label(group_id)}" }\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
		render :partial => '/groups/group_exhibits_list', :locals => { :group => Group.find(group_id), :cluster => cluster, :user_id => get_curr_user_id() }
end

	def remove_profile_picture
		if current_user == nil
			render :text => "You are not logged in. Has your session expired?"
			return
		end
		id = params[:id]
		cluster = Cluster.find(id)
		cluster.image = nil
		cluster.save
		GroupsUser.email_hook("group", cluster.group_id, "Profile thumbnail removed in #{Group.find(cluster.group_id).name}", "#{get_curr_user_name} has removed the separate thumbnail from the #{Group.get_clusters_label(cluster.group_id)} \"#{cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
    redirect_to :back
	end

	def edit_thumbnail
		if !user_signed_in?
			flash = "You are not logged in. Has your session expired?"
			render :text => respond_to_file_upload("stopEditGroupThumbnailUpload", flash)
			return
		end
		cluster_id = params[:id]
		cluster = Cluster.find(cluster_id)
		err = Image.save_image(params['image'], cluster)
		case err[:status]
		when :error then
			flash = err[:user_error]
			logger.error(err[:log_error])
		when :saved then
			flash = "OK:Thumbnail updated"
			GroupsUser.email_hook("group", cluster.group_id, "Profile thumbnail changed in #{Group.get_clusters_label(cluster.group_id)} in #{Group.find(cluster.group_id).name}", "#{get_curr_user_name} has uploaded a new thumbnail picture to the #{Group.get_clusters_label(cluster.group_id)} \"#{cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
		when :no_image then
			flash = "ERROR: No image specified"
		end
#		image = params['image']
#		if image && image
#			image = Image.new({ :uploaded_data => image })
#			end
#		begin
#			cluster.image = image
#			if cluster.save
#				cluster.image.save! if cluster.image
#				flash = "OK:Thumbnail updated"
#				GroupsUser.email_hook("group", cluster.group_id, "Profile thumbnail changed in #{Group.get_clusters_label(cluster.group_id)} in #{Group.find(cluster.group_id).name}", "#{get_curr_user_name} has uploaded a new thumbnail picture to the #{Group.get_clusters_label(cluster.group_id)} \"#{cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
#			else
#				flash = "Error updating thumbnail"
#			end
#		rescue
#			flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#		end
    render :text => respond_to_file_upload("stopEditGroupThumbnailUpload", flash)  # This is loaded in the iframe and tells the dialog that the upload is complete.
	end

  # GET /clusters/1
  # GET /clusters/1.xml
  def show
		# This can be called the conventional way with an id, or it can be called with a group/cluster path.
		if params[:id] == nil
			# we were given a group and cluster name instead
			group_name = params[:group]
			cluster_name = params[:cluster]
			group = Group.find_by_visible_url(group_name)
			group = Group.find_by_id(group_name) if group == nil
			if group == nil
				render_404
				return
			end

			cluster = Cluster.find_by_group_id_and_visible_url(group.id, cluster_name)
			cluster = Cluster.find_by_id(cluster_name) if cluster == nil
			if cluster
				params[:id] = cluster.id
			else
				render_404
				return
			end
		end

		@cluster = Cluster.find_by_visible_url(params[:id])
		if @cluster == nil
			@cluster = Cluster.find_by_id(params[:id])
		end
		if @cluster == nil
			redirect_to "/"
			return
		end
		@group = Group.find(@cluster.group_id)

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @cluster }
		end
  end

	def cluster_exhibits_list
		cluster = Cluster.find(params[:id])
		render :partial => 'cluster_exhibits_list', :locals => { :group => Group.find(cluster.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

  # POST /clusters
  # POST /clusters.xml
	def create
		# TODO-PER: the error processing can probably be simplified now that the image handling is in save_image.
		err = Image.save_image(params['image'], nil)
		img_id = nil
		case err[:status]
			when :error then
				logger.error(err[:log_error])
				render :text => respond_to_file_upload("stopNewClusterUpload", err[:user_error])  # This is loaded in the iframe and tells the dialog that the upload is complete.
				return
			when :saved
				img_id = err[:id]
		end
#		begin
#			if params['image'] && params['image'].length > 0
#				image = Image.new({ :uploaded_data => params['image'] })
#			end
			#params[:cluster]['visibility'] = 'everyone'
			group_id = params[:cluster][:group_id]
			name = params[:cluster][:name]
			cluster = Cluster.find_by_group_id_and_name(group_id, name)
			if cluster != nil
				flash = "Duplicate #{Group.get_clusters_label(group_id)} name. Please choose another."
			else
				@cluster = Cluster.new(params[:cluster])
				@cluster.image_id = img_id
				#err = false
				if @cluster.save
#					begin
#						@cluster.image.save! if @cluster.image
#					rescue
#						err = true
#						@cluster.delete
#						flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#					end
#					if err == false
						GroupsUser.email_hook("group", group_id, "New #{Group.get_clusters_label(group_id)} in #{Group.find(group_id).name}", "#{get_curr_user_name} has created the #{Group.get_clusters_label(group_id)} \"#{@cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
						flash = "OK:#{@cluster.id}"
#					end
				else
					flash = "Error creating #{Group.get_clusters_label(group_id)}"
				end
			end
#		rescue
#			flash = "Server error when creating #{Group.get_clusters_label(group_id)}."
#		end
    render :text => respond_to_file_upload("stopNewClusterUpload", flash)  # This is loaded in the iframe and tells the dialog that the upload is complete.
  end

  # PUT /clusters/1
  # PUT /clusters/1.xml
	def update
		@cluster = Cluster.find(params[:id])
		@cluster.update_attributes(params[:cluster])
		which = params[:cluster].keys.join(" and ")
		GroupsUser.email_hook("group", @cluster.group_id, "#{Group.get_clusters_label(@cluster.group_id)} changed in #{Group.find(@cluster.group_id).name}", "#{get_curr_user_name} has updated the field \"#{which}\" in #{Group.get_clusters_label(@cluster.group_id)} \"#{@cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))

		render :partial => 'cluster_details', :locals => { :group => Group.find(@cluster.group_id), :cluster => @cluster, :user_id => get_curr_user_id() }
	end

  # DELETE /clusters/1
  # DELETE /clusters/1.xml
  def destroy
    @cluster = Cluster.find(params[:id])
		group_id = @cluster.group_id
		GroupsUser.email_hook("group", group_id, "#{Group.get_clusters_label(@cluster.group_id)} deleted in #{Group.find(@cluster.group_id).name}", "#{get_curr_user_name} has deleted the #{Group.get_clusters_label(@cluster.group_id)} \"#{@cluster.name}\".", url_for(:controller => 'home', :action => 'index', :only_path => false))
    @cluster.destroy

		# Also remove the exhibits and discussions from being in the cluster.
		exhibits = Exhibit.where({cluster_id: params[:id]})
		exhibits.each { |exhibit|
			exhibit.cluster_id = nil
			exhibit.save!
		}
		threads = DiscussionThread.where({cluster_id: params[:id]})
		threads.each { |thread|
			thread.cluster_id = nil
			thread.save!
		}
		redirect_to :controller => 'groups', :action => "show", :id => group_id
  end
end
