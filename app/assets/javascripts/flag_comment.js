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
/*global GeneralDialog,serverRequest */
/*global Class*/
/*extern flagComment */

function flagComment(comment_id, action_url, els, can_edit, can_delete, is_main)
{
  var ReportDlg = Class.create({
      initialize: function ( params ) {
         var title = params.title;
         var addAction = params.addAction;
         var dlg = null;
         var id='reason';
         var msg = params.msg;
         var prompt = params.prompt ? prompt : 'Reason:';
         
         // privileged functions
         this.report = function(event, reportParams)
         {
            reportParams.dlg.cancel();
            var data = reportParams.dlg.getAllData();
            serverAction({action: {
              actions: action_url, 
              els: els,
              params: { comment_id: comment_id, reason: data[id], can_edit: can_edit, can_delete: can_delete, is_main: is_main } }
            }); 
          };
      
         var dlgLayout = {
            page: 'layout',
            rows: 
            [
               [{text: msg, klass: 'gd_text_input_dlg_label'}],
               [ { text: prompt, klass: 'gd_text_input_dlg_label' }, 
                 { textarea: id, klass: 'report_comment_textarea'} ],
               [ { rowClass: 'gd_last_row'}, 
                 {button: "Report", callback: this.report, isDefault: true}, 
                 {button: 'Cancel', callback: GeneralDialog.cancelCallback} ]
            ]
         };
         dlgLayout.rows.push();
         
         
         var dlgparams = {this_id: "gd_text_input_dlg", pages: [ dlgLayout ], body_style: "gd_message_box_dlg", row_style: "gd_message_box_row", 
            title: title, focus: GeneralDialog.makeId(id)};
         dlg = new GeneralDialog(dlgparams);
         dlg.center();
      }
   });
   
   new ReportDlg({title:"Report this comment as objectionable", 
                  msg:"Enter a reason in the space below and click 'Report' to send an email to the administrators complaining about this entry."});

}
