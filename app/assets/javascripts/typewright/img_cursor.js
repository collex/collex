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
// Requires the object 'line' to handle all getting and setting values for the set of data.

/*global line */
/*global imgWidth, imgHeight*/

var createImageCursor = function(Y) {
	"use strict";

   function get_scaling() {
      // Get the scaling and offset of the thumbnail image.
      var imgThumb = Y.one("#tw_img_thumb");
      var ofsXThumb = imgThumb.getX();
      var ofsYThumb = imgThumb.getY();
      var displaySizeThumb = {
         width : imgThumb._node.width,
         height : imgThumb._node.height
      };
      var xFactorThumb = displaySizeThumb.width / imgWidth;
      var yFactorThumb = displaySizeThumb.height / imgHeight;
      return {
         origWidth : imgWidth,
         ofsXThumb : ofsXThumb,
         ofsYThumb : ofsYThumb,
         xFactorThumb : xFactorThumb,
         yFactorThumb : yFactorThumb
      };
   }

   function setPointer(id, left, top, width, height, ofsX, ofsY, scrollY) {
      var pointer = Y.one(id);
      var pLeft = left + ofsX;
      var pTop = top + ofsY - scrollY;
      if ( width < 0) {
         width = 100;
      }
      if ( height < 0) {
         height = 20;
      }
      pointer.setStyles({
         left : pLeft + 'px',
         top : pTop + 'px',
         width : width + 'px',
         height : height + 'px',
         display : 'block'
      });
      pointer.setAttribute('data-orig-left', pLeft);
      pointer.setAttribute('data-orig-top', pTop);
      pointer.setAttribute('data-orig-width', width);
      pointer.setAttribute('data-orig-height', height);
   }

//   function hidePointer(id) {
//      var pointer = Y.one(id);
//      pointer.setStyles({
//         display : 'none'
//      });
//   }

   function setThumbnailCursor(scaling, currentLine) {
      var pointer = Y.one('#tw_pointer_thumb');
      var rect = line.getRect(currentLine);
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
      pointer.setStyles({
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
      var url = imgs.item(0).getStyle('backgroundImage');

      // find the last - and the .png extension
      var pos = url.lastIndexOf("-");
      var pos2 = url.lastIndexOf(".png");
      var urlLeft = url.substring(0, pos + 1);
      var urlRight = url.substring(pos2);

      // replace with selector labels
      var labels = getSectorLabels(sector, imgs.size());
      var i;
      for ( i = 0; i < imgs.size(); i++) {
         imgs.item(i).setStyle('backgroundImage', urlLeft + labels[i] + urlRight);
      }
   }

   function getImageVars(scaling, currentLine) {
      // Get the scaling and offset of the larger image.
      // Also get the height of the window so we know how to scroll.

      var imageVars = {};
      imageVars.imgs = Y.all("#tw_img_full div");
      imageVars.numImages = imageVars.imgs.size();
      imageVars.middleImage = Math.floor(imageVars.numImages / 2);
      imageVars.topNode = imageVars.imgs.item(0);
      imageVars.sectorSize = imageVars.topNode.get('offsetHeight');
      imageVars.ofsX = imageVars.topNode.getX();
      imageVars.ofsY = imageVars.topNode.getY();
      imageVars.displaySize = {
         width : imageVars.topNode.get('offsetWidth'),
         height : imageVars.sectorSize * imageVars.numImages
      };
      imageVars.ratio = imageVars.displaySize.width / scaling.origWidth;

      // Get the absolute coordinates of the current line, then scale them to the size of the visible window.
      var rect = line.getRect(currentLine);
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

      var maxSector = imgHeight*imageVars.ratio / imageVars.sectorSize;
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
         var box = Y.one("#tw_pointer_doc");
         var left = box.getStyle('left').replace("px", "");
         var top = box.getStyle('top').replace("px", "");
         var width = box.getStyle('width').replace("px", "");
         var height = box.getStyle('height').replace("px", "");
         var origLeft = box.getAttribute('data-orig-left');
         var origTop = box.getAttribute('data-orig-top');
         var origWidth = box.getAttribute('data-orig-width');
         var origHeight = box.getAttribute('data-orig-height');
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
         var del = imgHeight - out.b;
         if ( del < 0 ) {
            out.b = Math.min(out.b, imgHeight);
            box.setStyle("height",((out.b-out.t)*imageVars.ratio)+"px");
         }
         out.t = Math.max(out.t, 0);
         return out;
      }
   };
   return imgCursor;
};
