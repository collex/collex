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

var RedirectIfLoggedIn = Class.create({
	initialize: function (parent_id, url, message, isLoggedIn) {
		this.class_type = 'RedirectIfLoggedIn';	// for debugging
		
		if (isLoggedIn)
			window.location = url;
		else {
			var dlg = new SignInDlg();
			dlg.setInitialMessage(message);
			dlg.setRedirectPage(url);
			dlg.show(parent_id, 'sign_in'); 
		}
	}
});

var SignInDlg = Class.create({
	initialize: function () {
		this.class_type = 'SignInDlg';	// for debugging

		// private variables
		var This = this;
		var initialFlashMessage = "";
		var redirectPage = "";
		
		// private functions
		this.changeView = function (event, view)
		{
			// These are all the elements that can be turned on and off in the dialog.
			// All elements have switchable_element, and they each then have another class
			// that matches the value of the view parameter. Then this loop either hides or shows
			// each element.
			var els = $$('.switchable_element');
			els.each(function (el) {
				if (el.hasClassName(view))
					el.show();
				else
					el.hide();
			});
			
			switch (view)
			{
				case 'my_account': $('account_email').focus(); break;
				case 'sign_in': $('signin_username').focus(); break;
				case 'create_account': $('create_username').focus(); break;
				case 'account_help': $('help_username').focus(); break;
			}

			return false;
		};
		
		this.sendWithAjax = function (event, params)
		{
			var url = params[0];
			var flash_id = params[1];
			// Get the parameters from the enclosing form
			var form = this.up('form');
			var els = form.select('input');
			var p = {};
			els.each(function(el) { p[el.id] = el.value; });
			var x = new Ajax.Request(url, {
				parameters : p,
				onSuccess : function(resp) {
					$(flash_id).update(resp.responseText);
					if (redirectPage === "")
						window.location.reload(true);
					else
						window.location = redirectPage;
				},
				onFailure : function(resp) { $(flash_id).update(resp.responseText); }
			});
		};

		// privileged methods
		this.setInitialMessage = function (message) {
			initialFlashMessage = message;
		};
		
		this.setRedirectPage = function (url) {
			redirectPage = url;
		}
		
		this.show = function (parent_id, view, username, email) {
			
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

			var elements = [
				{
					page: 'my_account',
					title: 'Manage your Collex account',
					elements: [
						{
							item_type: 'instructions', data: 'Change any of your account items below.'
						},
						{
							item_type: 'group', data: {
								title: 'Account',
								fields: [
									{ id: 'account_username', label: 'User name:', fixed: (username === undefined) ? '' : username },
									{ id: 'account_email', label: 'E-mail address:', text: 30, value: (email === undefined) ? '' : email },
									{ id: 'account_password', label: 'Password:', password: 30 },
									{ label: ' ', fixed: '(leave blank if not changing your password)' },
									{ id: 'account_password2', label: 'Re-type password:', password: 30 },
									{ submit: 'UPDATE', submit_url: '/login/change_account', callback: this.sendWithAjax }
								]
							}
						}
					]
				},

				{
					page: 'sign_in',
					title: 'Collex Account Sign in',
					elements: [
						{
							item_type: 'instructions', data: 'Sign in to personalize your Collex experience.<br/>If you sign in, you can collect objects and create tags.'
						},
						{
							item_type: 'group', data: {
								title: 'Sign in',
								fields: [
									{ id: 'signin_username', label: 'User name:', text: 30 },
									{ id: 'signin_password', label: 'Password:', password: 30 },
									{ submit: 'Sign In', submit_url: '/login/verify_login', callback: this.sendWithAjax }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: "I don't have an account.",
								fields: [
									{ page_link: 'Create a new account', new_page: 'create_account', callback: this.changeView }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: "I can't access my account.",
								fields: [
									{ page_link: 'Help', new_page: 'account_help', callback: this.changeView }
								]
							}
						}
					]
				},
				
				{
					page: 'create_account',
					title: 'Create Your Collex Account',
					elements: [
						{
							item_type: 'instructions', data: 'Fill in the fields below to instantly create a Collex account.'
						},
						{
							item_type: 'group', data: {
								title: 'Sign up',
								fields: [
									{ id: 'create_username', label: 'User name:', text: 30 },
									{ id: 'create_email', label: 'E-mail address:', text: 30 },
									{ id: 'create_password', label: 'Password:', password: 30 },
									{ id: 'create_password2', label: 'Re-type password:', password: 30 },
									{ submit: 'SIGN UP', submit_url: '/login/submit_signup', callback: this.sendWithAjax }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: "I already have an account.",
								fields: [
									{ page_link: 'please Sign in', new_page: 'sign_in', callback: this.changeView }
								]
							}
						}
					]
				},
				
				{
					page: 'account_help',
					title: 'Collex Account Help',
					elements: [
						{
							item_type: 'instructions', data: 'Having trouble signing in? Choose one of the options below.'
						},
						{
							item_type: 'group', data: {
								title: 'I forgot my password.',
								fields: [
									{ id: 'help_username', label: 'User name:', text: 30 },
									{ submit: 'email me a new password', submit_url: '/login/reset_password', callback: this.sendWithAjax }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: 'I forgot my user name.',
								fields: [
									{ id: 'help_email', label: 'E-mail address:', text: 30 },
									{ submit: 'email me my user name', submit_url: '/login/recover_username', callback: this.sendWithAjax }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: "I don't have an account.",
								fields: [
									{ page_link: 'please Sign up', new_page: 'create_account', callback: this.changeView }
								]
							}
						},
						{
							item_type: 'group', data: {
								title: "I want to try to log in again.",
								fields: [
									{ page_link: 'please Sign in', new_page: 'sign_in', callback: this.changeView }
								]
							}
						}
					]
				}
			];
			
			var dlg = new GeneralDialog(parent_id, "login_dlg", "Collex Account", elements, initialFlashMessage);
			this.changeView(null, view);
			dlg.center();
		};
	}
});

