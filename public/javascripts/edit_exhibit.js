/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
 	var els = document.getElementsByClassName('exhibit_header');
	for (var i = 0; i < els.length; i++)
	{
		new Ajax.InPlaceEditor(els[i], 'edit_header');
	}
 	
	els = document.getElementsByClassName('exhibit_text');
	for (var i = 0; i < els.length; i++)
	{
		new Ajax.InPlaceEditor(els[i], 'edit_text', { rows : '20', cols : '40' });
	}
	
	Sortable.create('exhibit_outline');
	//Sortable.create('exhibit_outline_page');
	//Sortable.create('exhibit_outline_section');
	
	FullWindow.initialize('full_window', "OUTLINE");
 });

//<div class="full_window_wrapper" style="position:absolute; width: 362px;">// wrapper
//	<div class="full_window_client" style="z-index: 0; left: 435px; top: 209px; height: 477px; width: 362px;">
//		<div class="full_window_title">  OUTLINE </div>
//		<div class="full_window_content"> content </div>	// user supplied
//	</div>
//	<div class="full_window_resizer" style="width: 362px;"/>
//</div>

var Resizable = Class.create({
  initialize: function(element) {
    var defaults = {
      handle: false,
      reverteffect: function(element, top_offset, left_offset) {
        var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;
        new Effect.Move(element, { x: -left_offset, y: -top_offset, duration: dur,
          queue: {scope:'_draggable', position:'end'}
        });
      },
      endeffect: function(element) {
        var toOpacity = Object.isNumber(element._opacity) ? element._opacity : 1.0;
        new Effect.Opacity(element, {duration:0.2, from:0.7, to:toOpacity, 
          queue: {scope:'_draggable', position:'end'},
          afterFinish: function(){ 
            Draggable._dragging[element] = false 
          }
        }); 
      },
      zindex: 1000,
      revert: false,
      quiet: false,
      scroll: false,
      scrollSensitivity: 20,
      scrollSpeed: 15,
      snap: false,  // false, or xy or [x,y] or function(x,y){ return [x,y] }
      delay: 0
    };
    
    if(!arguments[1] || Object.isUndefined(arguments[1].endeffect))
      Object.extend(defaults, {
        starteffect: function(element) {
          element._opacity = Element.getOpacity(element);
          Draggable._dragging[element] = true;
          new Effect.Opacity(element, {duration:0.2, from:element._opacity, to:0.7}); 
        }
      });
    
    var options = Object.extend(defaults, arguments[1] || { });

    this.element = $(element);
    
    if(options.handle && Object.isString(options.handle))
      this.handle = this.element.down('.'+options.handle, 0);
    
    if(!this.handle) this.handle = $(options.handle);
    if(!this.handle) this.handle = this.element;
    
    if(options.scroll && !options.scroll.scrollTo && !options.scroll.outerHTML) {
      options.scroll = $(options.scroll);
      this._isScrollChild = Element.childOf(this.element, options.scroll);
    }

    Element.makePositioned(this.element); // fix IE    

    this.options  = options;
    this.dragging = false;   

    this.eventMouseDown = this.initDrag.bindAsEventListener(this);
    Event.observe(this.handle, "mousedown", this.eventMouseDown);
    
    Draggables.register(this);
  },
  
  destroy: function() {
    Event.stopObserving(this.handle, "mousedown", this.eventMouseDown);
    Draggables.unregister(this);
  },
  
  currentDelta: function() {
    return([
      parseInt(Element.getStyle(this.element,'left') || '0'),
      parseInt(Element.getStyle(this.element,'top') || '0')]);
  },
  
  initDrag: function(event) {
    if(!Object.isUndefined(Draggable._dragging[this.element]) &&
      Draggable._dragging[this.element]) return;
    if(Event.isLeftClick(event)) {    
      // abort on form elements, fixes a Firefox issue
      var src = Event.element(event);
      if((tag_name = src.tagName.toUpperCase()) && (
        tag_name=='INPUT' ||
        tag_name=='SELECT' ||
        tag_name=='OPTION' ||
        tag_name=='BUTTON' ||
        tag_name=='TEXTAREA')) return;
        
      var pointer = [Event.pointerX(event), Event.pointerY(event)];
      var pos     = Position.cumulativeOffset(this.element);
      this.offset = [0,1].map( function(i) { return (pointer[i] - pos[i]) });
      
      Draggables.activate(this);
      Event.stop(event);
    }
  },
  
  startDrag: function(event) {
    this.dragging = true;
    if(!this.delta)
      this.delta = this.currentDelta();
    
    if(this.options.zindex) {
      this.originalZ = parseInt(Element.getStyle(this.element,'z-index') || 0);
      this.element.style.zIndex = this.options.zindex;
    }
    
    if(this.options.ghosting) {
      this._clone = this.element.cloneNode(true);
      this.element._originallyAbsolute = (this.element.getStyle('position') == 'absolute');
      if (!this.element._originallyAbsolute)
        Position.absolutize(this.element);
      this.element.parentNode.insertBefore(this._clone, this.element);
    }
    
    if(this.options.scroll) {
      if (this.options.scroll == window) {
        var where = this._getWindowScroll(this.options.scroll);
        this.originalScrollLeft = where.left;
        this.originalScrollTop = where.top;
      } else {
        this.originalScrollLeft = this.options.scroll.scrollLeft;
        this.originalScrollTop = this.options.scroll.scrollTop;
      }
    }
    
    Draggables.notify('onStart', this, event);
        
    if(this.options.starteffect) this.options.starteffect(this.element);
  },
  
  updateDrag: function(event, pointer) {
    if(!this.dragging) this.startDrag(event);
    
    if(!this.options.quiet){
      Position.prepare();
      Droppables.show(pointer, this.element);
    }
    
    Draggables.notify('onDrag', this, event);
    
    this.draw(pointer);
    if(this.options.change) this.options.change(this);
    
    if(this.options.scroll) {
      this.stopScrolling();
      
      var p;
      if (this.options.scroll == window) {
        with(this._getWindowScroll(this.options.scroll)) { p = [ left, top, left+width, top+height ]; }
      } else {
        p = Position.page(this.options.scroll);
        p[0] += this.options.scroll.scrollLeft + Position.deltaX;
        p[1] += this.options.scroll.scrollTop + Position.deltaY;
        p.push(p[0]+this.options.scroll.offsetWidth);
        p.push(p[1]+this.options.scroll.offsetHeight);
      }
      var speed = [0,0];
      if(pointer[0] < (p[0]+this.options.scrollSensitivity)) speed[0] = pointer[0]-(p[0]+this.options.scrollSensitivity);
      if(pointer[1] < (p[1]+this.options.scrollSensitivity)) speed[1] = pointer[1]-(p[1]+this.options.scrollSensitivity);
      if(pointer[0] > (p[2]-this.options.scrollSensitivity)) speed[0] = pointer[0]-(p[2]-this.options.scrollSensitivity);
      if(pointer[1] > (p[3]-this.options.scrollSensitivity)) speed[1] = pointer[1]-(p[3]-this.options.scrollSensitivity);
      this.startScrolling(speed);
    }
    
    // fix AppleWebKit rendering
    if(Prototype.Browser.WebKit) window.scrollBy(0,0);
    
    Event.stop(event);
  },
  
  finishDrag: function(event, success) {
    this.dragging = false;
    
    if(this.options.quiet){
      Position.prepare();
      var pointer = [Event.pointerX(event), Event.pointerY(event)];
      Droppables.show(pointer, this.element);
    }

    if(this.options.ghosting) {
      if (!this.element._originallyAbsolute)
        Position.relativize(this.element);
      delete this.element._originallyAbsolute;
      Element.remove(this._clone);
      this._clone = null;
    }

    var dropped = false; 
    if(success) { 
      dropped = Droppables.fire(event, this.element); 
      if (!dropped) dropped = false; 
    }
    if(dropped && this.options.onDropped) this.options.onDropped(this.element);
    Draggables.notify('onEnd', this, event);

    var revert = this.options.revert;
    if(revert && Object.isFunction(revert)) revert = revert(this.element);
    
    var d = this.currentDelta();
    if(revert && this.options.reverteffect) {
      if (dropped == 0 || revert != 'failure')
        this.options.reverteffect(this.element,
          d[1]-this.delta[1], d[0]-this.delta[0]);
    } else {
      this.delta = d;
    }

    if(this.options.zindex)
      this.element.style.zIndex = this.originalZ;

    if(this.options.endeffect) 
      this.options.endeffect(this.element);
      
    Draggables.deactivate(this);
    Droppables.reset();
  },
  
  keyPress: function(event) {
    if(event.keyCode!=Event.KEY_ESC) return;
    this.finishDrag(event, false);
    Event.stop(event);
  },
  
  endDrag: function(event) {
    if(!this.dragging) return;
    this.stopScrolling();
    this.finishDrag(event, true);
    Event.stop(event);
  },
  
  draw: function(point) {
    var pos = Position.cumulativeOffset(this.element);
    if(this.options.ghosting) {
      var r   = Position.realOffset(this.element);
      pos[0] += r[0] - Position.deltaX; pos[1] += r[1] - Position.deltaY;
    }
    
    var d = this.currentDelta();
    pos[0] -= d[0]; pos[1] -= d[1];
    
	var par = $(this.element.parentNode);
    var r   = Position.realOffset(this.element);
	var scr = par.cumulativeScrollOffset();
	var left = parseInt(par.getStyle('left'));
	var top = parseInt(par.getStyle('top'));
	var par_width = r[0] + point[0] - scr[0] - left;
	var par_height = r[1] + point[1] - scr[1] - top;
	par.setStyle(
		{
			width : par_width + "px",
			height : par_height + "px"
		}
	);
	//$(this.element).setStyle( { top : par_height - 20 + 'px'});

    if(this.options.scroll && (this.options.scroll != window && this._isScrollChild)) {
      pos[0] -= this.options.scroll.scrollLeft-this.originalScrollLeft;
      pos[1] -= this.options.scroll.scrollTop-this.originalScrollTop;
    }
    
    var p = [0,1].map(function(i){ 
      return (point[i]-pos[i]-this.offset[i]) 
    }.bind(this));
    
    if(this.options.snap) {
      if(Object.isFunction(this.options.snap)) {
        p = this.options.snap(p[0],p[1],this);
      } else {
      if(Object.isArray(this.options.snap)) {
        p = p.map( function(v, i) {
          return (v/this.options.snap[i]).round()*this.options.snap[i] }.bind(this))
      } else {
        p = p.map( function(v) {
          return (v/this.options.snap).round()*this.options.snap }.bind(this))
      }
    }}
    
    var style = this.element.style;
//    if((!this.options.constraint) || (this.options.constraint=='horizontal'))
//      style.left = p[0] + "px";
//    if((!this.options.constraint) || (this.options.constraint=='vertical'))
//      style.top  = p[1] + "px";
	  

    if(style.visibility=="hidden") style.visibility = ""; // fix gecko rendering
  },
  
  stopScrolling: function() {
    if(this.scrollInterval) {
      clearInterval(this.scrollInterval);
      this.scrollInterval = null;
      Draggables._lastScrollPointer = null;
    }
  },
  
  startScrolling: function(speed) {
    if(!(speed[0] || speed[1])) return;
    this.scrollSpeed = [speed[0]*this.options.scrollSpeed,speed[1]*this.options.scrollSpeed];
    this.lastScrolled = new Date();
    this.scrollInterval = setInterval(this.scroll.bind(this), 10);
  },
  
  scroll: function() {
    var current = new Date();
    var delta = current - this.lastScrolled;
    this.lastScrolled = current;
    if(this.options.scroll == window) {
      with (this._getWindowScroll(this.options.scroll)) {
        if (this.scrollSpeed[0] || this.scrollSpeed[1]) {
          var d = delta / 1000;
          this.options.scroll.scrollTo( left + d*this.scrollSpeed[0], top + d*this.scrollSpeed[1] );
        }
      }
    } else {
      this.options.scroll.scrollLeft += this.scrollSpeed[0] * delta / 1000;
      this.options.scroll.scrollTop  += this.scrollSpeed[1] * delta / 1000;
    }
    
    Position.prepare();
    Droppables.show(Draggables._lastPointer, this.element);
    Draggables.notify('onDrag', this);
    if (this._isScrollChild) {
      Draggables._lastScrollPointer = Draggables._lastScrollPointer || $A(Draggables._lastPointer);
      Draggables._lastScrollPointer[0] += this.scrollSpeed[0] * delta / 1000;
      Draggables._lastScrollPointer[1] += this.scrollSpeed[1] * delta / 1000;
      if (Draggables._lastScrollPointer[0] < 0)
        Draggables._lastScrollPointer[0] = 0;
      if (Draggables._lastScrollPointer[1] < 0)
        Draggables._lastScrollPointer[1] = 0;
      this.draw(Draggables._lastScrollPointer);
    }
    
    if(this.options.change) this.options.change(this);
  },
  
  _getWindowScroll: function(w) {
    var T, L, W, H;
    with (w.document) {
      if (w.document.documentElement && documentElement.scrollTop) {
        T = documentElement.scrollTop;
        L = documentElement.scrollLeft;
      } else if (w.document.body) {
        T = body.scrollTop;
        L = body.scrollLeft;
      }
      if (w.innerWidth) {
        W = w.innerWidth;
        H = w.innerHeight;
      } else if (w.document.documentElement && documentElement.clientWidth) {
        W = documentElement.clientWidth;
        H = documentElement.clientHeight;
      } else {
        W = body.offsetWidth;
        H = body.offsetHeight
      }
    }
    return { top: T, left: L, width: W, height: H };
  }
});

var FullWindow = {
	initialize: function(content_element, title_str) {
		// We are given an element that is the contents that we are wrapping up in a window.
		// We create the following elements:
		// The window has an overall wrapper that does the border and is Draggable.
		// That contains two divs:
		// The first div is the client area of the window: that's everything but the resizer.
		// The second div is the resizer.
		// The first div in the client div is the title and contains the title_str. That is what the user grabs to drag.
		// The last div is the actual content that is passed in by the user.
		var elContent = $(content_element);
		var elClient = elContent.wrap('div', { 'class' : 'full_window_client' });
		var elTitle = new Element('div', { 'class' : 'full_window_title' });
		elTitle.innerHTML = title_str;
		elTitle.setStyle(
			{
				backgroundColor: '#cccccc',
				fontWeight: 'bold',
				textAlign: 'center',
				cursor: 'move'
			});
		elClient.insert(elTitle, 'top');
		elContent.remove();
		elClient.insert(elContent, 'bottom');
		var elWrapper = elClient.wrap('div', { 'class' : 'full_window_wrapper' });
		elWrapper.setStyle(
			{ position : 'absolute',
				backgroundColor: 'white',
				border: '4px solid #000088',
				overflow: 'auto'
			  });
		var elResizer = new Element('div', { 'class' : 'full_window_resizer' });
		elResizer.setStyle(
		{
			background : 'white url(../images/resize-handler.gif) no-repeat scroll 100% 100%',
			//border : '1px solid #B0B0B0',
			cursor : 'se-resize',
			fontSize : '11px',
			height : '11px',
			lineHeight :'11px',
		});
		elWrapper.insert(elResizer, 'bottom');

		new Draggable(elWrapper, { handle: elTitle });
		new Resizable(elResizer);

	},	// end initialize()
};

 var Resizer = {
 	einfo: false,
 	minheight: 50,
 	minwidth: 100,
 	initialize: function()
 	{
		// Attach this class to the onload function so we can initialize at the right time.
 		with (document) 
 		if (getElementsByTagName && createElement && insertBefore && appendChild) {
 			this.oldload = window.onload;
 			window.onload = this.onload;
 		}
 	},
 	onload: function()
 	{
		// First call the existing onload function so we don't break other scripts.
 		if (Resizer.oldload) {
 			Resizer.oldload();
 			Resizer.oldload = null;
 		}
		
		// Make all div's resizable if they have 'resizable' in the class name.
		var x = $$('.resizable');
		x.each( function(el) { Resizer.prepare(el) });
 	},
 	prepare: function(ta)
 	{
		var target = $(ta);
		var wrapper = target.wrap('div');
 		var handler = document.createElement('div');
 		wrapper.style.width = ta.offsetWidth + 'px';
 		handler.className = 'textarea-resizer';
 		handler.style.width = (ta.offsetWidth - 2) + 'px';
 		handler._wrapper = wrapper;
 		handler._ta = ta;
 		wrapper.appendChild(handler);
 		handler.onmousedown = function(e)
 		{
 			Resizer.onmousedown(e, this);
 		}
 	},
 	onmousedown: function(e, handler)
 	{
 		if (this.einfo || !handler._wrapper) 
 			return;
 		if (!e) 
 			e = window.event;
 		this.einfo = {
 			handler: handler,
 			wrapper: handler._wrapper,
 			ta: handler._ta,
 			w: handler._ta.offsetWidth,
 			h: handler._ta.offsetHeight,
 			x: e.clientX,
 			y: e.clientY
 		};
 		with (this.einfo) {
 			ta.className += ' textarea-active';
 			wrapper.className = 'textarea-wrapper';
 		}
 		this.oldmousemove = document.onmousemove;
 		this.oldmouseup = document.onmouseup;
 		document.onmousemove = function(e)
 		{
 			Resizer.onmousemove(e);
 		}
 		document.onmouseup = function(e)
 		{
 			Resizer.onmouseup(e);
 		}
 	},
 	onmouseup: function(e)
 	{
 		if (!this.einfo) 
 			return;
 		with (this.einfo) {
 			ta.className = ta.className.replace(/ *textarea-active/, '');
 			wrapper.className = '';
 		}
 		this.einfo = false;
 		document.onmousemove = this.oldmousemove;
 		document.onmouseup = this.oldmouseup;
 	},
 	onmousemove: function(e)
 	{
 		if (!this.einfo) 
 			return;
 		if (!e) 
 			e = window.event;
 		this.einfo.ta.style.height = Math.max(this.minheight, this.einfo.h + e.clientY - this.einfo.y) + 'px';
 		this.einfo.ta.style.width = Math.max(this.minwidth, this.einfo.w + e.clientX - this.einfo.x) + 'px';
 		this.einfo.handler.style.width = this.einfo.ta.style.width;
 		this.einfo.wrapper.style.width = this.einfo.ta.style.width;
 		this.cancel_event(e);
 		return false;
 	},
 	cancel_event: function(e)
 	{
 		if (e.preventDefault) 
 			e.preventDefault();
 		if (e.stopPropagation) 
 			e.stopPropagation();
 		e.cancelBubble = true;
 		e.returnValue = false;
 	}
 };
 
 Resizer.initialize();
