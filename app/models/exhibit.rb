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
    exhibit = Exhibit.create(:title => title, :user_id => user_id, :thumbnail => thumbnail, :visible_url => transform_url(url), :is_published => 0)
    exhibit.insert_example_page(1)
    exhibit.insert_example_page(2)
		exhibit.reset_fonts_to_default()
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

  def self.get_sharing_text(s)
    case s
      when nil: return ""
      when 0: return ""
      when 1: return "This license lets others distribute, remix, tweak, and build upon your work, even commercially, as long as they credit you for the original creation. This is the most accommodating of licenses offered, in terms of what others can do with your works licensed under Attribution."
      when 2: return "This license lets others remix, tweak, and build upon your work even for commercial reasons, as long as they credit you and license their new creations under the identical terms. This license is often compared to open source software licenses. All new works based on yours will carry the same license, so any derivatives will also allow commercial use."
      when 3: return "This license allows for redistribution, commercial and non-commercial, as long as it is passed along unchanged and in whole, with credit to you."
      when 4: return "This license lets others remix, tweak, and build upon your work non-commercially, and although their new works must also acknowledge you and be non-commercial, they don’t have to license their derivative works on the same terms."
      when 5: return "This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit you and license their new creations under the identical terms. Others can download and redistribute your work just like the by-nc-nd license, but they can also translate, make remixes, and produce new stories based on your work. All new work based on yours will carry the same license, so any derivatives will also be non-commercial in nature."
      when 6: return "This license is the most restrictive of our six main licenses, allowing redistribution. This license is often called the “free advertising” license because it allows others to download your works and share them with others as long as they mention you and link back to you, but they can’t change them in any way or use them commercially."
      else return ""
    end
  end

  def published?()
    return is_published != nil && is_published != 0
  end
  
  def get_sharing()
    return Exhibit.get_sharing_static(is_published)
  end
  
  def get_sharing_int()
    return is_published == nil ? 0 : is_published
  end
  
  def self.get_sharing_static(s)
    case s
      when nil: return "Not Shared"
      when 0: return "Not Shared"
      when 1: return "Attribution"
      when 2: return "Attribution Share Alike"
      when 3: return "Attribution No Derivatives"
      when 4: return "Attribution Non-Commercial"
      when 5: return "Attribution Non-Commercial Share Alike"
      when 6: return "Attribution Non-Commercial No Derivatives"
      else return "Not Shared"
    end
  end
  
  def set_sharing(str)
    case str
      when "Not Shared": self.is_published = 0
      when "Attribution": self.is_published = 1
      when "Attribution Share Alike": self.is_published = 2
      when "Attribution No Derivatives": self.is_published = 3
      when "Attribution Non-Commercial": self.is_published = 4
      when "Attribution Non-Commercial Share Alike": self.is_published = 5
      when "Attribution Non-Commercial No Derivatives": self.is_published = 6
      when '0': self.is_published = 0
      when '1': self.is_published = 1
      when '2': self.is_published = 2
      when '3': self.is_published = 3
      when '4': self.is_published = 4
      when '5': self.is_published = 5
      when '6': self.is_published = 6
      else self.is_published = 0
    end
  end

  def self.get_sharing_license_type(is_published)
    case is_published
      when 1: return "by"
      when 2: return "by-sa"
      when 3: return "by-nd"
      when 4: return "by-nc"
      when 5: return "by-nc-sa"
      when 6: return "by-nc-nd"
      else return "ERROR"
    end
  end

  def get_sharing_widget()
    if published?
      license = Exhibit.get_sharing_license_type(is_published)
      return "#{get_sharing_icon_with_link()}<p>This work is licensed under a <a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
        license + "/3.0/us/\">Creative Commons " + get_sharing() + " 3.0 United States License</a>.</p>"
    else
      return "This exhibit is visible to just me."
    end
  end
  
  def get_sharing_image()
    return Exhibit.get_sharing_icon_url(is_published)
  end
  
  def self.get_sharing_icon_url(is_published)
    if is_published != nil && is_published != 0
      return "<img alt='Creative Commons License' style='border-width:0' src='http://i.creativecommons.org/l/#{get_sharing_license_type(is_published)}/3.0/us/88x31.png' />"
    else
      return "<img alt='Creative Commons License' height='31' style='border-width:0' src='/images/not_shared.jpg' />"
    end
  end
  
  def get_sharing_icon_with_link()
    license = Exhibit.get_sharing_license_type(is_published)
    return "<a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
      license + "/3.0/us/\" title='This work is licensed under a Creative Commons #{get_sharing()} 3.0 United States License'>#{Exhibit.get_sharing_icon_url(is_published)}</a>"
  end
  
  def self.get_all_published
    return Exhibit.find(:all, :conditions => [ 'is_published <> 0'])
  end
  
  def self.getJsonLicenseInfo()
    str = "[ { text: 'Exhibit should be visible to just me', icon: \"#{self.get_sharing_icon_url(0)}\" },"
    1.upto(6) do |i|
      str = str + "{ text: '" + self.get_sharing_text(i) + "', icon: \"" + self.get_sharing_icon_url(i) + "\" }"
#      str = str + "{ text: '" + "t" + "', icon: \"" + "i" + "\" }"
      str = str + "," if i != 6
    end
    str = str + "]"
    return str
  end
  
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

end

