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
    fname = "#{RAILS_ROOT}/log/#{RAILS_ENV}.log"
    f = File.new(fname)
    tim = "TIME"
    name = "NAME"
    f.each_line do |line|
        if line.index('LoginController#verify_login') != nil
          s = line.index(' at ') + 4
          e = line.index(')') - 1
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

end
