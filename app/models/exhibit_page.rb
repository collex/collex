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

class ExhibitPage < ActiveRecord::Base
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  has_many :exhibit_elements, :order => :position, :dependent=>:destroy

  after_save :handle_solr

  def handle_solr
	  SearchUserContent.delay.index('exhibit', self.exhibit.id)
  end

  def insert_border(element)
      element.set_border_type('start_border')
  end

  private
  # NOTE: Because the :order interface is one based, it is difficult to keep track of when there is an
  # off by one error. Therefore the following convention has been used:
  # variables named "pos" or "position" are one based and should be used to store values in the database.
  # variables named "i" or "index" are zero based and should be used in all array indexes.
  
  def has_border(pos)
    elements = self.exhibit_elements
    return elements[pos-1].get_border_type() != 'no_border'
  end
  
  def find_top_of_border(pos)
    # We are either at the top now or at a continuation.
    # This shouldn't be called if we aren't in a border. But if it is, then return -1. 
    # There should always be a start above a continuation, but if not, then the highest continuation is returned.
    elements = self.exhibit_elements
    i = pos-1
    
    return -1 if elements[i].get_border_type() == 'no_border'
    
    while i >= 0
      return i if elements[i].get_border_type() == 'start_border'
      return i+1  if elements[i].get_border_type() == 'no_border'
      i = i - 1
    end
    return 0  # we got to the top, so that is the start of the border.
  end
  
  def find_bottom_of_border(pos)
    # We are either at the top or at a continuation.
    # We are looking for anything except a continuation and we want to return the last continuation.
    # If we are erroneously called while not in a border, then return -1
    elements = self.exhibit_elements
    i = pos-1
    
    return -1 if elements[i].get_border_type() == 'no_border'
    i = i+1 # We start at the next element because the current one could be a start. That's ok for the first element.

    while i < self.exhibit_elements.length
      return i-1 if elements[i].get_border_type() != 'continue_border'
      i = i + 1
    end
    return self.exhibit_elements.length-1 # There must have been continues all the way to the bottom, so the bottom is the last one.
  end

  def get_top_border_elements(pos)
    i = find_top_of_border(pos)
    return [ nil, nil, nil ] if i < 0
    el1 = (i > 0) ? self.exhibit_elements[i-1] : nil
    el2 = self.exhibit_elements[i]
    el3 = (i < self.exhibit_elements.length-1) ? self.exhibit_elements[i+1] : nil
    return [el1, el2, el3]
  end
  
  def get_bottom_border_elements(pos)
    i = find_bottom_of_border(pos)
    return [ nil, nil, nil, nil ] if i < 0
    el1 = (i > 0) ? self.exhibit_elements[i-1] : nil
    el2 = self.exhibit_elements[i]
    el3 = (i < self.exhibit_elements.length-1) ? self.exhibit_elements[i+1] : nil
    el4 = (i < self.exhibit_elements.length-2) ? self.exhibit_elements[i+2] : nil
    return [el1, el2, el3, el4]
  end
  
  public
 
  def move_top_of_border_down(element)
    els = get_top_border_elements(element.position)

    if els[1]
      els[1].set_border_type('no_border')
    end
    
    if els[2]
      els[2].set_border_type('start_border')
    end
    
    return has_border(element.position)
  end

  def move_bottom_of_border_up(element)
    els = get_bottom_border_elements(element.position)
    
#    if els[0]
#      els[0].set_border_type('start_border')
#    end
    
    if els[1]
      els[1].set_border_type('no_border')
    end
    
    return has_border(element.position)
  end

  def move_top_of_border_up(element)
    els = get_top_border_elements(element.position)
    
    if els[0]
      els[0].set_border_type('start_border')
    end

    if els[1]
      els[1].set_border_type('continue_border')
    end
    
    return has_border(element.position)
  end

  def move_bottom_of_border_down(element)
    els = get_bottom_border_elements(element.position)
    
    
    if els[2]
      swap = els[2].get_border_type()
      els[2].set_border_type('continue_border')
      if els[3]
        els[3].set_border_type(swap)
      end
    end
    
    return has_border(element.position)
  end

  def delete_border(element)
    els = get_top_border_elements(element.position)
    els2 = get_bottom_border_elements(element.position)
    
    top_el = els[1]
    bottom_el = els2[1]
    
    if top_el == nil || bottom_el == nil
      return
    end
    
    index_start = top_el.position - 1 
    index_end = bottom_el.position - 1
    
    elements = self.exhibit_elements
    while index_start <= index_end
      elements[index_start].set_border_type('no_border')
      index_start = index_start + 1
    end
  end

  def move_element_up(element_pos)
    if element_pos > 1
      exhibit_elements[element_pos-1].move_higher()
    else
      # That is the first element. Find the previous page and move it there.
      page_num = self.position
      if page_num > 1
        pages = Exhibit.find(self.exhibit_id).exhibit_pages
        return move_element_to_different_page(exhibit_elements[element_pos-1], pages[page_num-2], pages[page_num-2].exhibit_elements.length+1)
      end
    end
		return nil
  end
  
  def move_element_down(element_pos)
    if element_pos < exhibit_elements.length 
      exhibit_elements[element_pos-1].move_lower()
    else
      # That is the last element. Find the next page and move it there.
      exhibit_id = self.exhibit_id
      page_num = self.position
      pages = Exhibit.find(exhibit_id).exhibit_pages
      if page_num < pages.length
        # There is another page, so add the element to that.
        return move_element_to_different_page(exhibit_elements[element_pos-1], pages[page_num], 1)
      end
    end
		return nil
  end
  
  def move_element_to_different_page(element, dst_page, dst_position)
		# To move to a different page, we have to change the exhibit_page_id and the position
		# The trick is that all the other elements on the two pages affected may have their positions changed.

		element.remove_from_list()
		element.exhibit_page_id = dst_page.id
		element.save!
		element.insert_at(dst_position)
		return element.id	# TODO-PER: refactor - we don't need to return this anymore because the id doesn't change

#    # insert an element, then copy the current element onto it.
#    new_element = dst_page.insert_element(dst_position)
#    new_element.copy_data_portion(exhibit_elements[element_pos-1])
#    delete_element(element_pos)
#		return new_element.id
  end
  
  def insert_element(element_pos)
    new_element = ExhibitElement.factory(id)
    new_element.insert_at(element_pos)
    return new_element
  end
  
  def delete_element(element_pos)
    element = ExhibitElement.find(exhibit_elements[element_pos-1].id)  # fetch it again to be sure it is fresh: otherwise the wrong illustrations may be attached.
    element.remove_from_list()
    element.destroy
    return false
  end
end
