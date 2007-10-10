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

require File.dirname(__FILE__) + '/../test_helper'

class InterpretationsTest < Test::Unit::TestCase
  fixtures :interpretations, :users

  def test_cannot_duplicate_uri_and_username
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert !i2.valid?
  end
  
  def test_can_duplicate_uri_with_different_users
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 2, :object_uri => "foo")
    assert i2.valid?
  end

  def test_can_duplicate_user_with_different_uris
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 1, :object_uri => "baz")
    assert i2.valid?
  end  
end
