class ExhibitsBaseController < ApplicationController

  private
    def authorize_owner
      @exhibit = Exhibit.find(params[:id])
      unless @exhibit.owner?(user)
        flash[:warning] = "You do not have permission to edit that Exhibit!"
        redirect_to(exhibits_path) and return false
      end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That Exhibit could not be found."
      redirect_to exhibits_path
    end
end