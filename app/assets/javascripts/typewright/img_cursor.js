// img_cursor.js
//
// This is called on page load to create the imgCursor object.
// The imgCursor object handles drawing the two red boxes.
// One red box is over the thumbnail of the entire image and is called the "thumbnail cursor".
// The other red box is over the magnified image and is called the "image cursor".
//
// It also has a click handler to start and stop the resizing of the red box in the small document overview image.
// imgCursor.convertThumbToOrig() is called when a user clicks in the thumbnail: this figures out which line was clicked.
// imgCursor.update() is called when the line changes to move the cursor.
// imgCursor.getBox() is called when the user finishes moving the thumbnail.
//
// Requires the object 'TW.line' to handle all getting and setting values for the set of data.

/*global TW */

TW.createImageCursor = function() {
	"use strict";

	function get_scaling() {
		// Get the scaling and offset of the thumbnail image.
		var imgThumb = jQuery("#tw_img_thumb");
		var ofs = imgThumb.offset();
		var displaySizeThumb = {
			width: imgThumb.width(),
			height: imgThumb.height()
		};
		var xFactorThumb = displaySizeThumb.width / TW.imgWidth;
		var yFactorThumb = displaySizeThumb.height / TW.imgHeight;
		return {
			origWidth: TW.imgWidth,
			ofsXThumb: ofs.left,
			ofsYThumb: ofs.top,
			xFactorThumb: xFactorThumb,
			yFactorThumb: yFactorThumb
		};
	}

   function setPointer(id, left, top, width, height, ofsX, ofsY, scrollY) {
      var pointer = jQuery(id);
      var pLeft = left + ofsX;
      var pTop = top + ofsY - scrollY;
      if ( width < 0) {
         width = 100;
      }
      if ( height < 0) {
         height = 20;
      }
      pointer.css({
         left : pLeft + 'px',
         top : pTop + 'px',
         width : width + 'px',
         height : height + 'px',
         display : 'block'
      });
      pointer.attr('data-orig-left', pLeft);
      pointer.attr('data-orig-top', pTop);
      pointer.attr('data-orig-width', width);
      pointer.attr('data-orig-height', height);
   }

   function setThumbnailCursor(scaling, currentLine) {
      var pointer = jQuery('#tw_pointer_thumb');
      var rect = TW.line.getRect(currentLine);
      var left = rect.l * scaling.xFactorThumb + scaling.ofsXThumb;
      var top = rect.t * scaling.yFactorThumb + scaling.ofsYThumb;
      var width = (rect.r - rect.l);
      if ( width < 0) {
         width = 100;
      }
      width = width * scaling.xFactorThumb;

      var height = (rect.b - rect.t);
      if ( height < 0) {
         height = 20;
      }
      height = height  * scaling.yFactorThumb;
      pointer.css({
         left : left + 'px',
         top : top + 'px',
         width : width + 'px',
         height : height + 'px'
      });
   }

   function getSectorLabels(sector, numImages) {
      var labels = [];
      var i;
      for ( i = 0; i < numImages; i++) {
         var label = String(sector);
         labels.push(label);
         sector++;
         // Increment after because the image numbers are 0-based
      }
      return labels;
   }

   function setImages(imgs, sector) {
      // All urls here have the following format: ..name_###.png..
      var url = jQuery(imgs[0]).css('backgroundImage');

      // find the last - and the .png extension
      var pos = url.lastIndexOf("-");
      var pos2 = url.lastIndexOf(".png");
      var urlLeft = url.substring(0, pos + 1);
      var urlRight = url.substring(pos2);

      // replace with selector labels
      var labels = getSectorLabels(sector, imgs.length);
      var i;
      for ( i = 0; i < imgs.length; i++) {
         jQuery(imgs[i]).css('backgroundImage', urlLeft + labels[i] + urlRight);
      }
   }

   function getImageVars(scaling, currentLine) {
      // Get the scaling and offset of the larger image.
      // Also get the height of the window so we know how to scroll.

      var imageVars = {};
      imageVars.imgs = jQuery("#tw_img_full div");
      imageVars.numImages = imageVars.imgs.length;
      imageVars.middleImage = Math.floor(imageVars.numImages / 2);
      var topNode = jQuery(imageVars.imgs[0]);
      imageVars.sectorSize = topNode.height();
		var ofs = topNode.offset();
      imageVars.ofsX = ofs.left;
      imageVars.ofsY = ofs.top;
      imageVars.displaySize = {
         width : topNode.width(),
         height : imageVars.sectorSize * imageVars.numImages
      };
      imageVars.ratio = imageVars.displaySize.width / scaling.origWidth;

      // Get the absolute coordinates of the current line, then scale them to the size of the visible window.
      var rect = TW.line.getRect(currentLine);
      imageVars.left = rect.l * imageVars.ratio;
      imageVars.top = rect.t * imageVars.ratio;
      imageVars.width = (rect.r - rect.l) * imageVars.ratio;
      imageVars.height = (rect.b - rect.t) * imageVars.ratio;

      // Now we have the coordinates for the window, if the entire image were shown.
      // Figure out how much to scroll to get the cursor in the visible part.
      var midCursor = imageVars.top + imageVars.height / 2;
      //var midWindow = imageVars.displaySize.height / 2;
      imageVars.sector = midCursor / imageVars.sectorSize;
      imageVars.sector = Math.round(imageVars.sector);

      var maxSector = TW.imgHeight*imageVars.ratio / imageVars.sectorSize;
      maxSector = Math.round(maxSector);

      // sector is the image number that should be in the middle.
      if ( imageVars.sector > 0 ) {
         imageVars.sector = imageVars.sector - imageVars.middleImage;
      }
      imageVars.sector = Math.min( imageVars.sector, maxSector);

      imageVars.scrollY = imageVars.sector * imageVars.sectorSize;

      return imageVars;
   }

   function setImageCursor(scaling, currentLine) {
      var imageVars = getImageVars(scaling, currentLine);

      setImages(imageVars.imgs, imageVars.sector);

      setPointer('#tw_pointer_doc', imageVars.left, imageVars.top, imageVars.width, imageVars.height, imageVars.ofsX, imageVars.ofsY, imageVars.scrollY);
   }

   var imgCursor = {
      convertThumbToOrig : function(x, y) {
         var scaling = get_scaling();
         return {
            x : (x - scaling.ofsXThumb) / scaling.xFactorThumb,
            y : (y - scaling.ofsYThumb) / scaling.yFactorThumb
         };
      },

      update : function(currentLine) {
         var scaling = get_scaling();

         // Move the cursor for the thumbnail image.
         setThumbnailCursor(scaling, currentLine);

         setImageCursor(scaling, currentLine);

      },

      getBox : function(currentLine) {
         var box = jQuery("#tw_pointer_doc");
         var left = box.css('left').replace("px", "");
         var top = box.css('top').replace("px", "");
         var width = box.css('width').replace("px", "");
         var height = box.css('height').replace("px", "");
         var origLeft = box.attr('data-orig-left');
         var origTop = box.attr('data-orig-top');
         var origWidth = box.attr('data-orig-width');
         var origHeight = box.attr('data-orig-height');
         if (left === origLeft && top === origTop && width === origWidth && height === origHeight) {
            return null;
            // There was no change, so don't report box data
         }
         var imageVars = getImageVars(get_scaling(), currentLine);
         var out=  {
            l : (parseInt(left,10) - imageVars.ofsX) / imageVars.ratio,
            t : (parseInt(top,10) - imageVars.ofsY + imageVars.scrollY) / imageVars.ratio,
            r : (parseInt(width,10) + parseInt(left,10) - imageVars.ofsX) / imageVars.ratio,
            b : (parseInt(height,10) + parseInt(top,10) - imageVars.ofsY + imageVars.scrollY) / imageVars.ratio
         };
         var del = TW.imgHeight - out.b;
         if ( del < 0 ) {
            out.b = Math.min(out.b, TW.imgHeight);
            box.css("height",((out.b-out.t)*imageVars.ratio)+"px");
         }
         out.t = Math.max(out.t, 0);
         return out;
      }
   };
   return imgCursor;
};
