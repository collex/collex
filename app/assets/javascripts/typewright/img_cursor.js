// cursor.js
//
// Requires the global variable currLine to contain the current line number.
// Requires the object 'line' to handle all getting and setting values for the set of data.

/*global currLine */
/*global YUI */
/*global line */
/*extern imgCursor */

var imgCursor = { };

YUI().use('node', 'event-delegate', 'event-key', 'event-mousewheel', 'event-custom', function(Y) {
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
		pointer.setStyles({ left: (left + ofsX) + 'px', top: (top +  + ofsY - scrollY) + 'px', width: width + 'px', height: height + 'px', display: 'block' });
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
		for (var i = 0; i < numImages; i++) {
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
		for (var i = 0; i < imgs.size(); i++) {
			imgs.item(i).setStyle('backgroundImage', urlLeft + labels[i] + urlRight);
		}
	}

	function setImageCursor(scaling) {
		// Get the scaling and offset of the larger image.
		// Also get the height of the window so we know how to scroll.

		var imgs = Y.all("#tw_img_full div");
		var numImages = imgs.size();
		var middleImage = Math.floor(numImages/2);
		var topNode = imgs.item(0);
		var sectorSize = topNode.get('offsetHeight');
		var ofsX = topNode.getX();
		var ofsY = topNode.getY();
		var displaySize = { width: topNode.get('offsetWidth'), height: sectorSize * numImages };
		var ratio = displaySize.width/scaling.origWidth;
		var xFactor = ratio;
		var yFactor = ratio;

		// Get the absolute coordinates of the current line, then scale them to the size of the visible window.
		var rect = line.getRect(currLine);
		var left = rect.l * xFactor;
		var top = rect.t * yFactor;
		var width = (rect.r - rect.l) * xFactor;
		var height = (rect.b - rect.t) * yFactor;
		// Now we have the coordinates for the window, if the entire image were shown.
		// Figure out how much to scroll to get the cursor in the visible part.

		var midCursor = top + height/2;
		var midWindow = displaySize.height/2;
		var sector = midCursor / sectorSize;
		sector = Math.floor(sector);	// sector is the image number that should be in the middle.
		sector = sector - middleImage;	// now sector is the image number that should be on the top.
		if (sector < 0)
			sector = 0;
		var scrollY = sector * sectorSize;
		//img.setStyles({ backgroundPosition: '0px -' + scrollY + 'px' });
		setImages(imgs, sector);

		setPointer('#tw_pointer_doc', left, top, width, height, ofsX, ofsY, scrollY);

		// Set the word boundaries
		if (showDebugItems) {
			var words = line.getCurrentWords(currLine);
			for (var i = 0; i < 20; i++) {
				if (words && words.length > i)
					setPointer('#tw_pointer_word_1_'+i, words[i], xFactor, yFactor, ofsX, ofsY, scrollY);
				else
					hidePointer('#tw_pointer_word_1_'+i);
			}
		}
	}

	imgCursor.convertThumbToOrig = function(x, y) {
		var scaling = get_scaling();
		return { x: (x-scaling.ofsXThumb) / scaling.xFactorThumb, y: (y-scaling.ofsYThumb) / scaling.yFactorThumb };
	};

	imgCursor.update = function() {
		var scaling = get_scaling();

		// Move the cursor for the thumbnail image.
		setThumbnailCursor(scaling);

		setImageCursor(scaling);
	};

});
