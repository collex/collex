# encoding: UTF-8
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
require 'nokogiri'

class Exhibit < ActiveRecord::Base
	#require 'rexml/document'
  has_many :exhibit_pages, :order => :position, :dependent=>:destroy
  has_many :exhibit_objects, :dependent=>:destroy
	belongs_to :group
	belongs_to :cluster

	attr_accessor :editors_only
	attr_accessor :group_only
	attr_accessor :author

  after_save :handle_solr

  def handle_solr
	  SearchUserContent.delay.index('exhibit', self.id)
  end
	
	def self.can_edit(user, exhibit_id)
		return false if user == nil
		return false if exhibit_id == nil
		exhibit = Exhibit.find(exhibit_id)
		if exhibit.is_published == 1 && exhibit.group_id
			group = Group.find(exhibit.group_id)
			return false if group.group_type == 'peer-reviewed'
		end
		return true if user.role_names.include?('admin')
		return exhibit.user_id == user.id
	end

	def can_view(user)
		# The user can view the exhibit if:
		# - they are the author or an admin
		# - the exhibit is not in a group and is published
		# - the exhibit is in a group and the group allows it
		return true if user != nil && user.role_names.include?('admin')
		return true if user != nil && (user.id == self.user_id || user.id == self.alias_id)
		return true if self.group_id == nil && self.is_published == 1
		if self.group_id != nil
			group = Group.find(self.group_id)
			return group.can_view_exhibit(self, user != nil ? user.id : nil)
		end
		return false
	end

	def reset_fonts_to_default
		# set the default values for fields that were added later
		self.header_font_name = 'Arial'
		self.header_font_size = '24'
		self.text_font_name = 'Times New Roman'
		self.text_font_size = '18'
		self.illustration_font_name = 'Trebuchet MS'
		self.illustration_font_size = '14'
		self.caption1_font_name = 'Trebuchet MS'
		self.caption1_font_size = '14'
		self.caption2_font_name = 'Trebuchet MS'
		self.caption2_font_size = '14'
		self.endnotes_font_name = 'Times New Roman'
		self.endnotes_font_size = '16'
		self.footnote_font_name = 'Times New Roman'
		self.footnote_font_size = '16'
		self.save
	end

	def fonts_match_defaults
		return false if self.header_font_name != 'Arial'
		return false if self.header_font_size != '24'
		return false if self.text_font_name != 'Times New Roman'
		return false if self.text_font_size != '18'
		return false if self.illustration_font_name != 'Trebuchet MS'
		return false if self.illustration_font_size != '14'
		return false if self.caption1_font_name != 'Trebuchet MS'
		return false if self.caption1_font_size != '14'
		return false if self.caption2_font_name != 'Trebuchet MS'
		return false if self.caption2_font_size != '14'
		return false if self.endnotes_font_name != 'Times New Roman'
		return false if self.endnotes_font_size != '16'
		return false if self.footnote_font_name != 'Times New Roman'
		return false if self.footnote_font_size != '16'
		return true
	end
	
  def self.factory(user_id, url, title, thumbnail, group_id, cluster_id)
    thumbnail = thumbnail.strip
    if thumbnail.length > 0 && thumbnail.index('http') != 0
      thumbnail = "http://" + thumbnail
    end
		resource_name = title
		found = Exhibit.find_by_resource_name(resource_name)
		suffix = 1
		while found do
			resource_name += "#{suffix}"
			found = Exhibit.find_by_resource_name(resource_name)
			suffix += 1
		end
		params = { :title => title, :resource_name => resource_name, :user_id => user_id, :thumbnail => thumbnail, :visible_url => transform_url(url), :is_published => 0, :license_type => self.get_default_license() }
		params[:group_id] = group_id if group_id != nil
		params[:cluster_id] = cluster_id if cluster_id != nil
    exhibit = Exhibit.create(params)
    exhibit.insert_example_page(1)
    #exhibit.insert_example_page(2)
		exhibit.reset_fonts_to_default()
		exhibit.bump_last_change()
    return exhibit
  end
  
  def self.transform_url(url)
    # The legal characters are: Letters (A-Z and a-z), numbers (0-9) and the characters '-', '~' and '_'
    # All other characters are replaced by underscores, then multiple underscores are replaced by one underscore.
    # This never returns more than 30 characters.

	return url if url == nil
    url = url.tr('^A-Za-z0-9\-\~', '_')
    # remove more than one underline in a row
    url = url.gsub(/_+/, '_')
    url = url.slice(0..29) if url.length > 30
    return url
  end
  
  def insert_example_page(page_num)
    new_page = ExhibitPage.create(:exhibit_id => id)
    new_page.insert_at(page_num)
    
    type1 = 'pic_text'
    type2 = 'text_pic'
    if page_num == 2
      type1 = 'text_pic'
      type2 = 'pic_text'
    end
    el = new_page.insert_element(1)
		if page_num == 1
	    el.element_text = "Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above."
		else
	    el.element_text = "Enter your text here."
		end
    #el.element_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
    el.save
    el.change_layout(type1)
    ExhibitIllustration.factory(el.id, 1)

    el = new_page.insert_element(2)
    el.element_text = "Enter your text here."
    #el.element_text = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
    el.save

    el = new_page.insert_element(3)
    el.element_text = "Enter your text here."
    #el.element_text = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."
    el.save
    el.change_layout(type2)
    ExhibitIllustration.factory(el.id, 1)
  end
  
  def insert_page(page_num)
    new_page = ExhibitPage.create(:exhibit_id => id)
    new_page.insert_at(page_num)
    new_page.insert_element(1)
  end
  
  def move_page_up(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_higher()
  end
  
  def move_page_down(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_lower()
  end
  
  def delete_page(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.remove_from_list()
    curr_page.destroy
  end
  
  def self.find_by_illustration_id(illustration_id)
    return nil if illustration_id == nil || illustration_id == 0
    illustration = ExhibitIllustration.find_by_id(illustration_id)
    return nil if illustration == nil
    return self.find_by_element_id(illustration.exhibit_element_id)
  end
  
  def self.find_by_element_id(element_id)
    return nil if element_id == nil || element_id == 0
    element = ExhibitElement.find_by_id(element_id)
    return nil if element == nil
    page = ExhibitPage.find_by_id(element.exhibit_page_id)
    return nil if page == nil
    return Exhibit.find(page.exhibit_id)
  end

  def self.all_my_exhibits(user_id)
    my_exhibits = where({user_id: user_id})
    return [] if my_exhibits.nil? || my_exhibits.length == 0
    return my_exhibits.map { |exhibit| { value: exhibit.id, text: exhibit.title }  }
  end
  
  def self.js_array_of_all_public_exhibits()
    exhibits = self.get_all_published()
    str = ""
    for exhibit in exhibits
      if str != ""
        str += ",\n"
      end
      str += "{ title: \"#{CGI.escapeHTML(exhibit.title)}\", thumbnail: \"#{exhibit.thumbnail}\" }"
    end
    return str
  end

	# TODO-PER: All the license stuff can be refactored now that sharing and license have been separated into two variables.
	# license_type can only be between 1-6 now, so the zero cases aren't ever used.
	
	def self.get_default_license()
		return 4
	end

  def self.get_sharing_text(s)
    case s
      when nil then return ""
      when 0 then return ""
      when 1 then return "This license lets others distribute, remix, tweak, and build upon your work, even commercially, as long as they credit you for the original creation. This is the most accommodating of licenses offered, in terms of what others can do with your works licensed under Attribution."
      when 2 then return "This license lets others remix, tweak, and build upon your work even for commercial reasons, as long as they credit you and license their new creations under the identical terms. This license is often compared to open source software licenses. All new works based on yours will carry the same license, so any derivatives will also allow commercial use."
      when 3 then return "This license allows for redistribution, commercial and non-commercial, as long as it is passed along unchanged and in whole, with credit to you."
      when 4 then return "This license lets others remix, tweak, and build upon your work non-commercially, and although their new works must also acknowledge you and be non-commercial, they don’t have to license their derivative works on the same terms."
      when 5 then return "This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit you and license their new creations under the identical terms. Others can download and redistribute your work just like the by-nc-nd license, but they can also translate, make remixes, and produce new stories based on your work. All new work based on yours will carry the same license, so any derivatives will also be non-commercial in nature."
      when 6 then return "This license is the most restrictive of our six main licenses, allowing redistribution. This license is often called the “free advertising” license because it allows others to download your works and share them with others as long as they mention you and link back to you, but they can’t change them in any way or use them commercially."
      else return ""
    end
  end

  def published?()
    return is_published != nil && is_published != 0
  end
  
  def get_sharing()
    return Exhibit.get_sharing_static(get_effective_license_type())
  end
  
  def get_sharing_int()
		license = get_effective_license_type()
    return Exhibit.is_license_specified(license) ? license : Exhibit.get_default_license()
  end
  
  def self.get_sharing_static(s)
    case s
      when nil then return ""
      when 0 then return ""
      when 1 then return "Attribution"
      when 2 then return "Attribution Share Alike"
      when 3 then return "Attribution No Derivatives"
      when 4 then return "Attribution Non-Commercial"
      when 5 then return "Attribution Non-Commercial Share Alike"
      when 6 then return "Attribution Non-Commercial No Derivatives"
      else return ""
    end
  end
  
  def set_sharing(str)
    case str
      #when "Not Shared": self.is_published = 0
      when "Attribution" then self.license_type = 1
      when "Attribution Share Alike" then self.license_type = 2
      when "Attribution No Derivatives" then self.license_type = 3
      when "Attribution Non-Commercial" then self.license_type = 4
      when "Attribution Non-Commercial Share Alike" then self.license_type = 5
      when "Attribution Non-Commercial No Derivatives" then self.license_type = 6
      #when '0': self.is_published = 0
      when '1' then self.license_type = 1
      when '2' then self.license_type = 2
      when '3' then self.license_type = 3
      when '4' then self.license_type = 4
      when '5' then self.license_type = 5
      when '6' then self.license_type = 6
      else self.license_type = self.get_default_license()
    end
  end

  def self.get_sharing_license_type(license_type)
    case license_type
      when 1 then return "by"
      when 2 then return "by-sa"
      when 3 then return "by-nd"
      when 4 then return "by-nc"
      when 5 then return "by-nc-sa"
      when 6 then return "by-nc-nd"
      else return "ERROR"
    end
  end

  def get_sharing_widget()
    #if published?
      license = Exhibit.get_sharing_license_type(get_effective_license_type())
      return "#{get_sharing_icon_with_link()}<p>This work is licensed under a <a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
        license + "/3.0/us/\">Creative Commons " + get_sharing() + " 3.0 United States License</a>.</p>"
    #else
    #  return "This exhibit is visible to just me."
    #end
  end
  
  def get_sharing_image()
    return Exhibit.get_sharing_icon_url(get_effective_license_type())
  end
  
  def self.get_sharing_icon_url(license_type)
    if license_type != nil && license_type != 0
      return "<img alt='Creative Commons License' style='border-width:0' src='http://i.creativecommons.org/l/#{get_sharing_license_type(license_type)}/3.0/us/88x31.png' />"
    else
      return ActionController::Base.new.view_context.image_tag('not_shared.jpg', alt: 'Creative Commons License', height: '31', style: 'border-width:0')
    end
  end
  
  def get_sharing_icon_with_link()
		effective_license = get_effective_license_type()
    license = Exhibit.get_sharing_license_type(effective_license)
    return "<a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
      license + "/3.0/us/\" title='This work is licensed under a Creative Commons #{Exhibit.get_sharing_static(effective_license)} 3.0 United States License'>#{Exhibit.get_sharing_icon_url(effective_license)}</a>"
  end
  
  def self.get_all_published
    return Exhibit.all(:conditions => [ 'is_published <> 0'])
  end

	def self.is_license_specified(license_type)
		return license_type != nil && license_type != '' && license_type.to_i > 0
	end

	def self.get_license_info(add_inherit, group_id)
		ret = []
		if add_inherit
		   group = Group.find(group_id)
		   group_label = group.get_exhibits_label().downcase()
			ret.push({ :id => 0, :text => "Each #{group_label} can specify a license.", :icon => self.get_sharing_icon_url(0), :abbrev => self.get_sharing_static(0) })
		end
    1.upto(6) do |i|
			ret.push({ :id => i, :text => self.get_sharing_text(i), :icon => self.get_sharing_icon_url(i), :abbrev => self.get_sharing_static(i) })
		end
		return ret
	end

#  def self.getJsonLicenseInfo()
#    str = "[ { text: 'Exhibit should be visible to just me', icon: \"#{self.get_sharing_icon_url(0)}\" },"
#    1.upto(6) do |i|
#      str = str + "{ text: '" + self.get_sharing_text(i) + "', icon: \"" + self.get_sharing_icon_url(i) + "\" }"
##      str = str + "{ text: '" + "t" + "', icon: \"" + "i" + "\" }"
#      str = str + "," if i != 6
#    end
#    str = str + "]"
#    return str
#  end
  
  def get_id_if_no_visible_url()
    if visible_url == nil || visible_url.length == 0
      return "#{id}"
    end
    return ''
  end

#  def self.find_by_section_id(section_id)
#    section = ExhibitSection.find(section_id)
#    page = ExhibitPage.find(section.exhibit_page_id)
#    return Exhibit.find(page.exhibit_id)
#  end

	def self.has_footnotes(id)
		exhibit = Exhibit.find_by_visible_url(id)
		exhibit = Exhibit.find(id) if exhibit == nil
		for page in exhibit.exhibit_pages
			for element in page.exhibit_elements
				case element.exhibit_element_layout_type
				when 'header' then
					return true if element.header_footnote_id != nil
				when 'pic_text' then
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'pic_text_pic' then
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[1]) > 0
				when 'pics' then
					for illustration in element.exhibit_illustrations
						return true if exhibit.count_footnotes_from_illustration(illustration) > 0
					end
				when 'text' then
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'blockquote' then
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'text_pic' then
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
				when 'text_pic_text' then
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
					return true if exhibit.count_footnotes_from_text(element.element_text2) > 0
				end
			end
		end
		return false
	end

	def extract_footnotes_from_illustration(illustration)
		footnotes = []
		if illustration.illustration_type == 'Textual Illustration'
			footnotes = self.extract_footnotes_from_text(illustration.illustration_text)
		end
		footnotes.push(ExhibitFootnote.find(illustration.caption1_footnote_id).footnote) if illustration.caption1_footnote_id != nil
		footnotes.push(ExhibitFootnote.find(illustration.caption2_footnote_id).footnote) if illustration.caption2_footnote_id != nil
		return footnotes
	end

	def count_footnotes_from_illustration(illustration)
		return 0 if illustration == nil
		count = 0
		if illustration.illustration_type == 'Textual Illustration'
			count += self.count_footnotes_from_text(illustration.illustration_text)
		end
		count += 1 if illustration.caption1_footnote_id != nil
		count += 1 if illustration.caption2_footnote_id != nil
		return count
	end

	private
		def extract_up_to_matching_span(text)
			# this takes a string and returns the first part of it up to the </span>. This takes into account extra <span>...</span> pairs that are embedded.
			arr = text.split('<')
			left = ""
			level = 0
			arr.each { |a|
				if a.index('span') == 0
					level += 1
					left += '<' + a
				elsif a.index('/span') == 0
					level -= 1
					if level != -1
						left += '<' + a
					else
						break
					end
				else
					left += '<' + a
				end
			}
			left = left.sub('<', '')	# because we are placing '<' at the beginning of each concatination, we'll have an extra one at the beginning.

			return left
		end

	public
	def extract_links_from_text(text)
		# We are scanning for footnotes that have the following structure:
		#<span title="XXX" real_link="YYY" class="nines_linklike">ZZZ</span>
		#<span title="XXX" real_link="YYY" class="ext_linklike">ZZZ</span>
		# We are trying to extract the YYY and the ZZZ
		link_prefix = "<span title=\""
		link_mid = "real_link=\""
		link_signature = "class=\"nines_linklike\">"
		link_signature2 = "class=\"ext_linklike\">"

		links = []
		arr = text.split(link_prefix)
		arr.shift	# the first element won't have a link in it.
		# this may be a false alarm, so just ignore the item if the rest of it doesn't match
		arr.each { |f|
			arr2 = f.split(link_mid)
			if arr2.length == 2
				#arr2[1] now contains the url, plus the rest of the unparsed part.
				arr3 = arr2[1].split('"')
				url = arr3[0]
				# look for either link type
				arr3 = arr2[1].split(link_signature)
				arr3 = arr2[1].split(link_signature2) if arr3.length == 1
				if arr3.length == 2
					text = extract_up_to_matching_span(arr3[1])
					cr = CachedProperty.first(:conditions => [ "name = ? AND value = ?", 'url', url ])
					name = nil
					if cr
						cr2 = CachedProperty.first(:conditions => [ "name = ? AND cached_resource_id = ?", 'title', cr.cached_resource_id ])
						if cr2
							name = cr2.value
						end
					end
					links.push({ :text => text, :url => url, :name => name })
  			end
			end
		}
		return links
	end

	def extract_links_from_illustration(illustration)
		links = []
		if illustration.illustration_type == 'Textual Illustration'
			links = self.extract_footnotes_from_text(illustration.illustration_text)
		end
		return links
	end

	def extract_footnotes_from_text(text)
		# We are scanning for footnotes that have the following structure:
		footnote_prefix = '<a href="#" onclick=\'var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">'
		# footnote number
		footnote_mid = '</a><span class="hidden">'
		# actual footnote
		# '</span>'

		footnotes = []
		arr = text.split(footnote_prefix)
		arr.shift	# the first element won't have a footnote in it.
		arr.each { |f|
			arr2 = f.split(footnote_mid)
			if arr2.length == 2
				foot = extract_up_to_matching_span(arr2[1])
				footnotes.push(foot)
			end
		}
		return footnotes
	end

	def count_footnotes_from_text(text)
		# We are scanning for footnotes that have the following structure:
		footnote_prefix = '<a href="#" onclick=\'var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">'
		# footnote number
		footnote_mid = '</a><span class="hidden">'
		# actual footnote
		footnote_end = '</span>'

		count = 0
		arr = text.split(footnote_prefix)
		arr.shift	# the first element won't have a footnote in it.
		arr.each { |f|
			arr2 = f.split(footnote_mid)
			if arr2.length == 2
				arr3 = arr2[1].split(footnote_end)
				count += 1
			end
		}
		return count
	end

	def get_all_footnotes()
		footnotes = []
		for page in self.exhibit_pages
			for element in page.exhibit_elements
				case element.exhibit_element_layout_type
				when 'header' then
					footnotes.push(ExhibitFootnote.find(element.header_footnote_id).footnote) if element.header_footnote_id != nil
				when 'pic_text' then
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'pic_text_pic' then
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[1]))
				when 'pics' then
					for illustration in element.exhibit_illustrations
						footnotes.concat(self.extract_footnotes_from_illustration(illustration))
					end
				when 'text' then
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'blockquote' then
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'text_pic' then
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
				when 'text_pic_text' then
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
					footnotes.concat(self.extract_footnotes_from_text(element.element_text2))
				else
					# this will happen if a new type is added but this method is not updated to handle it.
					footnotes.push("Unknown: #{element.exhibit_element_layout_type}")
				end

			end
		end
		return footnotes
	end

	def get_starting_footnote_per_page()
		footnotes = []
		count = 1
		for page in self.exhibit_pages
			footnotes.push(count)
			for element in page.exhibit_elements
				case element.exhibit_element_layout_type
				when 'header' then
					count += 1 if element.header_footnote_id != nil
				when 'pic_text' then
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
					count += self.count_footnotes_from_text(element.element_text)
				when 'pic_text_pic' then
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
					count += self.count_footnotes_from_text(element.element_text)
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[1])
				when 'pics' then
					for illustration in element.exhibit_illustrations
						count += self.count_footnotes_from_illustration(illustration)
					end
				when 'text' then
					count += self.count_footnotes_from_text(element.element_text)
				when 'blockquote' then
					count += self.count_footnotes_from_text(element.element_text)
				when 'text_pic' then
					count += self.count_footnotes_from_text(element.element_text)
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
				when 'text_pic_text' then
					count += self.count_footnotes_from_text(element.element_text)
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
					count += self.count_footnotes_from_text(element.element_text2)
				end
			end
		end
		return footnotes
	end

	def get_all_links()
		pages = []
		for page in self.exhibit_pages
			links = []
			for element in page.exhibit_elements
				case element.exhibit_element_layout_type
				when 'pic_text' then
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
					links.concat(self.extract_links_from_text(element.element_text))
				when 'pic_text_pic' then
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
					links.concat(self.extract_links_from_text(element.element_text))
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[1]))
				when 'pics' then
					for illustration in element.exhibit_illustrations
						links.concat(self.extract_links_from_illustration(illustration))
					end
				when 'text' then
					links.concat(self.extract_links_from_text(element.element_text))
				when 'blockquote' then
					links.concat(self.extract_links_from_text(element.element_text))
				when 'text_pic' then
					links.concat(self.extract_links_from_text(element.element_text))
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
				when 'text_pic_text' then
					links.concat(self.extract_links_from_text(element.element_text))
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
					links.concat(self.extract_links_from_text(element.element_text2))
				end
			end
			pages.push(links)
		end
		return pages
	end

	def bump_last_change
		self.last_change = Time.now()
		self.save
	end

	def get_apparent_author()
		return User.find((self.alias_id != nil && self.alias_id > 0) ? self.alias_id : self.user_id)
	end

	def get_authors()
		users = [ get_apparent_author() ]
		if self.additional_authors
			ids = self.additional_authors.split(',')
			ids.each {|id|
				user = User.find_by_id(id)
				if user
					users.push(user)
				end
			}
		end
		return users
	end

	def get_apparent_author_name()
		# This gets the alias if there is one, and the real author if there isn't.
		author_rec = get_apparent_author()
		auth = author_rec.fullname ? author_rec.fullname : author_rec.username
		return auth
	end

	def get_apparent_author_email()
		# This gets the alias if there is one, and the real author if there isn't.
		author_rec = get_apparent_author()
		return author_rec.email
	end

	def get_friendly_url()
		url = (self.visible_url && self.visible_url.length > 0)  ? "/exhibits/#{self.visible_url}" : "/exhibits/#{self.id}"
		return url
	end

	def get_font_name(type)
		type = type + '_font_name'
		if self.group_id == nil || self.group_id == 0
			return self[type]
		else
			group = Group.find(self.group_id)
			if group[type] == nil || group[type] == ''
				return self[type]
			else
				return group[type]
			end
		end
	end

	def get_font_size(type)
		type = type + '_font_size'
		if self.group_id == nil || self.group_id == 0
			return self[type]
		else
			group = Group.find(self.group_id)
			if group[type] == nil || group[type] == ''
				return self[type]
			else
				return group[type]
			end
		end
	end

	def get_effective_license_type()
		if self.group_id == nil || self.group_id == 0
			return self.license_type
		else
			group = Group.find(self.group_id)
			if Exhibit.is_license_specified(group.license_type)
				return group.license_type
			else
				return self.license_type
			end
		end
	end

	def get_category()
		return "community" if self.group_id == nil || self.group_id == 0
		return Group.find(self.group_id).group_type
	end

	private
	ARCHIVE_PREFIX = "exhibit_"
	
	def self.strip_tags(str)
		ret = ""
		arr = str.split('<')
		arr.each {|el|
			gt = el.index('>')
			if gt
				ret += el.slice(gt+1..el.length-1) + ' '
			else
				ret += el
			end
		}
		ret = ret.gsub("&nbsp;", " ")
		return ret
	end

	@@solr = nil
	def add_object(data, type, section_params, should_commit)
		if section_params
			title = "#{section_params[:name]}: #{self.title}"
			page_str = "?page=#{section_params[:page]}"
			page = section_params[:page]
		else
			title = "#{self.title}"
			page_str = ""
			page = 0
		end
		year = self.updated_at.year
		archive = Group.find(self.group_id)
		doc = { id: self.id, page: page, title: title, federation: Setup.default_federation(), archive: archive.id, archive_name: archive.name, archive_url: archive.get_visible_url,
			url: "#{self.get_friendly_url()}#{page_str}", text_url: self.get_friendly_url(), source: Setup.site_name(),
			role_PBL: archive.name, text: data.join(" \n"), title_sort: title, author_sort: self.get_apparent_author_name(), type: type, year: year }
		archive_thumbnail = PublicationImage.get_image(archive.publication_image_id)
		doc[:archive_thumbnail] = archive_thumbnail if !archive_thumbnail.blank?
		authors = self.get_authors()
		doc[:role_AUT] = []
		authors.each {|author|
			doc[:role_AUT].push(author.fullname)
		}
		genres = self.genres == nil ? [] : self.genres.split(', ')
		doc[:genre] = genres if genres.length > 0
		disciplines = self.disciplines == nil ? [] : self.disciplines.split(', ')
		doc[:discipline] = disciplines if disciplines.length > 0
		doc[:thumbnail] = self.thumbnail if !self.thumbnail.blank?
		@@solr = Catalog.factory_create(false) if @@solr == nil
		@@solr.add_object(doc, should_commit)
	end

	public

	def self.index_all_peer_reviewed
		groups = Group.where({group_type: 'peer-reviewed'})
		exhibits = []
		groups.each {|group|
			exhibits += Exhibit.where({group_id: group.id, is_published: 1})
		}
		exhibits.each{ |exhibit|
			should_commit = exhibit.id == exhibits.last.id
			puts "Indexing: #{exhibit.title}#{' (commit)' if should_commit }"
			exhibit.index_exhibit(should_commit)
		}
	end

	def make_resource_name
		name = self.resource_name
		if name == nil || name.strip().length == 0
			name = "#{self.id}"
		end
		return name
	end

  # generate the old-style archive name for an exhibit... like: exhibit_152
  #
	def make_old_archive_name
		return "#{ARCHIVE_PREFIX}#{self.id}"
	end
	
	# Generate a namespaced archive name for an exhibit. Example exhibit_NINES_152
	#
	def make_archive_name
    return "#{ARCHIVE_PREFIX}#{Setup.site_name()}_#{self.id}"
  end

	def unindex_exhibit(should_commit)
		@@solr = Catalog.factory_create(false) if @@solr == nil
		@@solr.delete_exhibit(self.id, should_commit)
	end

	def self.unindex_all_exhibits()
		@@solr = Catalog.factory_create(false) if @@solr == nil
		exhibits = @@solr.get_exhibits()
		exhibits.each {|exhibit|
			id = exhibit.split('/').last
			puts "Removing exhibit #{id}: #{exhibit}"
			@@solr.delete_exhibit(id, exhibit == exhibits.last)	# just commit on the last one
		}
	end

	def get_all_text()
		full_data = []
		pages = self.exhibit_pages
		pages.each{|page|
			elements = page.exhibit_elements
			elements.each {|element|
				full_data.push(Exhibit.strip_tags(element.element_text)) if element.element_text
				full_data.push(Exhibit.strip_tags(element.element_text2)) if element.element_text2
				if element.header_footnote_id
					footnote = ExhibitFootnote.find(element.header_footnote_id)
					full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
				end
				illustrations = element.exhibit_illustrations
				illustrations.each {|illustration|
					full_data.push(Exhibit.strip_tags(illustration.illustration_text)) if illustration.illustration_text
					full_data.push(illustration.caption1) if illustration.caption1
					full_data.push(illustration.caption2) if illustration.caption2
					full_data.push(illustration.alt_text) if illustration.alt_text
					if illustration.caption1_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption1_footnote_id)
						full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
					end
					if illustration.caption2_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption2_footnote_id)
						full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
					end
				}
			}
		}
		return full_data.join(" \n")
	end

	def index_exhibit(should_commit)
		solr = Catalog.factory_create(false)
		
		puts "Delete old index #{self.id}"
		solr.delete_exhibit(self.id, false)
		
		full_data = []
		section_name = ""	# The sections are set whenever there is a new header element; it is independent of the page.
		num_sections = 0
		section_page = 1
		data = []
		pages = self.exhibit_pages
		pages.each{|page|
			elements = page.exhibit_elements
			elements.each {|element|
				if element.exhibit_element_layout_type == 'header'
					if section_name.length > 0
						add_object(data, :partial, { :count => num_sections, :name => section_name, :page => section_page }, false)
					end
					section_name = Exhibit.strip_tags(element.element_text)
					section_page = page.position
					num_sections += 1
					data = []
				end
				data.push(Exhibit.strip_tags(element.element_text)) if element.element_text
				data.push(Exhibit.strip_tags(element.element_text2)) if element.element_text2
				full_data.push(Exhibit.strip_tags(element.element_text)) if element.element_text
				full_data.push(Exhibit.strip_tags(element.element_text2)) if element.element_text2
				if element.header_footnote_id
					footnote = ExhibitFootnote.find(element.header_footnote_id)
					data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
					full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
				end
				illustrations = element.exhibit_illustrations
				illustrations.each {|illustration|
					data.push(Exhibit.strip_tags(illustration.illustration_text)) if illustration.illustration_text
					data.push(illustration.caption1) if illustration.caption1
					data.push(illustration.caption2) if illustration.caption2
					data.push(illustration.alt_text) if illustration.alt_text
					full_data.push(Exhibit.strip_tags(illustration.illustration_text)) if illustration.illustration_text
					full_data.push(illustration.caption1) if illustration.caption1
					full_data.push(illustration.caption2) if illustration.caption2
					full_data.push(illustration.alt_text) if illustration.alt_text
					if illustration.caption1_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption1_footnote_id)
						data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
						full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
					end
					if illustration.caption2_footnote_id
						footnote = ExhibitFootnote.find( illustration.caption2_footnote_id)
						data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
						full_data.push(Exhibit.strip_tags(footnote.footnote)) if footnote.footnote
					end
				}
			}
			if data.length > 0 && section_name.length > 0
				add_object(data, :partial, { :count => num_sections, :name => section_name, :page => section_page }, false)
			end
		}
		add_object(full_data, :whole, nil, should_commit)

		# add to the resource tree
		#value = self.make_archive_name()
		#puts "Add #{value} to resource tree"
		#facet = FacetCategory.find_by_value(value)
		#parent = FacetCategory.find_by_value("#{Setup.site_name()} Exhibits")
		#id = parent ? parent.id : 1
		#if facet == nil
		#	FacetValue.create(:value => value, :parent_id => id)
		#end
		#site = Catalog.factory_create(false).get_archive(value) #Site.find_by_code(value)
		#if site == nil
		#	Site.create(:code => value, :description => make_resource_name())
		#end

	end

	def self.adjust_indexing_all(group_id, typ)
		exhibits = self.where({group_id: group_id})
		exhibits.each { |exhibit|
			exhibit.adjust_indexing(typ, exhibit == exhibits.last)
		}
	end

	def adjust_indexing(action, should_commit)
		case action
		when :group_becomes_peer_reviewed then
			index_exhibit(should_commit) if self.is_published == 1
		when :group_leaves_peer_reviewed then
			unindex_exhibit(should_commit) if self.is_published == 1
		when :publishing then
			index_exhibit(should_commit) if self.group_id && Group.find(self.group_id).group_type == 'peer-reviewed'
		when :unpublishing then
			unindex_exhibit(should_commit) if self.group_id && Group.find(self.group_id).group_type == 'peer-reviewed'
		when :limit_to_group then
			unindex_exhibit(should_commit) if self.group_id && Group.find(self.group_id).group_type == 'peer-reviewed'
		when :limit_to_everyone then
			index_exhibit(should_commit) if self.group_id && Group.find(self.group_id).group_type == 'peer-reviewed'
		when :leave_group then
			if self.group_id
				group = Group.find_by_id(self.group_id)
				if group && group.group_type == 'peer-reviewed'
					unindex_exhibit(should_commit)
				end
			end
		end
	end

	def get_visibility_friendly_text()
		return "Access to this exhibit is restricted to you." if self.is_published == 0	# if it is not published, that's the same in all cases
		return "This exhibit is visible to everyone." if self.group_id == 0	# if it is not in a group, then all the special cases don't apply
		if Group.is_peer_reviewed_group(self)
			return "This exhibit is visible to everyone." if self.is_published == 1
			return "Submitted for peer-review" if self.is_published == 2
			return "This exhibit is visible to the group's administrators." if self.is_published == 4
			return "Submitted for peer-review/visible to everyone." if self.is_published == 5
			return "This exhibit is visible to everyone."	# This case probably won't happen, but it could if the user changes the group when in a funny state.
		else
			return "This exhibit is visible to everyone." if self.is_published == 1
			return "This exhibit is visible to members of the group." if self.is_published == 3
			return "This exhibit is visible to the group's administrators." if self.is_published == 4
			return "This exhibit is visible to everyone."	# This case probably won't happen, but it could if the user changes the group when in a funny state.
		end
	end

	def get_publish_links()
		ret = []
		if Group.is_peer_reviewed_group(self)
			case self.is_published
			when 0 then
				ret.push( { :text=> "[Submit for peer review]", :param => 2 })
				ret.push( { :text=> "[Submit for peer review/share with everyone]", :param => 5 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
			when 2 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
				ret.push( { :text=> "[Submit for peer review/share with everyone]", :param => 5 })
			when 3 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Submit for peer review]", :param => 2 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
				ret.push( { :text=> "[Submit for peer review/share with everyone]", :param => 5 })
			when 4 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Submit for peer review]", :param => 2 })
				ret.push( { :text=> "[Submit for peer review/share with everyone]", :param => 5 })
			when 5 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
				ret.push( { :text=> "[Submit for peer review/don't share]", :param => 2 })
			end
			return ret
		elsif self.group_id != nil
			case self.is_published
			when 0 then
				ret.push( { :text=> "[Share with group]", :param => 3 })
				ret.push( { :text=> "[Publish to web]", :param => 1 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
			when 1 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Share with group]", :param => 3 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
			when 2 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Share with group]", :param => 3 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
			when 3 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Publish to web]", :param => 1 })
				ret.push( { :text=> "[Share with administrators]", :param => 4 })
			when 4 then
				ret.push( { :text=> "[Unpublish]", :param => 0 })
				ret.push( { :text=> "[Publish to web]", :param => 1 })
				ret.push( { :text=> "[Share with group]", :param => 3 })
			end
			return ret
		else
			text = self.is_published == 1 ? "[Unpublish]" : "[Publish to web]"
			param = self.is_published == 1 ? 0 : 1
			return [ { :text => text, :param => param } ]
		end
	end

	def self.get_exhibits_in_group(group, cluster, user_id, sort_by)
		# if the cluster exists, we want all exhibits in that cluster; if it does not, we want all exhibits that aren't in a cluster.
		# We want all public exhibits, and if the user is a member of the group, also the exhibits just visible to the group.
		is_member = group.is_member(user_id)
		is_editor = group.can_edit(user_id)
		if cluster == nil
			if is_member
				exes = Exhibit.all(:conditions => [ "group_id = ? AND is_published <> 0 AND cluster_id IS NULL", group.id])
				exhibits = []
				for ex in exes
					ex.author = ex.get_apparent_author_name()
					if ex.is_published == 3 || ex.editor_limit_visibility == 'group'
						ex.group_only = true
						ex.editors_only = false
						exhibits.push(ex)
					elsif is_editor && ex.is_published == 4
						ex.group_only = false
						ex.editors_only = true
						exhibits.push(ex)
					elsif ex.is_published != 2 && ex.is_published != 4
						ex.group_only = false
						ex.editors_only = false
						exhibits.push(ex)
					end
				end
			else
				exhibits = Exhibit.all(:conditions => [ "group_id = ? AND is_published = 1 AND (editor_limit_visibility IS NULL OR editor_limit_visibility <> 'group') AND cluster_id IS NULL", group.id])
				exhibits.each { |ex|
					ex.author = ex.get_apparent_author_name()
				}
			end
		else
			if is_member
				exes = Exhibit.all(:conditions => [ "group_id = ? AND is_published <> 0 AND cluster_id = ?", group.id, cluster.id])
				exhibits = []
				for ex in exes
					ex.author = ex.get_apparent_author_name()
					if ex.is_published == 3 || ex.editor_limit_visibility == 'group'
						ex.group_only = true
						ex.editors_only = false
						exhibits.push(ex)
					elsif is_editor && ex.is_published == 4
						ex.group_only = false
						ex.editors_only = true
						exhibits.push(ex)
					elsif ex.is_published != 2 && ex.is_published != 4
						ex.group_only = false
						ex.editors_only = false
						exhibits.push(ex)
					end
				end
			else
				exhibits = Exhibit.all(:conditions => [ "group_id = ? AND (is_published = 1 OR is_published = 5) AND (editor_limit_visibility IS NULL OR editor_limit_visibility <> 'group') AND cluster_id = ?", group.id, cluster.id])
				exhibits.each { |ex|
					ex.author = ex.get_apparent_author_name()
				}
			end
		end
		case sort_by
		when 'last_change' then exhibits = exhibits.sort { |a,b| b.last_change <=> a.last_change }
		when 'title' then exhibits = exhibits.sort { |a,b| a.title <=> b.title }
		when 'author' then exhibits = exhibits.sort { |a,b| a.author <=> b.author }
		end
		return exhibits
	end

	def self.get_pending_exhibits_in_group(group, cluster, user_id)
		if group.can_edit(user_id)
			if cluster == nil
				pending_exhibits = Exhibit.all(:conditions => ["group_id = ? AND cluster_id IS NULL AND is_published = 2", group.id])
			else
				pending_exhibits = Exhibit.all(:conditions => ["group_id = ? AND cluster_id = ? AND is_published = 2", group.id, cluster.id])
			end
		else
			if cluster == nil
				pending_exhibits = Exhibit.all(:conditions => ["group_id = ? AND cluster_id IS NULL AND is_published = 2 AND user_id = ?", group.id, user_id])
			else
				pending_exhibits = Exhibit.all(:conditions => ["group_id = ? AND cluster_id = ? AND is_published = 2 AND user_id = ?", group.id, cluster.id, user_id])
			end
		end
		return pending_exhibits
	end

	def get_badge()
		# if the exhibit is in a group, then we will use that group's badge, if it exists
		if self.group_id
			group = Group.find(self.group_id)
			if group.group_type == 'peer-reviewed'
				return PeerReview.get_badge(group.badge_id)
			end
		end
		# either the group wasn't peer-reviewed, or the exhibit isn't in a group
		return ""
	end

	def is_peer_reviewed()
		return false if self.group_id == nil	# and if it isn't in a group, it can't be peer-reviewed any other way
		return false if self.is_published != 1	# even if it is in a peer-reviewed group, it must be published to be peer-reviewed
		group = Group.find(self.group_id)
		return group.group_type == 'peer-reviewed'	# so it is in a peer-reviewed group and it is published.
	end

	def self.clean_up_word_file(this_folder)
		`rm -R #{this_folder}`
	end

	def self.process_word_paragraph(para, footnotes)
		str = ''
		type = 'text'
		para.xpath('w:pPr').each { |r|
			r.xpath('w:ind').each { |x| type = 'blockquote' if x.attribute('left') && x.attribute('left').to_s.to_i > 200 }
			r.xpath('w:framePr').each { |x| type = 'dropcap' if x.attribute('dropCap') && x.attribute('dropCap').to_s == "drop" }
		}
		para.children.each { |r|
			name = r.name()
			hyperlink = false
			if name == 'hyperlink'
				hyperlink = true
				ns = r.xpath('w:r')
				if ns && ns.length > 0
					r = ns[0]
				end
			end
			if r.name() == 'r'
				has_underline = false
				r.xpath('w:rPr/w:u').each { |x| has_underline = true if x.attribute('val').to_s != 'none' && x.attribute('val').to_s != 'off' }
				has_italics = false
				r.xpath('w:rPr/w:i').each { |x| has_italics = true if x.attribute('val').to_s != 'none' && x.attribute('val').to_s != 'off' }
				has_bold = false
				r.xpath('w:rPr/w:b').each { |x| has_bold = true if x.attribute('val').to_s != 'none' && x.attribute('val').to_s != 'off' }
				footnote_id = nil
				r.xpath('w:footnoteReference').each { |x| footnote_id = 'F'+x.attribute('id').to_s }
				r.xpath('w:endnoteReference').each { |x| footnote_id = 'E'+x.attribute('id').to_s }
				r.xpath('w:t').each { |t|
					str << "<span title=\"External Link: #{t.text}\" real_link=\"#{t.text}\" class=\"ext_linklike\">" if hyperlink
					str << "<span style=\"text-decoration: underline;\">" if has_underline
					str << "<strong>" if has_bold
					str << "<em>" if has_italics
					str << t.text
					str << "</em>" if has_italics
					str << "</strong>" if has_bold
					str << "</span>" if has_underline
					str << "</span>" if hyperlink
				}
				if footnote_id && footnotes && footnotes[footnote_id]
					footnote_template = "<a href=\"#\" onclick='var footnote = $(this).next(); new MessageBoxDlg(\"Footnote\", footnote.innerHTML); return false;' class=\"superscript\">@</a><span class=\"hidden\">$$$$</span>"
					str << footnote_template.sub('$$$$', footnotes[footnote_id])
				end
			end
		}
		return { :type => type, :text => str }
	end

	def self.process_input_file(file)
		root_folder = "#{Rails.root}/tmp/exhibit_import"
		puts `mkdir #{root_folder}`
		this_folder = "#{root_folder}/#{Time.now.to_s.gsub(/\W/, '_')}"
		puts `mkdir #{this_folder}`
		filename = "#{file.original_filename.gsub(' ','_')}.gz"
		File.open("#{this_folder}/#{filename}", "wb") { |f| f.write(file.read) }
#		puts `cd #{this_folder} && tar xvfz #{filename}`
		puts `cd #{this_folder} && unzip #{filename}`

		footnotes = {}
		begin
			footnotes_doc = Nokogiri::XML(File.new("#{this_folder}/word/footnotes.xml"))
			#footnotes_doc = REXML::Document.new( File.new("#{this_folder}/word/footnotes.xml") )
			footnotes_doc.xpath('//w:p').each { |para|
			#REXML::XPath.each( footnotes_doc, "//w:p" ){ |para|
				par = para.parent
				index = 'F'+par.attribute('id').to_s
				str = footnotes[index] ? footnotes[index] : ''
				str += self.process_word_paragraph(para, nil)[:text]
				footnotes[index] = str if str.length > 0
			}
		rescue
			# It's ok for the footnotes file doesn't exist.
		end

		# add the endnotes to the footnotes -- they are the same to us
		# For each <w:endnote w:id="9999"><w:p> element, concatenate all of its <w:t> text. Note that the <w:t> elements might not be direct descendants.
		begin
			endnotes_doc = Nokogiri::XML(File.new("#{this_folder}/word/endnotes.xml"))
			endnotes_doc.xpath('//w:p').each { |para|
				par = para.parent
				index = 'E'+par.attribute('id').to_s
				str = footnotes[index] ? footnotes[index] : ''
				str += self.process_word_paragraph(para, nil)[:text]
				footnotes[index] = str if str.length > 0
			}
		rescue
			# It's ok for the footnotes file doesn't exist.
		end

		begin
			# If this file doesn't exist, the uploaded file was probably not a word file.
			doc = Nokogiri::XML(File.new("#{this_folder}/word/document.xml"))
		rescue
			raise "The uploaded file is not in docx format."
		end

		paragraphs = []
		in_blockquote = false
		in_dropcap = false
		doc.xpath('//w:p').each { |para|
		#REXML::XPath.each( doc, "//w:p" ){ |para|
			p = self.process_word_paragraph(para, footnotes)
			if p[:type] == 'dropcap'
				in_dropcap = true
				in_blockquote = false
				paragraphs.push({ :type => 'text', :text => p[:text] })
			elsif p[:type] == 'blockquote'
				if in_blockquote
					paragraphs[paragraphs.length-1][:text] = paragraphs[paragraphs.length-1][:text] + "<br />" + p[:text]
				else
					if p[:text].length > 0
						paragraphs.push(p)
						in_blockquote = true
					end
				end
				in_dropcap = false
			else
				if in_dropcap
					paragraphs[paragraphs.length-1][:text] = "<div class=\"drop_cap\">" + paragraphs[paragraphs.length-1][:text] + p[:text] + "</div>"
				else
					paragraphs.push(p) if p[:text].length > 0
				end
				in_blockquote = false
				in_dropcap = false
			end
		}
		self.clean_up_word_file(this_folder)
		return paragraphs
	end

	def self.get_referencing_exhibits(uri, curr_user)
		exhibits = ExhibitObject.where({uri: uri})
		user_name = curr_user ? curr_user.fullname : ''
		rows = []
		for exhibit in exhibits
			# We only want to display the exhibit if it can be viewed, so only if it is owned by the current user, or is public
			# We only want to have the edit link if it is owned by the current user.
			real_exhibit = Exhibit.find(exhibit.exhibit.id)
			owner = User.find(real_exhibit.user_id)
			if user_name == owner.username || real_exhibit.published?
				edit_path = ""
				if Exhibit.can_edit(curr_user, real_exhibit.id)
					edit_path = "/builder/#{real_exhibit.id}"
				end
				rows.push({ title: real_exhibit.title,
							view_path: "/exhibits/#{real_exhibit.visible_url != nil && real_exhibit.visible_url.length > 0 ? real_exhibit.visible_url : real_exhibit.id}",
							edit_path: edit_path
						  })
			end
		end # each exhibit
		return rows
	end

end

