class GroupsController < ApplicationController
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

	def accept_request
		success = GroupsUser.accept_request(params[:id])
		group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
		redirect_to :action => 'acknowledge_notification', :type => 'accept_request', :success => success, :group_id => group_id
	end

	def decline_request
		success = GroupsUser.decline_request(params[:id])
		group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
		redirect_to :action => 'acknowledge_notification', :type => 'decline_request', :success => success, :group_id => group_id
	end

	def join_group
		has_login = GroupsUser.has_login(params[:id])
		if has_login
			success = GroupsUser.join_group(params[:id])
			group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
			user_id = User.find(GroupsUser.find(Group.id_retriever(params[:id])).user_id)
			user = User.find(user_id)
			session[:user] = { :email => user.email, :fullname => user.fullname, :username => user.username, :role_names => user.role_names }
			redirect_to :action => 'acknowledge_notification', :type => 'join_group', :success => success, :group_id => group_id
		else
			redirect_to :action => 'create_login', :id => Group.id_retriever(params[:id]), :message => ''
		end
	end

	def create_login_create
		gu_id = params[:id]
		user_name = params[:user_name]
		email = params[:email]
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

		session[:user] = COLLEX_MANAGER.create_user(username, password.strip, email)
		params[:id] = Group.id_obfuscator(gu_id)
		join_group()
	end

	def decline_group
		success = GroupsUser.decline_group(params[:id])
		group_id = GroupsUser.get_group_from_obfuscated_id(params[:id])
		redirect_to :action => 'acknowledge_notification', :type => 'decline_group', :success => success, :group_id => group_id
	end

	 def leave_group
		 group_id = params[:group_id]
		 user_id = params[:user_id]
		 GroupsUser.leave_group(group_id, user_id)
		 redirect_to :back
	 end

	 def request_join
		 group_id = params[:group_id]
		 user_id = params[:user_id]
		 GroupsUser.request_join(group_id, user_id)
		 redirect_to :back
	 end

	def edit_membership
		group = params[:group]
		group.each {|id,value|
			gu = GroupsUser.find(id)
			if value['delete'] == 'true'
				gu.destroy
			else
				role = value['editor'] == 'true' ? 'editor' : 'member'
				if gu.role != role
					gu.role = role
					gu.save!
				end
			end
		}

		render :text => "ok"
	end

	def remove_profile_picture
		id = params[:id]
    group = Group.find(id)
		group.image = nil
		group.save
    redirect_to :back
	end

	def edit_thumbnail
		group_id = params[:id]
		group = Group.find(group_id)
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
		group.image = image
		if group.save
			group.image.save! if group.image
			flash = "OK:Thumbnail updated"
		else
			flash = "Error updating thumbnail"
		end
    render :text => "<script type='text/javascript'>window.top.window.stopEditGroupThumbnailUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
	end

  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
		if params[:id] == 'verify_group_title'
			title = params[:name]
			group = Group.find_by_name(title)
			if group == nil
				render :text => "ok"
			else
				render :text => "There is already a group with this title.", :status => :bad_request
			end
		else
			@group = Group.find(params[:id])

			respond_to do |format|
				format.html # show.html.erb
				format.xml  { render :xml => @group }
			end
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

  # POST /groups
  # POST /groups.xml
  def create
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
    @group = Group.new(params[:group])
		@group.use_styles = 0
		@group.image = image
		if @group.save
			@group.image.save! if @group.image
			flash = "OK:#{@group.id}"
			@group.invite_members(params[:emails])
		else
			flash = "Error creating group"
		end
    render :text => "<script type='text/javascript'>window.top.window.stopNewGroupUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.

#    respond_to do |format|
#      if @group.save
#        flash[:notice] = 'Group was successfully created.'
#        format.html { redirect_to(@group) }
#        format.html { redirect_to(@group) }
#        format.xml  { render :xml => @group, :status => :created, :location => @group }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
		@group.update_attributes(params[:group])

		if params[:emails]
			@group.invite_members(params[:emails])
		end
#    respond_to do |format|
#      if @group.update_attributes(params[:group])
#        flash[:notice] = 'Group was successfully updated.'
#        format.html { redirect_to(@group) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
#      end
#    end
		curr_user = session[:user] == nil ? nil : User.find_by_username(session[:user][:username])
		render :partial => 'group_details', :locals => { :group => @group, :user_id => curr_user.id }
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

		# Also remove the exhibits and discussions from being in the group.
		exhibits = Exhibit.find_all_by_group_id(params[:id])
		exhibits.each { |exhibit|
			exhibit.group_id = nil
			exhibit.save!
		}
		threads = DiscussionThread.find_all_by_group_id(params[:id])
		threads.each { |thread|
			thread.group_id = nil
			thread.save!
		}
		groupsusers = GroupsUser.find_all_by_group_id(params[:id])
		groupsusers.each { |gu|
			gu.destroy
		}
		redirect_to :controller => 'exhibits', :action => "index"
#    respond_to do |format|
#      format.html { redirect_to(groups_url) }
#      format.xml  { head :ok }
#    end
  end
end
