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

      case constraint[:type]
        when :facet
          string_constraint << "#{constraint[:field]}:#{constraint[:value]}"
        when :expression
          string_constraint << "?:#{constraint[:expression]}"
        when :saved
          string_constraint << "?:#{User.find_by_username(constraint[:field]).searches.find_by_name(constraint[:value]).to_solr_expression}"
      end
      
      string_constraint
    end
    
    ary << 'type:A'
  end
end