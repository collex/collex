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

var SortableExhibit = {
	
	create: function(exhibit_id, _options) {
	  var options = Object.extend({
      pageTag:        'div',
      sectionTag:     'div',
      objectTag:      'div',
      pageOverlap:    'vertical',
      sectionOverlap: 'vertical',
      objectOverlap:  'vertical'
    }, _options || { });
    
	  var exhibit_id = exhibit_id;
	  var sortableSections = $$('.section').pluck('id');
	  var sortablePages = $$('.sortable-page').pluck('id');
	  
	  sortableSections.each(function(id){
      Sortable.create(id, {tag: options.objectTag, overlap: options.objectOverlap, constraint: 'none', only: 'sortable-object', containment: sortableSections, dropOnEmpty: true, handle: 'item-handle', scroll: window});
    });
    
	  sortablePages.each(function(id){
      Sortable.create(id, {tag: options.sectionTag, overlap: options.sectionOverlap, only: 'section', containment: sortablePages, dropOnEmpty: true, handle: 'section-handle', scroll: window});
    });
    
	  Sortable.create("sortable-pages", {tag: options.pageTag, overlap: options.pageOverlap, only: 'sortable-page', handle: 'page-handle', scroll: window});
	},
	
	submit: function(exhibit_id) {
    $('exhibit-menu-spinner').show();
    $('arrange-save-successful').hide();
    $('arrange-save-failed').hide();
    
    var serializedSections = $$('.sortable-page').pluck('id').collect(function(name) {
      return Sortable.serialize(name);
    }).join('&');
     var serializedResources = $$('.section').pluck('id').collect(function(name) {
      return Sortable.serialize(name);
    }).join('&');

    new Ajax.Request("/exhibits/sort", {
      method: "post",
      parameters: Sortable.serialize("sortable-pages") + '&id=' + exhibit_id + '&' + serializedSections + '&' + serializedResources,
      onComplete: function(transport){
        $('exhibit-menu-spinner').hide();
        if(200 == transport.status)
          $('arrange-save-successful').show();
        else
          $('arrange-save-failed').show();
        end
      }
    });
  },
  
  remove: function(url, dom_id) {
    $('arrange-request-successful').hide();
    $('arrange-request-failed').hide();
    
    if (!confirm("Remove?")) return;
    
    new Ajax.Request(url, {
      method: "post",
      parameters: {_method: 'delete'},
      onSuccess: function(transport){
        var json = transport.responseText.evalJSON();
        $('arrange-request-successful').down().update(json.message);
        $('arrange-request-successful').show();
        Element.remove(dom_id);
      },
      onFailure: function(transport){
        var json = transport.responseText.evalJSON();
        $('arrange-request-failed').down().update(json.message);
        $('arrange-request-failed').show();
      }
    }); 
  }  
};

