class ExhibitController < ApplicationController
  layout "nines"
  
  def mine
    @exhibit_types = ExhibitType.find(:all)
  end
end
