require File.dirname(__FILE__) + '/../test_helper'
require 'exhibited_sections_controller'

# Re-raise errors caught by the controller.
class ExhibitedSectionsController; def rescue_action(e) raise e end; end

class ExhibitedSectionsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ExhibitedSectionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
