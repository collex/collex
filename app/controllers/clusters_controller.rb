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
  layout 'nines'
  before_filter :init_view_options

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :exhibits
    @uses_yui = true
    return true
  end
  public

	def move_exhibit
		exhibit_id = params[:exhibit_id]
		cluster_id = params[:cluster_id]
		exhibit = Exhibit.find(exhibit_id)
		exhibit.cluster_id = cluster_id
		exhibit.save!
		cluster = Cluster.find(cluster_id)
		render :partial => 'cluster_details', :locals => { :group => Group.find(cluster.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

	def remove_from_cluster
		exhibit_id = params[:exhibit_id]
		cluster_id = params[:cluster_id]
		group_id = params[:group_id]
		exhibit = Exhibit.find(exhibit_id)
		exhibit.cluster_id = nil
		exhibit.save!
		cluster = Cluster.find(cluster_id)
		render :partial => 'cluster_details', :locals => { :group => Group.find(cluster.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

	def remove_profile_picture
		id = params[:id]
    cluster = Cluster.find(id)
		cluster.image = nil
		cluster.save
    redirect_to :back
	end

	def edit_thumbnail
		cluster_id = params[:id]
		cluster = Cluster.find(cluster_id)
		image = params['image']
		if image && image
			image = Image.new({ :uploaded_data => image })
#			if image	# If there were an error in uploading the image, don't go further.
#				begin
#					user.image.save!
#					user.save
#				rescue
#					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#				end
			end
		cluster.image = image
		if cluster.save
			cluster.image.save! if cluster.image
			flash = "OK:Thumbnail updated"
		else
			flash = "Error updating thumbnail"
		end
    render :text => "<script type='text/javascript'>window.top.window.stopEditGroupThumbnailUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
	end

  # GET /clusters/1
  # GET /clusters/1.xml
  def show
		if params[:id] == 'verify_cluster_title'
			title = params[:name]
			cluster = Cluster.find_by_name(title)
			if cluster == nil
				render :text => "ok"
			else
				render :text => "There is already a cluster with this title.", :status => :bad_request
			end
		else
			@cluster = Cluster.find(params[:id])
			@group = Group.find(@cluster.group_id)

			respond_to do |format|
				format.html # show.html.erb
				format.xml  { render :xml => @cluster }
			end
		end
  end

	def cluster_exhibits_list
		cluster = Cluster.find(params[:id])
		render :partial => 'cluster_exhibits_list', :locals => { :group => Group.find(cluster.group_id), :cluster => cluster, :user_id => get_curr_user_id() }
	end

  # POST /clusters
  # POST /clusters.xml
  def create
		begin
			if params['image'] && params['image'].length > 0
				image = Image.new({ :uploaded_data => params['image'] })
	#			if image	# If there were an error in uploading the image, don't go further.
	#				begin
	#					user.image.save!
	#					user.save
	#				rescue
	#					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
	#				end
				end
			@cluster = Cluster.new(params[:cluster])
			@cluster.image = image
			err = false
			if @cluster.save
				begin
					@cluster.image.save! if @cluster.image
				rescue
					err = true
					@cluster.delete
					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
				end
				if err == false
					flash = "OK:#{@cluster.id}"
				end
			else
				flash = "Error creating cluster"
			end
		rescue
			flash = "Server error when creating cluster."
		end
    render :text => "<script type='text/javascript'>window.top.window.stopNewClusterUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
  end

  # PUT /clusters/1
  # PUT /clusters/1.xml
  def update
    @cluster = Cluster.find(params[:id])
		@cluster.update_attributes(params[:cluster])

		render :partial => 'cluster_details', :locals => { :group => Group.find(@cluster.group_id), :cluster => @cluster, :user_id => get_curr_user_id() }
  end

  # DELETE /clusters/1
  # DELETE /clusters/1.xml
  def destroy
    @cluster = Cluster.find(params[:id])
		group_id = @cluster.group_id
    @cluster.destroy

		# Also remove the exhibits and discussions from being in the cluster.
		exhibits = Exhibit.find_all_by_cluster_id(params[:id])
		exhibits.each { |exhibit|
			exhibit.cluster_id = nil
			exhibit.save!
		}
		threads = DiscussionThread.find_all_by_cluster_id(params[:id])
		threads.each { |thread|
			thread.cluster_id = nil
			thread.save!
		}
		redirect_to :controller => 'groups', :action => "show", :id => group_id
  end
end
