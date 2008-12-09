/**
 * @author paulrosen
 */
var Widenable = {
 	einfo: false,
 	minwidth: 10,
 	prepare: function(ta, callbackFunction)
 	{
		var target = $(ta);
		if (target.hasClassName("widenable_attached"))
			return;
			
		target.addClassName("widenable_attached");
		
		// Wrap the existing element in a table and put the handler beside it.
		var wrapper1 = target.wrap('td');
		var wrapper2 = wrapper1.wrap('tr');
		var wrapper = wrapper2.wrap('table');
		var column = new Element('td');
 		var handler = new Element('span');
 		wrapper2.appendChild(column);
		column.appendChild(handler);
		column.setStyle({ verticalAlign : 'bottom' });

 		//wrapper.style.width = ta.offsetWidth + 'px';
		//wrapper.setAttribute({cellSpacing : '0px', cellPadding: '0px' });
		wrapper.setStyle({cellSpacing : '0px', cellPadding: '0px' });

		handler.setStyle( { cursor: 'e-resize',
			border : "0px",
			padding: "0px" });
		handler.innerHTML = '<img src="../images/resize-handler.gif" alt="" class="resizer" onmousedown="Widenable.onmousedown(event, this);"/>';
		//handler.innerHTML = '&hArr;';

 		handler._wrapper = wrapper;
		var elToWiden = $(target.getAttribute('widenableelement'));
		if (!elToWiden)
			elToWiden = target;
		elToWiden.callbackFunction = callbackFunction;
 		handler._ta = elToWiden;
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
 			x: e.clientX
 		};
		this.einfo.ta.className += ' textarea-active';
		this.einfo.wrapper.className = 'textarea-wrapper';
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
		this.einfo.ta.className = this.einfo.ta.className.replace(/ *textarea-active/, '');
		this.einfo.wrapper.className = '';
		var callbackFunction = $(this.einfo.ta).callbackFunction;
		callbackFunction(this.einfo.ta.id, $(this.einfo.ta).getAttribute("element_id"), parseInt($(this.einfo.ta).getStyle('width')));
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
