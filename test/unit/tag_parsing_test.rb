##########################################################################
# Copyright 2007 Applied Research in Patacriticism
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

class TagParsingTest < Test::Unit::TestCase

  def test_lowercasing
    assert_equal ['tag'], Tag.parse("TAG")
  end

  def test_whitespace_separation
    assert_equal ['one', 'two'], Tag.parse(%q{one two})
  end
  
  def test_quoted_text_as_one_word_with_dashes
    assert_equal ['something-quoted', 'please'], Tag.parse(%q{"something quoted" please})
  end

  def test_remove_punctuation    
    assert_equal ['its-great'], Tag.parse(%q{"it's great"})
  end

  def test_remove_punctuation_orphaned_quotes 
    assert_equal ['eriks', 'missing', 'end', 'quote'], Tag.parse(%q{erik's "missing end quote})
  end
  
  def test_preserve_dashes
    assert_equal ['dashes-already-here'], Tag.parse('dashes-already-here')
  end
  
  def test_commas
    assert_equal ['one', 'two'], Tag.parse('one,two')
  end
  
  def test_duplicates
    assert_equal ["woolen-mills"], Tag.parse(%q{woolen-mills "woolen mills"})
  end
end
