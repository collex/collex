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

Spinner = Class.create( {
	
	initialize: function( target, config ) {
		this.frame  = 1;
		this.target = $(target);
		this.config = config;
		
		// Set the height
		if(this.config.height) {
			this.target.setStyle({ height: this.config.height+"px" });
		}
	
		// Set the width	
		if(this.config.width) {
			this.target.setStyle({ width: this.config.width+"px" });
		}
	
		// Set or get the spinner image		
		if(this.config.image) {
			var imageURL = "url("+this.config.image+")";
			this.target.setStyle( { backgroundImage: imageURL, 
									backgroundPosition: "0px 0px",
									backgroundRepeat: "no-repeat" } );
		} else {
			this.config.image = this.target.setStyle({ backgroundImage: ''});
		}
		
		// Set the frame speed
		if(!config.speed) {
			this.config.speed = 0.25;
		}

		// Set the frame speed
		if(!config.frames) {
			this.config.frames = 12;
		}
				
		// Kick off the animation
		this.executer = new PeriodicalExecuter(this.redraw.bindAsEventListener(this), this.config.speed);

		// show the spinner container
		this.target.show();
	},
	
	// Update the drawing area by adjusting the background-image
	redraw: function(pe) {				
		// If we've reached the last frame, loop back around
		if(this.frame >= this.config.frames) {
			this.frame = 1;
		}
		
		// Set the background-position for this frame
		var pos = "-"+(this.frame*this.config.width)+"px 0px";
		this.target.setStyle({ backgroundPosition: pos });
		
		// Increment the frame count
		this.frame++;
	},
	
	stop: function() {
	    this.executer.stop();
		this.target.hide();
	}
});

