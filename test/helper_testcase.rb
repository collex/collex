##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

# TODO Add this to your test_helper.rb
#require File.expand_path(File.dirname(__FILE__) + '/helper_testcase')

# Re-raise errors caught by the controller.
class StubController < ApplicationController
  def rescue_action(e) raise e end;
  attr_accessor :request, :url
end

class HelperTestCase < Test::Unit::TestCase

  # Add other helpers here if you need them
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::PrototypeHelper

  def setup
    super

    @request    = ActionController::TestRequest.new
    @controller = StubController.new
    @controller.request = @request

    # Fake url rewriter so we can test url_for
    @controller.url = ActionController::UrlRewriter.new @request, {}
    
    ActionView::Helpers::AssetTagHelper::reset_javascript_include_default
  end

  def test_dummy
    # do nothing - required by test/unit
  end
end
