//------------------------------------------------------------------------
//    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
//    
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//  
//        http://www.apache.org/licenses/LICENSE-2.0
//  
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//----------------------------------------------------------------------------

/*global Class, $, $$, Element */
/*global GeneralDialog, serverAction, submitForm */
/*extern EditFontsDlg */

var EditFontsDlg = Class.create({
	initialize : function(url, active_record_id, rec_data, table_name, show_not_specified, update_div, set_colors)
	{
		var values = rec_data;
		var options = [ { text: 'Arial', value: 'Arial'},
			{ text: 'Arial Black', value: 'Arial Black'},
			{ text: 'Courier New', value: 'Courier New'},
			{ text: 'Lucinda Console', value: 'Lucinda Console'},
			{ text: 'Tahoma', value: 'Tahoma'},
			{ text: 'Times New Roman', value: 'Times New Roman'},
			{ text: 'Trebuchet MS', value: 'Trebuchet MS'},
			{ text: 'Verdana', value: 'Verdana'}
		];

		var sizes = [ { text: '9', value: '9' }, { text: '10', value: '10' }, { text: '11', value: '11' }, { text: '12', value: '12' }, { text: '13', value: '13' },
			 { text: '14', value: '14' }, { text: '15', value: '15' }, { text: '16', value: '16' }, { text: '18', value: '18' }, { text: '20', value: '20' },
			 { text: '22', value: '22' }, { text: '24', value: '24' }, { text: '26', value: '26' }, { text: '28', value: '28' }, { text: '32', value: '32' },
			 { text: '36', value: '36' }, { text: '40', value: '40' }, { text: '44', value: '44' }, { text: '48', value: '48' }, { text: '54', value: '54' }
		];

		var ok = function (event, params)
		{
			//var curr_page = params.curr_page;
			var page = params.curr_page;
			var dlg = params.dlg;

			dlg.setFlash("Updating Fonts...", false);
			if (update_div)
				serverAction({action:{ els: update_div, params: dlg.getAllData(), actions: url, onSuccess: function() { dlg.cancel(); } }});
			else
				submitForm(page, url);
		};

		var updatePreview = function(field, new_value) {
			var parts = field.split('_');
			var preview_id = "preview_" + parts[1];
			if (parts[3] === 'size')
				$(preview_id).setStyle({ fontSize: new_value + "px" });
			else
				$(preview_id).setStyle({ fontFamily: new_value });
		};

		var layout = {
				page: 'layout',
				rows: [
					[ { select: table_name +'[use_styles]', value: values.use_styles, klass: 'not_specified hidden', options: [ { text: 'Use these styles in all exhibits', value: 1 }, { text: 'Allow exhibits to use their own styles', value: 0 } ]} ],
					[ { text: 'Header:', klass: 'edit_font_label' }, { select: table_name +'[header_font_name]', value: values.header_font_name, options: options, callback: updatePreview}, { select: table_name +'[header_font_size]', value: values.header_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'Body Text:', klass: 'edit_font_label' }, { select: table_name +'[text_font_name]', value: values.text_font_name, options: options, callback: updatePreview}, { select: table_name +'[text_font_size]', value: values.text_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'Illustration:', klass: 'edit_font_label' }, { select: table_name +'[illustration_font_name]', value: values.illustration_font_name, options: options, callback: updatePreview}, { select: table_name +'[illustration_font_size]', value: values.illustration_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'First Caption:', klass: 'edit_font_label' }, { select: table_name +'[caption1_font_name]', value: values.caption1_font_name, options: options, callback: updatePreview}, { select: table_name +'[caption1_font_size]', value: values.caption1_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'Second Caption:', klass: 'edit_font_label' }, { select: table_name +'[caption2_font_name]', value: values.caption2_font_name, options: options, callback: updatePreview}, { select: table_name +'[caption2_font_size]', value: values.caption2_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'Footnote Popup:', klass: 'edit_font_label' }, { select: table_name +'[footnote_font_name]', value: values.footnote_font_name, options: options, callback: updatePreview}, { select: table_name +'[footnote_font_size]', value: values.footnote_font_size, options: sizes, callback: updatePreview } ],
					[ { text: 'Endnotes:', klass: 'edit_font_label' }, { select: table_name +'[endnotes_font_name]', value: values.endnotes_font_name, options: options, callback: updatePreview}, { select: table_name +'[endnotes_font_size]', value: values.endnotes_font_size, options: sizes, callback: updatePreview } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Save', callback: ok, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'id', value: active_record_id } ]
				]
			};

		if (set_colors) {
			var last = layout.rows.pop();
			layout.rows.push([ { text: 'Edit the colors below by using the 6 character RGB code', klass: 'edit_color_instructions' } ]);
			layout.rows.push([ { text: 'Header Color:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_header_color]', value: values.exhibit_header_color } ]);
			layout.rows.push([ { text: 'Body Text Color:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_text_color]', value: values.exhibit_text_color } ]);
			layout.rows.push([ { text: 'Caption1 Color:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_caption1_color]', value: values.exhibit_caption1_color } ]);
			layout.rows.push([ { text: 'Caption1 Bkgrd:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_caption1_background]', value: values.exhibit_caption1_background } ]);
			layout.rows.push([ { text: 'Caption2 Color:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_caption2_color]', value: values.exhibit_caption2_color } ]);
			layout.rows.push([ { text: 'Caption2 Bkgrd:', klass: 'edit_font_label' }, { input: table_name + '[exhibit_caption2_background]', value: values.exhibit_caption2_background } ]);
			layout.rows.push(last);
		}

		var params = { this_id: "edit_font_dlg", pages: [ layout ], body_style: "edit_font_div", row_style: "new_exhibit_row", title: "Edit Exhibit Fonts" };
		var dlg = new GeneralDialog(params);
		if (show_not_specified) {
			$$('.not_specified').each(function(el){ el.removeClassName('hidden'); });
		}
		//dlg.changePage('layout', null);
		dlg.center();

		var div = $('edit_font_dlg');
		var div2 = div.down('.bd');
		var preview = new Element('div');
		preview.addClassName('font_preview');
		preview.appendChild(new Element('h3', { id: 'preview_header' }).update("Header"));

		var illustration = new Element('div', { style: "float: right;" });
		illustration.appendChild(new Element('div', { id: 'preview_illustration' }).update("Textual Illustration."));
		var caption1 = new Element('div', { id: 'preview_caption1' }).update("Caption 1");
		illustration.appendChild(caption1);
		caption1.appendChild(new Element('div', { id: 'preview_caption2' }).update("Caption 2"));
		preview.appendChild(illustration);

		preview.appendChild(new Element('div', { id: 'preview_text' }).update("Paragraph of text."));
		preview.appendChild(new Element('div', { id: 'preview_endnotes', style: 'clear:both;' }).update("<span class='endnote_superscript'>1</span>Endnote"));

		// A mockup of the footnote dialog
		var divFootnote = new Element('div', { style: "text-align: left;" });
		var divFootnote2 = new Element('div', { style: "position:inherit; visibility: visible; z-index: 2;" });
		divFootnote2.addClassName("yui-panel-container yui-dialog show-scrollbars shadow");
		divFootnote.appendChild(divFootnote2);
		var divFootnote3 = new Element('div', { style: "visibility: visible;" });
		divFootnote3.addClassName("yui-module yui-overlay yui-panel");
		divFootnote2.appendChild(divFootnote3);
		var divFootnote4 = new Element('div').update("Footnote");
		divFootnote4.addClassName("hd");
		divFootnote3.appendChild(divFootnote4);
		var divFootnote5 = new Element('div');
		divFootnote5.addClassName("bd");
		divFootnote3.appendChild(divFootnote5);
		var divFootnote6 = new Element('div');
		divFootnote5.appendChild(divFootnote6);
		var divFootnote7 = new Element('div');
		divFootnote7.addClassName("gd_message_box_row");
		divFootnote6.appendChild(divFootnote7);
		var divFootnote8 = new Element('span', { id: 'preview_footnote' }).update('Text of footnote.');
		divFootnote8.addClassName("gd_message_box_label");
		divFootnote7.appendChild(divFootnote8);
		preview.appendChild(divFootnote);

		div2.insert({ top: preview });
		div2.down(".gd_last_row").addClassName('clear_both');

		$('preview_header').setStyle({ fontFamily: values.header_font_name, fontSize: values.header_font_size + 'px', marginTop: '1px', marginBottom: '5px' });
		$('preview_header').addClassName('exhibit_header');
		$('preview_illustration').setStyle({ fontFamily: values.illustration_font_name, fontSize: values.illustration_font_size + 'px' });
		$('preview_illustration').addClassName('exhibit_illustration_text');
		$('preview_caption1').setStyle({ fontFamily: values.caption1_font_name, fontSize: values.caption1_font_size + 'px' });
		$('preview_caption1').addClassName('exhibit_caption1');
		$('preview_caption2').setStyle({ fontFamily: values.caption2_font_name, fontSize: values.caption2_font_size + 'px' });
		$('preview_caption2').addClassName('exhibit_caption2');
		$('preview_text').setStyle({ fontFamily: values.text_font_name, fontSize: values.text_font_size + 'px' });
		$('preview_footnote').setStyle({ fontFamily: values.footnote_font_name, fontSize: values.footnote_font_size + 'px' });
		$('preview_endnotes').setStyle({ fontFamily: values.endnotes_font_name, fontSize: values.endnotes_font_size + 'px' });
	}
});
