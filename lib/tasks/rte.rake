##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

namespace :rte do
  
  # Strip word formatting noise from data. All of the formatting is burried
  # with xml comments, so all that is necessary to remove it is to find
  # sections delimited by <!-- and --> and chop them out
  #
  def strip_ms_word_junk( data )
    done = false
    until done
      pos = data.index( "<!--")
      if pos
        pre_comment = data[0...pos]
        work = data[pos..-1]
        ep = work.index( "-->")
        if ep
          data = pre_comment + work[(ep+3)..-1]  
        else
          raise "Element contains unterminated comment!"
        end
      else
        done = true  
      end
    end  
    
    final = ''
    # 2nd pass.. word leaves a one space line at the end of its mess. This causes trouble too, so
    # walk each line of the text and remove it if its just a  ' ' 
    data.each_line do | line |
      final += line if line.strip.length > 0
    end
    return final 
  end
  
  desc "Cleanup MS-Word formatting data from rich text exhibit entries"
  task :cleanup  => :environment do
    puts "Retrieve all exhibit entries..."  
    ele_list = ExhibitElement.all
    ele_list.each do |ele|
       puts "Cleaning element #{ele.id} ..."
      clean_txt = strip_ms_word_junk( ele.element_text )
      if clean_txt != ele.element_text
        ele.element_text = clean_txt
        ele.save
        puts "   DONE"
      else
        puts " No formatting changes made"
      end    
    end
  end
end