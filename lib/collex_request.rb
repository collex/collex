require 'solr'

class CollexRequest < Solr::Request::Select
  def initialize(qt, params = {})
    super(qt)
    @params = params
  end

  def constraints
    ary = @params[:constraints].collect do |constraint|
      string_constraint = ""
      string_constraint << "-" if constraint[:invert]
      string_constraint << (constraint.has_key?(:expression) ? "?:#{constraint[:expression]}" : "#{constraint[:field]}:#{constraint[:value]}")
      string_constraint
    end
    
    ary << 'type:A'
  end
end