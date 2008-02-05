require File.dirname(__FILE__) + '/../test_helper'

class AgentTypeTest < Test::Unit::TestCase
  fixtures :agent_types
  
  def test_find_by_name
    agent = AgentType.find_by_name(agent_types(:author).name)
    assert_not_equal nil, agent
    assert_equal agent.name, agent_types(:author).name
  end
end
