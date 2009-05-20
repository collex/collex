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
    @sites_forest = FacetCategory.sorted_facet_tree().sorted_children
    @facet_tree = FacetTree.find_by_value('archive')
    @found_resources = get_all_found_resources()
    search_one_branch(@sites_forest, @found_resources)
  end
  
#  def get_resource_details
#    site = params[:site]
#    rec = FacetCategory.find_by_value(site)
#    ret = {}
#    ret[:parent_id] = rec[:parent_id]
#    ret[:carousel_include] = rec[:carousel_include]
#    ret[:carousel_title] = rec[:carousel_title]
#    ret[:carousel_description] = rec[:carousel_description]
#    ret[:carousel_url] = rec[:carousel_url]
#    ret[:image] = ''  #'/uploads/0000/0057/rossetti_painting_thumb.jpg'
#    ret[:image] = rec.image.public_filename if rec && rec.image
#    if rec != nil && rec[:type] != nil
#      desc_rec = Site.find_by_code(site)
#      if desc_rec
#        ret[:display_name] = desc_rec[:description]
#        ret[:is_category] = false
#        ret[:site_url] = desc_rec[:url]
#        ret[:site_thumbnail] = desc_rec[:thumbnail]
#      else
#        ret[:display_name] = ""
#        ret[:is_category] = false
#        ret[:site_url] = ""
#        ret[:site_thumbnail] = ""
#      end
#    else
#      ret[:display_name] = ""
#      ret[:is_category] = true
#      ret[:site_url] = ""
#      ret[:site_thumbnail] = ""
#    end
#    render :text => ret.to_json()
#  end

  def get_categories
    categories = FacetCategory.get_all_categories()
    ret = [{ :value => 1, :text => '[root]' }]
    categories.each {|category|
      ret.push({ :value => category.id, :text => category.display_name })
    }

    render :text => ret.to_json()
  end
  
  def get_categories_and_details
    categories = FacetCategory.get_all_categories()
    cat_ret = [{ :value => 1, :text => '[root]' }]
    categories.each {|category|
      cat_ret.push({ :value => category.id, :text => category.display_name })
    }

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
      if desc_rec
        ret[:display_name] = desc_rec[:description]
        ret[:is_category] = false
        ret[:site_url] = desc_rec[:url]
        ret[:site_thumbnail] = desc_rec[:thumbnail]
      else
        ret[:display_name] = ""
        ret[:is_category] = false
        ret[:site_url] = ""
        ret[:site_thumbnail] = ""
      end
    else
      ret[:display_name] = ""
      ret[:is_category] = true
      ret[:site_url] = ""
      ret[:site_thumbnail] = ""
    end
    render :text => { :categories => cat_ret, :details => ret }.to_json()
    
  end
  
  # The file upload is done in a separate call because of ajax limitations.
  def edit_facet_upload
    value = params[:value]
    facet = FacetCategory.find_by_value(value)
    if params['carousel_thumbnail'].length > 0
      facet.image = Image.new({ :uploaded_data => params['carousel_thumbnail'] })
      facet.image.save!
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
    name = params[:category_name]
    parent = params[:parent_category_id]
    FacetCategory.create(:value => name, :parent_id => parent)
    render_edit_site_list()
  end
  
  def delete_facet
    value = params[:site]
    facet = FacetCategory.find_by_value(value)
    if facet[:type] == nil
      # category
      parent_id = facet.parent_id
      children = FacetCategory.find(:all, :conditions => [ 'parent_id = ?', facet.id])
      children.each { |child|
        child.parent_id = parent_id
        child.save
      }
    else
      # site
      site = Site.find_by_code(value)
      site.destroy
    end
    facet.destroy
    render_edit_site_list()
  end
  
  def add_site
    name = params[:display_name]
    parent = params[:parent_category_id]
    value = params[:site]
    facet = FacetCategory.find_by_value(value)
    if facet == nil
      FacetValue.create(:value => value, :parent_id => parent)
    else
      facet.update_attributes
    end
    
    site = Site.find_by_code(value)
    if site == nil
      Site.create(:code => value, :description => name)
    end
    render_edit_site_list()
  end
  
  def remove_site
    value = params[:site]
    facet = FacetCategory.find_by_value(value)
    facet.destroy if facet
    site = Site.find_by_code(value)
    site.destroy if site
    
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

  def get_all_found_resources
    solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
    results = solr.search([], 1, 10)
    found_resources = results['facets']['archive']
    resources = []
    found_resources.each {|key,val| resources.push(key)}
    return resources
  end
end
