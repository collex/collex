// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
//
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global Class, $, Event */
/*extern SidebarTagCloud */

var SidebarTagCloud = Class.create( {
	
	initialize: function( ) {				
		this.instructions = { 'tag': 'tag', 'annotation': 'annotation' };
		this.initSidebarFilterHandler();	
	},
	
	initSidebarFilterHandler: function() {
		// initialize keystroke event for sidebar filter field
		this.sidebarTouched = false;
		//this.updateTagCloud();
		Event.observe('sidebar_search', 'keyup', this.onSidebarFilter.bindAsEventListener(this) );					
	},

	// respond to changes in the sidebar filter field
	onSidebarFilter: function() {
		this.sidebarTouched = true;
		this.updateTagCloud();
	},
		
	// update the display of the tag cloud
	updateTagCloud: function() {
		
		var tagCloud = $('tagcloud');
		if( !tagCloud ) return;
		
		// so that we don't filter on the "filter tags" text.
		var sidebarFilterString = this.sidebarTouched ?	$('sidebar_search').value.toLowerCase() : "";

		// collect all of the <a> tags in the tagcloud <div> 
		var tags = tagCloud.select('a');

		var i = 0;
		var visibleTags = [];

		// hide tags that don't match the filter
		tags.each( function(tag) {
			if (tag.hasClassName('dont_filter') === false) {
				if( sidebarFilterString.blank() || (tag.innerHTML.toLowerCase().indexOf( sidebarFilterString ) >= 0) ) {
					tag.show();
					visibleTags[i++] = tag;
				} 
				else {
					tag.hide();
				}
			} else if (tag.innerHTML === '[show fewer tags]') {
				if (sidebarFilterString.blank())
					tag.show();
				else
					tag.hide();
			} else if (tag.innerHTML === '[show entire tag cloud]') {
				if (!sidebarFilterString.blank())
					tag.hide();
			}

		});

		// If some tags are hidden, then show them when the filter is used.
		var moreTags = $('more_tags');
		if (moreTags)
			moreTags.show();
	}
});

