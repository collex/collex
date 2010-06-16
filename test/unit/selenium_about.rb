require "rubygems"
gem "selenium-client"
require "selenium/client"

class AboutPages < Test::Unit::TestCase

  def setup
    @verification_errors = []
    @selenium = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*iexplore",
      :url => "http://localhost:3001/",
      :timeout_in_second => 60

    @selenium.start_new_browser_session
  end
  
  def teardown
    @selenium.close_current_browser_session
    assert_equal [], @verification_errors
  end
  
  def test_about_pages
    @selenium.open "/"
    @selenium.click "link=exact:What is NINES?"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Scholarship"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Peer Review"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Editorial Boards"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Scholarly Projects"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Other Resources"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Submissions"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Readings"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Software"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Collex"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Juxta"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Ivanhoe"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//div[@id='content_container']/div[1]/div/p[4]/a[1]"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Executive Council"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Research and Development"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Affiliates"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Outreach"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Workshops"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "header_left"
    @selenium.wait_for_page_to_load "30000"
  end
end
