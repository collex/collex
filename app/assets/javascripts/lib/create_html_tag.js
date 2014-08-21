if (!window.pss)
	window.pss = {};

window.pss.createHtmlTag = function(tagName, attributes, content) {
	"use strict";
	var html = "<";

	var arrAttr = [ tagName ];
	for (var key in attributes) {
		if (attributes.hasOwnProperty(key)) {
			var val = attributes[key];
			if (val && typeof val === 'string')
				val = val.replace(/'/g, "&apos;");

			arrAttr.push(key + "='" + val + "'");
		}
	}
	html += arrAttr.join(' ');

	if (content)
		html += ">" + content + "</" + tagName + ">";
	else
		html += "/>";
	return html;
};

window.pss.createHtmlSelectTag = function(attributes, options, selection) {
	"use strict";
	var optionEl = '';
	for (var i = 0; i < options.length; i++) {
		var attr = { value: options[i].value };
		if (options[i].value === selection || options[i].text === selection ||
			(selection !== '' && options[i].value === parseInt(selection, 10)))
			attr.selected = 'selected';
		var text = options[i].text;
		if (options[i].i18n) {
			attr['data-i18n'] = options[i].i18n;
			text = window.helpers.getI18nValue(options[i].i18n);
		}
		optionEl += window.pss.createHtmlTag('option', attr, text);
	}
	return window.pss.createHtmlTag('select', attributes, optionEl);
};
