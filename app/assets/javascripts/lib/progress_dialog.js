/*global GeneralDialog, getCurrentProgressDialog, hideProgressDialog, setTimeout, clearTimeout, Event */

jQuery(document).ready(function($) {
   "use strict";

   var progressDialog = null;
   var progressCount = 0;
   var progressShowTimeout = null;
   var progressCancelTimeout = null;
   var pendingMessage = '';
   var defaultProgressShowDelay = 200;  // ms to wait before showing dialog
   var defaultProgressCancelDelay = 200;  // ms to wait before hiding dialog

   // updates existing progress dialog, or sets up timer with delay to show a new one
   // delay param is optional, if not passed, value of defaultProgressShowDelay will be used
   // calls to show and cancel are counted, so you must call cancelProgressDialog() an
   // equal number of times to the show calls for the dialog to actually disappear
   function showProgressDialog(message, delay) {
      progressCount++;
      if (typeof delay == "undefined") {
         delay = defaultProgressShowDelay;
      }
      if (progressCancelTimeout) {
         // if we were about to close the progress dialog, leave it open
         clearTimeout(progressCancelTimeout);
         progressCancelTimeout = null;
      }
      if (progressDialog) {
         // dialog already present, just change the message
         $('.gd_progress_dialog_message_text').text(message);
         progressDialog.show(); // make sure it is visible
      } else {
         // dialog not present, save the message
         pendingMessage = message;
         if (!progressShowTimeout) {
            // wait a short while to show the dialog, to prevent flicker for very short tasks
            progressShowTimeout = setTimeout(function () {
               progressShowTimeout = null;
               var dlg = progressCreateDialog();
               dlg.show(); // make sure it is visible
               if (progressCount < 1) {
                  // in case a cancel happened asynchronously while we were showing
                  dlg.cancel();
               } else {
                  progressDialog = dlg;
               }
            }, delay);
         }
      }
   }

   // get the current progress dialog, if one is visible
   function getCurrentProgressDialog() {
      return progressDialog;
   }

   // close progress dialog after a certain delay
   // delay param is optional, if not passed, value of defaultProgressCancelDelay will be used
   // calls to show and cancel are counted, so you must call cancelProgressDialog() an
   // equal number of times to the showProgressDialog() calls for the dialog to actually disappear
   // it is safe to call cancelProgressDialog() more times than you call show
   function cancelProgressDialog(delay) {
      progressCount--;
      if (typeof delay == "undefined") {
         delay = defaultProgressCancelDelay;
      }
      if (progressCount <= 0) {
         progressCount = 0;
         if (progressShowTimeout) {
            // if we were about to show the progress dialog, don't.
            clearTimeout(progressShowTimeout);
            progressShowTimeout = null;
         }
         if (!progressCancelTimeout) {
            // wait a short time, then close the progress dialog.
            // The wait keeps the dialog from flickering if we get a series
            // of shows and cancels right after one another.
            progressCancelTimeout = setTimeout(function () {
               progressCancelTimeout = null;
               if (progressDialog) {
                  var dlg = progressDialog;
                  progressDialog = null;
                  dlg.cancel();
                  // sometimes the mask is not getting hidden by dlg.cancel();
                  var mask = $('div.mask');
                  mask.hide();
               }
            }, delay);
         }
      }
   }

   function progressCreateDialog() {
      var dlgLayout = {
         page: 'spinner_layout',
         rows: [
            //[ {picture: '/images/progress_transparent.gif', alt: 'please wait'}],
            [
               {
                  text: ' ',
                  klass: 'gd_transparent_progress_spinner'
               }
            ],
            [
               {
                  rowClass: 'gd_progress_label_row'
               },
               {
                  text: pendingMessage,
                  klass: 'transparent_progress_label gd_progress_dialog_message_text'
               }
            ]
         ]
      };

      var pgsParams = {
         this_id: "gd_progress_spinner_dlg",
         pages: [dlgLayout],
         body_style: "gd_progress_spinner_div",
         row_style: "gd_progress_spinner_row"
      };
      var dlg = new GeneralDialog(pgsParams);
      dlg.center();
      return dlg;
   }

   window.showProgressDialog = showProgressDialog;
   window.cancelProgressDialog = cancelProgressDialog;
   window.getCurrentProgressDialog = getCurrentProgressDialog;



   function preload_images() {
      var preload_spinner = new Image();
      preload_spinner.src = progress_transparent; //"progress_transparent.gif";
      //  chrome cancels the loading of the spinner image once a page change is detected
      //  so the spinner image is never loaded.  This 'forces' it to load the image.
      // IE isn't loading the image either :(
      progressDialog = progressCreateDialog();
      progressDialog.hide();
   }

   Event.observe(window, 'load', preload_images);
});
