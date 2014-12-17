// ------------------------------------------------------------------------
//     Copyright 2010 Applied Research in Patacriticism and the University of Virginia
//
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global GeneralDialog, submitForm, reloadPage */
/*extern featureDlg, varFeatureDlg, stopFeatureUpload */

var varFeatureDlg = null;

function stopFeatureUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		varFeatureDlg.fileUploadFinished();
	else
		varFeatureDlg.fileUploadError(errMessage);
	return true;
}

var featureDlg = function(saved_searches, ok_action, params, img_url) {
	var This = this;

	var dlg = null;
	var sendWithAjax = function (event, params)
	{
		varFeatureDlg = This;
		//var curr_page = params.curr_page;
		var url = params.arg0;

		dlg.setFlash('Verifying feature update...', false);
		//var data = dlg.getAllData();

		submitForm('layout', url.url, url.method);	// we have to submit the form normally to get the uploaded file transmitted.
	};

	this.fileUploadError = function(errMessage) {
		dlg.setFlash(errMessage, true);
	};

	this.fileUploadFinished = function() {
		dlg.setFlash('Feature updated successfully. Please wait...', false);
		reloadPage();
	};

	var dlgLayout = {
		page: 'layout',
		rows: [
			[ { text: 'Object\'s URI:', klass: 'admin_dlg_label' },     { input: 'features[object_uri]', klass: 'new_exhibit_input_long', value: params.object_uri } ],
			[ { text: 'Saved Search URL:', klass: 'admin_dlg_label' }, { input: 'features[saved_search_url]', value: params.saved_search_url, klass: 'new_exhibit_input_long' } ],
			[ { text: 'Disabled:', klass: 'admin_dlg_label' }, { checkbox: 'features[disabled]', klass: 'new_exhibit_input_long', value: params.disabled } ],
			[ { rowClass: 'clear_both' }, { text: 'Thumbnail:', klass: '' },  { image: 'image', size: '37', value: img_url, removeButton: 'Remove Thumbnail', klass: '' } ],
			[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
		]
	};

	var dlgParams = { this_id: "features_dlg", pages: [ dlgLayout ], body_style: "forum_reply_dlg", row_style: "new_exhibit_row", title: "Features", focus: 'features_object_uri' };
	dlg = new GeneralDialog(dlgParams);
	//dlg.changePage('layout', 'features_object_uri');
	dlg.center();
};
