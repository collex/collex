// cursor.js
//
// Requires the global variable currLine to contain the current line number.
// Requires the object 'line' to handle all getting and setting values for the set of data.

/*global currLine */
/*global YUI */
/*global line */
/*extern imgCursor */

var imgCursor = { };

YUI().use('node', 'event-delegate', 'event-custom', 'resize', function(Y) {
   console.log("IMAGE_CURSOR LOADED "+ new Date());
	function get_scaling() {
		// Get the scaling and offset of the thumbnail image.
		var imgThumb = Y.one("#tw_img_thumb");
		var ofsXThumb = imgThumb.getX();
		var ofsYThumb = imgThumb.getY();
		var displaySizeThumb = { width: imgThumb._node.width, height: imgThumb._node.height };
		var xFactorThumb = displaySizeThumb.width / imgWidth;
		var yFactorThumb = displaySizeThumb.height / imgHeight;
		return { origWidth: imgWidth, ofsXThumb: ofsXThumb, ofsYThumb: ofsYThumb, xFactorThumb: xFactorThumb, yFactorThumb: yFactorThumb };
	}

	function setPointer(id, left, top, width, height, ofsX, ofsY, scrollY) {
		var pointer = Y.one(id);
		var pLeft = left + ofsX;
		var pTop = top + ofsY - scrollY;
		pointer.setStyles({ left: pLeft + 'px', top: pTop + 'px', width: width + 'px', height: height + 'px', display: 'block' });
		pointer.setAttribute('data-orig-left', pLeft);
		pointer.setAttribute('data-orig-top', pTop);
		pointer.setAttribute('data-orig-width', width);
		pointer.setAttribute('data-orig-height', height);
	}

	function hidePointer(id) {
		var pointer = Y.one(id);
		pointer.setStyles({ display: 'none' });
	}

	function setThumbnailCursor(scaling) {
		var pointer = Y.one('#tw_pointer_thumb');
		var rect = line.getRect(currLine);
		var left = rect.l * scaling.xFactorThumb + scaling.ofsXThumb;
		var top = rect.t * scaling.yFactorThumb + scaling.ofsYThumb;
		var width = (rect.r - rect.l) * scaling.xFactorThumb;
		var height = (rect.b - rect.t) * scaling.yFactorThumb;
		pointer.setStyles({ left: left + 'px', top: top + 'px', width: width + 'px', height: height + 'px' });
	}

	function getSectorLabels(sector, numImages) {
		var labels = [];
		var i;
		for ( i = 0; i < numImages; i++) {
			var label = '' + sector;
            labels.push(label);
            sector++;	// Increment after because the image numbers are 0-based
		}
		return labels;
	}

	function setImages(imgs, sector) {
		// All urls here have the following format: ..name_###.png..
		var url = imgs.item(0).getStyle('backgroundImage');
		
		// find the last - and the .png extension
		var pos = url.lastIndexOf("-");
        var pos2 = url.lastIndexOf(".png");
		var urlLeft = url.substring(0, pos+1);
		var urlRight = url.substring(pos2);
		
		// replace with selector labels
		var labels = getSectorLabels(sector, imgs.size());
		var i;
		for (i = 0; i < imgs.size(); i++) {
			imgs.item(i).setStyle('backgroundImage', urlLeft + labels[i] + urlRight);
		}
	}

	function getImageVars(scaling) {
		// Get the scaling and offset of the larger image.
		// Also get the height of the window so we know how to scroll.

		var imageVars  = {};
		imageVars.imgs = Y.all("#tw_img_full div");
		imageVars.numImages = imageVars.imgs.size();
		imageVars.middleImage = Math.floor(imageVars.numImages/2);
		imageVars.topNode = imageVars.imgs.item(0);
		imageVars.sectorSize = imageVars.topNode.get('offsetHeight');
		imageVars.ofsX = imageVars.topNode.getX();
		imageVars.ofsY = imageVars.topNode.getY();
		imageVars.displaySize = { width: imageVars.topNode.get('offsetWidth'), height: imageVars.sectorSize * imageVars.numImages };
		imageVars.ratio = imageVars.displaySize.width/scaling.origWidth;

		// Get the absolute coordinates of the current line, then scale them to the size of the visible window.
		var rect = line.getRect(currLine);
		imageVars.left = rect.l * imageVars.ratio;
		imageVars.top = rect.t * imageVars.ratio;
		imageVars.width = (rect.r - rect.l) * imageVars.ratio;
		imageVars.height = (rect.b - rect.t) * imageVars.ratio;
		// Now we have the coordinates for the window, if the entire image were shown.
		// Figure out how much to scroll to get the cursor in the visible part.

		var midCursor = imageVars.top + imageVars.height/2;
		var midWindow = imageVars.displaySize.height/2;
		imageVars.sector = midCursor / imageVars.sectorSize;
		imageVars.sector = Math.floor(imageVars.sector);	// sector is the image number that should be in the middle.
		imageVars.sector = imageVars.sector - imageVars.middleImage;	// now sector is the image number that should be on the top.
		if (imageVars.sector < 0) {
			imageVars.sector = 0;
		}
		imageVars.scrollY = imageVars.sector * imageVars.sectorSize;

		return imageVars;
	}

	function setImageCursor(scaling) {
		var imageVars = getImageVars(scaling);

		setImages(imageVars.imgs, imageVars.sector);

		setPointer('#tw_pointer_doc', imageVars.left, imageVars.top, imageVars.width, imageVars.height, imageVars.ofsX, imageVars.ofsY, imageVars.scrollY);

		// Set the word boundaries
//		if (showDebugItems) {
//			var words = line.getCurrentWords(currLine);
//			for (var i = 0; i < 20; i++) {
//				if (words && words.length > i)
//					setPointer('#tw_pointer_word_1_'+i, words[i], xFactor, yFactor, ofsX, ofsY, scrollY);
//				else
//					hidePointer('#tw_pointer_word_1_'+i);
//			}
//		}
	}

	imgCursor.convertThumbToOrig = function(x, y) {
		var scaling = get_scaling();
		return { x: (x-scaling.ofsXThumb) / scaling.xFactorThumb, y: (y-scaling.ofsYThumb) / scaling.yFactorThumb };
	};

	var resize;
	Y.on("click", function(e) {
		if (resize) {
			resize.destroy();
			resize = undefined;
		} else {
			resize = new Y.Resize({
				//Selector of the node to resize
				node: '#tw_pointer_doc'
			});
			resize.on('resize:end', function() {
				var box = imgCursor.getBox();
				if (box) {
					line.setRect(currLine, box);
					Y.Global.fire('changeLine:box_size');
				}
			});
		}
		e.halt();
	}, ".tw_resize_box");

	imgCursor.update = function() {
		var scaling = get_scaling();

		// Move the cursor for the thumbnail image.
		setThumbnailCursor(scaling);

		setImageCursor(scaling);

		if (resize) {
			resize.destroy();
			resize = undefined;
		}
	};

	imgCursor.getBox = function() {
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
			return null;    // There was no change, so don't report box data
		}
		var imageVars = getImageVars(get_scaling());
		return { l: (parseInt(left)-imageVars.ofsX)/imageVars.ratio,
			t: (parseInt(top)-imageVars.ofsY + imageVars.scrollY)/imageVars.ratio,
			r: (parseInt(width)+parseInt(left)-imageVars.ofsX)/imageVars.ratio,
			b: (parseInt(height)+parseInt(top)-imageVars.ofsY + imageVars.scrollY)/imageVars.ratio };
	};
	
	Y.Global.fire('imageCursor:loaded');

});
