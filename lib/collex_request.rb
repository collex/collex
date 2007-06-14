require 'solr'

class CollexRequest < Solr::Request::Select
  def initialize(qt, params = {})
    super(qt)
    @params = params
  end

  def constraints
    ary = []
    if @params[:constraints]
      ary = @params[:constraints].collect do |constraint|
        constraint.to_s
      end
    end
    
    ary << 'type:A'
  end
end