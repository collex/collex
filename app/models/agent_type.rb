class AgentType < ActiveRecord::Base
  has_one :cached_agent  
end
