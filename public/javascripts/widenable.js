/**
 * @author paulrosen
 */
var Widenable = {
 	einfo: false,
 	minwidth: 10,
 	prepare: function(ta, callbackFunction)
 	{
		var target = $(ta);
		target.callbackFunction = callbackFunction;
		
		// Wrap the existing element in a table and put the handler beside it.
		var wrapper1 = target.wrap('td');
		var wrapper2 = wrapper1.wrap('tr');
		var wrapper = wrapper2.wrap('table');
		var column = new Element('td');
 		var handler = new Element('span');
 		wrapper2.appendChild(column);
		column.appendChild(handler);

 		//wrapper.style.width = ta.offsetWidth + 'px';

		handler.setStyle( { cursor: 'e-resize' });
		handler.innerHTML = '&#x25BA;';

 		handler._wrapper = wrapper;
 		handler._ta = ta;
 		handler.onmousedown = function(e)
 		{
 			Widenable.onmousedown(e, this);
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
 			x: e.clientX,
 		};
 		with (this.einfo) {
 			ta.className += ' textarea-active';
 			wrapper.className = 'textarea-wrapper';
 		}
 		this.oldmousemove = document.onmousemove;
 		this.oldmouseup = document.onmouseup;
 		document.onmousemove = function(e)
 		{
 			Widenable.onmousemove(e);
 		}
 		document.onmouseup = function(e)
 		{
 			Widenable.onmouseup(e);
 		}
 	},
 	onmouseup: function(e)
 	{
 		if (!this.einfo) 
 			return;
 		with (this.einfo) {
 			ta.className = ta.className.replace(/ *textarea-active/, '');
 			wrapper.className = '';
			var callbackFunction = $(ta).callbackFunction;
			callbackFunction(ta.id, $(ta).getStyle('width'));
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
 		this.einfo.ta.style.width = Math.max(this.minwidth, this.einfo.w + e.clientX - this.einfo.x) + 'px';
 		//this.einfo.handler.style.width = this.einfo.ta.style.width;
 		//this.einfo.wrapper.style.width = this.einfo.ta.style.width;
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
