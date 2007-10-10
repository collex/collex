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

class Guest
  def id
    -1
  end

  # the guest user will have these roles:
  ROLES = ['guest']
  
  # will return false for any method <role_name>_role? that is not in ROLES and true for those in ROLES
  def method_missing(method, *args, &block)
    if method.to_s =~ /_role\?$/ 
      ROLES.include?(method.to_s[0..-7])
    else
      super
    end
  end

  def role_names
    ROLES
  end
  
  def username
    "guest"
  end
  
end