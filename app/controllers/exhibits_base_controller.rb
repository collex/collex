class ExhibitsBaseController < ApplicationController

  private
    def authorize_owner
      id = params[:exhibit_id] || params[:id]
      @exhibit = Exhibit.find(id)
      unless @exhibit.updatable_by?(user_or_guest)
        logger.info("#{user_or_guest.username} is not owner of #{@exhibit.title} (id=#{@exhibit.id})")
        flash[:warning] = "You do not have permission to edit that Exhibit!"
        redirect_to(exhibits_path) and return false
      end
    rescue ActiveRecord::RecordNotFound
      logger.info("Exhibit with id #{id} not found.")
      flash[:warning] = "That Exhibit could not be found."
      redirect_to exhibits_path
    end
end