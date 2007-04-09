RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'breakpoint'
require 'action_view/helpers/tag_helper'

class ElementalHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper
  include DangDeveloper::ElementalHelper
  
  def setup
    @content = "some content."
    @options = {:id => "some_id", :class => "css_class", :onClick => "alert('dang')"}
  end
  
  # Self-closing and content tags without content:
  def test_creates_self_closing_tags
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element}")
      expected = "<#{element}/>"
      assert_dom_equal expected, result
    end
    DangDeveloper::ElementalHelper.self_closing_tags.each do |element|
      result = eval("#{element}")
      expected = "<#{element}/>"
      assert_dom_equal expected, result
    end
  end
  
  def test_creates_self_closing_tags_with_options
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element}(@options)")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}/>"
      assert_dom_equal expected, result
    end
    DangDeveloper::ElementalHelper.self_closing_tags.each do |element|
      result = eval("#{element}(@options)")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}/>"
      assert_dom_equal expected, result
    end
  end
  
  def test_creates_self_closing_tags_reject_content
    DangDeveloper::ElementalHelper.self_closing_tags.each do |element|
      assert_raise(NoMethodError) { eval("#{element} @content") }
    end
  end
  
  def test_creates_self_closing_tags_with_options_reject_content
    DangDeveloper::ElementalHelper.self_closing_tags.each do |element|
      assert_raise(ArgumentError) { eval("#{element} @content, :id => 'dang'") }
    end
  end
  
  # Content-tags: non-block syntax
  def test_creates_content_tags
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element} @content")
      expected = "<#{element}>#{@content}</#{element}>"
      assert_dom_equal expected, result
    end    
  end
  
#    def test_creates_content_tag_with_content_option
#     DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
#       result = eval("#{element} :content => @content")
#       expected = "<#{element}>#{@content}</#{element}>"
#       assert_dom_equal expected, result
#     end    
#   end
  
  def test_creates_content_tags_with_options
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element} @content, @options")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}>#{@content}</#{element}>"
      assert_dom_equal expected, result
    end    
  end

  def test_creates_nested_content_tags
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element}(span(@content))")
      expected = "<#{element}><span>#{@content}</span></#{element}>"
      assert_dom_equal expected, result
    end    
  end
  
  def test_creates_nested_content_tags_with_options
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      result = eval("#{element}(span(@content, @options), @options)")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}><span #{tag_options(@options.stringify_keys)}>#{@content}</span></#{element}>"
      assert_dom_equal expected, result
    end    
  end
  
  # Content-tags: block syntax
  def test_creates_content_tags_with_block
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      _erbout = ''
      eval("#{element} {}")
      expected = "<#{element}></#{element}>"
      assert_dom_equal expected, _erbout
    end    
  end

  def test_creates_content_tags_with_block_and_options
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      _erbout = ''
      eval("#{element}(@options) {}")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}></#{element}>"
      assert_dom_equal expected, _erbout
    end
  end

  def test_creates_nested_content_tags_with_block
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      _erbout = ''
      eval("#{element} do em {} end")
      expected = "<#{element}><em></em></#{element}>"
      assert_dom_equal expected, _erbout
    end    
  end
  

  def test_creates_nested_content_tags_with_block_and_options
    DangDeveloper::ElementalHelper.xhtml_content_tags.each do |element|
      _erbout = ''
      eval("#{element}(@options) do em(@options) {} end")
      expected = "<#{element} #{tag_options(@options.stringify_keys)}><em #{tag_options(@options.stringify_keys)}></em></#{element}>"
      assert_dom_equal expected, _erbout
    end    
  end
  
end