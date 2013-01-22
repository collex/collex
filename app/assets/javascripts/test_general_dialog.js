/*global YUI, YAHOO */
/*global document, window */
/*global serverAction, serverNotify, serverRequest, GeneralDialog, initializeSelectCtrl */
/*global postLink */
/*global MessageBoxDlg, RteInputDlg, TextInputDlg, SelectInputDlg */
/*global showInLightbox, showPartialInLightBox, ShowDivInLightbox */

/* TODO: This hasn't been kept up to date and needs to just run on demand.
window.mockAjax = false;

window.mockXhr = {
	expect: {},
	add: function(action, fxn) {
		this.expect[action] = fxn;
	},
	execute: function(params) {
		var fxn = this.expect[params.action];
		if (fxn)
			return fxn(params.params);
		return { status: 404, responseText: 'URL ' + params.action + ' not expected' };
	}
};

YUI({ useBrowserConsole: true }).use('test', 'io', 'node-event-simulate', function(Y) {
	// This is the global responder for the finish of an ajax call. Just replace testCallback with the function
	// you want to use, then, when that is triggered, set testCallback back to nullFunction again.
	var nullFunction = function() {};
	var testCallback = nullFunction;
	Y.Global.on('io:end', function() {
		Y.later(100, this, testCallback);	// Delay a little to make sure the page has had a chance to update
	}, Y);

	function setAllTestsToIgnore(tests, except) {
		if (tests._should === undefined)
			tests._should = { ignore: {}};
		for (var fn in tests) {
			if (fn.indexOf('test') === 0) {
				if (fn === except)
					tests._should.ignore[fn] = false;
				else
					tests._should.ignore[fn] = true;
			}
		}
	}

	var indicateIgnored = true;
	function putTestControlsOnPage(div, arrArrTests, except) {
		var addTestNamesToList = function(ul, tests) {
			if (ul) {
				var li = document.createElement('li');
				li.innerHTML = tests.name;
				ul.appendChild(li);
				for (var fn in tests) {
					if (fn.indexOf('test') === 0) {
						li = document.createElement('li');
						li.setAttribute("id", fn);
						var a = document.createElement('a');
						a.setAttribute("href", '#');
						a.innerHTML = fn;
						li.appendChild(a);
						ul.appendChild(li);
					}
				}
			}
		};

		var outer = Y.one(div);
		for (var i = 0; i < arrArrTests.length; i++) {
			var ul = document.createElement('ul');
			outer.appendChild(ul);
			var arrTests = arrArrTests[i];
			for (var j = 0; j < arrTests.length; j++) {
				if (j !== 0) {
					var li = document.createElement('li');
					li.innerHTML = '<hr />';
					ul.appendChild(li);
				}
				addTestNamesToList(ul, arrTests[j]);
			}
		}
		outer.all('ul').each(function(el) { el.addClass('test_list'); });

		var ignoreAll = function(testToRun) {
			for (var i = 0; i < arrArrTests.length; i++) {
				var arrTests = arrArrTests[i];
				for (var j = 0; j < arrTests.length; j++) {
					setAllTestsToIgnore(arrTests[j], testToRun);
				}
			}
		};

		Y.on("click", function(e) {
			var node = e.target;
			var next = node.next();
			if (next)
				next._node.innerHTML = '';
			var parent = node.ancestor('li');
			parent.removeClass('succeeded');
			parent.removeClass('failed');
			parent.removeClass('ignored');
			parent.addClass('running');
			ignoreAll(node._node.innerHTML);
			indicateIgnored = false;
			Y.Test.Runner.run();
			return false;
		}, "#tests a");

		var handleTestResult = function(data){
			var elTest = Y.one('#'+data.testName);
			var elNext = elTest.next('li');
			if (elNext)
				elNext.addClass('running');

			switch(data.type) {
				case Y.Test.Runner.TEST_FAIL_EVENT:
					elTest.removeClass('running');
					elTest.addClass('failed');
					var msg = elTest.one('span');
					if (msg === null)
						msg = document.createElement('span');
					else
						msg = msg._node;
					msg.innerHTML = ' -- ' + data.error.message;
					elTest.appendChild(msg);
					break;
				case Y.Test.Runner.TEST_PASS_EVENT:
					elTest.removeClass('running');
					elTest.addClass('succeeded');
					break;
				case Y.Test.Runner.TEST_IGNORE_EVENT:
					elTest.removeClass('running');
					if (indicateIgnored)
						elTest.addClass('ignored');
					break;
			}
		};

		Y.Test.Runner.subscribe(Y.Test.Runner.TEST_FAIL_EVENT, handleTestResult);
		Y.Test.Runner.subscribe(Y.Test.Runner.TEST_IGNORE_EVENT, handleTestResult);
		Y.Test.Runner.subscribe(Y.Test.Runner.TEST_PASS_EVENT, handleTestResult);
		if (except)
			ignoreAll(except);
	}

	// This handles the two parts of an ajax test: the action that causes the server callback,
	// and the tests that should be run after the server has responded.
	function ajaxTest(This, fxnCall, fxnTest) {
		testCallback = Y.bind(function() {
			testCallback = nullFunction;	// Unset the callback, so there is no chance of getting called twice.
			This.resume(fxnTest);
		}, This);
		Y.bind(fxnCall, This)();
		This.wait();
	}

	var preDelay = 2000;
	var postDelay = 1000;
	// This does three actions: it makes a call to the function to be tested,
	// It simulates some type of user action, and it analyzes the results.
	// The preDelay and postDelay are in there so that the tests are on the page
	// long enough to be visible. It is important to have at least a little delay so that
	// the browser has time to process the items, but they don't need to be large if
	// you want the tests to run quickly.
	function action(This, exposition, risingAction, denouement) {
		exposition();
		Y.later(preDelay, This, function() {
			This.resume(function() {
				risingAction();
				Y.later(postDelay, This, function() {
					This.resume(denouement);
				});
				This.wait();
			});
		});
		This.wait();
	}

	// This does multiple actions in a row for a single test, with all the delays necessary
	function actions(This, arrActions) {
		if (arrActions.length === 0)
			return;
		var firstAction = arrActions[0];
		var nextActions = [];
		for (var i = 1; i < arrActions.length; i++)
			nextActions.push(arrActions[i]);

		var proxyDenouement = function() {
			firstAction[2]();
			actions(This, nextActions);
		};
		action(This, firstAction[0], firstAction[1], proxyDenouement);
	}

	//
	// ATOMIC ACTIONS
	//

	function clickElement(id) {
		var el = Y.one(id);
		el.simulate("click");
	}

	function clickX() {
		var el = Y.one(".container-close");
		el.simulate("click");
	}

	function pressEsc() {
		if (window.escFxn)
			window.escFxn.call(window.dlgThis);
//		var els = [document, '#gd_modal_dlg_parent',
//			'#gd_message_box_dlg_c',
//			'#gd_message_box_dlg',
//			'.bd',
//			'#gd_message_box_dlg_gd_message_box_dlg',
//			'#layout',
//			'#gd_message_box_dlg_btn0',
//			'#gd_message_box_dlg_btn0-button'
//		];
//		for (var i = 0; i < els.length; i++) {
//			Y.one(els[i]).simulate("keyup", { charCode: 27 });
//			Y.one(els[i]).simulate("keydown", { charCode: 27 });
//			Y.one(els[i]).simulate("keypress", { charCode: 27 });
//		}
	}
	
	function pressEnter() {
		if (window.enterFxn)
			window.enterFxn.call(window.dlgThis);
//		var el = Y.one('html');
//		el.simulate("keydown", { charCode: 13 });
	}

	function dragElement(id, x, y) {
		// Find a coordinate inside the element that is to be dragged.
		var el = Y.one("#"+id);
		if (el) {
			var currX = el.getX() + 5;
			var currY = el.getY() + 5;

			// Simulate the dragdrop
			var dd1 = new YAHOO.util.DD(id);
			dd1.handleMouseDown({ pageX: currX, pageY: currY, target: dd1.getEl() });
			YAHOO.util.DDM.handleMouseMove({ pageX: x, pageY: y });
			YAHOO.util.DDM.handleMouseUp({ pageX: x, pageY: y });
		}
	}

	function typeInEl(which, text) {
		var el = Y.one(which);
		el._node.value = text;
	}

	function setOption(select_id, index) {
		var el = Y.one("#"+select_id);
		el = el.next();
		el.simulate("mousedown");
		el = el.next();
		var option = el.one('.yuimenuitem');
		for (var i = 1; i <= index; i++)
			option = option.next();
		option.simulate("click");
	}
//  testDrag: function () {
//    var DDM = YAHOO.util.DragDropMgr;
//    var Dom = YAHOO.util.Dom;
//    var Assert = YAHOO.util.Assert;
//    var draggable = myTools.makeDraggable(this.test_div_id);
//    var start_x = Dom.getX(this.test_div_id);
//    var start_y = Dom.getY(this.test_div_id);
//    var end_x = start_x + 10;
//    var end_y = start_y + 10;
//    draggable.handleMouseDown({
//      pageX: start_x,
//      pageY: start_y,
//      target: draggable
//      });
//    DDM.handleMouseMove({ pageX: end_x, pageY: end_y });
//    DDM.handleMouseUp({ pageX: end_x, pageY: end_y });
//    Assert.areEqual(end_x, Dom.getX(this.test_div_id), 'test_div should now be at end x point');
//    Assert.areEqual(end_y, Dom.getY(this.test_div_id), 'test_div should now be at end y point');
//  }
	function resize(x, y) {
		// TODO-PER: This should resize the dialog
	}

//	function clickDropdown(id, sel) {
//		var but = Y.one("#" + id + "-button");
//		but.simulate("mousedown");
//		var buttonMenu = Y.one('.yui-button-menu.visible');
//		var choice = buttonMenu.one('li[index="' + sel + '"]');
//		choice.simulate("click");
////		Y.one("#yui-gen"+sel).simulate("click");
//		but.simulate("mouseup");
//		Y.one("#" + id).removeClass('yui-button-active yui-menu-button-active');
//	}
//
//	function clickOption(id, option) {
//		var links = Y.all("#" + id + " a");
//		links.each(function(a) {
//			if (a._node.innerHTML === option)
//				a.simulate("click");
//		});
//	}
//
//	function setTextField(id, value) {
//		var field = Y.one('#'+id);
//		field._node.value = value;
//	}
//
//	function readDropdown(id, sel) {
//		var but = Y.one("#" + id + "-button");
//		but.simulate("mousedown");
//		var buttonMenu = Y.one('.yui-button-menu.visible');
//		var el = buttonMenu.one('li[index="' + sel + '"] a');
//		but.simulate("mouseup");
//		but.simulate("mousedown");
//		but.simulate("mouseup");
//
//		var str = el._node.innerHTML;
//		return str;
//	}
//
//	function makeDirty() {
//		var el = Y.one('#abc');
//		el.simulate("keypress", { charCode: 65 });
//	}

	//
	// ASSERTS
	//
	function dlgGone() {
		var div = Y.one("#gd_modal_dlg_parent");
		if (div) {
			Y.Assert.areSame("", div._node.innerHTML, "The dialog was not successfully removed.");
		}
	}

	function assertExists(id) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Element " + id + " should exist.");
	}

	function containsText(id, text) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Div should contain text, but was not present.");
		var inner = div._node.innerHTML;
		Y.assert(inner.indexOf(text) >= 0, "The text \"" + text + "\" was not present in the element \"" + id + "\"");
	}

	function assertValue(id, text) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Div should contain a value, but was not present.");
		var inner = div._node.value;
		Y.assert(inner.indexOf(text) >= 0, "The value \"" + text + "\" was not present in the element \"" + id + "\"");
	}

	function assertClass(id, klass) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Div should contain a class, but was not present.");
		var k = div._node.className;
		Y.Assert.areSame(k, klass, "The element should have the class " + klass);
	}

	function assertTag(id, tag) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Element should be an input tag, but was not present.");
		Y.assert(div._node.tagName.toLowerCase() === tag.toLowerCase(), "Element should have an " + tag + " tag but had a tag of "+div._node.tagName);
	}

	function assertInputType(id, type) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Element should be an input tag, but was not present.");
		Y.assert(div._node.tagName.toLowerCase() === 'input', "Element should have an input tag but had a tag of "+div._node.tagName);
		Y.assert(div._node.type === type, "Input should be of type " + type);
	}

	function assertElementArrayText(id, texts) {
		var els = Y.all(id);
		Y.Assert.areSame(texts.length, els._nodes.length, "There should be " + texts.length + " elements, but there were " + els._nodes.length);
		for (var i = 0; i < els._nodes.length; i++) {
			Y.Assert.areSame(texts[i], els._nodes[i].innerHTML, "The " + i + " element should have the value " + texts[i] + ", but is " + els._nodes[i].innerHTML);
		}
	}

	function assertAttributes(id, attributes) {
		var div = Y.one(id);
		Y.Assert.isNotUndefined(div, "Element should be present.");
		for (attr in attributes) {
			if (hasOwnProperty(attr)) {
				var value = div.getAttribute(attr);
				Y.Assert.isNotUndefined(value, "Element should have the attribute " + attr);
				Y.Assert.areSame(attributes[attr], value, "The " + attr + " attribute should have the value " + attributes[attr] + ", but is " + value);
			}
		}
	}

	function assertSelect(id, texts) {
		var els = Y.all(id+' option');
		Y.Assert.areSame(texts.length, els._nodes.length, "There should be " + texts.length + " elements, but there were " + els._nodes.length);
		for (var i = 0; i < els._nodes.length; i++) {
			Y.Assert.areSame(texts[i], els._nodes[i].innerHTML, "The " + i + " element should have the value " + texts[i] + ", but is " + els._nodes[i].innerHTML);
		}
	}

	function assertFlashError(text) {
		var el = Y.one('.gd_flash_notice_error');
		if (el === null && text === null)
			return;
		Y.Assert.areSame(text, el._node.innerHTML);
	}

	function assertFlashOk(text) {
		var el = Y.one('.gd_flash_notice_ok');
		Y.Assert.areSame(text, el._node.innerHTML);
	}

	function assertHasDragHeader(has) {
		var header = Y.one('.hd');
		if (header) {
			var hasId = (header._node.id === "gd_message_box_dlg_h");
			var cursorStyle = header.getStyle('cursor');
			if (has) {
				Y.Assert.areSame('move', cursorStyle, 'Dragging error: header should have a hand cursor');
				Y.Assert.areSame(true, hasId, "Dragging error: header should be set up with id");
			} else {
				Y.Assert.areSame('auto', cursorStyle, 'Dragging error: header should NOT have a hand cursor');
				Y.Assert.areSame(false, hasId, "Dragging error: header should NOT be set up with id");
			}
		} else {
			if (has)
				Y.assert(false, 'Dragging error: should have header');
		}
	}

	function assertPosition(id, x, y) {
		var el = Y.one("#"+id);
		if (el) {
			var currX = el.getX() + 5;
			var currY = el.getY() + 5;
			Y.Assert.areSame(x, currX, "X Position is not correct: " + x + ' vs. ' + currX);
			Y.Assert.areSame(y, currY, "Y Position is not correct: " + y + ' vs. ' + currY);
		}
	}

////---------------------------------------------------------------

	function ajaxThenCancel(This, fxnCall, fxnTest) {
		var risingAction = function() {
			clickX();
			Y.later(postDelay, This, function() {
				This.resume(dlgGone);
			});
			This.wait();
		};
		var fxnNewTest = function() {
			fxnTest();
			Y.later(postDelay, This, function() {
				This.resume(risingAction);
			});
			This.wait();
		};
		ajaxTest(This, fxnCall, fxnNewTest);
	}

	//
	// TESTS
	//
	var dlg = new Y.Test.Suite({
		name : "general_dialog",

		setUp : function () {
			//test-suite-level setup
		},

		tearDown: function () {
			//test-suite-level teardown
		}
	});

	var testCaseMessageBox = new Y.Test.Case({
		name: "MessageBox",

		_should: {
			ignore: {
			}
		},
		testShowDlg : function () {
			action(this,
				function() {
					new MessageBoxDlg("Testing the message box", "This is a test of the messagebox.");
				},
				function() {
					assertHasDragHeader(true);
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowDlgSecond : function () {
			action(this,
				function() {
					new MessageBoxDlg("Testing a second messagebox", "This is another test of the messagebox.");
				},
				function() {
					clickElement("#gd_message_box_dlg_btn0-button");
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowDlgEsc : function () {
			action(this,
				function() {
					new MessageBoxDlg("Testing the ESC key", "The ESC key should dismiss this dialog.");
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowDlgDrag : function () {
			actions(this,
				[[function() {
					new MessageBoxDlg("Test dragging the dialog", "This dialog should move to the upper left.");
				},
				function() {
					dragElement("gd_message_box_dlg_h", 14, 20);
				},
				function() {
					assertPosition("gd_message_box_dlg_h", 14, 20);
					assertHasDragHeader(true);
				}],
				[function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testShowDlgEnter : function () {
			action(this,
				function() {
					new MessageBoxDlg("Testing the ENTER key", "The ENTER key should dismiss this dialog.");
				},
				function() {
					pressEnter();
				},
				function() {
					dlgGone();
				}
			);
		}
	});
	dlg.add(testCaseMessageBox);


	var testCaseLightBox = new Y.Test.Case({
		name: "Lightbox",

		_should: {
			ignore: {
				testShowLightboxAjax500: true,
				testShowLightboxResize: true
			}
		},
		testShowLightboxDefault : function () {
			action(this,
				function() {
					showInLightbox({ title: "Lightbox - default size", img: "/images/nines/join_my_collex.gif", spinner: "/images/ajax_loader.gif" });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxSmall : function () {
			action(this,
				function() {
					showInLightbox({ title: "Lightbox - small", img: "/images/nines/join_my_collex.gif", spinner: "/images/ajax_loader.gif", size: 80 });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxLarge : function () {
			action(this,
				function() {
					showInLightbox({ title: "Lightbox - large", img: "/images/nines/join_my_collex.gif", spinner: "/images/ajax_loader.gif", size: 900 });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxMissing : function () {
			action(this,
				function() {
					showInLightbox({ title: "Lightbox - missing", img: "/images/nines/MISSING.gif", spinner: "/images/ajax_loader.gif", size: 900 });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxId : function () {
			action(this,
				function() {
					new ShowDivInLightbox({ title: "Lightbox - from id", id: "lightbox_stuff" });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxIdClass : function () {
			action(this,
				function() {
					new ShowDivInLightbox({ title: "Lightbox - from id with class", id: "lightbox_stuff", klass: "lightbox_test_colorful" });
				},
				function() {
					clickX();
				},
				function() {
					dlgGone();
				}
			);
		},

		testShowLightboxAjax : function () {
			var This = this;
			window.mockAjax = false;
			var fxnCall = function() {
				showPartialInLightBox('/help/resources', 'Lightbox - through ajax', '/images/ajax_loader.gif');
			};
			var fxnTest = function() {
				containsText("#gd_lightbox_contents", "NINES resources");
			};
			ajaxThenCancel(This, fxnCall, fxnTest);
		},

		testShowLightboxAjaxBadUrl : function () {
			var This = this;
			window.mockAjax = false;
			var fxnCall = function() {
				showPartialInLightBox('/helf', 'Lightbox - bad url', '/images/ajax_loader.gif');
			};
			var fxnTest = function() {
				containsText("#gd_lightbox_contents", "Sorry! The server didn't understand the request \"/helf\"");
			};
			ajaxThenCancel(This, fxnCall, fxnTest);
		},

		testShowLightboxAjax500 : function () {
			var This = this;
			window.mockAjax = false;
			var fxnCall = function() {
				showPartialInLightBox('/test_exception_notifier', 'Lightbox - server crash', '/images/ajax_loader.gif');
			};
			var fxnTest = function() {
				containsText("#gd_lightbox_contents", "Sorry! You've hit an error. We apologize for this problem");
			};
			ajaxThenCancel(This, fxnCall, fxnTest);
		},

		testShowLightboxAjaxErrorMsg : function () {
			var This = this;
			window.mockAjax = false;
			var fxnCall = function() {
				showPartialInLightBox('/test_error_response', 'Lightbox - server error message', '/images/ajax_loader.gif');
			};
			var fxnTest = function() {
				containsText("#gd_lightbox_contents", "This is a test message from the server.");
			};
			ajaxThenCancel(This, fxnCall, fxnTest);
		},

		testShowLightboxResize : function () {
			action(this,
				function() {
					showInLightbox({ title: "Lightbox - resize", img: "/images/nines/join_my_collex.gif", spinner: "/images/ajax_loader.gif", size: 80 });
				},
				function() {
					resize();
				},
				function() {
					Y.Assert.areSame("", "STUB");
				}
			);
		}
	});
	dlg.add(testCaseLightBox);

	var This = null;
	var testCaseSingleInputDlg = new Y.Test.Case({
		name: "SingleInputDlg",
		_should: {
			ignore: {
				testSelectInputPopulate: true,
				testSelectInputPopulateError: true,
				testSelectInputPopulateMissingError: true,
				testSelectInputPopulateAjaxError: true
			}
		},

		setUp : function () {
			This = this;
			window.mockXhr.add('/tests/succeed', function(params) {
				return { status: 200 };
			});
			window.mockXhr.add('/tests/verify', function(params) {
				if (params.column.length > 0) {
					if (params.testing === 'I exist')
						return { status: 200 };
					else
						return { status: 400, responseText: 'Extraparams not picked up.' };
				} else
					return { status: 400, responseText: 'This entry cannot be blank.' };
			});
			window.mockXhr.add('/tests/500', function(params) {
				This.waitMessage = Y.one('.gd_flash_notice_ok')._node.innerHTML;
				return { status: 500 };
			});
			window.mockXhr.add('/tests/populate', function(params) {
				return { status: 200, responseText: '[{ "text": "one", "value": "100"}, {"text": "two", "value": "200" }]' };
			});
			window.mockXhr.add('/tests/populateError', function(params) {
				return { status: 500 };
			});
			window.mockXhr.add('/tests/populateAjaxError', function(params) {
				return { status: 200, responseText: "He{!y ] this isn't. json" };
			});
			window.mockAjax = true;
		},

		tearDown: function () {
			window.mockAjax = false;
		},

		testTextInputVerifyFxn : function () {
			actions(this,
				[[ function() {
					var verifyFxn = function(data) {
						assertFlashOk('Please wait...');
						var val = data.column;
						if (val.length === 0)
							return "This entry cannot be blank. Please enter a value.";
						return null;
					};

					new TextInputDlg({
						title: 'Text Input Dlg - Verify function',
						prompt: 'Field',
						id: 'column',
						okStr: 'Save',
						value: '',
						verifyFxn: verifyFxn,
						actions: { method: 'PUT', url: '/tests/succeed' },
						target_els: 'bit_bucket' });
				},
				function() {
					pressEnter();
				},
				function() {
					assertFlashError("This entry cannot be blank. Please enter a value.");
				} ],
				[ function() {
					typeInEl('#column', 'data here');
				},
				function() {
					pressEnter();
				},
				function() {
					dlgGone();
				} ]]
			);
		},

		testTextInputVerifyUrl : function () {
			var prompt = 'Boy! these are ugly colors:';
			actions(this,
				[[ function() {
					new TextInputDlg({
						title: 'Text Input Dlg - Verify URL',
						prompt: prompt,
						id: 'column',
						okStr: 'Go ahead',
						value: '',
						verify: '/tests/verify',
						extraParams: { testing: "I exist"},
						body_style: 'ghastly_dialog',
						inputKlass: 'short_box',
						actions: { method: 'PUT', url: '/tests/succeed' },
						target_els: 'bit_bucket' });
				},
				function() {
					containsText('#gd_text_input_dlg_btn0-button', 'Go ahead');
					containsText('#gd_text_input_dlg_h', 'Text Input Dlg');
					containsText('.gd_text_input_dlg_label', prompt);
					pressEnter();
				},
				function() {
					assertFlashError("This entry cannot be blank.");
				} ],
				[ function() {
					typeInEl('#column', 'data here');
				},
				function() {
					pressEnter();
				},
				function() {
					dlgGone();
				} ]]
			);
		},

		testTextInput404 : function () {
			actions(this,
				[[ function() {
					new TextInputDlg({
						title: 'Text Input Dlg - 404',
						prompt: 'Type stuff here:',
						id: 'column',
						value: '',
						noDefault: true,
						actions: { url: '/tests/404' },
						target_els: 'bit_bucket' });
				},
				function() {
					containsText('#gd_text_input_dlg_btn0-button', 'Ok');
					pressEnter();	// This shouldn't do anything
				},
				function() {
					assertFlashError(null);
				} ],
				[ function() {
				},
				function() {
					clickElement('#gd_text_input_dlg_btn0-button');
				},
				function() {
					assertFlashError("Sorry! The server didn't understand the request \"/tests/404\". Either a bad URL was given or there is an internal error. If you think this message is in error, please email the administrators.");
				} ],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testTextInput500 : function () {
			var msg = "Custom Wait Message!";
			actions(this,
				[[ function() {
					new TextInputDlg({
						title: 'Text Input Dlg - 500',
						prompt: 'Type stuff here:',
						id: 'column',
						value: '',
						pleaseWaitMsg: msg,
						actions: { url: '/tests/500' },
						target_els: 'bit_bucket' });
				},
				function() {
					clickElement('#gd_text_input_dlg_btn0-button');
				},
				function() {
					Y.Assert.areSame(msg, This.waitMessage);
					assertFlashError("Sorry! You've hit an error. We apologize for this problem and hope you'll bear with us as we work to make this website better! System administrators have been automatically notified of the error. If you have additional feedback, please e-mail us.");
				} ],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testTextInputCustomSuccess : function () {
			var gotHere = false;
			var onSuccess = function(resp) {
				gotHere = true;
			};
			actions(this,
				[[ function() {
					new TextInputDlg({
						title: 'Text Input Dlg - Custom Success',
						prompt: 'Type stuff here:',
						id: 'column',
						value: 'starting value',
						onSuccess: onSuccess,
						actions: { url: '/tests/succeed' },
						target_els: 'bit_bucket' });
				},
				function() {
					Y.Assert.areSame('starting value', Y.one('#column')._node.value);
					clickElement('#gd_text_input_dlg_btn0-button');
				},
				function() {
					Y.assert(gotHere, "The onSuccess handler was not called.");
					dlgGone();
				}]]
			);
		},

		testTextInputCustomFailure : function () {
			var gotHere = false;
			var onFailure = function(resp) {
				gotHere = true;
			};
			actions(this,
				[[ function() {
					new TextInputDlg({
						title: 'Text Input Dlg - Custom Failure',
						prompt: 'Type stuff here:',
						id: 'column',
						value: '',
						onFailure: onFailure,
						actions: { url: '/tests/500' },
						target_els: 'bit_bucket' });
				},
				function() {
					clickElement('#gd_text_input_dlg_btn0-button');
				},
				function() {
					Y.assert(gotHere, "The onFailure handler was not called.");
				}],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testSelectInputOptions : function () {
			actions(this,
				[[ function() {
					new SelectInputDlg({
						title: 'Simple Select',
						prompt: 'Type',
						id: 'select_type',
						options: [ { text: 'community', value:'10' }, { text: 'classroom', value: '11' }, { text: 'publication', value: '12' } ],
						value: '11',
						actions: { method: 'PUT', url: '/tests/succeed/' },
						target_els: 'group_details' });
				},
				function() {
					Y.Assert.areSame('11', Y.one('#select_type')._node.value, "Initial value not set");
					setOption("select_type", 2);
				},
				function() {
					Y.Assert.areSame('12', Y.one('#select_type')._node.value, "Wrong item selected");
				}],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testSelectInputExplanation : function () {
			var explanations = [ 'This group is being used for scholarly collaboration. File this group under the "Community" section.',
				'This group is being used to teach. File this group under the "Classroom" section.',
				'Publication groups work closely with the staff to vet their content. If you select this option a notification will be sent to the staff, and someone will be in contact with you soon.' ];
			actions(this,
				[[ function() {
					new SelectInputDlg({
						title: 'Select With Explanation',
						prompt: 'Type',
						id: 'select_type',
						options: [ { text: 'community', value:'10' }, { text: 'classroom', value: '11' }, { text: 'publication', value: '12' } ],
						explanation: explanations,
						value: '11',
						actions: { method: 'PUT', url: '/tests/succeed/' },
						target_els: 'group_details' });
				},
				function() {
					Y.Assert.areSame(explanations[1], Y.one('#gd_postExplanation')._node.innerHTML, "Initial explanation not set");
					setOption("select_type", 2);
				},
				function() {
					Y.Assert.areSame(explanations[2], Y.one('#gd_postExplanation')._node.innerHTML, "Explanation not changed");
				}],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testSelectInputPopulate : function () {
			actions(this,
				[[ function() {
					new SelectInputDlg({
						title: 'Select Ajax Populate',
						prompt: 'Type',
						id: 'select_type',
						populateUrl: "/tests/populate",
						options: [ { value: -1, text: 'Loading data. Please Wait...' } ],
						actions: { method: 'PUT', url: '/tests/succeed/' },
						target_els: 'group_details' });
				},
				function() {
					setOption("select_type", 1);
				},
				function() {
					Y.Assert.areSame('201', Y.one('#select_type')._node.value, "Wrong item selected");
				}],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testSelectInputPopulateError : function () {
		},

		testSelectInputPopulateMissingError : function () {
		},

		testSelectInputPopulateAjaxError : function () {
		}
// Test these: RteInputDlg
// title: The title of the dialog.
// okCallback: A function that is called after the user presses ok and after the dialog has been dismissed.
// value: The starting value when the dialog is first shown.
// populate_urls: What to call to get the objects for the Link toolbar button.
// progress_img: The progress image to show while populating the Link dialog.
// extraButton: { label: the name of the button, callback: a function that is called when the user pushes the button }.
// new RteInputDlg({ title: 'Edit Footnote', okCallback: setFootnote, value: footnote.innerHTML, populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img, extraButton: { label: "Delete Footnote", callback: deleteFootnote } });
// new RteInputDlg({ title: 'Add Footnote', okCallback: setFootnote, value: '', populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img });
//	new RteInputDlg({ title: 'Edit Description', okCallback: okCallback, value: value, populate_urls: [ populate_url ], progress_img: progress_img });

	});
	dlg.add(testCaseSingleInputDlg);

	var lastLinkCalled = '';
	var testCaseAjax = new Y.Test.Case({
		name: "Ajax",
		_should: {
			ignore: {
//				testSelectControl: true,
//				testPostLink: true,
//				testConfirmCancel: true,
//				testConfirmOk: true,
//				testMultipleAction: true
			}
		},

		setUp : function () {
			window.mockSubmit = function(link, params) {
				lastLinkCalled = link;
			};
			window.mockXhr.add('/test/confirm', function(params) {
				return { status: 200, responseText: 'The response from confirm' };
			});
			window.mockXhr.add('/test/confirm2', function(params) {
				return { status: 200, responseText: 'The response from confirm2' };
			});
			window.mockAjax = true;
		},

		tearDown: function () {
			window.mockAjax = false;
		},

		testSelectControl : function () {
			actions(this,
				[[ function() {
				},
				function() {
					// Select the 'testing' item
				},
				function() {
					Y.assert(false, 'Not written');
					// assert that the 'testing' item was selected and the callback was called
				} ],
				[ function() {
					// Select the 'name' item
				},
				function() {
					// assert that the 'name' item was selected and the callback was called
				},
				function() {
				} ]]
			);
		},
		testPostLink : function () {
			action(this,
				function() {
					lastLinkCalled = '';
					postLink("/testing");
				},
				function() {
				},
				function() {
					Y.assert("/testing", lastLinkCalled);
					// assert that the 'testing' item was selected and the callback was called
				}
			);
		},
		testConfirmCancel : function () {
			action(this,
				function() {
					serverAction({
						confirm: { title: 'User Confirmation', message: 'The user will press cancel in this test.'},
						action: { actions: '/test/shouldnt_call', params: { id: 'anything' }},
						progress: { waitMessage: 'Doing the action...' }});
				},
				function() {
					Y.assert(false, 'Not written');
				},
				function() {
				}
			);
		},
		testConfirmOk : function () {
			action(this,
				function() {
					serverAction({
						confirm: { title: 'User Confirmation', message: 'The user will press cancel in this test.'},
						action: { actions: '/test/confirm', params: { id: 'anything' }},
						progress: { waitMessage: 'Doing the action...' }});
				},
				function() {
					Y.assert(false, 'Not written');
					// Test that the progress message is up
				},
				function() {
				}
			);
		},
		testMultipleAction : function () {
			action(this,
				function() {
					Y.one('area1')._node.innerHTML = '';
					Y.one('area2')._node.innerHTML = '';
					serverAction({
						action: { actions: [ '/test/confirm', 'test/confirm2' ], els: [ 'area1', 'area2' ], params: { id: 'anything' }}});
				},
				function() {
					Y.assert(false, 'Not written');
					// be sure that both area1 and area2 are updated.
				},
				function() {
				}
			);
		}
	});
	dlg.add(testCaseAjax);


	var testCaseCustomDlg = new Y.Test.Case({
		name: "Custom Dialog",
		_should: {
			ignore: {
//				testDialogNoMove: true
//				testDialogAllDefaults: true
//				testDialogAllOptions: true
			}
		},

		setUp : function () {
			window.mockXhr.add('/tests/populate', function(params) {
				return { status: 200, responseText: '[{ "text": "one", "value": "100"}, {"text": "two", "value": "200" }]' };
			});
			window.mockAjax = true;
		},

		tearDown: function () {
			window.mockAjax = false;
		},

		testDialogNoMove : function () {
			actions(this,
				[[ function() {
					var dlgLayout = {
							page: 'layout',
							rows: [
								[ { text: 'This dialog cannot be dragged' } ],
								[ { rowClass: 'gd_last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
							]
						};

					var params = { this_id: "no_move_dlg", pages: [ dlgLayout ] };
					dlg = new GeneralDialog(params);
					//dlg.changePage('layout');
					dlg.center();
				},
				function() {
					dragElement("no_move_dlg_h", 14, 20);
				},
				function() {
					assertPosition("no_move_dlg_h", 14, 20);
					assertHasDragHeader(false);
				}],
				[function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				}]]
			);
		},

		testDialogAllDefaults : function () {
			var filterString = null;
			var buttonClicked = false;
			var linkClicked = false;
			actions(this,
				[[ function() {
					var filter = function(str) {
						filterString = str;
					};
					var button = function() {
						buttonClicked = true;
					};
					var link = function() {
						linkClicked = true;
					};
					var dlgLayout = {
							page: 'layout',
							rows: [
								[ { text: 'Text field' }, { input: 'input' }, { inputFilter: 'inputFilter', prompt: 'Click here', callback: filter }],
								[ { picture: "/images/nines/join_my_collex.gif" }, { textarea: 'textarea' } ],
								[ { inputWithStyle: "inputWithStyle" }, { hidden: 'hidden', value: 'hidden value'}, { password: 'password' }],
								[ { button: 'a button', callback: button }, { link: 'link', callback: link }],
								[ { select: 'select'}, { select: 'select2', options: [ { text: 'one', value: 'first'},{ text: 'two', value: 'second'} ]}, { checkbox: 'checkbox' }],
								[ { checkboxList: 'checkboxList', items: [ 'c-one', 'c-two', 'c-three']}, { radioList: 'radioList', options: [ 'r-one', 'r-two', 'r-three']}],
								[ { date: 'date*'}, { image: 'image'}],
								[ ],
								[ { rowClass: 'gd_last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
							]
						};

					var params = { this_id: "all_defaults_dlg", pages: [ dlgLayout ], title: "All Defaults" };
					dlg = new GeneralDialog(params);
					//dlg.changePage('layout', 'category_name');
					dlg.center();
				},
				function() {
					containsText("form.layout div span", "Text field");
					assertInputType("#input", 'text');
					assertInputType("#inputFilter", 'text');
					assertValue("#inputFilter", 'Click here');
					assertAttributes("img", { src: '/images/nines/join_my_collex.gif', alt: '/images/nines/join_my_collex.gif' });
					assertTag("#textarea", 'textarea');
					assertInputType("#inputWithStyle", 'text');
					assertInputType("#inputWithStyle_bold", 'hidden');
					assertClass("#all_defaults_dlg_a3", "gd_bold_button");
					assertAttributes("#all_defaults_dlg_a3", { title: 'Bold' });
					assertInputType("#inputWithStyle_italic", 'hidden');
					assertClass("#all_defaults_dlg_a4", "gd_italic_button");
					assertAttributes("#all_defaults_dlg_a4", { title: 'Italic' });
					assertInputType("#inputWithStyle_underline", 'hidden');
					assertClass("#all_defaults_dlg_a5", "gd_underline_button");
					assertAttributes("#all_defaults_dlg_a5", { title: 'Underline' });
					assertInputType("#hidden", 'hidden');
					assertValue("#hidden", 'hidden value');
					assertInputType("#password", 'password');
					assertTag("#all_defaults_dlg_btn0-button", 'button');
					containsText("#all_defaults_dlg_btn0-button", "a button");
					assertTag("#all_defaults_dlg_a6", 'a');
					containsText("#all_defaults_dlg_a6", "link");
					assertTag("#select", 'input');
					assertTag("#select2", 'input');
					assertValue("#select2", "first");
					assertInputType("#checkbox", 'checkbox');
					assertValue("#checkbox", "1");
					assertElementArrayText("#yui-gen5 a", [ 'one', 'two']);

					assertInputType("#checkboxList_c-one", 'checkbox');
					assertInputType("#checkboxList_c-two", 'checkbox');
					assertInputType("#checkboxList_c-three", 'checkbox');
					assertInputType("#radioList_r-one", 'radio');
					assertInputType("#radioList_r-two", 'radio');
					assertInputType("#radioList_r-three", 'radio');
					// TODO: be sure that the first radio button is selected.
					assertSelect("#date1i", [ '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014' ]);
					assertSelect("#date2i", [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]);
					assertSelect("#date3i", [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' ]);
					assertInputType("#image", 'file');

					containsText(".gd_last_row button", 'Cancel', 'Row class not set');

					typeInEl("#inputFilter", "hi there");
					clickElement("#all_defaults_dlg_btn0-button");
					clickElement("#all_defaults_dlg_a6");
				},
				function() {
					Y.assert(buttonClicked, "Expected the button callback to have been called.");
					Y.assert(linkClicked, "Expected the link callback to have been called.");
					Y.Assert.areSame('hi there', filterString, "Expected filter callback to fire with the current value of the filter. Received:" + filterString);
				} ],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				} ]]
			);
		},
		testDialogAllOptions : function () {
			var buttonArg = '';
			var linkArg = '';
			var selectArg = '';
			var removeCalled = false;
			actions(this,
				[[ function() {
					var button = function(a) {
						buttonArg = a;
					};
					var link = function(a) {
						linkArg = a;
					};
					var selectCallback = function(a) {
						selectArg = a;
					};
					var removeButton = function() {
						removeCalled = true;
					};
					var dlgLayout = {
							page: 'layout',
							rows: [
								[ { text: 'Ugly text', klass: 'ugly_text', id: 'text_id' }, { input: 'input', klass: 'ugly_text', value: 'input value' }, { inputFilter: 'inputFilter', klass: 'ugly_text', value: 'starting value', prompt: 'Clicky' }],
								[ { picture: "/images/nines/join_my_collex.gif", klass: 'small_pic', alt: 'alt text for pix' }, { textarea: 'textarea', klass: 'small_pic', value: 'textarea value'  } ],
								[ { inputWithStyle: "inputWithStyle", klass: 'ugly_text', value: { text: 'style value', isBold: true, isItalic: true, isUnderline: true } }, { hidden: 'hidden', klass: 'ugly_text', value: 'hidden value'}, { password: 'password', klass: 'ugly_text', value: 'startpass' }],
								[ { button: 'def button', callback: button, arg0: 'buttonArg', isDefault: true, klass: 'ugly_text' }, { link: 'link', callback: link, klass: 'ugly_text', arg0: 'linkArg', title: 'link title' }],
								[ { select: 'select2', options: [ { text: 'one', value: 'first'},{ text: 'two', value: 'second'} ], klass: 'ugly_text', value: 'second', callback: selectCallback, arg0: "selectArg"}, { checkbox: 'checkbox', klass: 'ugly_text', value: '1' }],
								[ { checkboxList: 'checkboxList', items: [ ['c-one', 100], ['c-two', 200], ['c-three', 300]], selections: [ 200 ], klass: 'ugly_text', columns: 2}, { radioList: 'radioList', klass: 'ugly_text', options: [ ['r-one', '51'], ['r-two', '52'], ['r-three', '53']], value: '52'}],
								[ { date: 'date*', klass: 'ugly_text', value: '2008-10-20'}, { image: 'image', klass: 'small_pic', value: "/images/nines/join_my_collex.gif", alt: 'current image', size: 80, removeButton: removeButton }],
								[ ],
								[ { rowClass: 'gd_last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
							]
						};

					var params = { this_id: "all_options_dlg", pages: [ dlgLayout ], title: "All Options" };
					dlg = new GeneralDialog(params);
					dlg.center();
				},
				function() {
					containsText("#text_id", "Ugly text");
					assertClass("#text_id", "ugly_text");
					assertInputType("#input", 'text');
					assertValue("#input", 'input value');
					assertClass("#input", "ugly_text");
					assertInputType("#inputFilter", 'text');
					assertValue("#inputFilter", 'starting value');
					assertClass("#inputFilter", "ugly_text");
					assertAttributes("img", { src: '/images/nines/join_my_collex.gif', alt: 'alt text for pix' });
					assertClass("img", "small_pic");
					assertTag("#textarea", 'textarea');
					assertValue("#textarea", 'textarea value');
					assertClass("#textarea", "small_pic");
					// TODO: test the bold, etc, attributes
					assertInputType("#inputWithStyle", 'text');
					assertClass("#inputWithStyle", "ugly_text");
					assertInputType("#inputWithStyle_bold", 'hidden');
					assertClass("#all_options_dlg_a3", "gd_bold_button");
					assertAttributes("#all_options_dlg_a3", { title: 'Bold' });
					assertInputType("#inputWithStyle_italic", 'hidden');
					assertClass("#all_options_dlg_a4", "gd_italic_button");
					assertAttributes("#all_options_dlg_a4", { title: 'Italic' });
					assertInputType("#inputWithStyle_underline", 'hidden');
					assertClass("#all_options_dlg_a5", "gd_underline_button");
					assertAttributes("#all_options_dlg_a5", { title: 'Underline' });

					assertInputType("#hidden", 'hidden');
					assertValue("#hidden", 'hidden value');
					assertClass("#hidden", "ugly_text");
					assertInputType("#password", 'password');
					assertValue("#password", 'startpass');
					assertClass("#password", "ugly_text");
					assertTag("#all_options_dlg_btn0-button", 'button');
					containsText("#all_options_dlg_btn0-button", "def button");
					assertClass("#all_options_dlg_btn0-button", "ugly_text");
					assertTag("#all_options_dlg_a6", 'a');
					containsText("#all_options_dlg_a6", "link");
					assertClass("#all_options_dlg_a6", "ugly_text");
					assertAttributes("#all_options_dlg_a6", { title: 'link title' });
					assertTag("#select2", 'input');
					assertValue("#select2", "second");
					assertClass("#select2", "ugly_text");
					assertInputType("#checkbox", 'checkbox');
					assertValue("#checkbox", "1");
					assertClass("#checkbox", "ugly_text");
					assertElementArrayText("#yui-gen5 a", [ 'one', 'two']);

					assertInputType("#checkboxList_c-one", 'checkbox');
					assertInputType("#checkboxList_c-two", 'checkbox');
					assertInputType("#checkboxList_c-three", 'checkbox');
					assertClass("#checkboxList_c-one", "ugly_text");
					// TODO: be sure that the second one is checked and that it is in two columns.
					assertInputType("#radioList_r-one", 'radio');
					assertInputType("#radioList_r-two", 'radio');
					assertInputType("#radioList_r-three", 'radio');
					assertClass("#radioList_r-three", "ugly_text");
					// TODO: be sure that the second radio button is selected.
					assertSelect("#date1i", [ '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014' ]);
					assertSelect("#date2i", [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]);
					assertSelect("#date3i", [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' ]);
					assertValue("#date1i", 2008);
					assertValue("#date2i", 10);
					assertValue("#date3i", 20);
					assertInputType("#image", 'file');

					clickElement("#all_options_dlg_a6");
					setOption("#select", 0);
					clickElement("#removeButton");
					pressEnter();
				},
				function() {
					Y.Assert.areSame("buttonArg", buttonArg, "Expected the button argument to have been set.");
					Y.Assert.areSame("linkArg", linkArg, "Expected the link argument to have been set.");
					Y.Assert.areSame("selectArg", selectArg, "Expected the select argument to have been set.");
					Y.assert(removeCalled, "Expected the remove button callback to have been called.");
				} ],
				[ function() {
				},
				function() {
					pressEsc();
				},
				function() {
					dlgGone();
				} ]]
			);
		},
		testDialogMultiplePages : function () {
			Y.assert(false, "Not yet written");
		},
		testDialogCustomControl : function () {
			Y.assert(false, "Not yet written");
		}
	});
	dlg.add(testCaseCustomDlg);
//	this_id: the id of this dialog
//	title (opt): the title; if blank, then no title bar appears.
//	width (opt): the width
//	flash_notice (opt): the initial message to put in the flash message
//	body_style (opt):	class to attach to the body
//	row_style (opt): class to attach to each row
//	pages: array of pages
//
//	the page represents one form and only one is displayed at a time.
//	page: the id, name, and class to apply to the form.
//	rows: array describing each row.
//
//	row: array of elements to place in the row
//
//	element:
//
// text: whatToDisplay, klass (opt): classToAttach, id (opt): idOfElement [creates <span>]
// picture: src and alt**, klass (opt): classToAttach, id (opt): idOfElement [creates <img>]
// input: id and name, klass (opt): classToAttach, value (opt): initial value [creates <input type='text'>]
// inputFilter: id and name, klass (opt): classToAttach, value (opt): initial value, prompt: text when not focused, callback: function for each event [creates <input type='text'>]
// inputWithStyle: id and name, klass (opt): classToAttach, value: { text: initial value, isBold: bool, isItalic: bool, isUnderline: bool }  [creates <input type='text'><button><button><button>]
// hidden: id and name, klass (opt): classToAttach, value: initial value [creates <input type='hidden'>]
// password: id and name, klass (opt): classToAttach, value: initial value [creates <input type='password'>]
// button: text on button, klass (opt): classToAttach, isDefault (opt): bool, isSubmit** (opt): bool, url** (opt): parameter passed to callback, callback: function to call when pressed [creates:<button>]
// link: text on link, klass (opt): classToAttach, arg0 (opt): parameter passed to callback, callback: function to call when pressed [creates:<a>]
// select: id and name, klass (opt): classToAttach, change**: function to call when selection changes, options (opt): array of { text: , value: }, value (opt): the initial selection [creates: <select>]
// custom: object that contains the control [defines functions: getMarkup(), getSelection()], klass (opt): classToAttach [creates: whatever the object wants]
// checkbox: id or name, klass (opt): classToAttach, value (opt): '1' if initially selected [creates: <input type=checkbox><span>]
// checkboxList: prefix of id and name, klass (opt): classToAttach, columns (opt): number of columns, items: array of either text, or [ id, text ], selections: array of initially selected items [creates: <table><tbody><tr><td><input type=checkbox><span>**]
// radioList: id and name, klass (opt): classToAttach, options: array of { text: value: }, value: initial selection [creates:<table><tbody><tr><td><input type=radio><span>**]
// textarea: id and name, klass (opt): classToAttach, value (opt): initial value [creates:<textarea>]
// date: template for id and name, value (opt): initial value (expressed as 'yyyy-mm-dd .*') [creates: <select><select><select>]
// image: id and name, value (opt): src for current image, size (opt): size of input box, klass(opt): class for both image and link button**, removeButton (opt): link for button to remove current image. [creates: <div><img><input type=file><a></div>]
// rowClass: adds a class name to the current row
//
// Member functions:
//	makeId(name): removes brackets so that it is a legal html id
//	getOuterDomElement(): gets the outer wrapper div
//	getEditor(index): gets the index'th textarea
//	getAllData(): returns an array of all values that the user have filled in as [ {id: value:}].
//	getTitle(): returns the title of this dialog
//	setFlash(msg, is_error): sets the flash message at the top of the dialog.
//	changePage(view, focus_el): sets one page visible and the others hidden, and focuses a particular element
//	cancel(): cancels the dialog
//	center(): centers the dialog
//	initTextAreas({ toolbarGroups: linkDlgHandler: footnote: bodyStyle: onlyClass: only change textareas with this class}): changes textareas to RTE

	var runOnlyThis = 'testDialogAllOptions';	// Set this to ignore all but one test
	putTestControlsOnPage("#tests", 
		[ [testCaseMessageBox, testCaseLightBox], [testCaseSingleInputDlg, testCaseAjax], [ testCaseCustomDlg ] ], runOnlyThis);
	Y.Test.Runner.add(dlg);
	Y.Test.Runner.run();
});

*/
