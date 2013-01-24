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
class ApplicationController < ActionController::Base
  #session_times_out_in 4.hours
  #before_filter :set_charset
  before_filter :session_create
  
  helper_method :is_logged_in?, :username, :user,
                :is_admin?, :get_curr_user_id, :respond_to_file_upload

  # TODO-PER: This is for the old auto complete plugin. It should be replaced with the jquery one.
  ActionController::Base.send :include, AutoComplete
  ActionController::Base.helper AutoCompleteMacrosHelper

  def test_exception_notifier
		raise "This is only a test of the automatic notification system."
	end

	def test_error_response
		render :text => 'This is a test message from the server.', :status => :bad_request
	end

  private
	def new_constraints_obj()
		return [ FederationConstraint.new(:fieldx => 'federation', :value => Setup.default_federation(), :inverted => false) ]
	end

  	def refill_session_cache()
		session[:num_docs] = nil
		session[:num_sites] = nil
		session[:federations] = nil
		session[:archives] = nil
		session[:carousel] = nil
		session[:resource_tree] = nil
    session[:languages] = nil
		Catalog.set_cached_data(session[:carousel], session[:resource_tree], session[:archives], session[:languages])
		session_create()
	end

	def session_create
		logger.warn("Session: #{ session && !session['user'].blank? ? session['user'][:username] : "ANONYMOUS" } #{session ? session.keys : "ERROR"}")
		begin
			ActionMailer::Base.default_url_options[:host] = request.host_with_port
			if !self.kind_of?(TestJsController)
				session[:constraints] ||= new_constraints_obj()
				solr = Catalog.factory_create(session[:use_test_index] == "true")
				session[:num_docs] ||= solr.num_docs()
				session[:num_sites] ||= solr.num_sites()
				session[:num_docs] ||= 0
				session[:num_sites] ||= 0
			end
			if session[:federations] == nil
				solr ||= Catalog.factory_create(session[:use_test_index] == "true")
				session[:federations] = solr.get_federations()
			end
			if session[:archives] == nil || session[:carousel] == nil || session[:resource_tree] == nil
				solr ||= Catalog.factory_create(session[:use_test_index] == "true")

				session[:archives] = solr.get_archives()
				session[:carousel] = solr.get_carousel()
				session[:resource_tree] = solr.get_resource_tree()
        session[:languages] = solr.get_languages()
			else
				Catalog.set_cached_data(session[:carousel], session[:resource_tree], session[:archives], session[:languages])
			end
		rescue Catalog::Error => e
			logger.error "****\n**** Catalog Error: #{e.to_s} ApplicationController:session_create\n****"
			session[:num_docs] ||= 0
			session[:num_sites] ||= 0
			session[:federations] ||= {}
			session[:archives] ||= []
			session[:carousel] ||= []
			session[:resource_tree] ||= []
		end
    end
  
#    def set_charset
#      headers['Content-Type'] = 'text/html; charset=utf-8'
#      headers['Pragma'] = 'no-cache'
#      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
#    end
      
    def is_logged_in?
      session[:user] ? true : false
    end

    def is_admin?
      user = session[:user]
      if user and user[:role_names] and user[:role_names].include? 'admin'
        return true
      end
      return false
    end
    def username
      session[:user] ? session[:user][:username] : nil
    end
    
    def user
      username ? User.find_by_username(username) : nil
    end
    
		def get_curr_user
			user = session[:user]
			return nil if user == nil
			user = User.find_by_username(user[:username])
			return user
		end
  protect_from_forgery
		def get_curr_user_id
			user = session[:user]
			return nil if user == nil
			user = User.find_by_username(user[:username])
			return user.id
		end

    def render_404
      respond_to do |type|
        type.html { render :file => "#{Rails.root}/public/static/#{SKIN}/404.html", :status => "404 Not Found", :layout => false }
        type.all  { render :nothing => true, :status => "404 Not Found" }
      end
    end

    def render_422
      respond_to do |type|
        type.html { render :file => "#{Rails.root}/public/static/#{SKIN}/422.html", :status => "422 Error", :layout => false }
        type.all  { render :nothing => true, :status => "422 Error" }
      end
    end
	#
    #def render_500
    #  respond_to do |type|
    #    type.html { render :file => "#{Rails.root}/public/static/#{SKIN}/500.html", :status => "500 Error", :layout => false }
    #    type.all  { render :nothing => true, :status => "500 Error" }
    #  end
    #end
	#
    #def rescue_action_in_public(exception)
    #  case exception
    #    when ::ActiveRecord::RecordNotFound, ::ActionController::UnknownController, ::ActionController::UnknownAction, ::ActionController::RoutingError
    #      render_404
	#
    #    else
    #      render_500
	#
    #      deliverer = self.class.exception_data
    #      data = case deliverer
    #        when nil then {}
    #        when Symbol then send(deliverer)
    #        when Proc then deliverer.call(self)
    #      end
	#
    #      ExceptionNotifier.deliver_exception_notification(exception, self,
    #        request, data)
    #  end
    #end

	def respond_to_file_upload(callback, message)
	  return "<script type='text/javascript'>window.top.window.#{callback}('#{message}');</script>"
	end

end
