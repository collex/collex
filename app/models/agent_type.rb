class AgentType < ActiveRecord::Base
  has_many :cached_agents
end
