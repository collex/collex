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

class Exhibit < ActiveRecord::Base
  has_many :exhibit_pages, :order => :position, :dependent=>:destroy
  has_many :exhibit_objects, :dependent=>:destroy
	belongs_to :group
	belongs_to :cluster

	 def self.can_edit(user, exhibit_id)
    return false if user == nil
    return false if exhibit_id == nil
    exhibit = Exhibit.find(exhibit_id)
		return false if exhibit.category == "peer-reviewed"
		if exhibit.group_id
			group = Group.find(exhibit.group_id)
			return false if group.group_type == 'peer-reviewed'
		end
    return true if user.role_names.include?('admin')
    return exhibit.user_id == user.id
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
	
  def self.factory(user_id, url, title, thumbnail)
    thumbnail = thumbnail.strip
    if thumbnail.length > 0 && thumbnail.index('http') != 0
      thumbnail = "http://" + thumbnail
    end
    exhibit = Exhibit.create(:title => title, :user_id => user_id, :thumbnail => thumbnail, :visible_url => transform_url(url), :is_published => 0, :license_type => self.get_default_license(), :category => Group.types()[0])
    exhibit.insert_example_page(1)
    exhibit.insert_example_page(2)
		exhibit.reset_fonts_to_default()
		exhibit.bump_last_change()
    return exhibit
  end
  
  def self.transform_url(url)
    # The legal characters are: Letters (A-Z and a-z), numbers (0-9) and the characters '-', '~' and '_'
    # All other characters are replaced by underscores, then multiple underscores are replaced by one underscore.
    # This never returns more than 30 characters.

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
    el.element_text = "Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above."
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
  
  def self.js_array_of_all_my_exhibits(user_id)
    my_exhibits = find(:all, :conditions => ['user_id = ?', user_id] )
    return "" if my_exhibits.length == 0
    
    str = ""
    for exhibit in my_exhibits
      if str != ""
        str += ","
      end
      str += '"' + h(exhibit.title) + '"'
      #str += '"' + exhibit.title.gsub('"', "\\\"") + '"'
    end
    return str
  end
  
  def self.js_array_of_all_public_exhibits()
    exhibits = self.get_all_published()
    str = ""
    for exhibit in exhibits
      if str != ""
        str += ",\n"
      end
      str += "{ title: \"#{h(exhibit.title)}\", thumbnail: \"#{exhibit.thumbnail}\" }";
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
      return "<img alt='Creative Commons License' height='31' style='border-width:0' src='/images/not_shared.jpg' />"
    end
  end
  
  def get_sharing_icon_with_link()
		effective_license = get_effective_license_type()
    license = Exhibit.get_sharing_license_type(effective_license)
    return "<a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
      license + "/3.0/us/\" title='This work is licensed under a Creative Commons #{Exhibit.get_sharing_static(effective_license)} 3.0 United States License'>#{Exhibit.get_sharing_icon_url(effective_license)}</a>"
  end
  
  def self.get_all_published
    return Exhibit.find(:all, :conditions => [ 'is_published <> 0'])
  end

	def self.is_license_specified(license_type)
		return license_type != nil && license_type != '' && license_type.to_i > 0
	end

	def self.get_license_info(add_inherit)
		ret = []
		if add_inherit
			ret.push({ :id => 0, :text => 'Each exhibit can specify a license.', :icon => self.get_sharing_icon_url(0), :abbrev => self.get_sharing_static(0) })
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
				when 'header':
					return true if element.header_footnote_id != nil
				when 'pic_text':
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'pic_text_pic':
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[1]) > 0
				when 'pics':
					for illustration in element.exhibit_illustrations
						return true if exhibit.count_footnotes_from_illustration(illustration) > 0
					end
				when 'text':
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'blockquote':
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
				when 'text_pic':
					return true if exhibit.count_footnotes_from_text(element.element_text) > 0
					return true if exhibit.count_footnotes_from_illustration(element.exhibit_illustrations[0]) > 0
				when 'text_pic_text':
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
			arr.each_with_index { |a,i|
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
				when 'header':
					footnotes.push(ExhibitFootnote.find(element.header_footnote_id).footnote) if element.header_footnote_id != nil
				when 'pic_text':
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'pic_text_pic':
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[1]))
				when 'pics':
					for illustration in element.exhibit_illustrations
						footnotes.concat(self.extract_footnotes_from_illustration(illustration))
					end
				when 'text':
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'blockquote':
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
				when 'text_pic':
					footnotes.concat(self.extract_footnotes_from_text(element.element_text))
					footnotes.concat(self.extract_footnotes_from_illustration(element.exhibit_illustrations[0]))
				when 'text_pic_text':
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
				when 'header':
					count += 1 if element.header_footnote_id != nil
				when 'pic_text':
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
					count += self.count_footnotes_from_text(element.element_text)
				when 'pic_text_pic':
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
					count += self.count_footnotes_from_text(element.element_text)
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[1])
				when 'pics':
					for illustration in element.exhibit_illustrations
						count += self.count_footnotes_from_illustration(illustration)
					end
				when 'text':
					count += self.count_footnotes_from_text(element.element_text)
				when 'blockquote':
					count += self.count_footnotes_from_text(element.element_text)
				when 'text_pic':
					count += self.count_footnotes_from_text(element.element_text)
					count += self.count_footnotes_from_illustration(element.exhibit_illustrations[0])
				when 'text_pic_text':
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
				when 'pic_text':
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
					links.concat(self.extract_links_from_text(element.element_text))
				when 'pic_text_pic':
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
					links.concat(self.extract_links_from_text(element.element_text))
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[1]))
				when 'pics':
					for illustration in element.exhibit_illustrations
						links.concat(self.extract_links_from_illustration(illustration))
					end
				when 'text':
					links.concat(self.extract_links_from_text(element.element_text))
				when 'blockquote':
					links.concat(self.extract_links_from_text(element.element_text))
				when 'text_pic':
					links.concat(self.extract_links_from_text(element.element_text))
					links.concat(self.extract_links_from_illustration(element.exhibit_illustrations[0]))
				when 'text_pic_text':
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

	def get_apparent_author_name()
		# This gets the alias if there is one, and the real author if there isn't.
		author_rec = User.find(self.alias_id ? self.alias_id : self.user_id)
		author = author_rec.fullname ? author_rec.fullname : author_rec.username
		return author
	end

	def get_friendly_url()
		return self.visible_url ? "/exhibits/view/#{self.visible_url}" : "/exhibits/view/#{exhibit.id}"
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

	private
	URI_BASE = 'http://nines.org/peer-reviewed-exhibit/'
	ARCHIVE_PREFIX = "exhibit_"
	
	def strip_tags(str)
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

	def add_object(solr, data, boost, section_params)
		uri = "#{URI_BASE}#{self.id}"
		if section_params
			uri += "/#{section_params[:count]}"
			title = "#{self.title} (#{section_params[:name]})"
			page_str = "?page=#{section_params[:page]}"
		else
			title = "#{self.title}"
			page_str = ""
		end
		genres = self.genres.split(', ')
		doc = { :uri => uri, :title => title, :thumbnail => self.thumbnail, :has_full_text => true,
			:genre => genres, :archive => self.make_archive_name(), :role_AUT => self.get_apparent_author_name(),	:url => "#{self.get_friendly_url()}#{page_str}", :text_url => self.get_friendly_url(), :source => "#{SITE_NAME}",
			:text => data.join(" \n"), :title_sort => title, :author_sort => self.get_apparent_author_name() }
		solr.add_object(doc, boost)
	end

	public

	RESOURCE_CATEGORY = "NINES Exhibits"	# TODO: generalize this, and allow exhibits to come from 18th connect, too.

	def self.index_all_peer_reviewed
		exhibits = Exhibit.all(:conditions => [ "category = ?", 'peer-reviewed'])
		exhibits.each{ |exhibit|
			exhibit.index_exhibit(exhibit.id == exhibits.last.id)
		}
	end

	def make_resource_name
		name = self.resource_name
		if name == nil || name.strip().length == 0
			name = "#{self.id}"
		end
		return name
	end

	def make_archive_name
		return "#{ARCHIVE_PREFIX}#{make_resource_name()}"
	end

	def unindex_exhibit()
		solr = CollexEngine.new()
		solr.delete_archive(self.make_archive_name())
		solr.commit()
	end

	def self.unindex_all_exhibits()
		solr = CollexEngine.new()
		archives = solr.get_all_archives()
		changed = false
		archives.each {|archive|
			if archive.index(ARCHIVE_PREFIX) == 0
				puts "Removing archive #{archive}"
				solr.delete_archive(archive)
				changed = true
			end
		}
		if changed == true
			solr.commit()
		end
	end

	def index_exhibit(should_commit)
		boost_section = 3.0
		boost_exhibit = 2.0
		solr = CollexEngine.new()
		solr.delete_archive(self.make_archive_name())
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
						add_object(solr, data, boost_section, { :count => num_sections, :name => section_name, :page => section_page })
					end
					section_name = strip_tags(element.element_text)
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
				add_object(solr, data, boost_section, { :count => num_sections, :name => section_name, :page => section_page })
			end
		}
		add_object(solr, full_data, boost_exhibit, nil)
		solr.commit() if should_commit

		# add to the resource tree
		value = self.make_archive_name()
    facet = FacetCategory.find_by_value(value)
		parent = FacetCategory.find_by_value(RESOURCE_CATEGORY)
		id = parent ? parent.id : 1
    if facet == nil
      FacetValue.create(:value => value, :parent_id => id)
		end
    site = Site.find_by_code(value)
    if site == nil
      Site.create(:code => value, :description => make_resource_name())
    end

	end
end

