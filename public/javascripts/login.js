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

/*global Class, $, $$, $H, Ajax */
/*global GeneralDialog */

// This contains popup dialogs for signing in, my account info, creating an account, and sign in help

var SignInDlg = Class.create({
	initialize: function () {
		this.class_type = 'SignInDlg';	// for debugging

		// private variables
		var This = this;
		var initialFlashMessage = "";
		var redirectPage = "";
		
		// private functions
		this.changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.destination;
			var dlg = param.dlg;
			
			var focus_el = null;
			switch (view)
			{
//				case 'my_account': focus_el = 'account_email'; break;
				case 'sign_in': focus_el = 'signin_username'; break;
				case 'create_account': focus_el = 'create_username'; break;
				case 'account_help': focus_el = 'help_username'; break;
			}

			dlg.changePage(view, focus_el);

			return false;
		};
		
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		this.sendWithAjax = function (event, params)
		{
			var getForm = function(This) {
				if (This.up)
					return This.up('form');
				var els = $$("." + This);
				return els[0].up('form');
			};
			
			var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;

			// Get the parameters from the enclosing form
			var form = getForm(this);
			var els = form.select('input');
			var p = {};
			els.each(function(el) { p[el.id] = el.value; });
			var x = new Ajax.Request(url, {
				parameters : p,
				onSuccess : function(resp) {
					dlg.setFlash(resp.responseText, false);
					if (redirectPage === "")
						window.location.reload(true);
					else
						window.location = redirectPage;
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		// privileged methods
		this.setInitialMessage = function (message) {
			initialFlashMessage = message;
		};
		
		this.setRedirectPage = function (url) {
			redirectPage = url;
		};

		this.setRedirectPageToCurrentWithParam = function(str) {
			var url = '' + window.location;
			var anchor = "";
			if (url.indexOf('#') > 0) {
				anchor = url.substring(url.indexOf('#'));
				url = url.substring(0, url.indexOf('#'));
			}
			if (url.indexOf('?') > 0)
				url += '&';
			else
				url += '?';
			url += str;
			redirectPage = url + anchor;
		};
		
		this.show = function (view, username, email) {
			
			// TODO-PER: Code to just do a call back instead of this dialog
//			switch (view)
//			{
//				case 'sign_in':
//					window.location = '/login/login';
//					break;
//				case 'my_account':
//					window.location = '/login/account';
//					break;
//				case 'create_account':
//					window.location = '/login/signup';
//					break;
//				case 'account_help':
//					window.location = '/login/account_help';
//					break;
//			}
//			return;

			var login = {
					page: 'sign_in',
					rows: [
						[ { text: 'Log in', klass: 'login_title' } ],
						[ { text: 'User name:', klass: 'login_label' } ],
						[ { input: 'signin_username', klass: 'login_input' } ],
						[ { text: 'Password:', klass: 'login_label' } ],
						[ { password: 'signin_password', klass: 'login_input' } ],
						[ { button: 'Log in', url: '/login/verify_login', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel }],
						[ { text: '', klass: 'login_label' } ],
						[ { page_link: 'Create a new account', new_page: 'create_account', callback: this.changeView } ],
						[ { page_link: 'Forgot user name or password?', new_page: 'account_help', callback: this.changeView } ]
					]
				};

			var account_help = {
					page: 'account_help',
					rows: [
						[ { text: 'I forgot my password.', klass: 'login_title' } ],
						[ { text: 'Enter your user name and we will email a new password to your email account on file.', klass: 'login_instructions' } ],
						[ { text: 'User name:', klass: 'login_label' } ],
						[ { input: 'help_username', klass: 'login_input' } ],
						[ { button: 'Submit', url: '/login/reset_password', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ],
						[ { text: '', klass: 'login_label' } ],
						[ { text: '', klass: 'login_label' } ],
						[ { text: 'I forgot my user name.', klass: 'login_title' } ],
						[ { text: 'Enter your email address and we will email you your user name.', klass: 'login_instructions' } ],
						[ { text: 'E-mail address:', klass: 'login_label' } ],
						[ { input: 'help_email', klass: 'login_input' } ],
						[ { button: 'Submit', url: '/login/recover_username', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ],
						[ { text: '', klass: 'login_label' } ],
						[ { page_link: 'Create a new account', new_page: 'create_account', callback: this.changeView } ],
						[ { page_link: 'Log in', new_page: 'sign_in', callback: this.changeView } ]
					]
				};

			var create_account = {
					page: 'create_account',
					rows: [
						[ { text: 'Create a New Account', klass: 'login_title' } ],
						[ { text: 'User name:', klass: 'login_label' } ],
						[ { input: 'create_username', klass: 'login_input' } ],
						[ { text: 'E-mail address:', klass: 'login_label' } ],
						[ { input: 'create_email', klass: 'login_input' } ],
						[ { text: 'Password:', klass: 'login_label' } ],
						[ { password: 'create_password', klass: 'login_input' } ],
						[ { text: 'Re-type password:', klass: 'login_label' } ],
						[ { password: 'create_password2', klass: 'login_input' } ],
						[ { button: 'Sign up', url: '/login/submit_signup', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ],
						[ { page_link: 'Log in', new_page: 'sign_in', callback: this.changeView } ]
					]
				};
				
//				var my_account = {
//					page: 'my_account',
//					rows: [
//						[ { text: 'Edit Account', klass: 'login_title' } ],
//						[ { text: 'User name:', klass: 'login_label' },
//							{ id: 'account_username', klass: 'login_input', text: username } ],
//						[ { text: 'E-mail address:', klass: 'login_label' } ],
//						[ { input: 'account_email', klass: 'login_input', value: email } ],
//						[ { text: 'Password:', klass: 'login_label' } ],
//						[ { text: '(leave blank if not changing your password)', klass: 'login_instructions' } ],
//						[ { password: 'account_password', klass: 'login_input' } ],
//						[ { text: 'Re-type password:', klass: 'login_label' } ],
//						[ { password: 'account_password2', klass: 'login_input' } ],
//						[ { button: 'Update', url: '/login/change_account', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
//					]
//				};
			var pages = [ login, account_help, create_account ];

			var params = { this_id: "login_dlg", pages: pages, flash_notice: initialFlashMessage, body_style: "login_div", row_style: "login_row" };
			var dlg = new GeneralDialog(params);
			this.changeView(null, { curr_page: '', destination: view, dlg: dlg });
			dlg.center();
			
			return;
		};
	}
});

var RedirectIfLoggedIn = Class.create({
	initialize: function (url, message, isLoggedIn) {
		this.class_type = 'RedirectIfLoggedIn';	// for debugging
		
		if (isLoggedIn)
			window.location = url;
		else {
			var dlg = new SignInDlg();
			dlg.setInitialMessage(message);
			dlg.setRedirectPage(url);
			dlg.show('sign_in'); 
		}
	}
});
