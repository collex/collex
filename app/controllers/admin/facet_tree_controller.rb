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

class Admin::FacetTreeController < Admin::BaseController
  def index
    params[:tree] = 'archive'
    edit
    render :action => 'edit'
  end

  def list
    @facet_trees = FacetTree.find(:all)
  end

  def edit
    @sites_forest = FacetCategory.sorted_facet_tree().sorted_children
    @facet_tree = FacetTree.find_by_value(params[:tree])
    @found_resources = get_all_found_resources()
#    solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
#    @results = solr.search([], 1, 10) # temp, to test the drawing of the tree
    search_one_branch(@sites_forest, @found_resources)
  end
  
  def get_resource_details
    site = params[:site]
    rec = FacetCategory.find_by_value(site)
    ret = {}
    ret[:parent_id] = rec[:parent_id]
    ret[:carousel_include] = rec[:carousel_include]
    ret[:carousel_title] = rec[:carousel_title]
    ret[:carousel_description] = rec[:carousel_description]
    ret[:carousel_url] = rec[:carousel_url]
    ret[:image] = ''  #'/uploads/0000/0057/rossetti_painting_thumb.jpg'
    ret[:image] = rec.image.public_filename if rec && rec.image
    if rec != nil && rec[:type] != nil
      desc_rec = Site.find_by_code(site)
      ret[:display_name] = desc_rec[:description]
      ret[:is_category] = false
      ret[:site_url] = desc_rec[:url]
      ret[:site_thumbnail] = desc_rec[:thumbnail]
    else
      ret[:display_name] = ""
      ret[:is_category] = true
      ret[:site_url] = ""
      ret[:site_thumbnail] = ""
    end
    render :text => ret.to_json()
  end

  def get_categories
    categories = FacetCategory.get_all_categories()
    ret = [{ :value => 1, :text => '[root]' }]
    categories.each {|category|
      ret.push({ :value => category.id, :text => category.display_name })
    }

    render :text => ret.to_json()
  end
  
  # The file upload is done in a separate call because of ajax limitations.
  def edit_facet_upload
    value = params[:value]
    facet = FacetCategory.find_by_value(value)
    if params['carousel_thumbnail'].length > 0
      facet.image = Image.new({ :uploaded_data => params['carousel_thumbnail'] })
      facet.save
    end
    render :text => ""  # just need to return anything. This isn't displayed anyway.
  end
  
  def edit_facet
    site_url = params[:site_url]
    site_thumbnail = params[:site_thumbnail]
    carousel_url = params[:carousel_url]
    carousel_description = params[:carousel_description]
    parent_category_id = params[:parent_category_id]
    carousel_title = params[:carousel_title]
    value = params[:site]
    display_name = params[:display_name]
    carousel_include = params[:carousel_include]
    
    facet = FacetCategory.find_by_value(value)
    facet.carousel_url = carousel_url
    facet.carousel_description = carousel_description
    facet.carousel_title = carousel_title
    facet.carousel_include = (carousel_include == 'true') ? 1 : 0
    facet.parent_id = parent_category_id

    if facet[:type] != nil
      site = Site.find_by_code(value)
      site.url = site_url
      site.description = display_name
      site.thumbnail = site_thumbnail
      site.save
    else
      facet.value = display_name
    end
    facet.save
    
    render_edit_site_list()
  end
  
  def add_category
    render_edit_site_list()
  end
  
  def add_site
    render_edit_site_list()
  end
  
  def remove_site
    render_edit_site_list()
  end
  
private
  def render_edit_site_list
    @sites_forest = FacetCategory.sorted_facet_tree().sorted_children
    @found_resources = get_all_found_resources()
    search_one_branch(@sites_forest, @found_resources)
    
    render :partial => 'edit_site_list', :locals => { :sites_forest => @sites_forest, :found_resources => @found_resources, :parent_div => 'edit_site_list' }
  end
  
  def search_one_branch(site_arr, found_resources)
    site_arr.each {|site|
      if site['type'] == nil
        search_one_branch(site.sorted_children, found_resources)
      else
        name = site['value']
        index = found_resources.index(name)
        site['found'] = (index != nil)
        found_resources.delete_at(index) if index != nil
    end
    }
  end
public
#  def add_category
##    facet_tree = FacetTree.find_by_value(params[:tree])
##    facet_tree << FacetCategory.new(:value => "New Category")
##    facet_tree.save
#    FacetCategory.create(:value => "New Category", :parent_id => FacetTree.find_by_value('archive').id)
#    redirect_to :action => :edit, :tree => 'archive'
#  end
  
  def add_value
#    facet_tree = FacetTree.find_by_value(params[:tree])
#    facet_tree << FacetValue.new(:value => "new_value")
#    facet_tree.save
#    redirect_to :action => :edit, :tree => facet_tree.value
    FacetValue.create(:value => "new_value", :parent_id => FacetTree.find_by_value('archive').id)
    redirect_to :action => :edit, :tree => 'archive'
  end

  def remove
    FacetCategory.find(params[:id]).destroy
    redirect_to :action => :edit, :tree => params[:tree]
  end
  
  def move
    #parent = FacetCategory.find(params[:id])
    child = FacetCategory.find(params[:droppedid])
    child.parent_id = params[:id]
    #parent << child
    child.save
    
    render :partial => 'categories', :locals => {:categories => FacetTree.find_by_value(params[:tree]).children, :tree => params[:tree]}
  end
  
  def set_category_value
    item = FacetCategory.find(params[:id])
    item.value = params[:value]
    item.save
    render :text => item.value
  end

  # destroying a facet tree is serious business - the UI may depend on it, such as the NINES "archive" tree
  # def destroy
  #   FacetTree.find(params_by_value[:tree]).destroy
  #   redirect_to :action => 'list'
  # end
private
  def get_all_found_resources
    solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
    results = solr.search([], 1, 10)
    found_resources = results['facets']['archive']
    resources = []
    found_resources.each {|key,val| resources.push(key)}
    return resources
  end
end
