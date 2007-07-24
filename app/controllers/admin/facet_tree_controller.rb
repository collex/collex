class Admin::FacetTreeController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  def list
    @facet_trees = FacetTree.find(:all)
  end

  def edit
    @facet_tree = FacetTree.find_by_value(params[:tree])
  end
  
  def add_category
    facet_tree = FacetTree.find_by_value(params[:tree])
    facet_tree << FacetCategory.new(:value => "New Category")
    facet_tree.save
    redirect_to :action => :edit, :tree => facet_tree.value
  end
  
  def add_value
    facet_tree = FacetTree.find_by_value(params[:tree])
    facet_tree << FacetValue.new(:value => "new_value")
    facet_tree.save
    redirect_to :action => :edit, :tree => facet_tree.value
  end

  def remove
    FacetCategory.find(params[:id]).destroy
    redirect_to :action => :edit, :tree => params[:tree]
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

end
