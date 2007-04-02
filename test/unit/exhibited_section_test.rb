require File.dirname(__FILE__) + '/../test_helper'

class ExhibitedSectionTest < Test::Unit::TestCase
  fixtures :exhibited_sections

  # some testing for the paginating_find plugin enhancements
  def test_find_all_returns_all_exhibited_sections
    assert(ExhibitedSection.find(:all).size > 1)
  end
  # this tests an enhancement to PaginatingFind: if Model has class reader page_size, this is automatically used
  def test_find_all_with_page_returns_page_size_number_of_items
    assert_equal(ExhibitedSection.page_size, ExhibitedSection.find(:all, :page).page_size)
  end

end
