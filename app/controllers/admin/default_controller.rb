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

	URI_BASE = 'http://nines.org/peer-reviewed-exhibit/'

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
  
  def change_category
    exhibit_id = params[:exhibit_id]
    category = params[:category_id]
    exhibit = Exhibit.find(exhibit_id)
		old_category = exhibit.category
    exhibit.update_attribute('category', category)
		if category == 'peer-reviewed'
			index_exhibit(exhibit_id)
		elsif old_category == 'peer-reviewed'
			unindex_exhibit(exhibit_id)
		end
    render :text => category
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
				LoginMailer.deliver_accept_abuse_report_to_reporter({ :comment => comment }, user.email)
			}
			LoginMailer.deliver_accept_abuse_report_to_commenter({ :comment => comment }, User.find(commenter).email)
		rescue Exception => msg
			logger.error("**** ERROR: Can't send email: " + msg)
		end
		redirect_to :action => 'forum_pending_reports'
	end

	def remove_abuse_flag
		id = params[:comment]
		DiscussionComment.remove_abuse_flag(id)
		redirect_to :action => 'forum_pending_reports'
	end

	private

	def strip_tags(str)
		ret = ""
		arr = str.split('<')
		arr.each {|el|
			gt = el.index('>')
			if gt
				ret += el.slice(gt+1..el.length-1)
			else
				ret += el
			end
		}
		return ret
	end

	def unindex_exhibit(exhibit_id)
		solr = CollexEngine.new()#['exhibits'])
		#exhibit = Exhibit.find(exhibit_id)
		0.upto(10) {|i|	# TODO-PER: hack! how do you find the number of sections?
			solr.remove_object("#{URI_BASE}#{exhibit_id}/#{i}")
		}
		solr.remove_object("#{URI_BASE}#{exhibit_id}")
		solr.commit()
	end

	def index_exhibit(exhibit_id)
#		boost_section = 15.0
#		boost_exhibit = 12.0
		solr = CollexEngine.new()#['exhibits'])
		exhibit = Exhibit.find(exhibit_id)
		author_rec = User.find(exhibit.alias_id ? exhibit.alias_id : exhibit.user_id)
		author = author_rec.fullname ? author_rec.fullname : author_rec.username
		url = exhibit.visible_url ? "/exhibits/view/#{exhibit.visible_url}" : "/exhibits/view/#{exhibit_id}"
		full_data = []
		section_name = ""	# The sections are set whenever there is a new header element; it is independent of the page.
		num_sections = 0
		section_page = 1
		data = []
		genres = [ 'Criticism', 'Visual Art', 'Letters' ]
#		genres = exhibit.genres.split(',')
		pages = exhibit.exhibit_pages
		pages.each{|page|
			elements = page.exhibit_elements
			elements.each {|element|
				if element.exhibit_element_layout_type == 'header'
					if section_name.length > 0
						doc = { :uri => "#{URI_BASE}#{exhibit_id}/#{num_sections}", :title => "#{exhibit.title} (#{section_name})", :thumbnail => exhibit.thumbnail,
							:genre => genres, :archive => "exhibit", :role_AUT => author,	:url => "#{url}?page=#{section_page}", :text_url => url, :source => "#{SITE_NAME}",
							:text => data.join("\r\n") }
#						solr.add_object(doc, boost_section)
					end
					section_name = element.element_text
					section_page = page.position
					num_sections += 1
					data = []
				end
				data.push(strip_tags(element.element_text)) if element.element_text
				data.push(strip_tags(element.element_text2)) if element.element_text2
				full_data.push(strip_tags(element.element_text)) if element.element_text
				full_data.push(strip_tags(element.element_text2)) if element.element_text2
				if element.header_footnote_id
					footnote = ExhibitFootnote.find(element.header_footnote_id)
					data.push(strip_tags(footnote.footnote)) if footnote.footnote
					full_data.push(strip_tags(footnote.footnote)) if footnote.footnote
				end
				illustrations = element.exhibit_illustrations
				illustrations.each {|illustration|
					data.push(strip_tags(illustration.illustration_text)) if illustration.illustration_text
					data.push(illustration.caption1) if illustration.caption1
					data.push(illustration.caption2) if illustration.caption2
					data.push(illustration.alt_text) if illustration.alt_text
					full_data.push(strip_tags(illustration.illustration_text)) if illustration.illustration_text
					full_data.push(illustration.caption1) if illustration.caption1
					full_data.push(illustration.caption2) if illustration.caption2
					full_data.push(illustration.alt_text) if illustration.alt_text
					if illustration.caption1_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption1_footnote_id)
						data.push(strip_tags(footnote.footnote)) if footnote.footnote
						full_data.push(strip_tags(footnote.footnote)) if footnote.footnote
					end
					if illustration.caption2_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption2_footnote_id)
						data.push(strip_tags(footnote.footnote)) if footnote.footnote
						full_data.push(strip_tags(footnote.footnote)) if footnote.footnote
					end
				}
			}
			if data.length > 0 && section_name.length > 0
				doc = { :uri => "#{URI_BASE}#{exhibit_id}/#{num_sections}", :title => "#{exhibit.title} (#{section_name})", :thumbnail => exhibit.thumbnail,
					:genre => genres, :archive => "exhibit", :role_AUT => author,	:url => "#{url}?page=#{section_page}", :text_url => url, :source => "#{SITE_NAME}",
					:text => data.join("\r\n") }
#				solr.add_object(doc, boost_section)
			end
		}
		doc = { :uri => "#{URI_BASE}#{exhibit_id}", :title => "#{exhibit.title}", :thumbnail => exhibit.thumbnail,
			:genre => genres, :archive => "exhibit", :role_AUT => author,	:url => "#{url}", :text_url => url, :source => "#{SITE_NAME}",
			:text => full_data.join("\r\n") }
		solr.add_object(doc)#, boost_exhibit)
		solr.commit()
	end
end
