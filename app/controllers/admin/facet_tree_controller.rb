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
    solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
    @results = solr.search([], 1, 10) # temp, to test the drawing of the tree
    search_one_branch(@sites_forest, @found_resources)
  end
private
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
  def add_category
#    facet_tree = FacetTree.find_by_value(params[:tree])
#    facet_tree << FacetCategory.new(:value => "New Category")
#    facet_tree.save
    FacetCategory.create(:value => "New Category", :parent_id => FacetTree.find_by_value('archive').id)
    redirect_to :action => :edit, :tree => 'archive'
  end
  
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
