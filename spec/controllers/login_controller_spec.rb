##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require File.dirname(__FILE__) + '/../spec_helper'

describe LoginController do
  before(:each) do
    
  end
  
  it "should redirect to 'login' for authenticated action when no user in session" do
    get :controller => "collection"
    response.should redirect_to(:controller => "login", :action => "login")
  end
  
  # there is a class NinesCollectionManager in test/mocks/test that makes this work. Should probaby change.
  it "valid user should login successfully" do
    post :login, {:username => 'username', :password => 'password'} 
    response.should redirect_to(:controller => "sidebar", :action => "cloud", :type => "tag")
    session[:user][:username].should == "username"
  end
  
  it "logout from exhibits should redirect to exhibits" do
    request.env["HTTP_REFERER"] = "exhibits"
    get :logout
    response.should redirect_to(:controller => "exhibits")
  end
  
  it "logout from collect redirects to browse" do
    post :login, {:username => 'username', :password => 'password'} 
    get :logout
    response.should redirect_to(:controller => "search", :action => "browse")
  end
  
  it "'signup' should accept usernames with periods" do
    post :signup, {:username => 'user.name', :email => "fake@email.com", :fullname => "Full Name", :password => "password", :password2 => "password"}
    response.should redirect_to(:controller => "sidebar", :action => "cloud", :type => "genre")
    session[:user][:username].should == "user.name"
  end
  
  it "'signup' should reject usernames with spaces" do
    post :signup, {:username => 'user name', :email => "fake@email.com", :fullname => "Full Name", :password => "password", :password2 => "password"}
    response.should be_success
    response.should render_template("signup")
  end
  
  it "'signup' should reject email addresses without '@'" do
    post :signup, {:username => 'username', :email => "fakeemail.com", :fullname => "Full Name", :password => "password", :password2 => "password"}
    response.should be_success
    response.should render_template("signup")
  end
  
  it "'signup' should not allow blank passwords" do
    post :signup, {:username => 'username', :email => "fake@email.com", :fullname => "Full Name", :password => "", :password2 => ""}
    response.should be_success
    response.should render_template("signup")
  end
  
  it "'signup' should not allow non-matching passwords" do
    post :signup, {:username => 'username', :email => "fake@email.com", :fullname => "Full Name", :password => "one", :password2 => "two"}
    response.should be_success
    response.should render_template("signup")
  end
  
  it "'signup' should not allow duplicate usernames" do
    post :signup, {:username => 'username', :email => "fake@email.com", :fullname => "Full Name", :password => "password", :password2 => "password"}
    response.should be_redirect
    response.should redirect_to(:controller => "sidebar", :action => "cloud", :type => "genre")
    session[:user][:username].should == "username"

    post :signup, {:username => 'username', :email => "fake@email.com", :fullname => "Full Name", :password => "password", :password2 => "password"}
    response.should be_success
    response.should render_template("signup")
  end
  
end