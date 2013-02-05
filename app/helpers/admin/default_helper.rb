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

module Admin::DefaultHelper
  class Session < ActiveRecord::Base
  end
  def get_user_login_info
    ret = []
    fname = "#{Rails.root}/log/#{Rails.env}.log"
    f = File.new(fname)
    tim = "TIME"
    name = "NAME"
    f.each_line do |line|
        if line.index('POST "/login/verify_login"') != nil
          s = line.index(' at ') + 4
          e = line.length
          tim = line[s..e]
        elsif line.index('login/verify_login]') != nil
          status = line.index('302 Found') ? "OK" : line.index('200 OK') ? "OK" : "Illegal"
          ret.push(tim + " " + name + " " + status)
          tim = "TIME"
          name = "NAME"
        elsif line.index('verify_login') != nil
          s = line.index('username"=>"')
          if s != nil
            arr = line.split('username"=>"')
            arr = arr[1].split('"')
            name = arr[0]
          elsif line.index('UPDATE `logs` SET') != nil
            # just ignore the SQL log
          else
            ret.push(tim + " " + line)
          end
        end
    end
    return ret
  end

  def make_sub_menu_link(name, controller, action, current_page)
    if name == current_page
      link_to name, { :controller => controller, :action => action}, { :class => 'admin_menu_current' }
    else
      link_to name, { :controller => controller, :action => action}
    end
  end

	def make_sub_menu(name, items, current_page)
		klass = "admin_sub_menu"
		klass += " admin_menu_current" if name == current_page
		sub_menu = []
		items.each { |item|
			sub_menu.push(link_to(item[:name], item[:url]))
		}
		html = content_tag(:div, { class: klass }) do
			raw(name + content_tag(:ul, raw(sub_menu.map { |mi| content_tag(:li, mi) }.join(''))))
		end

		return html
	end
end
