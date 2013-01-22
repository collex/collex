// ------------------------------------------------------------------------
//     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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
/*global GeneralDialog, serverAction, showInLightbox, MessageBoxDlg, gotoPage, SignInDlg */
/*global window */
/*global $, $$ */
/*global Effect */
/*extern doEditDocument, showFootnoteDiv, closeFootnoteDiv, showFootnotePopup, tw_featureDlg */

/**
 * Call before editing. This will prompt for login if not
 * already logged in and redirect to correct page
 */
function doEditDocument(is_logged_in, edit_url)
{
  if ( !is_logged_in ) 
  {
    var dlg = new SignInDlg();
    dlg.setInitialMessage("Please log in to edit TypeWright texts");
    dlg.setRedirectPage( edit_url );
    dlg.show('sign_in');
  } 
  else 
  {
    gotoPage( edit_url );
  }
}

/**
 * Show the specified footnote div. Any other visible footnotes will be hidden
 */
function showFootnoteDiv(divId)
{
   var foo= $$('.footnote');
   var shown = false;
   var afterFinish = function (obj) { new Effect.Appear(divId); }; 
   for (var i = 0; i < foo.length; i++)
   {
      if ( foo[i].getStyle('display') !== 'none')
      {
        var id = foo[i].readAttribute("id");
        new Effect.Fade(id,  {afterFinish: afterFinish});
        shown = true;
      }    
   }
   
   if ( shown === false)
   {
      var box = $('footnotes_box');
      if ( box.getStyle('display') === 'none')
      {
        new Effect.BlindDown('footnotes_box',  {afterFinish: function (obj) { new Effect.Appear(divId); }});
      }
      else
      {
        new Effect.Appear(divId);
      }
   }
}

/**
 * Close and hide the specified footnote div
 */
function closeFootnoteDiv( divId )
{
    new Effect.Fade(divId,  {afterFinish: function (obj) { new Effect.BlindUp('footnotes_box'); }});
}

/**
 * Show a footnote image in a lighbox popup.
 * title: The title to be shown on the popup
 * image_path: Path to the image to display
 */
function showFootnotePopup( title, image_path )
{
  showInLightbox({ title: title, img: image_path});
}

var tw_featureDlg = function(ok_action, params) 
{
  var dlg = null;
  
  var sendWithAjax = function (event, params)
  {
    var url = params.arg0;

    dlg.setFlash('Verifying feature...', false);

    var onSuccess = function(resp)
    {
      dlg.cancel();
    };
    
    var onFailure = function(resp)
    {
      dlg.setFlash(resp.responseText, true);
    };
    
    serverAction({ action: {actions: url, els: 'tw_features', params: dlg.getAllData(), onSuccess: onSuccess, onFailure: onFailure} }); 
  };

  var dlgLayout = {
    page: 'layout',
    rows: [
      [ { text: 'Object\'s URI:', klass: 'admin_dlg_label' }, { input: 'features[uri]', klass: 'new_exhibit_input_long', value: params.uri } ],
      [ { text: 'Primary:', klass: 'admin_dlg_label' }, { checkbox: 'features[primary]', klass: 'new_exhibit_input_long', value: params.primary } ],
      [ { text: 'Disabled:', klass: 'admin_dlg_label' }, { checkbox: 'features[disabled]', klass: 'new_exhibit_input_long', value: params.disabled } ],
      [ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
    ]
  };

  var dlgParams = { this_id: "features_dlg", pages: [ dlgLayout ], body_style: "forum_reply_dlg", row_style: "new_exhibit_row", title: "Features", focus: 'features_object_uri' };
  dlg = new GeneralDialog(dlgParams);
  dlg.center();
};

  