class PanelController < ApplicationController
   before_filter :authorize, :load_panel

  def save_text
     @panel.text = params[:text]
     save
     render_text "SUCCEED"
  end
  
  def save_image
     @panel.image_url = params[:url]
     save
     render_text "SUCCEED"
  end

  private
    def save
       @panel.save!
    end

    def load_panel
       # TODO: Secure such that a user cannot edit another users panels
      @panel = Panel.find(params[:id])
    end

end
