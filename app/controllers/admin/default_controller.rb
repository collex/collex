##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

class Admin::DefaultController < Admin::BaseController

  def refresh_cached_objects
    # This reads all the items in the cached_resources table, and recreates the cached_properties table by retrieving the object from solr.
    # TODO: If an object was collected but is no longer available, this will just ignore it. Instead, it should create a list for an administator to straighten out.

    # TODO: If a user was deleted, all the user's collected objects and tags will still be in the system. We might want to weed out the cached_resources table
    # based on the collected_items table.
    # TODO: The tagassigns table has collected_item_ids. If we weed out collected_items, then we need to update that table, too.
    # TODO: The cached_properties table may contain properties that are orphaned and don't have a valid cached resource id

    cached_resources = CachedResource.find(:all)
    cached_resources.each do |cr|
      cr.recache_properties()
    end

    redirect_to :controller => 'admin/default', :action => 'index'
  end
  
#  def change_category
#    exhibit_id = params[:exhibit_id]
#    category = params[:category_id]
#    badge = params[:badge_id]
#    exhibit = Exhibit.find(exhibit_id)
#		old_category = exhibit.category
#    exhibit.update_attribute('category', category)
#    exhibit.update_attribute('badge_id', badge)
#		if category == 'peer-reviewed'
#			index_exhibit(exhibit_id)
#		elsif old_category == 'peer-reviewed'
#			unindex_exhibit(exhibit_id)
#		end
#    render :partial => 'exhibit_tr', :locals => { :exhibit => exhibit }
#  end

	def change_group_type
    group_id = params[:group_id]
    group_type = params[:group_type]
    badge = params[:badge_id]
    header_text_color = params[:header_text_color]
    header_background_color = params[:header_background_color]
    link_color = params[:link_color]
    publication_image = params[:publication_image_id]
    group = Group.find(group_id)
		old_type = group.group_type
    group.update_attribute('group_type', group_type)
    group.update_attribute('badge_id', badge)
    group.update_attribute('publication_image_id', publication_image)
    group.update_attribute('header_color', header_text_color)
    group.update_attribute('header_background_color', header_background_color)
    group.update_attribute('link_color', link_color)
		if group_type == 'peer-reviewed'
			exhibits = Exhibit.find_all_by_group_id(group_id)
			exhibits.each {|exhibit|
				exhibit.adjust_indexing(:group_becomes_peer_reviewed)
			}
			(CollexEngine.new).commit()
		elsif old_type == 'peer-reviewed'
			exhibits = Exhibit.find_all_by_group_id(group_id)
			exhibits.each {|exhibit|
				exhibit.adjust_indexing(:group_leaves_peer_reviewed)
			}
			(CollexEngine.new).commit()
		end
   render :partial => 'group_tr', :locals => { :group => group }
	end

	def delete_comment
		id = params[:comment]
		comment = DiscussionComment.find(id)
		commenter = comment.user_id
		reporter_ids = comment.reporter_ids
		DiscussionComment.delete_comment(id, session[:user], is_admin?)
		begin
			ids = reporter_ids.split(',')
			ids.each { |reporter_id|
				user = User.find(reporter_id)
				#LoginMailer.deliver_accept_abuse_report_to_reporter({ :comment => comment }, user.email)
				body = "Thanks for reporting the comment by #{User.find(comment.user_id).fullname}. It has been removed.\n\n"
				EmailWaiting.cue_email(SITE_NAME, ActionMailer::Base.smtp_settings[:user_name], user.fullname, user.email, "Abusive Comment Report Accepted", body, url_for(:controller => 'home', :action => 'index', :only_path => false), "")
			}
			#LoginMailer.deliver_accept_abuse_report_to_commenter({ :comment => comment }, User.find(commenter).email)
			body = "Your comment on #{comment.created_at } was considered inappropriate and has been removed by the administrator. The text of your comment was:\n\n"
			body += "#{@template.strip_tags(comment.comment)}\n\n"
			EmailWaiting.cue_email(SITE_NAME, ActionMailer::Base.smtp_settings[:user_name], User.find(commenter).fullname, User.find(commenter).email, "Abusive Comment Deleted", body, url_for(:controller => 'home', :action => 'index', :only_path => false), "")
		rescue Exception => msg
			logger.error("**** ERROR: Can't send email: " + msg)
		end
		redirect_to :action => 'forum_pending_reports'
	end

	def remove_abuse_flag
		id = params[:comment]
		DiscussionComment.remove_abuse_flag(id, url_for(:controller => 'home', :action => 'index', :only_path => false))
		redirect_to :action => 'forum_pending_reports'
	end

#	def unindex_exhibit(exhibit_id)
#		exhibit = Exhibit.find(exhibit_id)
#		exhibit.unindex_exhibit()
#	end

#	def index_exhibit(exhibit_id)
#		exhibit = Exhibit.find(exhibit_id)
#		exhibit.index_exhibit(true)
#	end

	def index
		@use_test_index = session[:use_test_index]
	end

	def stats
		@show_all = session[:show_all_stats]
	end

	def stats_show_all
		session[:show_all_stats] = session[:show_all_stats] == 'true' ? 'false' : 'true'
		redirect_to :action => 'stats'
	end

	def use_test_index
		use_test = params[:test]
		session[:use_test_index] = use_test
    redirect_to :controller => 'admin/default', :action => 'index'
	end

	def add_badge
		badge = PeerReview.create({})
		image = params['image']
		if image && image
			image = ImageFull.new({ :uploaded_data => image })
		end
		begin
			badge.image_full = image
			if badge.save
				badge.image_full.save! if badge.image_full
				flash = "OK:Badge updated"
			else
				flash = "Error updating badge"
			end
		rescue
			flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
		end
    render :text => "<script type='text/javascript'>window.top.window.stopAddBadgeUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
	end

	def add_publication_image
		publication_image = PublicationImage.create({})
		image = params['image']
		if image && image
			image = ImageFull.new({ :uploaded_data => image })
		end
		begin
			publication_image.image_full = image
			if publication_image.save
				publication_image.image_full.save! if publication_image.image_full
				flash = "OK:Publication image updated"
			else
				flash = "Error updating publication image"
			end
		rescue Exception => msg
			flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
		end
		render :text => "<script type='text/javascript'>window.top.window.stopAddPublicationImageUpload('#{flash}');</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
	end
end
