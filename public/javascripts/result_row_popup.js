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

/*global Class, $, $$, $H, Element, Ajax */
/*global YAHOO */

///////////////////////////////////////////////////////////////////////////

var ResultRowDlg = Class.create({
	initialize: function (populate_action, uri, progress_img, extra_button_data) {
		// This puts up a modal dialog that allows the administrator to change information about a site or category.
		this.class_type = 'ResultRowDlg';	// for debugging

		// private variables
		var This = this;
		var dlg = null;
		var obj = '';
		
		// private functions
		var ajax_params = extra_button_data;
		ajax_params.uri = uri;
		var populate = function() {
			new Ajax.Request(populate_action, { method: 'get', parameters: ajax_params,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.setFlash('', false);
					try {
						obj = resp.responseText; //.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					
					
					// We got the details. Now put it on the dialog.
					var details_arr = $$('.result_row_details');
					var details = details_arr[0];
					details.update(obj);
					var hidden_els = details.select(".search_result_data .hidden");
					hidden_els.each(function(el) {
						el.removeClassName('hidden');
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});			
		};
		
		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: '<img src="' + progress_img + '" alt="" />', klass: 'result_row_details' } ],
					[ { button: 'Cancel', callback: this.cancel } ]
				]
			};
		
		var params = { this_id: "result_row_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Object Details" };
		dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
		populate();
	}
});
