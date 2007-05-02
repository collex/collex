class ExhibitsBaseController < ApplicationController

  private
    def authorize_owner
      id = params[:exhibit_id] || params[:id]
      @exhibit = Exhibit.find(id)
      unless @exhibit.owner?(user)
        logger.info("#{user.username} is not owner of #{@exhibit.title} (id=#{@exhibit.id})")
        flash[:warning] = "You do not have permission to edit that Exhibit!"
        redirect_to(exhibits_path) and return false
      end
    rescue ActiveRecord::RecordNotFound
      logger.info("Exhibit with id #{id} not found.")
      flash[:warning] = "That Exhibit could not be found."
      redirect_to exhibits_path
    end
end