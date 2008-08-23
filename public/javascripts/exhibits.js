/** 
 *  Copyright 2008 Applied Research in Patacriticism and the University of Virginia
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 **/
 
var Exhibit = {
  addAuthorInput: function(container_id){
    Exhibit.addRoleInput(container_id, 'exhibited_user_resource[role_AUT][]')
  },
  
  addEditorInput: function(container_id){
    Exhibit.addRoleInput(container_id, 'exhibited_user_resource[role_EDT][]')
  },
  
  addTranslatorInput: function(container_id){
    Exhibit.addRoleInput(container_id, 'exhibited_user_resource[role_TRL][]')
  },
  
  addRoleInput: function(container_id, input_name){
    var div = new Element('div').update(
      new Element('input', {type: 'text', name: input_name})
    ).insert(
      new Element('a', {href: '#', onClick: "this.up().remove(); return false;"}).update('remove')
    ); 
    
    $(container_id).insert(div);
    return false;
  }
}