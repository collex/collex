/** 
 *  Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

SidebarTagCloud = Class.create( {
	
	initialize: function( ) {				
		this.instructions = { 'tag': 'tag', 'annotation': 'annotation' };
		this.initialCloudSize = 50000;
		this.initSidebarFilterHandler();	
	},
	
	onSidebarLoadComplete: function() {
		this.spinner.stop();
		this.initSidebarFilterHandler();					
	},
	
	initSidebarFilterHandler: function() {
		// initialize keystroke event for sidebar filter field
		this.showAllCloudTags = false;
		this.sidebarTouched = false;
		this.updateTagCloud();
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
			if( sidebarFilterString.blank() || (tag.text.toLowerCase().indexOf( sidebarFilterString ) >= 0) ) {
				tag.show();
				visibleTags[i++] = tag;
			} 
			else {
				tag.hide();
			}
		});

		// hide excess tags if we are not showing all tags
		if( this.showAllCloudTags == false && visibleTags.length > this.initialCloudSize ) {
			var tagIndex = this.initialCloudSize; 
			while( tagIndex < visibleTags.length ) {
				visibleTags[tagIndex++].hide();
			}		
		}	
	},

	// toggle whether we show all tags or a subset
	toggleShowMoreCloudTags: function() {
		this.showAllCloudTags = !this.showAllCloudTags;
		var toggleButton = $('toggle-show-all-tags');
		if( this.showAllCloudTags ) {
			toggleButton.innerHTML = "hide more";
		} else {
			toggleButton.innerHTML = "show more";		
		}	
		this.updateTagCloud();
	},

	// update the sidebar with new content from the target URL
	updateSidebar: function( targetURL ) {		

		// hide the content
		$$('.content').invoke('hide');
		
		$('sidebar-spinner').show();
		
		// display a spinner
		this.spinner = new Spinner( 'sidebar-spinner', { height: 48, width: 48, speed: 0.1, image: '/images/spinner.png'} );
		
		new Ajax.Updater('sidebar', targetURL, {
			asynchronous:true, 
			evalScripts:true,
			onComplete: this.onSidebarLoadComplete.bindAsEventListener(this)
		});
	},	
		
	defaultInstructions: function(t) {
	  var key = t.name.split('-',1)[0];
	  return this.instructions[key];
	},

	clearInstructions: function(t) {
	  if (t.value == this.defaultInstructions(t)) {t.value = '';}
	},

	check_submit: function() {		
	    if (document.forms['dataform'].tag.value == '' || document.forms['dataform'].tag.value == this.instructions['tag'] ) { 
	      alert('Sorry! you must assign at least one keyword in order to collect an object.'); 
	      return false; 
	    }
	    return true;
	}				
});

