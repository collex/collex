require "test/unit"
require "rubygems"
gem "selenium-client"
require "selenium/client"

class Login < Test::Unit::TestCase

  def setup
    @verification_errors = []
    @selenium = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*chrome",
      :url => "http://localhost:3001/",
      :timeout_in_second => 60

    @selenium.start_new_browser_session
  end
  
  def teardown
    @selenium.close_current_browser_session
    assert_equal [], @verification_errors
  end

  def wait_for_dlg(dlg_id)
	  60.times {
		  return true if @selenium.is_element_present(dlg_id)
		  sleep(1)
	  }
	  return false
  end
  
  def verify_text_present(div, text)
    begin
        assert_equal text, @selenium.get_text(div)
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
	end
  end

	def verify_element_present(div)
		begin
			assert @selenium.is_element_present(div)
		rescue Test::Unit::AssertionFailedError
			@verification_errors << $!
		end
	end

  def test_login
    @selenium.open "/"
	verify_text_present("//div[@id='login_container']/a[1]", "LOG IN")
    @selenium.click "//div[@id='login_container']/a[1]"
	ok = wait_for_dlg("login_dlg")
    @selenium.type "signin_username", "paul"
    @selenium.type "signin_password", "pass"
    @selenium.click "login_dlg_btn0-button"
	@selenium.wait_for_page_to_load "30000"
	verify_text_present("//div[@id='login_container']/a[1]", "log out")
  end
end
