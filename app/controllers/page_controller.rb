class PageController < ApplicationController
  before_filter :authorize, :load_page
  
  def edit
     render "page/page_editor"
  end
  
  def index
     edit
  end
  
  def update
  end

  def add_section
     section = Section.new
     panel = Panel.new
     section.panels << panel
     
     @page.sections << section
     
     save
  end
  
  def reorder
     @page.reorder_sections params[:section_ids].split(/,\s*/)
     render_text "SUCCEED"
  end
    
  private
    def save
       if @page.save
          redirect_to :action => "edit", :id => @page
       else
          flash[:notice] = "Error saving"
          render_action 'edit'
       end     
    end

    def load_page
       # TODO: Secure such that a user cannot edit another users pages
      @page = Page.find(params[:id])
    end
end
