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

/*global $H, Class, $, $$, Element */
/*global window, document */
/*global YUI */
/*global GeneralDialog, genericAjaxFail, MessageBoxDlg */
/*extern serverAction, serverNotify, serverNotifySync, serverRequest, postLink, formatFailureMsg, submitForm, reloadPage, gotoPage, openInNewWindow, submitFormWithConfirmation, ConfirmDlg */

/*
 * Registers a callback which copies the csrf token into the
 * X-CSRF-Token header with each ajax request.  Necessary to
 * work with rails applications which have fixed
 * CVE-2011-0447
 */
Ajax.Responders.register({
   onCreate : function(request) {
      var csrf_meta_tag = $$('meta[name=csrf-token]')[0];

      if (csrf_meta_tag) {
         var header = 'X-CSRF-Token', token = csrf_meta_tag.readAttribute('content');

         if (!request.options.requestHeaders) {
            request.options.requestHeaders = {};
         }
         request.options.requestHeaders[header] = token;
      }
   }
});

var postLink = function(link, params, target) {
   if (window.mockSubmit) {
      window.mockSubmit(link, params, target);
   } else {
      var f = document.createElement('form');
      f.style.display = 'none';
      document.body.appendChild(f);
      f.method = 'POST';
      f.action = link;
      if (target)
         f.target = target;
      var m = document.createElement('input');
      m.setAttribute('type', 'hidden');
      m.setAttribute('name', '_method');
      m.setAttribute('value', 'post');
      f.appendChild(m);
      var csrf_param = $$('meta[name=csrf-param]')[0].content;
      var csrf_token = $$('meta[name=csrf-token]')[0].content;
      f.appendChild(new Element('input', {
         id : csrf_param,
         type : 'hidden',
         name : csrf_param,
         value : csrf_token
      }));

      if (params) {
         $H(params).each(function(p) {
            // Usually we are passed a hash of strings, but sometimes we get a value that is a hash itself. That should set up an input
            // for each value, and name it p.key[p.value.key]
            if ( typeof p.value === 'string')
               f.appendChild(new Element('input', {
                  type : 'hidden',
                  name : p.key,
                  value : p.value,
                  id : p.key
               }));
            else if ( typeof p.value === 'number') {
               f.appendChild(new Element('input', {
                  type : 'hidden',
                  name : p.key,
                  value : "" + p.value,
                  id : p.key
               }));
            } else {
               $H(p.value).each(function(pp) {
                  f.appendChild(new Element('input', {
                     type : 'hidden',
                     name : p.key + '[' + pp.key + ']',
                     value : pp.value,
                     id : pp.key
                  }));
               });
            }
         });
      }

      f.submit();
   }
};

function submitForm(id, action, method) {
   var createAuthenticityInput = function(form) {
      var csrf_param = $$('meta[name=csrf-param]')[0].content;
      var csrf_token = $$('meta[name=csrf-token]')[0].content;
      form.appendChild(new Element('input', {
         id : csrf_param,
         type : 'hidden',
         name : csrf_param,
         value : csrf_token
      }));
   };

   var form = $(id);
   if (method === 'PUT')
      form.appendChild(new Element('input', {
         id : '_method',
         type : 'hidden',
         name : '_method',
         value : "PUT"
      }));
   if (method === undefined || method === 'PUT')
      method = 'POST';
   form.writeAttribute({
      action : action,
      method : method
   });
   createAuthenticityInput(form);
   form.submit();
}

function reloadPage() {
   //window.location.reload(true);
   // This seems to defeat caching when the page is html.
   //noinspection SillyAssignmentJS
   window.location.href = window.location.href;
}

function gotoPage(url) {
   window.location = url;
}

function openInNewWindow(event, params) {
   window.open(params.arg0, '_blank');
}

var ConfirmDlg = Class.create({
   initialize : function(title, message, okStr, cancelStr, action) {
      // This puts up a modal dialog that replaces the confirm() call.

      // privileged functions
      this.ok = function(event, okParams) {
         okParams.dlg.cancel();
         action();
      };

      var dlgLayout = {
         page : 'layout',
         rows : [[{
            rowClass : 'gd_confirm_msg_row'
         }, {
            text : message,
            klass : 'gd_confirm_label'
         }], [{
            rowClass : 'gd_last_row'
         }, {
            button : okStr,
            callback : this.ok,
            isDefault : true
         }, {
            button : cancelStr,
            callback : GeneralDialog.cancelCallback
         }]]
      };

      var dlgParams = {
         this_id : "gd_confirm_dlg",
         pages : [dlgLayout],
         body_style : "gd_confirm_dlg",
         row_style : "gd_confirm_row",
         title : title
      };
      var dlg = new GeneralDialog(dlgParams);
      //dlg.changePage('layout', null);
      dlg.center();
   }
});

function submitFormWithConfirmation(params) {
   var id = params.id;
   var action = params.action;
   var method = params.method ? params.method : 'POST';
   var title = params.title;
   var message = params.message;
   var okStr = params.okStr ? params.okStr : 'Yes';
   var cancelStr = params.cancelStr ? params.cancelStr : 'No';

   var submitAction = function() {
      submitForm(id, action, method);
   };

   new ConfirmDlg(title, message, okStr, cancelStr, submitAction);
}

// confirm: (if present)
//		title: string
//		message: string
//		cancelLabel: string [def: "No"]
//		okLabel: string [def: 'Yes']
//		TODO-PER: not used - buttons: { label: string, action: function }
// action:
//	actions: An array of the URLs that will AJAXed, or a string containing a URL to be AJAXed, or a comma separated string of the URLs to be AJAXed.
//	els: An array of divs to update
//	onSuccess: A function to call if the ajax succeeds (optional)
//	onFailure: A function to call if the ajax fails (optional)
//	params: The hash that is sent back with the ajax call
// progress: (if present)
//		completeMessage: string or null
//		waitMessage: string
var serverAction = function(params) {

   var confirmParams = params.confirm;
   var actionParams = params.action;
   var progressParams = params.progress;
   var searchingParams = params.searching;

   var recurseUpdateWithAjax = function(rParams, resp) {
      // Parameters:
      //	actions: An array of the URLs that will AJAXed, or a string containing a URL to be AJAXed, or a comma separated string of the URLs to be AJAXed.
      //	els: An array of divs to update
      //	onSuccess: A function to call if the ajax succeeds (optional)
      //	onFailure: A function to call if the ajax fails (optional)
      //	rParams: The hash that is sent back with the ajax call
      //
      var action = null;
      var updateWithAjax = function(uParams) {
         // el: the element to update
         // action: the url to call
         // uParams: the params for the url
         // onSuccess: what to call after the operation successfully finishes
         // onFailure: what to call if the operation fails.
         var csrf_param = $$('meta[name=csrf-param]')[0].content;
         var csrf_token = $$('meta[name=csrf-token]')[0].content;

         var ajaxParams = uParams.params;
         if ( typeof action !== 'string') {
            ajaxParams = Object.clone(ajaxParams);
            ajaxParams._method = action.method;
            action = action.url;
         }

         // IF the ajax params come in as a string rather than a hash, we must append the
         // security token as a string append instead. If this is not done, the token will not
         // be properly accessed and rails 3.04 security treat this call as an attack and invalidate the session
         if ( typeof ajaxParams === 'string') {
            if (ajaxParams.length === 0) {
               ajaxParams += '?' + csrf_param + "=" + encodeURIComponent(csrf_token);
            } else {
               ajaxParams += '&' + csrf_param + "=" + encodeURIComponent(csrf_token);
            }
         } else {
            if (ajaxParams[csrf_param] === undefined)
               ajaxParams[csrf_param] = csrf_token;
         }

         if (uParams.el !== undefined && (uParams.el === null || uParams.el.length === 0))// we want to redraw the entire screen
         {
            if (ajaxParams._method === 'GET') {
               var url = action;
               var get_params = [];
               for (var key in ajaxParams ) {
                  if (ajaxParams.hasOwnProperty(key) && key !== csrf_param && key !== '_method') {
                     get_params.push(key + "=" + encodeURI(ajaxParams[key]));
                  }
               }

               if (get_params.length > 0) {
                  if (url.indexOf("?") > -1) {
                     url += "&";
                  } else {
                     url += "?";
                  }
                  url += get_params.join("&");
               }

               gotoPage(url);
            } else {
               // Instead of replacing an element, we want to redraw the entire page. There seems to be some conflict
               // if the form is resubmitted, so duplicate the form.
               postLink(action, ajaxParams, rParams.target);
            }
            return;
         }

         var ajaxCall = function(params) {
            jQuery.ajax({
               url : params.action,
               type : "POST",
               data : params.params,
               success : function(resp, textStatus, jqXHR) {
                  var el = $(params.el);
                  if (el) {
                     el.update(jqXHR.responseText);
                  }
                  if (params.onSuccess) {
                     params.onSuccess(jqXHR);
                  }
               },
               error : function(jqXHR, textStatus, errorThrown) {
                  if (params.onFailure) {
                     params.onFailure(jqXHR);
                  } else {
                     genericAjaxFail(params.dlg, jqXHR, params.action);
                  }
               }
            });

            // YUI().use('io', 'querystring-stringify-simple', function(Y) {
            // Y.on('io:end', function(e) { Y.Global.fire('io:end'); });
            // var onSuccess = function(id, o) {
            // var el = $(params.el);
            // if (el)
            // el.update(o.responseText);
            // if(params.onSuccess)
            // params.onSuccess(o);
            // };
            // var onFailure = function(id, o) {
            // if (params.onFailure)
            // params.onFailure(o);
            // else
            // genericAjaxFail(params.dlg, o, params.action);
            // };
            // if (window.mockAjax) {
            // var ret = window.mockXhr.execute(params);
            // Y.later(1000, this, function() {
            // if (ret.status === 200)
            // onSuccess(1, ret);
            // else
            // onFailure(1, ret);
            // Y.Global.fire('io:end');
            // });
            // } else
            // Y.io(params.action, { method: 'POST', data: params.params, on: { success: onSuccess, failure: onFailure } });
            // });
         };

         ajaxCall({
            action : action,
            params : ajaxParams,
            el : uParams.el,
            onSuccess : uParams.onSuccess,
            dlg : uParams.dlg,
            onFailure : uParams.onFailure
         });
      };

      if (rParams.params === undefined)
         rParams.params = {};
      var actions = rParams.actions;
      var els = rParams.els;
      var onSuccess = rParams.onSuccess;
      var onFailure = rParams.onFailure;
      var dlgParams = rParams.params;

      if ( typeof actions === 'string')
         actions = actions.split(',');
      else if (!Object.isArray(actions))
         actions = [actions];

      if ( typeof els === 'string')
         els = els.split(',');

      if (actions.length === 0) {
         if (onSuccess)
            onSuccess(resp);
         return;
      }

      action = actions.shift();
      var el = els ? els.shift() : null;
      var ajaxParams = {
         action : action,
         el : el,
         onSuccess : function(resp) {
            recurseUpdateWithAjax({
               actions : actions,
               els : els,
               target : actionParams.target,
               onSuccess : onSuccess,
               dlg : rParams.dlg,
               onFailure : onFailure,
               params : dlgParams
            }, resp);
         },
         dlg : rParams.dlg,
         onFailure : onFailure,
         params : dlgParams
      };
      updateWithAjax(ajaxParams);
   };

   var dlg = null;

   var finalSuccess = actionParams.onSuccess;
   var onSuccess = function(resp) {
      if (progressParams) {
         window.cancelProgressDialog();
         if (progressParams.completeMessage !== undefined) {
            new MessageBoxDlg("Success", progressParams.completeMessage);
         }
      }
      if (finalSuccess)
         finalSuccess(resp);
   };

   var onFailure = function(o) {
      if (progressParams) {
         window.cancelProgressDialog();
      }
      if (actionParams.onFailure)
         actionParams.onFailure(o);
      else
         genericAjaxFail(actionParams.dlg, o, actionParams.actions);
   };

   var action = function() {
      if (progressParams) {
         window.showProgressDialog(progressParams.waitMessage);
      }
      if (actionParams.actions) {
         recurseUpdateWithAjax({
            actions: actionParams.actions,
            els: actionParams.els,
            target: actionParams.target,
            onSuccess: onSuccess,
            dlg: actionParams.dlg,
            onFailure: onFailure,
            params: actionParams.params
         });
      } else {
         onSuccess();
      }
   };

   if (confirmParams) {
      var cancelStr = confirmParams.cancelLabel;
      if (cancelStr === undefined)
         cancelStr = "No";
      var okStr = confirmParams.okLabel;
      if (okStr === undefined)
         okStr = "Yes";
      new ConfirmDlg(confirmParams.title, confirmParams.message, okStr, cancelStr, action);
   } else
      action();
};

// This just sends a notification to the server and doesn't need a response.
var serverNotify = function(url, params) {
   serverAction({
      action : {
         actions : url,
         els : 'gd_bit_bucket',
         params : params
      }
   });
};

// This centralizes all the Ajax requests
// params:
//		url: string (required)
//		onSuccess: function (optional)
//		onFailure: function (optional)
//		params: hash of params to send to server (optional)
var serverRequest = function(params) {
   serverAction({
      action : {
         actions : params.url,
         els : 'gd_bit_bucket',
         params : params.params,
         onSuccess : params.onSuccess,
         onFailure : params.onFailure,
         dlg : params.dlg
      }
   });
};

function formatFailureMsg(resp, action) {
   if (resp.status === 500)
      return "Sorry! You've hit an error. We apologize for this problem and hope you'll bear with us as we work to make this website better! System administrators have been automatically notified of the error. If you have additional feedback, please e-mail us.";
   else if (resp.status === 404)
      return "Sorry! The server didn't understand the request \"" + action + "\". Either a bad URL was given or there is an internal error. If you think this message is in error, please email the administrators.";
   else if (resp.status === 0)
      return "Communication with the server has been temporarily interrupted. Please try again later.";
   else
      return resp.responseText;
}

