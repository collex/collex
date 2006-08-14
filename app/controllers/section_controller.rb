class SectionController < ApplicationController
   before_filter :authorize, :load_section
   
   def move_up
      @section.move_higher
      save
      redirect_to :controller => 'page', :action => 'edit', :id => @page
   end

   def move_down
      @section.move_lower
      save
      redirect_to :controller => 'page', :action => 'edit', :id => @page
   end

   def remove
      @section.destroy
      render_text "SUCCEED"
   end

   private
     def save
        if @page.save
           @page.reload
           redirect_to :controller => 'page', :action => "edit", :id => @page
        else
           flash[:notice] = "Error saving"
           render_action 'edit'
        end     
     end

     def load_section
        # TODO: Secure such that a user cannot edit another users sections
       @section = Section.find(@params[:id])
       @page = @section.page
     end
end
