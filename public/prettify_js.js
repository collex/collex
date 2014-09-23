function $A(e) {
	if (!e) return [];
	if ("toArray" in Object(e)) return e.toArray();
	for (var t = e.length || 0, n = new Array(t); t--;) n[t] = e[t];
	return n
}

function $w(e) {
	return Object.isString(e) ? (e = e.strip(), e ? e.split(/\s+/) : []) : []
}

function $H(e) {
	return new Hash(e)
}

function $R(e, t, n) {
	return new ObjectRange(e, t, n)
}

function $(e) {
	if (arguments.length > 1) {
		for (var t = 0, n = [], i = arguments.length; i > t; t++) n.push($(arguments[t]));
		return n
	}
	return Object.isString(e) && (e = document.getElementById(e)), Element.extend(e)
}

function showPartialInLightBox(e, t, n) {
	"use strict";
	var i = new Element("div", {
			id: "gd_lightbox_contents"
		}),
		r = i.wrap("div", {
			id: "gd_lightbox_id"
		}),
		o = new Element("center", {
			id: "gd_lightbox_img_spinner"
		});
	o.addClassName("gd_lightbox_img_spinner"), o.appendChild(new Element("div").update("Loading...")), o.appendChild(new Element("img", {
		src: n,
		alt: ""
	})), o.appendChild(new Element("div").update("Please wait")), r.appendChild(o);
	var a = new ShowDivInLightbox({
		title: t,
		div: r
	});
	if ("http" === e.substr(0, 4)) {
		var s = new Element("iframe", {
			style: "width:500px;height:700px;border: none;"
		});
		i.appendChild(s), s.src = e;
		var l = $("gd_lightbox_img_spinner");
		l && l.remove(), a.dlg.center()
	} else {
		var c = function() {
				var e = $("gd_lightbox_img_spinner");
				e && e.remove(), $("gd_lightbox_contents").show(), a.dlg.center()
			},
			u = function(t) {
				var n = $("gd_lightbox_img_spinner");
				n && n.remove(), $("gd_lightbox_contents").update(formatFailureMsg(t, e)), $("gd_lightbox_contents").setStyle({
					width: "450px",
					color: "red"
				}), $("gd_lightbox_contents").show(), a.dlg.center()
			};
		serverAction({
			action: {
				actions: e,
				els: "gd_lightbox_contents",
				params: {},
				onSuccess: c,
				onFailure: u
			}
		})
	}
}

function showInLightbox(e) {
	var t = e.title,
		n = e.img,
		i = e.spinner,
		r = e.size,
		o = null,
		a = function() {
			var e = $("gd_lightbox_img_spinner");
			e && e.remove();
			var t = $("gd_lightbox_img");
			if (t.show(), r && (t.width > r || t.height > r)) {
				var n = $("gd_lightbox_dlg"),
					i = parseInt(n.getStyle("width")) - t.width,
					a = parseInt(n.getStyle("height")) - t.height,
					s = t.width > t.height,
					l = t.width,
					c = t.height;
				s ? t.width = r : t.height = r;
				var u = function(e) {
						s ? t.width = e.width - i : t.height = e.height - a
					},
					d = null;
				d = s ? new YAHOO.util.Resize("gd_lightbox_dlg", {
					maxWidth: l + i,
					minWidth: 140,
					ratio: !0,
					handles: ["br"]
				}) : new YAHOO.util.Resize("gd_lightbox_dlg", {
					maxHeight: c + a + 16,
					minHeight: 140,
					ratio: !0,
					handles: ["br"]
				}), d.on("resize", u), $("gd_lightbox_dlg_h").setStyle({
					whiteSpace: "nowrap",
					overflow: "hidden"
				})
			}
			o.dlg.center()
		},
		s = "lightbox",
		l = new Element("img", {
			id: "gd_lightbox_img",
			alt: ""
		});
	l.setStyle({
		display: "none"
	});
	var c = l.wrap("div", {
			id: s + "_id"
		}),
		u = new Element("center", {
			id: "gd_lightbox_img_spinner"
		});
	u.addClassName("gd_lightbox_img_spinner"), u.appendChild(new Element("div").update("Image Loading...")), u.appendChild(new Element("img", {
		src: i,
		alt: ""
	})), u.appendChild(new Element("div").update("Please wait")), c.appendChild(u), o = new ShowDivInLightbox({
		title: t,
		div: c
	}), l.observe("load", a), l.setAttribute("src", n)
}

function dlgAjax(e, t, n, i) {
	var r = function() {
			e.cancel()
		},
		o = function(t) {
			e.setFlash(t.responseText, !0)
		};
	serverAction({
		action: {
			actions: t,
			els: n,
			params: i,
			onSuccess: r,
			onFailure: o
		}
	})
}

function genericAjaxFail(e, t, n) {
	var i = formatFailureMsg(t, n);
	e ? e.setFlash(i, !0) : new MessageBoxDlg("Communication Error", i)
}

function submitForm(e, t, n) {
	var i = function(e) {
			var t = $$("meta[name=csrf-param]")[0].content,
				n = $$("meta[name=csrf-token]")[0].content;
			e.appendChild(new Element("input", {
				id: t,
				type: "hidden",
				name: t,
				value: n
			}))
		},
		r = $(e);
	"PUT" === n && r.appendChild(new Element("input", {
		id: "_method",
		type: "hidden",
		name: "_method",
		value: "PUT"
	})), (void 0 === n || "PUT" === n) && (n = "POST"), r.writeAttribute({
		action: t,
		method: n
	}), i(r), r.submit()
}

function reloadPage() {
	window.location.href = window.location.href
}

function gotoPage(e) {
	window.location = e
}

function openInNewWindow(e, t) {
	window.open(t.arg0, "_blank")
}

function submitFormWithConfirmation(e) {
	var t = e.id,
		n = e.action,
		i = e.method ? e.method : "POST",
		r = e.title,
		o = e.message,
		a = e.okStr ? e.okStr : "Yes",
		s = e.cancelStr ? e.cancelStr : "No",
		l = function() {
			submitForm(t, n, i)
		};
	new ConfirmDlg(r, o, a, s, l)
}

function formatFailureMsg(e, t) {
	return 500 === e.status ? "Sorry! You've hit an error. We apologize for this problem and hope you'll bear with us as we work to make this website better! System administrators have been automatically notified of the error. If you have additional feedback, please e-mail us." : 404 === e.status ? "Sorry! The server didn't understand the request \"" + t + '". Either a bad URL was given or there is an internal error. If you think this message is in error, please email the administrators.' : 0 === e.status ? "Communication with the server has been temporarily interrupted. Please try again later." : e.responseText
}

function preload_image() {
	var e = new Image;
	e.src = progress_transparent, progressSpinnerSearchingDialog = new ProgressSpinnerDlg("Searching..."), progressSpinnerSearchingDialog.hide()
}

function stopAddBadgeUpload(e) {
	return e.startsWith("OK:") ? addBadgeDlg.fileUploadFinished(e.substring(3)) : addBadgeDlg.fileUploadError(e), !0
}

function stopAddPublicationImageUpload(e) {
	return e.startsWith("OK:") ? addPublicationImageDlg.fileUploadFinished(e.substring(3)) : addPublicationImageDlg.fileUploadError(e), !0
}

function impersonateUser(e, t) {
	new SelectInputDlg({
		title: "Choose User to Impersonate",
		prompt: "Select the user that you wish to impersonate",
		id: "user_id",
		actions: t,
		target_els: null,
		pleaseWaitMsg: "Changing apparent logged in user...",
		body_style: "edit_palette_dlg",
		options: [{
			value: -1,
			text: "Loading user names. Please Wait..."
		}],
		populateUrl: e
	})
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function ajax_pagination(e, t, n) {
	serverAction({
		action: {
			actions: e,
			els: t,
			params: {
				page: n
			}
		},
		progress: {
			waitMessage: "Loading page..."
		}
	})
}

function stopNewGroupUpload(e) {
	return e.startsWith("OK:") ? newGroupDlg.fileUploadFinished(e.substring(3)) : newGroupDlg.fileUploadError(e), !0
}

function stopUpload(e) {
	return e.length > 0 ? editProfileDlg.fileUploadError(e) : editProfileDlg.fileUploadFinished(), !0
}

function license_dialog(e) {
	var t = e.selection,
		n = e.id,
		i = e.update_id,
		r = e.callback_url,
		o = e.populateLicenses,
		a = e.id_name,
		s = e.sub_title,
		l = null,
		c = function(e, t) {
			var o = function() {
					t.dlg.cancel()
				},
				s = {
					id: n
				},
				l = t.dlg.getAllData();
			s[a] = l.sharing, serverAction({
				action: {
					actions: r,
					els: i,
					onSuccess: o,
					params: s
				}
			})
		},
		u = function() {
			new CCLicenseDlg(l, t, c, "Select License", s, "sharing")
		},
		d = function() {
			var e = function(e) {
				try {
					e.responseText.length > 0 && (l = e.responseText.evalJSON(!0), u())
				} catch (t) {
					new MessageBoxDlg("Error", t)
				}
			};
			serverRequest({
				url: o,
				onSuccess: e
			})
		};
	d()
}

function stopCreateNewExhibitUpload(e) {
	return e.startsWith("OK:") ? createNewExhibitDlg.fileUploadFinished(e.substring(3)) : createNewExhibitDlg.fileUploadError(e), !0
} //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function initializeElementEditing() {
	var e = $$(".widenable");
	e.each(function(e) {
		var t = e.up(".yui-resize-wrap");
		if (null === t && "IMG" !== e.tagName) {
			var n = new YAHOO.util.Resize(e.id, {
				ratio: !1,
				handles: ["r"]
			});
			n.subscribe("endResize", imgResized, e, !1)
		}
	}), "function" == typeof pageRenumberFootnotes && pageRenumberFootnotes()
}

function imgResized(e, t) {
	var n = t.up(".element_block");
	void 0 === n && (n = t.up(".element_block_hover"));
	var i = t.width;
	(void 0 === i || null === i) && (i = parseInt(t.getStyle("width")));
	var r = t.height;
	(void 0 === r || null === r) && (r = parseInt(t.getStyle("height"))), serverAction({
		action: {
			els: n.id,
			actions: "/builder/change_img_width",
			onSuccess: initializeElementEditing,
			params: {
				illustration_id: t.id,
				width: i,
				height: r
			}
		}
	})
}

function initializeResizableImageElement(e) {
	if (void 0 === YAHOO.util.Resize) return void initializeResizableImageElement.delay(.5, e);
	hideSpinner(e);
	var t = $(e),
		n = new YAHOO.util.Resize(t.id, {
			ratio: !0,
			handles: ["r", "l", "b", "br", "bl"]
		});
	n.subscribe("endResize", imgResized, t, !1)
}

function initializeResizableTextualElement(e) {
	var t = $(e),
		n = new YAHOO.util.Resize(t.id, {
			ratio: !1,
			handles: ["r", "l", "b", "br", "bl"]
		});
	n.subscribe("endResize", imgResized, t, !1)
}

function doAjaxLink(e, t, n) {
	serverAction({
		action: {
			actions: t,
			els: e,
			onSuccess: initializeElementEditing,
			params: n
		}
	})
}

function elementTypeChanged(e, t, n) {
	"pics" === n ? ($("add_image_" + t).show(), $("justify_" + t + "_wrapper").show()) : ($("add_image_" + t).hide(), $("justify_" + t + "_wrapper").hide());
	var i = {
		element_id: t,
		type: n
	};
	doAjaxLink(e + ",exhibit_builder_outline_content", "/builder/change_element_type,/builder/refresh_outline", i)
}

function illustrationJustificationChanged(e, t, n) {
	var i = {
		element_id: t,
		justify: n
	};
	doAjaxLink(e, "/builder/change_illustration_justification", i)
}

function doAjaxLinkConfirm(e, t, n) {
	serverAction({
		confirm: {
			title: "Delete Section",
			message: "You are about to delete this section. Do you want to continue?"
		},
		action: {
			actions: t,
			els: e,
			params: n
		},
		progress: {
			waitMessage: "Please Wait..."
		}
	})
}

function doAjaxLinkOnSelection(e, t) {
	var n = $$(".outline_tree_element_selected");
	if (1 !== n.length) return void new MessageBoxDlg("Exhibit Outline", "Please select a line in the outline.");
	var i = n[0].id,
		r = i.split("_"),
		o = r[r.length - 1],
		a = $("current_page").innerHTML,
		s = {
			verb: e,
			exhibit_id: t,
			element_id: o,
			page_id: a
		},
		l = ["exhibit_builder_outline_content", "exhibit_page"],
		c = ["/builder/modify_outline", "/builder/redraw_exhibit_page"];
	serverAction("delete_element" === e ? {
		confirm: {
			title: "Delete Section",
			message: "You are about to delete this section. Do you want to continue?"
		},
		action: {
			actions: c,
			els: l,
			params: s
		},
		progress: {
			waitMessage: "Please Wait..."
		}
	} : {
		action: {
			actions: c,
			els: l,
			params: s
		}
	})
}

function doAjaxLinkOnPage(e, t, n) {
	var i = $$(".outline_tree_element_selected");
	if (1 !== i.length) return void new MessageBoxDlg("Exhibit Outline", "Please select a line in the outline.");
	var r = i[0].id,
		o = r.split("_"),
		a = o[o.length - 1],
		s = {
			verb: e,
			exhibit_id: t,
			element_id: a,
			page_num: n
		};
	serverAction("delete_page" === e ? {
		confirm: {
			title: "Delete Page",
			message: "You are about to delete page number " + n + ". Do you want to continue?"
		},
		action: {
			els: ["exhibit_builder_outline_content", "exhibit_page"],
			actions: ["/builder/modify_outline_page", "/builder/reset_exhibit_page_from_outline"],
			params: s
		},
		progress: {
			waitMessage: "Please Wait..."
		}
	} : {
		action: {
			els: "exhibit_builder_outline_content",
			actions: "/builder/modify_outline_page",
			params: s
		}
	})
}

function sectionHovered(e, t, n, i) {
	var r = function(e, t) {
			var n = $(e);
			if (n) {
				var i = n.down("option", n.selectedIndex),
					r = i.innerHTML,
					o = new YAHOO.widget.Button({
						id: "menu" + e,
						name: "menu" + e,
						label: '<span class="yui-button-label">' + r + "</span>",
						type: "menu",
						menu: e,
						container: e + "_wrapper"
					}),
					a = function() {
						var t = $(e + "_wrapper");
						setTimeout(function() {
							var e = t.down("div");
							e.setStyle({
								zIndex: 50
							})
						}, 50)
					};
				o.on("focus", a);
				var s = function(e) {
					var n = e.newValue,
						i = n.cfg.getProperty("text");
					this.set("label", '<span class="yui-button-label">' + i + "</span>"), r !== i && t(n.value)
				};
				o.on("selectedMenuItemChange", s)
			}
		},
		o = e.id.split("_"),
		a = o[1];
	if (r(e.id + "_select_type", function(t) {
		elementTypeChanged(e.id, a, t)
	}), r("justify_" + a, function(t) {
		illustrationJustificationChanged(e.id, a, t)
	}), "waiting" === unhoverlist.get(e.id)) unhoverlist.set(e.id, "hovered");
	else {
		$(e).addClassName(n), $(e).removeClassName(i);
		var s = $(e).down("." + t);
		s.removeClassName("hidden")
	}
	return !1
}

function sectionUnhovered(e, t, n, i) {
	var r = function(e, t, n, i) {
		"waiting" === unhoverlist.get(e.id) && (unhoverlist.set(e.id, "cleared"), $(e).addClassName(n), $(e).removeClassName(i), $(e).down("." + t).addClassName("hidden"))
	};
	return unhoverlist.set(e.id, "waiting"), r.delay(.1, e, t, n, i), !1
}

function doRemoveObjectFromExhibit(e, t) {
	var n = $("in_exhibit_" + e + "_" + t);
	null !== n && n.remove(), serverAction({
		action: {
			actions: "/builder/remove_exhibited_object",
			els: "exhibited_objects_container",
			params: {
				uri: t,
				exhibit_id: e
			}
		}
	})
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function toggle_by_id(e) {
	Element.toggle(e + "_opened"), Element.toggle(e + "_closed"), Element.toggle(e)
}

function open_by_id(e) {
	Element.show(e + "_opened"), Element.hide(e + "_closed"), Element.show(e)
}

function hide_by_id(e) {
	Element.hide(e + "_opened"), Element.show(e + "_closed"), Element.hide(e)
}

function setPageSelected() {
	var e = $$(".selected_page");
	e.each(function(e) {
		e.removeClassName("selected_page")
	});
	var t = $$(".outline_tree_element_selected");
	if (t.length > 0) {
		var n = $(t[0]).up(".unselected_page");
		void 0 !== n && n.addClassName("selected_page")
	}
}

function setOutlineHeight() {
	if (outline_page_height > 0) {
		var e = $("exhibit_outline_pages");
		e.setStyle({
			height: outline_page_height + "px"
		})
	}
}

function scroll_to_target(e, t) {
	var n = function() {
			var e = function(e, t, n) {
				var i = e ? e : 0;
				return t && (!i || i > t) && (i = t), n && (!i || i > n) ? n : i
			};
			return e(window.pageYOffset ? window.pageYOffset : 0, document.documentElement ? document.documentElement.scrollTop : 0, document.body ? document.body.scrollTop : 0)
		},
		i = function(e) {
			var t = $(e);
			if (null === t) return 0;
			var i = YAHOO.util.Dom.getY(t),
				r = window.innerHeight,
				o = n();
			return o > i ? i - o : i > o + r ? i - o : 0
		},
		r = i(e);
	window.scrollBy(0, r), new Effect.Highlight(t)
}

function selectLine(e) {
	var t = $$(".outline_tree_element_selected");
	if (1 !== t.length || t[0].id !== e) {
		t.each(function(e) {
			e.removeClassName("outline_tree_element_selected")
		}), $(e).addClassName("outline_tree_element_selected"), setPageSelected();
		var n = e.split("_"),
			i = n[n.length - 1],
			r = "element_" + i;
		null !== $(r) ? scroll_to_target(r, "element_" + i) : serverAction({
			action: {
				actions: "/builder/find_page_containing_element",
				els: "exhibit_page",
				params: {
					element: r
				}
			}
		})
	}
}

function showExhibitOutline(e, t) {
	if (exhibit_outline.show(), -1 !== t) {
		e > 0 ? selectLine("outline_element_" + e) : t = parseInt($("current_page_num").innerHTML);
		for (var n = !1, i = 1; !n;) {
			var r = "outline_p" + i,
				o = $("outline_page_" + i);
			null === $(r) ? n = !0 : t === i ? (o.addClassName("selected_page"), open_by_id(r)) : (o.removeClassName("selected_page"), hide_by_id(r)), i++
		}
	}
}

function initOutline(e) {
	if (void 0 === YAHOO.util.Resize) return void initOutline.delay(.5, e);
	$(e).removeClassName("hidden");
	var t = 320,
		n = 180,
		i = YAHOO.util.Dom.getViewportHeight() - n - 80;
	exhibit_outline = new YAHOO.widget.Dialog(e, {
		width: t + "px",
		height: i + "px",
		fixedcenter: supportsFixedPositioning === !1,
		draggable: !0,
		constraintoviewport: !0,
		visible: !1,
		xy: [YAHOO.util.Dom.getViewportWidth() - t - 60, 180]
	});
	var r = new YAHOO.util.Resize(e, {
		handles: ["br"],
		autoRatio: !1,
		minWidth: 300,
		minHeight: 100,
		status: !1
	});
	r.on("startResize", function() {
		if (this.cfg.getProperty("constraintoviewport")) {
			var e = YAHOO.util.Dom,
				t = e.getClientRegion(),
				n = e.getRegion(this.element);
			r.set("maxWidth", t.right - n.left - YAHOO.widget.Overlay.VIEWPORT_OFFSET), r.set("maxHeight", t.bottom - n.top - YAHOO.widget.Overlay.VIEWPORT_OFFSET)
		} else r.set("maxWidth", null), r.set("maxHeight", null)
	}, exhibit_outline, !0), r.on("resize", function(e) {
		var t = e.height;
		this.cfg.setProperty("height", t + "px");
		var n = $("exhibit_outline_pages");
		outline_page_height = t - n.offsetTop - 15, setOutlineHeight()
	}, exhibit_outline, !0), exhibit_outline.setHeader("OUTLINE"), exhibit_outline.render();
	var o = $("exhibit_outline_pages");
	outline_page_height = i - o.offsetTop - 15, setOutlineHeight(), supportsFixedPositioning && $(e + "_c").setStyle({
		position: "fixed"
	})
}

function doPublish(e, t) {
	serverAction({
		action: {
			actions: ["/builder/publish_exhibit"],
			els: ["overview_data"],
			params: {
				id: e,
				publish_state: t
			}
		},
		progress: {
			waitMessage: "Updating..."
		}
	})
}

function editExhibitProfile(e, t, n, i, r, o, a, s) {
	var l = $$("." + n),
		c = {};
	l.each(function(e) {
		c[e.id + "_dlg"] = e.innerHTML.unescapeHTML()
	}), c.exhibit_id = t, c.element_id = e;
	var u = function(e, t) {
			var n = t.arg0,
				i = t.dlg;
			return i.changePage(n, "overview_title_dlg"), !1
		},
		d = function(e, t) {
			var n = $("genre_list"),
				i = t.dlg.getAllData(),
				r = "";
			for (var o in i)
				if (o.startsWith("genre[")) {
					var a = o.substring(6, o.indexOf("]"));
					i[o] === !0 && (r.length > 0 && (r += ", "), r += a)
				}
			n.update(r), n = $("discipline_list"), i = t.dlg.getAllData(), r = "";
			for (var o in i)
				if (o.startsWith("discipline[")) {
					var a = o.substring(11, o.indexOf("]"));
					i[o] === !0 && (r.length > 0 && (r += ", "), r += a)
				}
			n.update(r), u(e, t)
		};
	this.sendWithAjax = function(n, i) {
		var r = i.dlg;
		r.setFlash("Updating exhibit...", !1);
		var o = function() {
				r.cancel()
			},
			a = function(e) {
				r.setFlash(e.responseText, !0)
			},
			s = r.getAllData();
		s.exhibit_id = t, s.element_id = e, serverAction({
			action: {
				actions: ["/builder/edit_exhibit_overview", "/builder/update_title"],
				els: ["overview_data", "overview_title"],
				onSuccess: o,
				onFailure: a,
				params: s
			}
		})
	}, this.deleteExhibit = function() {
		serverAction({
			confirm: {
				title: "Delete Exhibit",
				message: "Warning: This will permanently remove this exhibit. Are you sure you want to continue?"
			},
			action: {
				actions: {
					method: "DELETE",
					url: "/builder/" + t
				}
			},
			progress: {
				waitMessage: "Deleting exhibit..."
			}
		})
	};
	var h = {
			page: "profile",
			rows: [
				[{
					text: "Exhibit Title:",
					klass: "new_exhibit_title"
				}, {
					input: "overview_title_dlg",
					value: c.overview_title_dlg,
					klass: "new_exhibit_input_long"
				}],
				[{
					text: "Exhibit Short Title:",
					klass: "new_exhibit_title"
				}, {
					text: "(Used for display in lists)",
					klass: "link_dlg_label_and"
				}, {
					input: "overview_resource_name_dlg",
					value: c.overview_resource_name_dlg,
					klass: "new_exhibit_input_long"
				}],
				[{
					text: "Visible URL:",
					klass: "new_exhibit_title"
				}],
				[{
					text: "http://nines.org/exhibits/",
					klass: "link_prefix_text"
				}, {
					input: "overview_visible_url_dlg",
					value: c.overview_visible_url_dlg,
					klass: "new_exhibit_input"
				}],
				[{
					text: "Thumbnail:",
					klass: "new_exhibit_title"
				}, {
					input: "overview_thumbnail_dlg",
					value: c.overview_thumbnail_dlg,
					klass: "new_exhibit_input_long"
				}],
				[{
					link: "[Choose Thumbnail from Collected Objects]",
					klass: "nav_link",
					callback: u,
					arg0: "choose_thumbnail"
				}],
				[{
					text: "Genres:",
					klass: "new_exhibit_title"
				}, {
					text: "&nbsp;" + c.overview_genres_dlg + "&nbsp;",
					id: "genre_list"
				}, {
					link: "[Select Genres]",
					klass: "nav_link",
					callback: u,
					arg0: "genres"
				}],
				[{
					text: "Disciplines:",
					klass: "new_exhibit_title"
				}, {
					text: "&nbsp;" + c.overview_disciplines_dlg + "&nbsp;",
					id: "discipline_list"
				}, {
					link: "[Select Disciplines]",
					klass: "nav_link",
					callback: u,
					arg0: "disciplines"
				}],
				[{
					text: "(" + window.gFederationName + " contributors are required to assign at least one genre to their objects. Please choose one or more from this list.)",
					klass: "link_dlg_label_and"
				}],
				[{
					link: "[Completely Delete Exhibit]",
					klass: "nav_link",
					callback: this.deleteExhibit
				}],
				[{
					rowClass: "gd_last_row"
				}, {
					button: "Save",
					callback: this.sendWithAjax,
					isDefault: !0
				}, {
					button: "Cancel",
					callback: GeneralDialog.cancelCallback
				}]
			]
		},
		p = function(e) {
			var t = $("overview_thumbnail_dlg"),
				n = $(e + "_img");
			t.value = n.src
		},
		f = new CreateListOfObjects(r, null, "nines_object", o, p);
	f.useTabs(i, r);
	var g = {
			page: "choose_thumbnail",
			rows: [
				[{
					text: "Choose Thumbnail from the list.",
					klass: "new_exhibit_title"
				}],
				[{
					text: "Sort objects by:",
					klass: "forum_reply_label"
				}, {
					select: "sort_by",
					callback: f.sortby,
					klass: "link_dlg_select",
					value: "date_collected",
					options: [{
						text: "Date Collected",
						value: "date_collected"
					}, {
						text: "Title",
						value: "title"
					}, {
						text: "Author",
						value: "author"
					}]
				}, {
					text: "and",
					klass: "link_dlg_label_and"
				}, {
					inputFilter: "filterObjects",
					klass: "",
					prompt: "type to filter objects",
					callback: f.filter
				}],
				[{
					link: "Exhibit Palette",
					klass: "dlg_tab_link_current",
					callback: f.ninesObjView,
					arg0: "exhibit"
				}, {
					link: "All My Objects",
					klass: "dlg_tab_link",
					callback: f.ninesObjView,
					arg0: "all"
				}],
				[{
					custom: f,
					klass: "dlg_tab_contents new_exhibit_label"
				}],
				[{
					rowClass: "gd_last_row"
				}, {
					button: "Ok",
					arg0: "profile",
					callback: u
				}, {
					button: "Cancel",
					arg0: "profile",
					callback: d
				}]
			]
		},
		m = {
			page: "genres",
			rows: [
				[{
					text: "Select all the genres that apply:",
					klass: "new_exhibit_title"
				}],
				[{
					checkboxList: "genre",
					klass: "checkbox_label",
					columns: 3,
					items: a,
					selections: c.overview_genres_dlg.split(", ")
				}],
				[{
					rowClass: "gd_last_row"
				}, {
					button: "Ok",
					arg0: "profile",
					callback: d
				}, {
					button: "Cancel",
					arg0: "profile",
					callback: d
				}]
			]
		},
		v = {
			page: "disciplines",
			rows: [
				[{
					text: "Select all the disciplines that apply:",
					klass: "new_exhibit_title"
				}],
				[{
					checkboxList: "discipline",
					klass: "checkbox_label",
					columns: 3,
					items: s,
					selections: c.overview_disciplines_dlg.split(", ")
				}],
				[{
					rowClass: "gd_last_row"
				}, {
					button: "Ok",
					arg0: "profile",
					callback: d
				}, {
					button: "Cancel",
					arg0: "profile",
					callback: d
				}]
			]
		},
		_ = [h, g, m, v],
		b = {
			this_id: "new_exhibit_wizard",
			pages: _,
			body_style: "new_exhibit_div",
			row_style: "new_exhibit_row",
			title: "Edit Exhibit Profile"
		},
		y = new GeneralDialog(b);
	u(null, {
		curr_page: "",
		arg0: "profile",
		dlg: y
	}), y.center(), f.populate(y, !1, "thumb")
}

function initializeInplaceRichEditor(e, t) {
	var n = function() {
		var e = $(this).down(),
			t = e.id,
			n = "",
			i = $(t).down(".exhibit_text");
		for (n = null !== i && void 0 !== i ? i.innerHTML : $(t).innerHTML, n = n.strip(); n.startsWith("<div>") && n.endsWith("</div>");) n = n.substring(5), n = n.substring(0, n.length - 6), n = n.strip();
		("Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above." === n || "Enter your text here." === n) && (n = "");
		var r = new FootnotesInRte;
		n = r.preprocessFootnotes(n);
		var o = function(e, n) {
				var i = n.dlg.getAllData();
				i.element_id = t, i.value = r.postprocessFootnotes(i.value), n.dlg.setFlash("Updating Text...", !1), inplaceObjectManager.ajaxUpdateFromElement($(t), i, initializeElementEditing), n.dlg.cancel()
			},
			a = {
				page: "layout",
				rows: [
					[{
						textarea: "value",
						value: n
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						callback: o,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			s = e.getStyle("width");
		s = parseInt(s) + 10 + 10 + 16;
		var l = {
				this_id: t + "builder_text_input_dlg",
				pages: [a],
				body_style: "exhibit_builder_text_dlg",
				row_style: "gd_message_box_row",
				title: "Enter Text",
				width: s + "px"
			},
			c = new GeneralDialog(l),
			u = t.split("_"),
			d = u[u.length - 1],
			h = "/forum/get_nines_obj_list",
			p = "/forum/get_nines_obj_list?element_id=" + d,
			f = "/assets/ajax_loader.gif",
			g = e.getStyle("font-family"),
			m = e.getStyle("font-size"),
			v = "html body { font-family: " + g + "; font-size: " + m + "; }";
		c.initTextAreas({
			toolbarGroups: ["dropcap", "list", "link&footnote"],
			linkDlgHandler: new LinkDlgHandler([p, h], f),
			footnote: {
				callback: r.addFootnote,
				populate_url: [p, h],
				progress_img: f
			},
			bodyStyle: v
		}), c.center();
		var _ = $("value");
		return _.select(), _.focus(), !1
	};
	inplaceObjectManager.initDiv(e, t, n)
}

function initializeInplaceHeaderEditor(e, t) {
	var n = function() {
		var t = $(this).down(),
			n = "inner_" + t.id,
			i = $(n).innerHTML;
		("Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above." === i || "Enter your text here." === i) && (i = "");
		var r = $("footnote_for_" + t.id),
			o = r ? r.innerHTML : "",
			a = function(t, n) {
				var i = e.split(",")[0],
					r = n.dlg,
					o = r.getAllData();
				o.element_id = i, r.setFlash("Updating Header...", !1), inplaceObjectManager.ajaxUpdateFromElement($(i), o, initializeElementEditing), n.dlg.cancel()
			},
			s = e.split(",")[0].split("_"),
			l = s[s.length - 1],
			c = "/forum/get_nines_obj_list",
			u = "/forum/get_nines_obj_list?element_id=" + l,
			d = "/assets/ajax_loader.gif",
			h = new FootnoteAbbrev({
				startingValue: o,
				field: "footnote",
				populate_exhibit_only: u,
				populate_all: c,
				progress_img: d
			}),
			p = {
				page: "layout",
				rows: [
					[{
						text: "Header: ",
						klass: "new_exhibit_label"
					}, {
						input: "value",
						value: i,
						klass: "header_input"
					}, {
						custom: h
					},
						h.createEditButton("footnoteEditStar")
					],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Save",
						callback: a,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			f = {
				this_id: "header_dlg",
				pages: [p],
				body_style: "edit_header_dlg",
				row_style: "new_exhibit_row",
				title: "Enter Header",
				focus: "value"
			},
			g = new GeneralDialog(f);
		g.center()
	};
	inplaceObjectManager.initDiv(e, t, n)
}

function initializeInplaceIllustrationEditor(e, t) {
	var n = function() {
		function e(e) {
			return {
				text: gIllustrationTypes[e][gIllustrationTypes[e].length - 1],
				value: gIllustrationTypes[e][0]
			}
		}
		var n = $(this).down(),
			i = n.id,
			r = {},
			o = $$("#" + i + " .saved_data");
		o.each(function(e) {
			e.hasClassName("ill_illustration_type") ? r.type = e.innerHTML : e.hasClassName("ill_image_url") ? r.image_url = e.innerHTML : e.hasClassName("ill_link") ? r.link_url = e.innerHTML : e.hasClassName("ill_image_width") ? r.ill_width = e.innerHTML : e.hasClassName("ill_illustration_text") ? r.ill_text = e.innerHTML : e.hasClassName("ill_illustration_alt_text") ? r.alt_text = e.innerHTML : e.hasClassName("ill_illustration_caption1") ? r.caption1 = e.innerHTML : e.hasClassName("ill_illustration_caption2") ? r.caption2 = e.innerHTML : e.hasClassName("ill_illustration_caption1_footnote") ? r.caption1_footnote = e.innerHTML : e.hasClassName("ill_illustration_caption2_footnote") ? r.caption2_footnote = e.innerHTML : e.hasClassName("ill_illustration_caption1_bold") ? r.caption1_bold = e.innerHTML : e.hasClassName("ill_illustration_caption1_italic") ? r.caption1_italic = e.innerHTML : e.hasClassName("ill_illustration_caption1_underline") ? r.caption1_underline = e.innerHTML : e.hasClassName("ill_illustration_caption2_bold") ? r.caption2_bold = e.innerHTML : e.hasClassName("ill_illustration_caption2_italic") ? r.caption2_italic = e.innerHTML : e.hasClassName("ill_illustration_caption2_underline") ? r.caption2_underline = e.innerHTML : e.hasClassName("ill_nines_object_uri") ? r.nines_object = e.innerHTML : e.hasClassName("ill_upload_filename") && (r.upload_filename = e.innerHTML)
		});
		var a = new FootnotesInRte;
		r.ill_text = a.preprocessFootnotes(r.ill_text);
		var s = function(e, t) {
				t === gIllustrationTypes[0][0] ? ($$(".image_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".text_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".not_nines").each(function(e) {
					e.addClassName("hidden")
				}), $$(".nines_only").each(function(e) {
					e.removeClassName("hidden")
				}), $$(".file_only").each(function(e) {
					e.addClassName("hidden")
				})) : t === gIllustrationTypes[1][0] ? ($$(".nines_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".text_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".image_only").each(function(e) {
					e.removeClassName("hidden")
				}), $$(".not_nines").each(function(e) {
					e.removeClassName("hidden")
				}), $$(".file_only").each(function(e) {
					e.addClassName("hidden")
				})) : t === gIllustrationTypes[2][0] ? ($$(".nines_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".image_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".not_nines").each(function(e) {
					e.removeClassName("hidden")
				}), $$(".text_only").each(function(e) {
					e.removeClassName("hidden")
				}), $$(".file_only").each(function(e) {
					e.addClassName("hidden")
				})) : t === gIllustrationTypes[3][0] && ($$(".nines_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".image_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".not_nines").each(function(e) {
					e.addClassName("hidden")
				}), $$(".text_only").each(function(e) {
					e.addClassName("hidden")
				}), $$(".file_only").each(function(e) {
					e.removeClassName("hidden")
				}))
			},
			l = function(e) {
				var t = $(e).down(".linkdlg_firstline");
				$("caption1").writeAttribute("value", t.innerHTML), t = $(e).down(".linkdlg_secondline"), $("caption2").writeAttribute("value", t.innerHTML)
			},
			c = i.split("_"),
			u = c[c.length - 1],
			d = "/forum/get_nines_obj_list",
			h = "/forum/get_nines_obj_list?illustration_id=" + u,
			p = "/assets/ajax_loader.gif",
			f = new CreateListOfObjects(h, r.nines_object, "nines_object", p, l);
		f.useTabs(d, h);
		var g = function(e, n) {
				n.dlg.cancel();
				var r = n.dlg.getAllData();
				if (r.ill_illustration_id = i, r.element_id = i, r.ill_text = a.postprocessFootnotes(r.ill_text), n.dlg.setFlash("Updating Illustration...", !1), f.resetCacheIfNecessary(), r.type === gIllustrationTypes[3][0]) {
					var o = t.split(",");
					submitForm("layout", o[0])
				} else inplaceObjectManager.ajaxUpdateFromElement($(i), r, initializeElementEditing)
			},
			m = new FootnoteAbbrev({
				startingValue: r.caption1_footnote,
				field: "caption1_footnote",
				populate_exhibit_only: h,
				populate_all: d,
				progress_img: p
			}),
			v = new FootnoteAbbrev({
				startingValue: r.caption2_footnote,
				field: "caption2_footnote",
				populate_exhibit_only: h,
				populate_all: d,
				progress_img: p
			}),
			_ = {
				page: "layout",
				rows: [
					[{
						text: "Type of Illustration:",
						klass: "edit_illustration_caption_label"
					}, {
						select: "type",
						callback: s,
						value: r.type,
						options: [e(0), e(1), e(2), e(3)]
					}, {
						hidden: "ill_illustration_id",
						value: i
					}, {
						hidden: "element_id",
						value: i
					}],
					[{
						text: "First Caption:",
						klass: "edit_illustration_caption_label"
					}, {
						inputWithStyle: "caption1",
						value: {
							text: r.caption1,
							isBold: "1" === r.caption1_bold,
							isItalic: "1" === r.caption1_italic,
							isUnderline: "1" === r.caption1_underline
						},
						klass: "header_input"
					}, {
						custom: m
					},
						m.createEditButton("footnoteEditStar")
					],
					[{
						text: "Second Caption:",
						klass: "edit_illustration_caption_label"
					}, {
						inputWithStyle: "caption2",
						value: {
							text: r.caption2,
							isBold: "1" === r.caption2_bold,
							isItalic: "1" === r.caption2_italic,
							isUnderline: "1" === r.caption2_underline
						},
						klass: "header_input"
					}, {
						custom: v
					},
						v.createEditButton("footnoteEditStar2")
					],
					[{
						text: "Sort objects by:",
						klass: "forum_reply_label nines_only hidden"
					}, {
						select: "sort_by",
						callback: f.sortby,
						klass: "link_dlg_select nines_only hidden",
						value: "date_collected",
						options: [{
							text: "Date Collected",
							value: "date_collected"
						}, {
							text: "Title",
							value: "title"
						}, {
							text: "Author",
							value: "author"
						}]
					}, {
						text: "and",
						klass: "link_dlg_label_and nines_only hidden"
					}, {
						inputFilter: "filterObjects",
						klass: "nines_only hidden",
						prompt: "type to filter objects",
						callback: f.filter
					}],
					[{
						text: "Image URL:",
						klass: "edit_illustration_label_lined_up image_only hidden"
					}, {
						input: "image_url",
						value: r.image_url,
						klass: "new_exhibit_input_long image_only hidden"
					}, {
						link: "Exhibit Palette",
						klass: "dlg_tab_link_current nines_only hidden",
						callback: f.ninesObjView,
						arg0: "exhibit"
					}, {
						link: "All My Objects",
						klass: "dlg_tab_link nines_only hidden",
						callback: f.ninesObjView,
						arg0: "all"
					}, {
						text: "Upload Image:",
						klass: "edit_illustration_label_lined_up file_only hidden"
					}, {
						image: "uploaded_image",
						size: 60,
						klass: "edit_illustration_upload file_only hidden",
						value: r.upload_filename,
						no_iframe: !0
					}],
					[{
						text: "Link URL:",
						klass: "edit_illustration_label_lined_up not_nines hidden"
					}, {
						input: "link_url",
						value: r.link_url,
						klass: "new_exhibit_input_long not_nines hidden"
					}, {
						custom: f,
						klass: "dlg_tab_contents nines_only hidden"
					}],
					[{
						textarea: "ill_text",
						klass: "edit_facet_textarea text_only",
						value: r.ill_text
					}],
					[{
						text: "Alt Text:",
						klass: "edit_illustration_label_lined_up image_only hidden"
					}, {
						input: "alt_text",
						value: r.alt_text,
						klass: "new_exhibit_input_long image_only hidden"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Save",
						callback: g,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			b = {
				this_id: "illustration_dlg",
				pages: [_],
				body_style: "edit_illustration_dlg",
				row_style: "new_exhibit_row",
				title: "Edit Illustration",
				focus: "illustration_dlg_sel0"
			},
			y = new GeneralDialog(b);
		y.initTextAreas({
			toolbarGroups: ["fontstyle", "alignment", "list", "link&footnote"],
			linkDlgHandler: new LinkDlgHandler([h, d], p),
			footnote: {
				callback: a.addFootnote,
				populate_url: [h, d],
				progress_img: p
			}
		}), f.populate(y, !0, "illust"), s(null, r.type), y.center()
	};
	inplaceObjectManager.initDiv(e, t, n)
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function renumberFootnotes(e) {
	var t = $$(".superscript"),
		n = e;
	t.each(function(e) {
		if (e.visible() && e.parentNode.visible()) {
			var t = "" + n;
			e.innerHTML = t, n += 1
		}
	})
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function thumbnail_resize() {
	var e = $(this),
		t = parseInt(e.up().getStyle("height"));
	e.show();
	var n = e.width,
		i = e.height;
	if (0 === i) return void setTimeout(thumbnail_resize.bind(this), 500);
	var r, o, a, s = n / i;
	if (n > i) r = 0, a = parseInt(t * s + ""), o = parseInt((t - a) / 2 + "");
	else {
		var l = t / s;
		r = "-" + parseInt((l - t) / 2 + ""), o = 0, a = t
	}
	e.setStyle({
		marginTop: r + "px",
		marginLeft: o + "px"
	}), e.writeAttribute("width", a)
}

function stopFeatureUpload(e) {
	return e.startsWith("OK:") ? varFeatureDlg.fileUploadFinished() : varFeatureDlg.fileUploadError(e), !0
} //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function flagComment(e, t, n, i, r, o) {
	var a = Class.create({
		initialize: function(a) {
			var s = a.title,
				l = (a.addAction, null),
				c = "reason",
				u = a.msg,
				d = a.prompt ? d : "Reason:";
			this.report = function(a, s) {
				s.dlg.cancel();
				var l = s.dlg.getAllData();
				serverAction({
					action: {
						actions: t,
						els: n,
						params: {
							comment_id: e,
							reason: l[c],
							can_edit: i,
							can_delete: r,
							is_main: o
						}
					}
				})
			};
			var h = {
				page: "layout",
				rows: [
					[{
						text: u,
						klass: "gd_text_input_dlg_label"
					}],
					[{
						text: d,
						klass: "gd_text_input_dlg_label"
					}, {
						textarea: c,
						klass: "report_comment_textarea"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Report",
						callback: this.report,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			};
			h.rows.push();
			var p = {
				this_id: "gd_text_input_dlg",
				pages: [h],
				body_style: "gd_message_box_dlg",
				row_style: "gd_message_box_row",
				title: s,
				focus: GeneralDialog.makeId(c)
			};
			l = new GeneralDialog(p), l.center()
		}
	});
	new a({
		title: "Report this comment as objectionable",
		msg: "Enter a reason in the space below and click 'Report' to send an email to the administrators complaining about this entry."
	})
} //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function loadLatestNews(e, t, n, i) {
	YUI().use("io", function(r) {
		var o = function(t, n) {
				var i = n.responseXML;
				if (null === i) return void $(e).update("<ul><li>Error in retrieving News Feed.</li></ul>\n");
				var r = i.documentElement,
					o = r.getElementsByTagName("channel"),
					a = o[0].getElementsByTagName("item"),
					s = $A(a),
					l = 5;
				s.length < 5 && (l = s.length);
				for (var c = "<ul>", u = 0; l > u; u++) {
					var d = s[u].getElementsByTagName("title"),
						h = s[u].getElementsByTagName("link"),
						p = d[0].text;
					void 0 === p && (p = d[0].textContent);
					var f = h[0].text;
					void 0 === f && (f = h[0].textContent), c += '<li><a href="' + f + '" class="nav_link" >' + p + "</a></li>\n"
				}
				c += '<li><a href="/news/" class="nav_link">MORE</a></li></ul>\n', $(e).update(c)
			},
			a = function() {
				i === !0 ? loadLatestNews(e, t, n, !1) : $(e).update("<ul><li>News feed currently unavailable.</li></ul>\n")
			};
		r.io(t, {
			method: "GET",
			on: {
				success: o,
				failure: a
			}
		})
	})
}

function stopEditGroupThumbnailUpload(e) {
	return e.startsWith("OK:") ? editGroupThumbnailDlg.fileUploadFinished(e.substring(3)) : editGroupThumbnailDlg.fileUploadError(e), !0
}

function stopNewClusterUpload(e) {
	return e.startsWith("OK:") ? newClusterDlg.fileUploadFinished(e.substring(3)) : newClusterDlg.fileUploadError(e), !0
} //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function hideSpinner(e) {
	var t = $("spinner_" + e);
	t.addClassName("hidden");
	var n = $(e);
	n.removeClassName("hidden")
}

function finishedLoadingImage(e, t, n, i) {
	var r = $(t).width,
		o = $(t).height;
	if (0 === r && 0 === o) $(t).width = n, $(t).height = i;
	else {
		var a = null,
			s = null;
		if (n >= r && i >= o) a = null;
		else if (n >= r && o > i) s = i;
		else if (r > n && i >= o) a = n;
		else {
			var l = r / n,
				c = o / i;
			l > c ? a = n : s = i
		} if (a) {
			$(t).width = a;
			var u = $(t).height,
				d = (i - u) / 2;
			d > 0 && $(t).setStyle({
				paddingTop: d + "px"
			})
		}
		if (s) {
			$(t).height = s;
			var h = $(t).width,
				p = (n - h) / 2;
			p > 0 && $(t).setStyle({
				paddingLeft: p + "px"
			})
		}
	}
	$(e).addClassName("hidden"), $(t).removeClassName("hidden")
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function toggleElementsByClass(e) {
	var t = $$("." + e);
	t.each(function(e) {
		e.toggle()
	})
}

function editTag(e) {
	new TextInputDlg({
		title: "Edit Tag",
		prompt: "Tag",
		id: "new_name",
		actions: "/results/edit_tag",
		extraParams: {
			old_name: e
		},
		value: e,
		target_els: null,
		pleaseWaitMsg: "Editing all objects with this tag..."
	})
}

function removeTag(e, t) {
	var n = 'Are you sure you want to remove all instances of the "' + t + '" tag that you created?';
	serverAction({
		confirm: {
			title: "Remove Tag",
			message: n
		},
		action: {
			actions: "/results/remove_all_tags",
			params: {
				tag: t
			}
		},
		progress: {
			waitMessage: 'Removing tag "' + t + '". Please wait...'
		}
	})
} //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function encodeForUri(e) {
	var t = e.gsub("%", "%25");
	return t = t.gsub("#", "%23"), t = t.gsub("&", "%26"), t = t.gsub(/\?/, "%3f")
}

function removeHidden(e, t) {
	var n = $(e);
	n.innerHTML.indexOf("more") > 0 ? ($$("#" + t + " .hidden").each(function(e) {
		"IMG" !== e.tagName && e.removeClassName("hidden"), e.addClassName("was_hidden")
	}), n.update(n.innerHTML.gsub("more", "less"))) : ($$("#" + t + " .was_hidden").each(function(e) {
		e.addClassName("hidden")
	}), n.update(n.innerHTML.gsub("less", "more")))
}

function bulkTag(e) {
	for (var t = Form.getInputs("bulk_collect_form", "checkbox"), n = "", i = !1, r = 0; r < t.length; r++) {
		var o = t[r];
		o.checked && (n += o.value + "	", i = !0)
	}
	if (i) {
		var a = {
			title: "Add Tag To All Checked Objects",
			prompt: "Tag:",
			id: "tag[name]",
			okStr: "Save",
			explanation_text: "Add multiple tags by separating them with a comma (e.g. painting, visual_art)",
			explanation_klass: "gd_text_input_help",
			extraParams: {
				uris: n
			},
			autocompleteParams: {
				url: e,
				token: ","
			},
			inputKlass: "new_exhibit_autocomplete",
			actions: ["/results/bulk_add_tag"],
			target_els: [null]
		};
		new TextInputDlg(a)
	} else new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.")
}

function bulkCollect(e) {
	for (var t = Class.create({
		initialize: function(t) {
			var n = t.title,
				i = t.addAction,
				r = t.skipAction,
				o = null,
				a = "tag[name]",
				s = "Your objects have been collected. Would you like to add a tag to the batch?",
				l = "Tag:",
				c = "Add multiple tags by separating them with a comma (e.g. painting, visual_art)";
			this.add = function(e, t) {
				t.dlg.cancel();
				var n = t.dlg.getAllData(),
					r = n[a];
				i(r)
			}, this.skip = function(e, t) {
				t.dlg.cancel(), r()
			};
			var u = {
				page: "layout",
				rows: [
					[{
						text: s,
						klass: "gd_text_input_dlg_label"
					}],
					[{
						text: l,
						klass: "gd_text_input_dlg_label"
					}, {
						autocomplete: a,
						klass: "new_exhibit_autocomplete",
						url: e,
						token: ","
					}],
					[{
						text: c,
						id: "gd_postExplanation",
						klass: "gd_text_input_help"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Add Tags",
						callback: this.add,
						isDefault: !0
					}, {
						button: "Skip Tags",
						callback: this.skip
					}]
				]
			};
			u.rows.push();
			var d = {
				this_id: "gd_text_input_dlg",
				pages: [u],
				body_style: "gd_message_box_dlg",
				row_style: "gd_message_box_row",
				title: n,
				focus: GeneralDialog.makeId(a)
			};
			o = new GeneralDialog(d), o.center()
		}
	}), n = Form.getInputs("bulk_collect_form", "checkbox"), i = !1, r = 0; r < n.length; r++) {
		var o = n[r];
		o.checked && (i = !0)
	}
	if (i) {
		var a = function(e) {
				var t = $("bulk_tag_text");
				t.value = e, submitForm("bulk_collect_form", "/results/bulk_collect", "post")
			},
			s = function() {
				submitForm("bulk_collect_form", "/results/bulk_collect", "post")
			};
		new t({
			title: "Tag Selections",
			addAction: a,
			skipAction: s
		})
	} else new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.")
}

function bulkUncollect() {
	for (var e = Form.getInputs("bulk_collect_form", "checkbox"), t = !1, n = 0; n < e.length; n++) {
		var i = e[n];
		if (i.checked) {
			t = !0;
			break
		}
	}
	t ? submitFormWithConfirmation({
		id: "bulk_collect_form",
		action: "/results/bulk_uncollect",
		title: "Remove Selected Objects from Collection?",
		message: "Are you sure you wish to remove the selected objects from your collection?"
	}) : new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.")
}

function toggleAllBulkCollectCheckboxes() {
	bulk_checked = !bulk_checked;
	for (var e = Form.getInputs("bulk_collect_form", "checkbox"), t = 0; t < e.length; t++) {
		var n = e[t];
		n.checked = bulk_checked
	}
	var i = document.getElementsByClassName("bulk_select_all");
	for (t = 0; t < i.length; t++) i[t].toggle();
	for (i = document.getElementsByClassName("bulk_unselect_all"), t = 0; t < i.length; t++) i[t].toggle()
}

function expandAllItems() {
	var e = jQuery(".search_result_data_container .hidden");
	e.removeClass("hidden"), e.addClass("was_hidden");
	var t = jQuery(".search_result_data_container .more");
	t.each(function(e, t) {
		t = jQuery(t), t.html(t.html().replace("more", "less"))
	})
}

function collapseAllItems() {
	var e = jQuery(".search_result_data_container .was_hidden");
	e.addClass("hidden"), e.removeClass("was_hidden");
	var t = jQuery(".search_result_data_container .more");
	t.each(function(e, t) {
		t = jQuery(t), t.html(t.html().replace("less", "more"))
	})
}

function toggleItemExpand() {
	var e = document.getElementById("expand_all"),
		t = document.getElementById("collapse_all");
	"none" === t.style.display ? (e.style.display = "none", t.style.display = "", expandAllItems()) : (e.style.display = "", t.style.display = "none", collapseAllItems())
}

function doCollect(e, t, n, i, r, o) {
	if (!r) {
		var a = new SignInDlg;
		return a.setInitialMessage("Please log in to collect objects"), a.setRedirectPageToCurrentWithParam("script=doCollect&uri=" + t + "&row_num=" + n + "&row_id=" + i), void a.show("sign_in")
	}
	var s = {
			partial: e,
			uri: t,
			row_num: n,
			full_text: ""
		},
		l = function(e) {
			var t = JSON.parse(e.responseText);
			window.collex.setCollected(n, t.collected_on, o)
		};
	serverAction({
		action: {
			actions: "/results/collect.json",
			els: [],
			params: s,
			onSuccess: l
		},
		progress: {
			waitMessage: "Collecting object..."
		}
	}), ninesObjCache && ninesObjCache.reset("/forum/get_nines_obj_list")
}

function doRemoveTag(e, t, n) {
	var i = t.substring(t.lastIndexOf("_") + 1),
		r = function(e) {
			var t = JSON.parse(e.responseText);
			window.collex.redrawTags(i, t.my_tags, t.other_tags)
		};
	serverAction({
		action: {
			actions: "/results/remove_tag.json",
			els: [],
			params: {
				uri: e,
				row_num: i,
				tag: n,
				full_text: ""
			},
			onSuccess: r
		}
	})
}

function doRemoveCollect(e, t, n, i) {
	var r = {
			partial: e,
			uri: t,
			row_num: n,
			full_text: ""
		},
		o = function() {
			window.collex.setUncollected(n, i), ninesObjCache && ninesObjCache.reset("/forum/get_nines_obj_list")
		};
	serverAction({
		confirm: {
			title: "Remove Object from Collection?",
			message: "Are you sure you wish to remove this object from your collection?"
		},
		action: {
			actions: "/results/uncollect",
			els: [],
			onSuccess: o,
			params: r
		},
		progress: {
			waitMessage: "Removing collected object..."
		}
	})
}

function doAddTag(e, t, n, i) {
	var r = {
		title: "Add Tag",
		prompt: "Tag:",
		explanation_text: "Add multiple tags by separating them with a comma (e.g. painting, visual_art)",
		explanation_klass: "gd_text_input_help",
		id: "tag[name]",
		okStr: "Save",
		extraParams: {
			uri: t,
			row_num: n,
			row_id: i,
			full_text: ""
		},
		autocompleteParams: {
			url: e,
			token: ","
		},
		inputKlass: "new_exhibit_autocomplete",
		actions: "/results/add_tag.json",
		target_els: [],
		onSuccess: function(e) {
			var t = JSON.parse(e.responseText);
			window.collex.redrawTags(n, t.my_tags, t.other_tags)
		}
	};
	new TextInputDlg(r)
}

function realLinkToEditorLink(e) {
	var t = e.indexOf("<a");
	if (0 > t) return e;
	var n = e.substring(0, t),
		i = e.substring(t);
	if (t = i.indexOf("</a>"), 0 > t) return e;
	var r = i.substring(t + 4);
	i = i.substring(0, t);
	var o = "ext_linklike",
		a = "External Link";
	if (i.indexOf("nines_link") > 0 && (o = "nines_linklike", a = "NINES Object"), t = i.indexOf("nines_linklike" === o ? "uri=" : "href="), 0 > t) return e;
	var s = i.substring(t).indexOf("=");
	i = i.substring(t + s + 2), t = i.indexOf('"');
	var l = i.indexOf("'");
	0 > t ? t = l : l >= 0 && t > l && (t = l);
	var c = i.substring(0, t);
	if (t = i.indexOf(">"), 0 > t) return e;
	var u = i.substring(t + 1);
	return i = '<span class="' + o + '" real_link="' + c + '" title="' + a + ": " + c + '">' + u + "</span>", realLinkToEditorLink(n + i + r)
}

function doAnnotation(e, t, n, i, r, o) {
	var a = $(i).innerHTML;
	a = a.gsub("<br />", "\n"), a = a.gsub("<br>", "\n"), a = realLinkToEditorLink(a);
	var s = function(n) {
			var i = function() {
				window.collex.redrawAnnotation(t, n)
			};
			serverAction({
				action: {
					actions: "/results/set_annotation",
					els: [],
					params: {
						note: n,
						uri: e,
						row_num: t,
						full_text: ""
					},
					onSuccess: i
				}
			})
		},
		l = a.length > 0 ? "Edit Private Annotation" : "Add Private Annotation";
	new RteInputDlg({
		title: l,
		value: a,
		populate_urls: [r],
		progress_img: o,
		okCallback: s
	})
}

function doAddToExhibit(e, t, n, i, r) {
	function o(e) {
		var t = JSON.parse(e.responseText);
		window.collex.redrawExhibits(n, t.exhibits)
	}
	if (0 === window.collex.exhibit_names.length) new MessageBoxDlg("Exhibits", 'You have not yet created any exhibits. <a href="/' + r + '" class="nav_link" >Click here</a> to get started with the Exhibit Wizard.');
	else {
		for (var a = $("search_result_" + n + "_full_text"), s = a ? a.innerHTML : "", l = [], c = 0; c < window.collex.exhibit_names.length; c++) {
			var u = window.collex.exhibit_names[c],
				d = u.text.length > 60 ? u.text.substring(0, 60) + "..." : u.text;
			l.push({
				text: d,
				value: u.value
			})
		}
		new SelectInputDlg({
			title: "Choose exhibit",
			prompt: "Exhibit:",
			id: "exhibit",
			actions: "/results/add_object_to_exhibit",
			target_els: [],
			okStr: "Save",
			options: l,
			extraParams: {
				partial: e,
				uri: t,
				row_num: n,
				full_text: s
			},
			onSuccess: o
		})
	}
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function searchValidationHome(e, t) {
	var n = $(t),
		i = n.value;
	n.disabled = !0, n.value = "......";
	var r = $(e).value;
	return 0 === r.length ? (new MessageBoxDlg("Error", "Please enter some text before searching."), n.disabled = !1, n.value = i, !1) : !0
} //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia

function setExhibitAuthorAlias(e, t, n, i, r) {
	new SelectInputDlg({
		title: "Choose User to Publish As",
		prompt: "Select the user that you wish to impersonate",
		id: "user_id",
		actions: t,
		target_els: i,
		extraParams: {
			exhibit_id: n,
			page_num: r
		},
		pleaseWaitMsg: "Updating Exhibit's Author...",
		body_style: "edit_palette_dlg",
		options: [{
			value: -1,
			text: "Loading user names. Please Wait..."
		}],
		populateUrl: e
	})
}

function addAdditionalAuthor(e, t, n, i, r) {
	new SelectInputDlg({
		title: "Add Additional Author",
		prompt: "Select the user that you wish to add to the author line",
		id: "user_id",
		actions: t,
		target_els: i,
		extraParams: {
			exhibit_id: n,
			page_num: r
		},
		pleaseWaitMsg: "Adding Author to Exhibit...",
		body_style: "edit_palette_dlg",
		options: [{
			value: -1,
			text: "Loading user names. Please Wait..."
		}],
		populateUrl: e
	})
}
/**
 * Diff Match and Patch
 *
 * Copyright 2006 Google Inc.
 * http://code.google.com/p/google-diff-match-patch/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function Diff_match_patch() {
	this.Diff_Timeout = 1, this.Diff_EditCost = 4, this.Match_Threshold = .5, this.Match_Distance = 1e3, this.Patch_DeleteThreshold = .5, this.Patch_Margin = 4, this.Match_MaxBits = 32
}

function patch_obj() {
	this.diffs = [], this.start1 = null, this.start2 = null, this.length1 = 0, this.length2 = 0
} //     Copyright 2011 Applied Research in Patacriticism and the University of Virginia

function doEditDocument(e, t) {
	if (e) gotoPage(t);
	else {
		var n = new SignInDlg;
		n.setInitialMessage("Please log in to edit TypeWright texts"), n.setRedirectPage(t), n.show("sign_in")
	}
}

function showFootnoteDiv(e) {
	for (var t = $$(".footnote"), n = !1, i = function() {
		new Effect.Appear(e)
	}, r = 0; r < t.length; r++)
		if ("none" !== t[r].getStyle("display")) {
			var o = t[r].readAttribute("id");
			new Effect.Fade(o, {
				afterFinish: i
			}), n = !0
		}
	if (n === !1) {
		var a = $("footnotes_box");
		"none" === a.getStyle("display") ? new Effect.BlindDown("footnotes_box", {
			afterFinish: function() {
				new Effect.Appear(e)
			}
		}) : new Effect.Appear(e)
	}
}

function closeFootnoteDiv(e) {
	new Effect.Fade(e, {
		afterFinish: function() {
			new Effect.BlindUp("footnotes_box")
		}
	})
}

function showFootnotePopup(e, t) {
	showInLightbox({
		title: e,
		img: t
	})
}
var Prototype = {
	Version: "1.7",
	Browser: function() {
		var e = navigator.userAgent,
			t = "[object Opera]" == Object.prototype.toString.call(window.opera);
		return {
			IE: !!window.attachEvent && !t,
			Opera: t,
			WebKit: e.indexOf("AppleWebKit/") > -1,
			Gecko: e.indexOf("Gecko") > -1 && -1 === e.indexOf("KHTML"),
			MobileSafari: /Apple.*Mobile/.test(e)
		}
	}(),
	BrowserFeatures: {
		XPath: !!document.evaluate,
		SelectorsAPI: !!document.querySelector,
		ElementExtensions: function() {
			var e = window.Element || window.HTMLElement;
			return !(!e || !e.prototype)
		}(),
		SpecificElementExtensions: function() {
			if ("undefined" != typeof window.HTMLDivElement) return !0;
			var e = document.createElement("div"),
				t = document.createElement("form"),
				n = !1;
			return e.__proto__ && e.__proto__ !== t.__proto__ && (n = !0), e = t = null, n
		}()
	},
	ScriptFragment: "<script[^>]*>([\\S\\s]*?)</script>",
	JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,
	emptyFunction: function() {},
	K: function(e) {
		return e
	}
};
Prototype.Browser.MobileSafari && (Prototype.BrowserFeatures.SpecificElementExtensions = !1);
var Abstract = {},
	Try = {
		these: function() {
			for (var e, t = 0, n = arguments.length; n > t; t++) {
				var i = arguments[t];
				try {
					e = i();
					break
				} catch (r) {}
			}
			return e
		}
	},
	Class = function() {
		function e() {}

		function t() {
			function t() {
				this.initialize.apply(this, arguments)
			}
			var n = null,
				i = $A(arguments);
			Object.isFunction(i[0]) && (n = i.shift()), Object.extend(t, Class.Methods), t.superclass = n, t.subclasses = [], n && (e.prototype = n.prototype, t.prototype = new e, n.subclasses.push(t));
			for (var r = 0, o = i.length; o > r; r++) t.addMethods(i[r]);
			return t.prototype.initialize || (t.prototype.initialize = Prototype.emptyFunction), t.prototype.constructor = t, t
		}

		function n(e) {
			var t = this.superclass && this.superclass.prototype,
				n = Object.keys(e);
			i && (e.toString != Object.prototype.toString && n.push("toString"), e.valueOf != Object.prototype.valueOf && n.push("valueOf"));
			for (var r = 0, o = n.length; o > r; r++) {
				var a = n[r],
					s = e[a];
				if (t && Object.isFunction(s) && "$super" == s.argumentNames()[0]) {
					var l = s;
					s = function(e) {
						return function() {
							return t[e].apply(this, arguments)
						}
					}(a).wrap(l), s.valueOf = l.valueOf.bind(l), s.toString = l.toString.bind(l)
				}
				this.prototype[a] = s
			}
			return this
		}
		var i = function() {
			for (var e in {
				toString: 1
			})
				if ("toString" === e) return !1;
			return !0
		}();
		return {
			create: t,
			Methods: {
				addMethods: n
			}
		}
	}();
! function() {
	function e(e) {
		switch (e) {
			case null:
				return y;
			case void 0:
				return w
		}
		var t = typeof e;
		switch (t) {
			case "boolean":
				return x;
			case "number":
				return E;
			case "string":
				return k
		}
		return C
	}

	function t(e, t) {
		for (var n in t) e[n] = t[n];
		return e
	}

	function n(e) {
		try {
			return _(e) ? "undefined" : null === e ? "null" : e.inspect ? e.inspect() : String(e)
		} catch (t) {
			if (t instanceof RangeError) return "...";
			throw t
		}
	}

	function i(e) {
		return r("", {
			"": e
		}, [])
	}

	function r(t, n, i) {
		var o = n[t],
			a = typeof o;
		e(o) === C && "function" == typeof o.toJSON && (o = o.toJSON(t));
		var s = b.call(o);
		switch (s) {
			case O:
			case S:
			case D:
				o = o.valueOf()
		}
		switch (o) {
			case null:
				return "null";
			case !0:
				return "true";
			case !1:
				return "false"
		}
		switch (a = typeof o) {
			case "string":
				return o.inspect(!0);
			case "number":
				return isFinite(o) ? String(o) : "null";
			case "object":
				for (var l = 0, c = i.length; c > l; l++)
					if (i[l] === o) throw new TypeError;
				i.push(o);
				var u = [];
				if (s === A) {
					for (var l = 0, c = o.length; c > l; l++) {
						var d = r(l, o, i);
						u.push("undefined" == typeof d ? "null" : d)
					}
					u = "[" + u.join(",") + "]"
				} else {
					for (var h = Object.keys(o), l = 0, c = h.length; c > l; l++) {
						var t = h[l],
							d = r(t, o, i);
						"undefined" != typeof d && u.push(t.inspect(!0) + ":" + d)
					}
					u = "{" + u.join(",") + "}"
				}
				return i.pop(), u
		}
	}

	function o(e) {
		return JSON.stringify(e)
	}

	function a(e) {
		return $H(e).toQueryString()
	}

	function s(e) {
		return e && e.toHTML ? e.toHTML() : String.interpret(e)
	}

	function l(t) {
		if (e(t) !== C) throw new TypeError;
		var n = [];
		for (var i in t) t.hasOwnProperty(i) && n.push(i);
		return n
	}

	function c(e) {
		var t = [];
		for (var n in e) t.push(e[n]);
		return t
	}

	function u(e) {
		return t({}, e)
	}

	function d(e) {
		return !(!e || 1 != e.nodeType)
	}

	function h(e) {
		return b.call(e) === A
	}

	function p(e) {
		return e instanceof Hash
	}

	function f(e) {
		return b.call(e) === T
	}

	function g(e) {
		return b.call(e) === D
	}

	function m(e) {
		return b.call(e) === O
	}

	function v(e) {
		return b.call(e) === N
	}

	function _(e) {
		return "undefined" == typeof e
	}
	var b = Object.prototype.toString,
		y = "Null",
		w = "Undefined",
		x = "Boolean",
		E = "Number",
		k = "String",
		C = "Object",
		T = "[object Function]",
		S = "[object Boolean]",
		O = "[object Number]",
		D = "[object String]",
		A = "[object Array]",
		N = "[object Date]",
		I = window.JSON && "function" == typeof JSON.stringify && "0" === JSON.stringify(0) && "undefined" == typeof JSON.stringify(Prototype.K),
		j = "function" == typeof Array.isArray && Array.isArray([]) && !Array.isArray({});
	j && (h = Array.isArray), t(Object, {
		extend: t,
		inspect: n,
		toJSON: I ? o : i,
		toQueryString: a,
		toHTML: s,
		keys: Object.keys || l,
		values: c,
		clone: u,
		isElement: d,
		isArray: h,
		isHash: p,
		isFunction: f,
		isString: g,
		isNumber: m,
		isDate: v,
		isUndefined: _
	})
}(), Object.extend(Function.prototype, function() {
	function e(e, t) {
		for (var n = e.length, i = t.length; i--;) e[n + i] = t[i];
		return e
	}

	function t(t, n) {
		return t = u.call(t, 0), e(t, n)
	}

	function n() {
		var e = this.toString().match(/^[\s\(]*function[^(]*\(([^)]*)\)/)[1].replace(/\/\/.*?[\r\n]|\/\*(?:.|[\r\n])*?\*\//g, "").replace(/\s+/g, "").split(",");
		return 1 != e.length || e[0] ? e : []
	}

	function i(e) {
		if (arguments.length < 2 && Object.isUndefined(arguments[0])) return this;
		var n = this,
			i = u.call(arguments, 1);
		return function() {
			var r = t(i, arguments);
			return n.apply(e, r)
		}
	}

	function r(t) {
		var n = this,
			i = u.call(arguments, 1);
		return function(r) {
			var o = e([r || window.event], i);
			return n.apply(t, o)
		}
	}

	function o() {
		if (!arguments.length) return this;
		var e = this,
			n = u.call(arguments, 0);
		return function() {
			var i = t(n, arguments);
			return e.apply(this, i)
		}
	}

	function a(e) {
		var t = this,
			n = u.call(arguments, 1);
		return e = 1e3 * e, window.setTimeout(function() {
			return t.apply(t, n)
		}, e)
	}

	function s() {
		var t = e([.01], arguments);
		return this.delay.apply(this, t)
	}

	function l(t) {
		var n = this;
		return function() {
			var i = e([n.bind(this)], arguments);
			return t.apply(this, i)
		}
	}

	function c() {
		if (this._methodized) return this._methodized;
		var t = this;
		return this._methodized = function() {
			var n = e([this], arguments);
			return t.apply(null, n)
		}
	}
	var u = Array.prototype.slice;
	return {
		argumentNames: n,
		bind: i,
		bindAsEventListener: r,
		curry: o,
		delay: a,
		defer: s,
		wrap: l,
		methodize: c
	}
}()),
	function(e) {
		function t() {
			return this.getUTCFullYear() + "-" + (this.getUTCMonth() + 1).toPaddedString(2) + "-" + this.getUTCDate().toPaddedString(2) + "T" + this.getUTCHours().toPaddedString(2) + ":" + this.getUTCMinutes().toPaddedString(2) + ":" + this.getUTCSeconds().toPaddedString(2) + "Z"
		}

		function n() {
			return this.toISOString()
		}
		e.toISOString || (e.toISOString = t), e.toJSON || (e.toJSON = n)
	}(Date.prototype), RegExp.prototype.match = RegExp.prototype.test, RegExp.escape = function(e) {
	return String(e).replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
};
var PeriodicalExecuter = Class.create({
	initialize: function(e, t) {
		this.callback = e, this.frequency = t, this.currentlyExecuting = !1, this.registerCallback()
	},
	registerCallback: function() {
		this.timer = setInterval(this.onTimerEvent.bind(this), 1e3 * this.frequency)
	},
	execute: function() {
		this.callback(this)
	},
	stop: function() {
		this.timer && (clearInterval(this.timer), this.timer = null)
	},
	onTimerEvent: function() {
		if (!this.currentlyExecuting) try {
			this.currentlyExecuting = !0, this.execute(), this.currentlyExecuting = !1
		} catch (e) {
			throw this.currentlyExecuting = !1, e
		}
	}
});
Object.extend(String, {
	interpret: function(e) {
		return null == e ? "" : String(e)
	},
	specialChar: {
		"\b": "\\b",
		"	": "\\t",
		"\n": "\\n",
		"\f": "\\f",
		"\r": "\\r",
		"\\": "\\\\"
	}
}), Object.extend(String.prototype, function() {
	function prepareReplacement(e) {
		if (Object.isFunction(e)) return e;
		var t = new Template(e);
		return function(e) {
			return t.evaluate(e)
		}
	}

	function gsub(e, t) {
		var n, i = "",
			r = this;
		if (t = prepareReplacement(t), Object.isString(e) && (e = RegExp.escape(e)), !e.length && !e.source) return t = t(""), t + r.split("").join(t) + t;
		for (; r.length > 0;)(n = r.match(e)) ? (i += r.slice(0, n.index), i += String.interpret(t(n)), r = r.slice(n.index + n[0].length)) : (i += r, r = "");
		return i
	}

	function sub(e, t, n) {
		return t = prepareReplacement(t), n = Object.isUndefined(n) ? 1 : n, this.gsub(e, function(e) {
			return --n < 0 ? e[0] : t(e)
		})
	}

	function scan(e, t) {
		return this.gsub(e, t), String(this)
	}

	function truncate(e, t) {
		return e = e || 30, t = Object.isUndefined(t) ? "..." : t, this.length > e ? this.slice(0, e - t.length) + t : String(this)
	}

	function strip() {
		return this.replace(/^\s+/, "").replace(/\s+$/, "")
	}

	function stripTags() {
		return this.replace(/<\w+(\s+("[^"]*"|'[^']*'|[^>])+)?>|<\/\w+>/gi, "")
	}

	function stripScripts() {
		return this.replace(new RegExp(Prototype.ScriptFragment, "img"), "")
	}

	function extractScripts() {
		var e = new RegExp(Prototype.ScriptFragment, "img"),
			t = new RegExp(Prototype.ScriptFragment, "im");
		return (this.match(e) || []).map(function(e) {
			return (e.match(t) || ["", ""])[1]
		})
	}

	function evalScripts() {
		return this.extractScripts().map(function(script) {
			return eval(script)
		})
	}

	function escapeHTML() {
		return this.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
	}

	function unescapeHTML() {
		return this.stripTags().replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&")
	}

	function toQueryParams(e) {
		var t = this.strip().match(/([^?#]*)(#.*)?$/);
		return t ? t[1].split(e || "&").inject({}, function(e, t) {
			if ((t = t.split("="))[0]) {
				var n = decodeURIComponent(t.shift()),
					i = t.length > 1 ? t.join("=") : t[0];
				void 0 != i && (i = decodeURIComponent(i)), n in e ? (Object.isArray(e[n]) || (e[n] = [e[n]]), e[n].push(i)) : e[n] = i
			}
			return e
		}) : {}
	}

	function toArray() {
		return this.split("")
	}

	function succ() {
		return this.slice(0, this.length - 1) + String.fromCharCode(this.charCodeAt(this.length - 1) + 1)
	}

	function times(e) {
		return 1 > e ? "" : new Array(e + 1).join(this)
	}

	function camelize() {
		return this.replace(/-+(.)?/g, function(e, t) {
			return t ? t.toUpperCase() : ""
		})
	}

	function capitalize() {
		return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()
	}

	function underscore() {
		return this.replace(/::/g, "/").replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2").replace(/([a-z\d])([A-Z])/g, "$1_$2").replace(/-/g, "_").toLowerCase()
	}

	function dasherize() {
		return this.replace(/_/g, "-")
	}

	function inspect(e) {
		var t = this.replace(/[\x00-\x1f\\]/g, function(e) {
			return e in String.specialChar ? String.specialChar[e] : "\\u00" + e.charCodeAt().toPaddedString(2, 16)
		});
		return e ? '"' + t.replace(/"/g, '\\"') + '"' : "'" + t.replace(/'/g, "\\'") + "'"
	}

	function unfilterJSON(e) {
		return this.replace(e || Prototype.JSONFilter, "$1")
	}

	function isJSON() {
		var e = this;
		return e.blank() ? !1 : (e = e.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@"), e = e.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]"), e = e.replace(/(?:^|:|,)(?:\s*\[)+/g, ""), /^[\],:{}\s]*$/.test(e))
	}

	function evalJSON(sanitize) {
		var json = this.unfilterJSON(),
			cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
		cx.test(json) && (json = json.replace(cx, function(e) {
			return "\\u" + ("0000" + e.charCodeAt(0).toString(16)).slice(-4)
		}));
		try {
			if (!sanitize || json.isJSON()) return eval("(" + json + ")")
		} catch (e) {}
		throw new SyntaxError("Badly formed JSON string: " + this.inspect())
	}

	function parseJSON() {
		var e = this.unfilterJSON();
		return JSON.parse(e)
	}

	function include(e) {
		return this.indexOf(e) > -1
	}

	function startsWith(e) {
		return 0 === this.lastIndexOf(e, 0)
	}

	function endsWith(e) {
		var t = this.length - e.length;
		return t >= 0 && this.indexOf(e, t) === t
	}

	function empty() {
		return "" == this
	}

	function blank() {
		return /^\s*$/.test(this)
	}

	function interpolate(e, t) {
		return new Template(this, t).evaluate(e)
	}
	var NATIVE_JSON_PARSE_SUPPORT = window.JSON && "function" == typeof JSON.parse && JSON.parse('{"test": true}').test;
	return {
		gsub: gsub,
		sub: sub,
		scan: scan,
		truncate: truncate,
		strip: String.prototype.trim || strip,
		stripTags: stripTags,
		stripScripts: stripScripts,
		extractScripts: extractScripts,
		evalScripts: evalScripts,
		escapeHTML: escapeHTML,
		unescapeHTML: unescapeHTML,
		toQueryParams: toQueryParams,
		parseQuery: toQueryParams,
		toArray: toArray,
		succ: succ,
		times: times,
		camelize: camelize,
		capitalize: capitalize,
		underscore: underscore,
		dasherize: dasherize,
		inspect: inspect,
		unfilterJSON: unfilterJSON,
		isJSON: isJSON,
		evalJSON: NATIVE_JSON_PARSE_SUPPORT ? parseJSON : evalJSON,
		include: include,
		startsWith: startsWith,
		endsWith: endsWith,
		empty: empty,
		blank: blank,
		interpolate: interpolate
	}
}());
var Template = Class.create({
	initialize: function(e, t) {
		this.template = e.toString(), this.pattern = t || Template.Pattern
	},
	evaluate: function(e) {
		return e && Object.isFunction(e.toTemplateReplacements) && (e = e.toTemplateReplacements()), this.template.gsub(this.pattern, function(t) {
			if (null == e) return t[1] + "";
			var n = t[1] || "";
			if ("\\" == n) return t[2];
			var i = e,
				r = t[3],
				o = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
			if (t = o.exec(r), null == t) return n;
			for (; null != t;) {
				var a = t[1].startsWith("[") ? t[2].replace(/\\\\]/g, "]") : t[1];
				if (i = i[a], null == i || "" == t[3]) break;
				r = r.substring("[" == t[3] ? t[1].length : t[0].length), t = o.exec(r)
			}
			return n + String.interpret(i)
		})
	}
});
Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;
var $break = {},
	Enumerable = function() {
		function e(e, t) {
			var n = 0;
			try {
				this._each(function(i) {
					e.call(t, i, n++)
				})
			} catch (i) {
				if (i != $break) throw i
			}
			return this
		}

		function t(e, t, n) {
			var i = -e,
				r = [],
				o = this.toArray();
			if (1 > e) return o;
			for (;
				(i += e) < o.length;) r.push(o.slice(i, i + e));
			return r.collect(t, n)
		}

		function n(e, t) {
			e = e || Prototype.K;
			var n = !0;
			return this.each(function(i, r) {
				if (n = n && !!e.call(t, i, r), !n) throw $break
			}), n
		}

		function i(e, t) {
			e = e || Prototype.K;
			var n = !1;
			return this.each(function(i, r) {
				if (n = !!e.call(t, i, r)) throw $break
			}), n
		}

		function r(e, t) {
			e = e || Prototype.K;
			var n = [];
			return this.each(function(i, r) {
				n.push(e.call(t, i, r))
			}), n
		}

		function o(e, t) {
			var n;
			return this.each(function(i, r) {
				if (e.call(t, i, r)) throw n = i, $break
			}), n
		}

		function a(e, t) {
			var n = [];
			return this.each(function(i, r) {
				e.call(t, i, r) && n.push(i)
			}), n
		}

		function s(e, t, n) {
			t = t || Prototype.K;
			var i = [];
			return Object.isString(e) && (e = new RegExp(RegExp.escape(e))), this.each(function(r, o) {
				e.match(r) && i.push(t.call(n, r, o))
			}), i
		}

		function l(e) {
			if (Object.isFunction(this.indexOf) && -1 != this.indexOf(e)) return !0;
			var t = !1;
			return this.each(function(n) {
				if (n == e) throw t = !0, $break
			}), t
		}

		function c(e, t) {
			return t = Object.isUndefined(t) ? null : t, this.eachSlice(e, function(n) {
				for (; n.length < e;) n.push(t);
				return n
			})
		}

		function u(e, t, n) {
			return this.each(function(i, r) {
				e = t.call(n, e, i, r)
			}), e
		}

		function d(e) {
			var t = $A(arguments).slice(1);
			return this.map(function(n) {
				return n[e].apply(n, t)
			})
		}

		function h(e, t) {
			e = e || Prototype.K;
			var n;
			return this.each(function(i, r) {
				i = e.call(t, i, r), (null == n || i >= n) && (n = i)
			}), n
		}

		function p(e, t) {
			e = e || Prototype.K;
			var n;
			return this.each(function(i, r) {
				i = e.call(t, i, r), (null == n || n > i) && (n = i)
			}), n
		}

		function f(e, t) {
			e = e || Prototype.K;
			var n = [],
				i = [];
			return this.each(function(r, o) {
				(e.call(t, r, o) ? n : i).push(r)
			}), [n, i]
		}

		function g(e) {
			var t = [];
			return this.each(function(n) {
				t.push(n[e])
			}), t
		}

		function m(e, t) {
			var n = [];
			return this.each(function(i, r) {
				e.call(t, i, r) || n.push(i)
			}), n
		}

		function v(e, t) {
			return this.map(function(n, i) {
				return {
					value: n,
					criteria: e.call(t, n, i)
				}
			}).sort(function(e, t) {
				var n = e.criteria,
					i = t.criteria;
				return i > n ? -1 : n > i ? 1 : 0
			}).pluck("value")
		}

		function _() {
			return this.map()
		}

		function b() {
			var e = Prototype.K,
				t = $A(arguments);
			Object.isFunction(t.last()) && (e = t.pop());
			var n = [this].concat(t).map($A);
			return this.map(function(t, i) {
				return e(n.pluck(i))
			})
		}

		function y() {
			return this.toArray().length
		}

		function w() {
			return "#<Enumerable:" + this.toArray().inspect() + ">"
		}
		return {
			each: e,
			eachSlice: t,
			all: n,
			every: n,
			any: i,
			some: i,
			collect: r,
			map: r,
			detect: o,
			findAll: a,
			select: a,
			filter: a,
			grep: s,
			include: l,
			member: l,
			inGroupsOf: c,
			inject: u,
			invoke: d,
			max: h,
			min: p,
			partition: f,
			pluck: g,
			reject: m,
			sortBy: v,
			toArray: _,
			entries: _,
			zip: b,
			size: y,
			inspect: w,
			find: o
		}
	}();
Array.from = $A,
	function() {
		function e(e, t) {
			for (var n = 0, i = this.length >>> 0; i > n; n++) n in this && e.call(t, this[n], n, this)
		}

		function t() {
			return this.length = 0, this
		}

		function n() {
			return this[0]
		}

		function i() {
			return this[this.length - 1]
		}

		function r() {
			return this.select(function(e) {
				return null != e
			})
		}

		function o() {
			return this.inject([], function(e, t) {
				return Object.isArray(t) ? e.concat(t.flatten()) : (e.push(t), e)
			})
		}

		function a() {
			var e = v.call(arguments, 0);
			return this.select(function(t) {
				return !e.include(t)
			})
		}

		function s(e) {
			return (e === !1 ? this.toArray() : this)._reverse()
		}

		function l(e) {
			return this.inject([], function(t, n, i) {
				return 0 != i && (e ? t.last() == n : t.include(n)) || t.push(n), t
			})
		}

		function c(e) {
			return this.uniq().findAll(function(t) {
				return e.detect(function(e) {
					return t === e
				})
			})
		}

		function u() {
			return v.call(this, 0)
		}

		function d() {
			return this.length
		}

		function h() {
			return "[" + this.map(Object.inspect).join(", ") + "]"
		}

		function p(e, t) {
			t || (t = 0);
			var n = this.length;
			for (0 > t && (t = n + t); n > t; t++)
				if (this[t] === e) return t;
			return -1
		}

		function f(e, t) {
			t = isNaN(t) ? this.length : (0 > t ? this.length + t : t) + 1;
			var n = this.slice(0, t).reverse().indexOf(e);
			return 0 > n ? n : t - n - 1
		}

		function g() {
			for (var e, t = v.call(this, 0), n = 0, i = arguments.length; i > n; n++)
				if (e = arguments[n], !Object.isArray(e) || "callee" in e) t.push(e);
				else
					for (var r = 0, o = e.length; o > r; r++) t.push(e[r]);
			return t
		}
		var m = Array.prototype,
			v = m.slice,
			_ = m.forEach;
		_ || (_ = e), Object.extend(m, Enumerable), m._reverse || (m._reverse = m.reverse), Object.extend(m, {
			_each: _,
			clear: t,
			first: n,
			last: i,
			compact: r,
			flatten: o,
			without: a,
			reverse: s,
			uniq: l,
			intersect: c,
			clone: u,
			toArray: u,
			size: d,
			inspect: h
		});
		var b = function() {
			return 1 !== [].concat(arguments)[0][0]
		}(1, 2);
		b && (m.concat = g), m.indexOf || (m.indexOf = p), m.lastIndexOf || (m.lastIndexOf = f)
	}();
var Hash = Class.create(Enumerable, function() {
	function e(e) {
		this._object = Object.isHash(e) ? e.toObject() : Object.clone(e)
	}

	function t(e) {
		for (var t in this._object) {
			var n = this._object[t],
				i = [t, n];
			i.key = t, i.value = n, e(i)
		}
	}

	function n(e, t) {
		return this._object[e] = t
	}

	function i(e) {
		return this._object[e] !== Object.prototype[e] ? this._object[e] : void 0
	}

	function r(e) {
		var t = this._object[e];
		return delete this._object[e], t
	}

	function o() {
		return Object.clone(this._object)
	}

	function a() {
		return this.pluck("key")
	}

	function s() {
		return this.pluck("value")
	}

	function l(e) {
		var t = this.detect(function(t) {
			return t.value === e
		});
		return t && t.key
	}

	function c(e) {
		return this.clone().update(e)
	}

	function u(e) {
		return new Hash(e).inject(this, function(e, t) {
			return e.set(t.key, t.value), e
		})
	}

	function d(e, t) {
		return Object.isUndefined(t) ? e : e + "=" + encodeURIComponent(String.interpret(t))
	}

	function h() {
		return this.inject([], function(e, t) {
			var n = encodeURIComponent(t.key),
				i = t.value;
			if (i && "object" == typeof i) {
				if (Object.isArray(i)) {
					for (var r, o = [], a = 0, s = i.length; s > a; a++) r = i[a], o.push(d(n, r));
					return e.concat(o)
				}
			} else e.push(d(n, i));
			return e
		}).join("&")
	}

	function p() {
		return "#<Hash:{" + this.map(function(e) {
			return e.map(Object.inspect).join(": ")
		}).join(", ") + "}>"
	}

	function f() {
		return new Hash(this)
	}
	return {
		initialize: e,
		_each: t,
		set: n,
		get: i,
		unset: r,
		toObject: o,
		toTemplateReplacements: o,
		keys: a,
		values: s,
		index: l,
		merge: c,
		update: u,
		toQueryString: h,
		inspect: p,
		toJSON: o,
		clone: f
	}
}());
Hash.from = $H, Object.extend(Number.prototype, function() {
	function e() {
		return this.toPaddedString(2, 16)
	}

	function t() {
		return this + 1
	}

	function n(e, t) {
		return $R(0, this, !0).each(e, t), this
	}

	function i(e, t) {
		var n = this.toString(t || 10);
		return "0".times(e - n.length) + n
	}

	function r() {
		return Math.abs(this)
	}

	function o() {
		return Math.round(this)
	}

	function a() {
		return Math.ceil(this)
	}

	function s() {
		return Math.floor(this)
	}
	return {
		toColorPart: e,
		succ: t,
		times: n,
		toPaddedString: i,
		abs: r,
		round: o,
		ceil: a,
		floor: s
	}
}());
var ObjectRange = Class.create(Enumerable, function() {
		function e(e, t, n) {
			this.start = e, this.end = t, this.exclusive = n
		}

		function t(e) {
			for (var t = this.start; this.include(t);) e(t), t = t.succ()
		}

		function n(e) {
			return e < this.start ? !1 : this.exclusive ? e < this.end : e <= this.end
		}
		return {
			initialize: e,
			_each: t,
			include: n
		}
	}()),
	Ajax = {
		getTransport: function() {
			return Try.these(function() {
				return new XMLHttpRequest
			}, function() {
				return new ActiveXObject("Msxml2.XMLHTTP")
			}, function() {
				return new ActiveXObject("Microsoft.XMLHTTP")
			}) || !1
		},
		activeRequestCount: 0
	};
if (Ajax.Responders = {
	responders: [],
	_each: function(e) {
		this.responders._each(e)
	},
	register: function(e) {
		this.include(e) || this.responders.push(e)
	},
	unregister: function(e) {
		this.responders = this.responders.without(e)
	},
	dispatch: function(e, t, n, i) {
		this.each(function(r) {
			if (Object.isFunction(r[e])) try {
				r[e].apply(r, [t, n, i])
			} catch (o) {}
		})
	}
}, Object.extend(Ajax.Responders, Enumerable), Ajax.Responders.register({
	onCreate: function() {
		Ajax.activeRequestCount++
	},
	onComplete: function() {
		Ajax.activeRequestCount--
	}
}), Ajax.Base = Class.create({
	initialize: function(e) {
		this.options = {
			method: "post",
			asynchronous: !0,
			contentType: "application/x-www-form-urlencoded",
			encoding: "UTF-8",
			parameters: "",
			evalJSON: !0,
			evalJS: !0
		}, Object.extend(this.options, e || {}), this.options.method = this.options.method.toLowerCase(), Object.isHash(this.options.parameters) && (this.options.parameters = this.options.parameters.toObject())
	}
}), Ajax.Request = Class.create(Ajax.Base, {
	_complete: !1,
	initialize: function($super, e, t) {
		$super(t), this.transport = Ajax.getTransport(), this.request(e)
	},
	request: function(e) {
		this.url = e, this.method = this.options.method;
		var t = Object.isString(this.options.parameters) ? this.options.parameters : Object.toQueryString(this.options.parameters);
		["get", "post"].include(this.method) || (t += (t ? "&" : "") + "_method=" + this.method, this.method = "post"), t && "get" === this.method && (this.url += (this.url.include("?") ? "&" : "?") + t), this.parameters = t.toQueryParams();
		try {
			var n = new Ajax.Response(this);
			this.options.onCreate && this.options.onCreate(n), Ajax.Responders.dispatch("onCreate", this, n), this.transport.open(this.method.toUpperCase(), this.url, this.options.asynchronous), this.options.asynchronous && this.respondToReadyState.bind(this).defer(1), this.transport.onreadystatechange = this.onStateChange.bind(this), this.setRequestHeaders(), this.body = "post" == this.method ? this.options.postBody || t : null, this.transport.send(this.body), !this.options.asynchronous && this.transport.overrideMimeType && this.onStateChange()
		} catch (i) {
			this.dispatchException(i)
		}
	},
	onStateChange: function() {
		var e = this.transport.readyState;
		e > 1 && (4 != e || !this._complete) && this.respondToReadyState(this.transport.readyState)
	},
	setRequestHeaders: function() {
		var e = {
			"X-Requested-With": "XMLHttpRequest",
			"X-Prototype-Version": Prototype.Version,
			Accept: "text/javascript, text/html, application/xml, text/xml, */*"
		};
		if ("post" == this.method && (e["Content-type"] = this.options.contentType + (this.options.encoding ? "; charset=" + this.options.encoding : ""), this.transport.overrideMimeType && (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0, 2005])[1] < 2005 && (e.Connection = "close")), "object" == typeof this.options.requestHeaders) {
			var t = this.options.requestHeaders;
			if (Object.isFunction(t.push))
				for (var n = 0, i = t.length; i > n; n += 2) e[t[n]] = t[n + 1];
			else $H(t).each(function(t) {
				e[t.key] = t.value
			})
		}
		for (var r in e) this.transport.setRequestHeader(r, e[r])
	},
	success: function() {
		var e = this.getStatus();
		return !e || e >= 200 && 300 > e || 304 == e
	},
	getStatus: function() {
		try {
			return 1223 === this.transport.status ? 204 : this.transport.status || 0
		} catch (e) {
			return 0
		}
	},
	respondToReadyState: function(e) {
		var t = Ajax.Request.Events[e],
			n = new Ajax.Response(this);
		if ("Complete" == t) {
			try {
				this._complete = !0, (this.options["on" + n.status] || this.options["on" + (this.success() ? "Success" : "Failure")] || Prototype.emptyFunction)(n, n.headerJSON)
			} catch (i) {
				this.dispatchException(i)
			}
			var r = n.getHeader("Content-type");
			("force" == this.options.evalJS || this.options.evalJS && this.isSameOrigin() && r && r.match(/^\s*(text|application)\/(x-)?(java|ecma)script(;.*)?\s*$/i)) && this.evalResponse()
		}
		try {
			(this.options["on" + t] || Prototype.emptyFunction)(n, n.headerJSON), Ajax.Responders.dispatch("on" + t, this, n, n.headerJSON)
		} catch (i) {
			this.dispatchException(i)
		}
		"Complete" == t && (this.transport.onreadystatechange = Prototype.emptyFunction)
	},
	isSameOrigin: function() {
		var e = this.url.match(/^\s*https?:\/\/[^\/]*/);
		return !e || e[0] == "#{protocol}//#{domain}#{port}".interpolate({
			protocol: location.protocol,
			domain: document.domain,
			port: location.port ? ":" + location.port : ""
		})
	},
	getHeader: function(e) {
		try {
			return this.transport.getResponseHeader(e) || null
		} catch (t) {
			return null
		}
	},
	evalResponse: function() {
		try {
			return eval((this.transport.responseText || "").unfilterJSON())
		} catch (e) {
			this.dispatchException(e)
		}
	},
	dispatchException: function(e) {
		(this.options.onException || Prototype.emptyFunction)(this, e), Ajax.Responders.dispatch("onException", this, e)
	}
}), Ajax.Request.Events = ["Uninitialized", "Loading", "Loaded", "Interactive", "Complete"], Ajax.Response = Class.create({
	initialize: function(e) {
		this.request = e;
		var t = this.transport = e.transport,
			n = this.readyState = t.readyState;
		if ((n > 2 && !Prototype.Browser.IE || 4 == n) && (this.status = this.getStatus(), this.statusText = this.getStatusText(), this.responseText = String.interpret(t.responseText), this.headerJSON = this._getHeaderJSON()), 4 == n) {
			var i = t.responseXML;
			this.responseXML = Object.isUndefined(i) ? null : i, this.responseJSON = this._getResponseJSON()
		}
	},
	status: 0,
	statusText: "",
	getStatus: Ajax.Request.prototype.getStatus,
	getStatusText: function() {
		try {
			return this.transport.statusText || ""
		} catch (e) {
			return ""
		}
	},
	getHeader: Ajax.Request.prototype.getHeader,
	getAllHeaders: function() {
		try {
			return this.getAllResponseHeaders()
		} catch (e) {
			return null
		}
	},
	getResponseHeader: function(e) {
		return this.transport.getResponseHeader(e)
	},
	getAllResponseHeaders: function() {
		return this.transport.getAllResponseHeaders()
	},
	_getHeaderJSON: function() {
		var e = this.getHeader("X-JSON");
		if (!e) return null;
		e = decodeURIComponent(escape(e));
		try {
			return e.evalJSON(this.request.options.sanitizeJSON || !this.request.isSameOrigin())
		} catch (t) {
			this.request.dispatchException(t)
		}
	},
	_getResponseJSON: function() {
		var e = this.request.options;
		if (!e.evalJSON || "force" != e.evalJSON && !(this.getHeader("Content-type") || "").include("application/json") || this.responseText.blank()) return null;
		try {
			return this.responseText.evalJSON(e.sanitizeJSON || !this.request.isSameOrigin())
		} catch (t) {
			this.request.dispatchException(t)
		}
	}
}), Ajax.Updater = Class.create(Ajax.Request, {
	initialize: function($super, e, t, n) {
		this.container = {
			success: e.success || e,
			failure: e.failure || (e.success ? null : e)
		}, n = Object.clone(n);
		var i = n.onComplete;
		n.onComplete = function(e, t) {
			this.updateContent(e.responseText), Object.isFunction(i) && i(e, t)
		}.bind(this), $super(t, n)
	},
	updateContent: function(e) {
		var t = this.container[this.success() ? "success" : "failure"],
			n = this.options;
		if (n.evalScripts || (e = e.stripScripts()), t = $(t))
			if (n.insertion)
				if (Object.isString(n.insertion)) {
					var i = {};
					i[n.insertion] = e, t.insert(i)
				} else n.insertion(t, e);
			else t.update(e)
	}
}), Ajax.PeriodicalUpdater = Class.create(Ajax.Base, {
	initialize: function($super, e, t, n) {
		$super(n), this.onComplete = this.options.onComplete, this.frequency = this.options.frequency || 2, this.decay = this.options.decay || 1, this.updater = {}, this.container = e, this.url = t, this.start()
	},
	start: function() {
		this.options.onComplete = this.updateComplete.bind(this), this.onTimerEvent()
	},
	stop: function() {
		this.updater.options.onComplete = void 0, clearTimeout(this.timer), (this.onComplete || Prototype.emptyFunction).apply(this, arguments)
	},
	updateComplete: function(e) {
		this.options.decay && (this.decay = e.responseText == this.lastText ? this.decay * this.options.decay : 1, this.lastText = e.responseText), this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency)
	},
	onTimerEvent: function() {
		this.updater = new Ajax.Updater(this.container, this.url, this.options)
	}
}), Prototype.BrowserFeatures.XPath && (document._getElementsByXPath = function(e, t) {
	for (var n = [], i = document.evaluate(e, $(t) || document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null), r = 0, o = i.snapshotLength; o > r; r++) n.push(Element.extend(i.snapshotItem(r)));
	return n
}), !Node) var Node = {};
Node.ELEMENT_NODE || Object.extend(Node, {
	ELEMENT_NODE: 1,
	ATTRIBUTE_NODE: 2,
	TEXT_NODE: 3,
	CDATA_SECTION_NODE: 4,
	ENTITY_REFERENCE_NODE: 5,
	ENTITY_NODE: 6,
	PROCESSING_INSTRUCTION_NODE: 7,
	COMMENT_NODE: 8,
	DOCUMENT_NODE: 9,
	DOCUMENT_TYPE_NODE: 10,
	DOCUMENT_FRAGMENT_NODE: 11,
	NOTATION_NODE: 12
}),
	function(e) {
		function t(e, t) {
			return "select" === e ? !1 : "type" in t ? !1 : !0
		}
		var n = function() {
				try {
					var e = document.createElement('<input name="x">');
					return "input" === e.tagName.toLowerCase() && "x" === e.name
				} catch (t) {
					return !1
				}
			}(),
			i = e.Element;
		e.Element = function(e, i) {
			i = i || {}, e = e.toLowerCase();
			var r = Element.cache;
			if (n && i.name) return e = "<" + e + ' name="' + i.name + '">', delete i.name, Element.writeAttribute(document.createElement(e), i);
			r[e] || (r[e] = Element.extend(document.createElement(e)));
			var o = t(e, i) ? r[e].cloneNode(!1) : document.createElement(e);
			return Element.writeAttribute(o, i)
		}, Object.extend(e.Element, i || {}), i && (e.Element.prototype = i.prototype)
	}(this), Element.idCounter = 1, Element.cache = {}, Element._purgeElement = function(e) {
	var t = e._prototypeUID;
	t && (Element.stopObserving(e), e._prototypeUID = void 0, delete Element.Storage[t])
}, Element.Methods = {
	visible: function(e) {
		return "none" != $(e).style.display
	},
	toggle: function(e) {
		return e = $(e), Element[Element.visible(e) ? "hide" : "show"](e), e
	},
	hide: function(e) {
		return e = $(e), e.style.display = "none", e
	},
	show: function(e) {
		return e = $(e), e.style.display = "", e
	},
	remove: function(e) {
		return e = $(e), e.parentNode.removeChild(e), e
	},
	update: function() {
		function e(e, t) {
			e = $(e);
			for (var n = Element._purgeElement, a = e.getElementsByTagName("*"), s = a.length; s--;) n(a[s]);
			if (t && t.toElement && (t = t.toElement()), Object.isElement(t)) return e.update().insert(t);
			t = Object.toHTML(t);
			var l = e.tagName.toUpperCase();
			if ("SCRIPT" === l && o) return e.text = t, e;
			if (r)
				if (l in Element._insertionTranslations.tags) {
					for (; e.firstChild;) e.removeChild(e.firstChild);
					Element._getContentFromAnonymousElement(l, t.stripScripts()).each(function(t) {
						e.appendChild(t)
					})
				} else if (i && Object.isString(t) && t.indexOf("<link") > -1) {
					for (; e.firstChild;) e.removeChild(e.firstChild);
					var c = Element._getContentFromAnonymousElement(l, t.stripScripts(), !0);
					c.each(function(t) {
						e.appendChild(t)
					})
				} else e.innerHTML = t.stripScripts();
			else e.innerHTML = t.stripScripts();
			return t.evalScripts.bind(t).defer(), e
		}
		var t = function() {
				var e = document.createElement("select"),
					t = !0;
				return e.innerHTML = '<option value="test">test</option>', e.options && e.options[0] && (t = "OPTION" !== e.options[0].nodeName.toUpperCase()), e = null, t
			}(),
			n = function() {
				try {
					var e = document.createElement("table");
					if (e && e.tBodies) {
						e.innerHTML = "<tbody><tr><td>test</td></tr></tbody>";
						var t = "undefined" == typeof e.tBodies[0];
						return e = null, t
					}
				} catch (n) {
					return !0
				}
			}(),
			i = function() {
				try {
					var e = document.createElement("div");
					e.innerHTML = "<link>";
					var t = 0 === e.childNodes.length;
					return e = null, t
				} catch (n) {
					return !0
				}
			}(),
			r = t || n || i,
			o = function() {
				var e = document.createElement("script"),
					t = !1;
				try {
					e.appendChild(document.createTextNode("")), t = !e.firstChild || e.firstChild && 3 !== e.firstChild.nodeType
				} catch (n) {
					t = !0
				}
				return e = null, t
			}();
		return e
	}(),
	replace: function(e, t) {
		if (e = $(e), t && t.toElement) t = t.toElement();
		else if (!Object.isElement(t)) {
			t = Object.toHTML(t);
			var n = e.ownerDocument.createRange();
			n.selectNode(e), t.evalScripts.bind(t).defer(), t = n.createContextualFragment(t.stripScripts())
		}
		return e.parentNode.replaceChild(t, e), e
	},
	insert: function(e, t) {
		e = $(e), (Object.isString(t) || Object.isNumber(t) || Object.isElement(t) || t && (t.toElement || t.toHTML)) && (t = {
			bottom: t
		});
		var n, i, r, o;
		for (var a in t) n = t[a], a = a.toLowerCase(), i = Element._insertionTranslations[a], n && n.toElement && (n = n.toElement()), Object.isElement(n) ? i(e, n) : (n = Object.toHTML(n), r = ("before" == a || "after" == a ? e.parentNode : e).tagName.toUpperCase(), o = Element._getContentFromAnonymousElement(r, n.stripScripts()), ("top" == a || "after" == a) && o.reverse(), o.each(i.curry(e)), n.evalScripts.bind(n).defer());
		return e
	},
	wrap: function(e, t, n) {
		return e = $(e), Object.isElement(t) ? $(t).writeAttribute(n || {}) : t = Object.isString(t) ? new Element(t, n) : new Element("div", t), e.parentNode && e.parentNode.replaceChild(t, e), t.appendChild(e), t
	},
	inspect: function(e) {
		e = $(e);
		var t = "<" + e.tagName.toLowerCase();
		return $H({
			id: "id",
			className: "class"
		}).each(function(n) {
			var i = n.first(),
				r = n.last(),
				o = (e[i] || "").toString();
			o && (t += " " + r + "=" + o.inspect(!0))
		}), t + ">"
	},
	recursivelyCollect: function(e, t, n) {
		e = $(e), n = n || -1;
		for (var i = [];
			 (e = e[t]) && (1 == e.nodeType && i.push(Element.extend(e)), i.length != n););
		return i
	},
	ancestors: function(e) {
		return Element.recursivelyCollect(e, "parentNode")
	},
	descendants: function(e) {
		return Element.select(e, "*")
	},
	firstDescendant: function(e) {
		for (e = $(e).firstChild; e && 1 != e.nodeType;) e = e.nextSibling;
		return $(e)
	},
	immediateDescendants: function(e) {
		for (var t = [], n = $(e).firstChild; n;) 1 === n.nodeType && t.push(Element.extend(n)), n = n.nextSibling;
		return t
	},
	previousSiblings: function(e) {
		return Element.recursivelyCollect(e, "previousSibling")
	},
	nextSiblings: function(e) {
		return Element.recursivelyCollect(e, "nextSibling")
	},
	siblings: function(e) {
		return e = $(e), Element.previousSiblings(e).reverse().concat(Element.nextSiblings(e))
	},
	match: function(e, t) {
		return e = $(e), Object.isString(t) ? Prototype.Selector.match(e, t) : t.match(e)
	},
	up: function(e, t, n) {
		if (e = $(e), 1 == arguments.length) return $(e.parentNode);
		var i = Element.ancestors(e);
		return Object.isNumber(t) ? i[t] : Prototype.Selector.find(i, t, n)
	},
	down: function(e, t, n) {
		return e = $(e), 1 == arguments.length ? Element.firstDescendant(e) : Object.isNumber(t) ? Element.descendants(e)[t] : Element.select(e, t)[n || 0]
	},
	previous: function(e, t, n) {
		return e = $(e), Object.isNumber(t) && (n = t, t = !1), Object.isNumber(n) || (n = 0), t ? Prototype.Selector.find(e.previousSiblings(), t, n) : e.recursivelyCollect("previousSibling", n + 1)[n]
	},
	next: function(e, t, n) {
		if (e = $(e), Object.isNumber(t) && (n = t, t = !1), Object.isNumber(n) || (n = 0), t) return Prototype.Selector.find(e.nextSiblings(), t, n);
		Object.isNumber(n) ? n + 1 : 1;
		return e.recursivelyCollect("nextSibling", n + 1)[n]
	},
	select: function(e) {
		e = $(e);
		var t = Array.prototype.slice.call(arguments, 1).join(", ");
		return Prototype.Selector.select(t, e)
	},
	adjacent: function(e) {
		e = $(e);
		var t = Array.prototype.slice.call(arguments, 1).join(", ");
		return Prototype.Selector.select(t, e.parentNode).without(e)
	},
	identify: function(e) {
		e = $(e);
		var t = Element.readAttribute(e, "id");
		if (t) return t;
		do t = "anonymous_element_" + Element.idCounter++; while ($(t));
		return Element.writeAttribute(e, "id", t), t
	},
	readAttribute: function(e, t) {
		if (e = $(e), Prototype.Browser.IE) {
			var n = Element._attributeTranslations.read;
			if (n.values[t]) return n.values[t](e, t);
			if (n.names[t] && (t = n.names[t]), t.include(":")) return e.attributes && e.attributes[t] ? e.attributes[t].value : null
		}
		return e.getAttribute(t)
	},
	writeAttribute: function(e, t, n) {
		e = $(e);
		var i = {},
			r = Element._attributeTranslations.write;
		"object" == typeof t ? i = t : i[t] = Object.isUndefined(n) ? !0 : n;
		for (var o in i) t = r.names[o] || o, n = i[o], r.values[o] && (t = r.values[o](e, n)), n === !1 || null === n ? e.removeAttribute(t) : n === !0 ? e.setAttribute(t, t) : e.setAttribute(t, n);
		return e
	},
	getHeight: function(e) {
		return Element.getDimensions(e).height
	},
	getWidth: function(e) {
		return Element.getDimensions(e).width
	},
	classNames: function(e) {
		return new Element.ClassNames(e)
	},
	hasClassName: function(e, t) {
		if (e = $(e)) {
			var n = e.className;
			return n.length > 0 && (n == t || new RegExp("(^|\\s)" + t + "(\\s|$)").test(n))
		}
	},
	addClassName: function(e, t) {
		return (e = $(e)) ? (Element.hasClassName(e, t) || (e.className += (e.className ? " " : "") + t), e) : void 0
	},
	removeClassName: function(e, t) {
		return (e = $(e)) ? (e.className = e.className.replace(new RegExp("(^|\\s+)" + t + "(\\s+|$)"), " ").strip(), e) : void 0
	},
	toggleClassName: function(e, t) {
		return (e = $(e)) ? Element[Element.hasClassName(e, t) ? "removeClassName" : "addClassName"](e, t) : void 0
	},
	cleanWhitespace: function(e) {
		e = $(e);
		for (var t = e.firstChild; t;) {
			var n = t.nextSibling;
			3 != t.nodeType || /\S/.test(t.nodeValue) || e.removeChild(t), t = n
		}
		return e
	},
	empty: function(e) {
		return $(e).innerHTML.blank()
	},
	descendantOf: function(e, t) {
		if (e = $(e), t = $(t), e.compareDocumentPosition) return 8 === (8 & e.compareDocumentPosition(t));
		if (t.contains) return t.contains(e) && t !== e;
		for (; e = e.parentNode;)
			if (e == t) return !0;
		return !1
	},
	scrollTo: function(e) {
		e = $(e);
		var t = Element.cumulativeOffset(e);
		return window.scrollTo(t[0], t[1]), e
	},
	getStyle: function(e, t) {
		e = $(e), t = "float" == t ? "cssFloat" : t.camelize();
		var n = e.style[t];
		if (!n || "auto" == n) {
			var i = document.defaultView.getComputedStyle(e, null);
			n = i ? i[t] : null
		}
		return "opacity" == t ? n ? parseFloat(n) : 1 : "auto" == n ? null : n
	},
	getOpacity: function(e) {
		return $(e).getStyle("opacity")
	},
	setStyle: function(e, t) {
		e = $(e);
		var n = e.style;
		if (Object.isString(t)) return e.style.cssText += ";" + t, t.include("opacity") ? e.setOpacity(t.match(/opacity:\s*(\d?\.?\d*)/)[1]) : e;
		for (var i in t) "opacity" == i ? e.setOpacity(t[i]) : n["float" == i || "cssFloat" == i ? Object.isUndefined(n.styleFloat) ? "cssFloat" : "styleFloat" : i] = t[i];
		return e
	},
	setOpacity: function(e, t) {
		return e = $(e), e.style.opacity = 1 == t || "" === t ? "" : 1e-5 > t ? 0 : t, e
	},
	makePositioned: function(e) {
		e = $(e);
		var t = Element.getStyle(e, "position");
		return "static" != t && t || (e._madePositioned = !0, e.style.position = "relative", Prototype.Browser.Opera && (e.style.top = 0, e.style.left = 0)), e
	},
	undoPositioned: function(e) {
		return e = $(e), e._madePositioned && (e._madePositioned = void 0, e.style.position = e.style.top = e.style.left = e.style.bottom = e.style.right = ""), e
	},
	makeClipping: function(e) {
		return e = $(e), e._overflow ? e : (e._overflow = Element.getStyle(e, "overflow") || "auto", "hidden" !== e._overflow && (e.style.overflow = "hidden"), e)
	},
	undoClipping: function(e) {
		return e = $(e), e._overflow ? (e.style.overflow = "auto" == e._overflow ? "" : e._overflow, e._overflow = null, e) : e
	},
	clonePosition: function(e, t) {
		var n = Object.extend({
			setLeft: !0,
			setTop: !0,
			setWidth: !0,
			setHeight: !0,
			offsetTop: 0,
			offsetLeft: 0
		}, arguments[2] || {});
		t = $(t);
		var i = Element.viewportOffset(t),
			r = [0, 0],
			o = null;
		return e = $(e), "absolute" == Element.getStyle(e, "position") && (o = Element.getOffsetParent(e), r = Element.viewportOffset(o)), o == document.body && (r[0] -= document.body.offsetLeft, r[1] -= document.body.offsetTop), n.setLeft && (e.style.left = i[0] - r[0] + n.offsetLeft + "px"), n.setTop && (e.style.top = i[1] - r[1] + n.offsetTop + "px"), n.setWidth && (e.style.width = t.offsetWidth + "px"), n.setHeight && (e.style.height = t.offsetHeight + "px"), e
	}
}, Object.extend(Element.Methods, {
	getElementsBySelector: Element.Methods.select,
	childElements: Element.Methods.immediateDescendants
}), Element._attributeTranslations = {
	write: {
		names: {
			className: "class",
			htmlFor: "for"
		},
		values: {}
	}
}, Prototype.Browser.Opera ? (Element.Methods.getStyle = Element.Methods.getStyle.wrap(function(e, t, n) {
	switch (n) {
		case "height":
		case "width":
			if (!Element.visible(t)) return null;
			var i = parseInt(e(t, n), 10);
			if (i !== t["offset" + n.capitalize()]) return i + "px";
			var r;
			return r = "height" === n ? ["border-top-width", "padding-top", "padding-bottom", "border-bottom-width"] : ["border-left-width", "padding-left", "padding-right", "border-right-width"], r.inject(i, function(n, i) {
				var r = e(t, i);
				return null === r ? n : n - parseInt(r, 10)
			}) + "px";
		default:
			return e(t, n)
	}
}), Element.Methods.readAttribute = Element.Methods.readAttribute.wrap(function(e, t, n) {
	return "title" === n ? t.title : e(t, n)
})) : Prototype.Browser.IE ? (Element.Methods.getStyle = function(e, t) {
	e = $(e), t = "float" == t || "cssFloat" == t ? "styleFloat" : t.camelize();
	var n = e.style[t];
	return !n && e.currentStyle && (n = e.currentStyle[t]), "opacity" == t ? (n = (e.getStyle("filter") || "").match(/alpha\(opacity=(.*)\)/)) && n[1] ? parseFloat(n[1]) / 100 : 1 : "auto" == n ? "width" != t && "height" != t || "none" == e.getStyle("display") ? null : e["offset" + t.capitalize()] + "px" : n
}, Element.Methods.setOpacity = function(e, t) {
	function n(e) {
		return e.replace(/alpha\([^\)]*\)/gi, "")
	}
	e = $(e);
	var i = e.currentStyle;
	(i && !i.hasLayout || !i && "normal" == e.style.zoom) && (e.style.zoom = 1);
	var r = e.getStyle("filter"),
		o = e.style;
	return 1 == t || "" === t ? ((r = n(r)) ? o.filter = r : o.removeAttribute("filter"), e) : (1e-5 > t && (t = 0), o.filter = n(r) + "alpha(opacity=" + 100 * t + ")", e)
}, Element._attributeTranslations = function() {
	var e = "className",
		t = "for",
		n = document.createElement("div");
	return n.setAttribute(e, "x"), "x" !== n.className && (n.setAttribute("class", "x"), "x" === n.className && (e = "class")), n = null, n = document.createElement("label"), n.setAttribute(t, "x"), "x" !== n.htmlFor && (n.setAttribute("htmlFor", "x"), "x" === n.htmlFor && (t = "htmlFor")), n = null, {
		read: {
			names: {
				"class": e,
				className: e,
				"for": t,
				htmlFor: t
			},
			values: {
				_getAttr: function(e, t) {
					return e.getAttribute(t)
				},
				_getAttr2: function(e, t) {
					return e.getAttribute(t, 2)
				},
				_getAttrNode: function(e, t) {
					var n = e.getAttributeNode(t);
					return n ? n.value : ""
				},
				_getEv: function() {
					var e, t = document.createElement("div");
					t.onclick = Prototype.emptyFunction;
					var n = t.getAttribute("onclick");
					return String(n).indexOf("{") > -1 ? e = function(e, t) {
						return (t = e.getAttribute(t)) ? (t = t.toString(), t = t.split("{")[1], t = t.split("}")[0], t.strip()) : null
					} : "" === n && (e = function(e, t) {
						return t = e.getAttribute(t), t ? t.strip() : null
					}), t = null, e
				}(),
				_flag: function(e, t) {
					return $(e).hasAttribute(t) ? t : null
				},
				style: function(e) {
					return e.style.cssText.toLowerCase()
				},
				title: function(e) {
					return e.title
				}
			}
		}
	}
}(), Element._attributeTranslations.write = {
	names: Object.extend({
		cellpadding: "cellPadding",
		cellspacing: "cellSpacing"
	}, Element._attributeTranslations.read.names),
	values: {
		checked: function(e, t) {
			e.checked = !!t
		},
		style: function(e, t) {
			e.style.cssText = t ? t : ""
		}
	}
}, Element._attributeTranslations.has = {}, $w("colSpan rowSpan vAlign dateTime accessKey tabIndex encType maxLength readOnly longDesc frameBorder").each(function(e) {
	Element._attributeTranslations.write.names[e.toLowerCase()] = e, Element._attributeTranslations.has[e.toLowerCase()] = e
}), function(e) {
	Object.extend(e, {
		href: e._getAttr2,
		src: e._getAttr2,
		type: e._getAttr,
		action: e._getAttrNode,
		disabled: e._flag,
		checked: e._flag,
		readonly: e._flag,
		multiple: e._flag,
		onload: e._getEv,
		onunload: e._getEv,
		onclick: e._getEv,
		ondblclick: e._getEv,
		onmousedown: e._getEv,
		onmouseup: e._getEv,
		onmouseover: e._getEv,
		onmousemove: e._getEv,
		onmouseout: e._getEv,
		onfocus: e._getEv,
		onblur: e._getEv,
		onkeypress: e._getEv,
		onkeydown: e._getEv,
		onkeyup: e._getEv,
		onsubmit: e._getEv,
		onreset: e._getEv,
		onselect: e._getEv,
		onchange: e._getEv
	})
}(Element._attributeTranslations.read.values), Prototype.BrowserFeatures.ElementExtensions && ! function() {
	function e(e) {
		for (var t, n = e.getElementsByTagName("*"), i = [], r = 0; t = n[r]; r++) "!" !== t.tagName && i.push(t);
		return i
	}
	Element.Methods.down = function(t, n, i) {
		return t = $(t), 1 == arguments.length ? t.firstDescendant() : Object.isNumber(n) ? e(t)[n] : Element.select(t, n)[i || 0]
	}
}()) : Prototype.Browser.Gecko && /rv:1\.8\.0/.test(navigator.userAgent) ? Element.Methods.setOpacity = function(e, t) {
	return e = $(e), e.style.opacity = 1 == t ? .999999 : "" === t ? "" : 1e-5 > t ? 0 : t, e
} : Prototype.Browser.WebKit && (Element.Methods.setOpacity = function(e, t) {
	if (e = $(e), e.style.opacity = 1 == t || "" === t ? "" : 1e-5 > t ? 0 : t, 1 == t)
		if ("IMG" == e.tagName.toUpperCase() && e.width) e.width++, e.width--;
		else try {
			var n = document.createTextNode(" ");
			e.appendChild(n), e.removeChild(n)
		} catch (i) {}
	return e
}), "outerHTML" in document.documentElement && (Element.Methods.replace = function(e, t) {
	if (e = $(e), t && t.toElement && (t = t.toElement()), Object.isElement(t)) return e.parentNode.replaceChild(t, e), e;
	t = Object.toHTML(t);
	var n = e.parentNode,
		i = n.tagName.toUpperCase();
	if (Element._insertionTranslations.tags[i]) {
		var r = e.next(),
			o = Element._getContentFromAnonymousElement(i, t.stripScripts());
		n.removeChild(e), o.each(r ? function(e) {
			n.insertBefore(e, r)
		} : function(e) {
			n.appendChild(e)
		})
	} else e.outerHTML = t.stripScripts();
	return t.evalScripts.bind(t).defer(), e
}), Element._returnOffset = function(e, t) {
	var n = [e, t];
	return n.left = e, n.top = t, n
}, Element._getContentFromAnonymousElement = function(e, t, n) {
	var i = new Element("div"),
		r = Element._insertionTranslations.tags[e],
		o = !1;
	if (r ? o = !0 : n && (o = !0, r = ["", "", 0]), o) {
		i.innerHTML = "&nbsp;" + r[0] + t + r[1], i.removeChild(i.firstChild);
		for (var a = r[2]; a--;) i = i.firstChild
	} else i.innerHTML = t;
	return $A(i.childNodes)
}, Element._insertionTranslations = {
	before: function(e, t) {
		e.parentNode.insertBefore(t, e)
	},
	top: function(e, t) {
		e.insertBefore(t, e.firstChild)
	},
	bottom: function(e, t) {
		e.appendChild(t)
	},
	after: function(e, t) {
		e.parentNode.insertBefore(t, e.nextSibling)
	},
	tags: {
		TABLE: ["<table>", "</table>", 1],
		TBODY: ["<table><tbody>", "</tbody></table>", 2],
		TR: ["<table><tbody><tr>", "</tr></tbody></table>", 3],
		TD: ["<table><tbody><tr><td>", "</td></tr></tbody></table>", 4],
		SELECT: ["<select>", "</select>", 1]
	}
},
	function() {
		var e = Element._insertionTranslations.tags;
		Object.extend(e, {
			THEAD: e.TBODY,
			TFOOT: e.TBODY,
			TH: e.TD
		})
	}(), Element.Methods.Simulated = {
	hasAttribute: function(e, t) {
		t = Element._attributeTranslations.has[t] || t;
		var n = $(e).getAttributeNode(t);
		return !(!n || !n.specified)
	}
}, Element.Methods.ByTag = {}, Object.extend(Element, Element.Methods),
	function(e) {
		!Prototype.BrowserFeatures.ElementExtensions && e.__proto__ && (window.HTMLElement = {}, window.HTMLElement.prototype = e.__proto__, Prototype.BrowserFeatures.ElementExtensions = !0), e = null
	}(document.createElement("div")), Element.extend = function() {
	function e(e) {
		if ("undefined" != typeof window.Element) {
			var t = window.Element.prototype;
			if (t) {
				var n = "_" + (Math.random() + "").slice(2),
					i = document.createElement(e);
				t[n] = "x";
				var r = "x" !== i[n];
				return delete t[n], i = null, r
			}
		}
		return !1
	}

	function t(e, t) {
		for (var n in t) {
			var i = t[n];
			!Object.isFunction(i) || n in e || (e[n] = i.methodize())
		}
	}
	var n = e("object");
	if (Prototype.BrowserFeatures.SpecificElementExtensions) return n ? function(e) {
		if (e && "undefined" == typeof e._extendedByPrototype) {
			var n = e.tagName;
			n && /^(?:object|applet|embed)$/i.test(n) && (t(e, Element.Methods), t(e, Element.Methods.Simulated), t(e, Element.Methods.ByTag[n.toUpperCase()]))
		}
		return e
	} : Prototype.K;
	var i = {},
		r = Element.Methods.ByTag,
		o = Object.extend(function(e) {
			if (!e || "undefined" != typeof e._extendedByPrototype || 1 != e.nodeType || e == window) return e;
			var n = Object.clone(i),
				o = e.tagName.toUpperCase();
			return r[o] && Object.extend(n, r[o]), t(e, n), e._extendedByPrototype = Prototype.emptyFunction, e
		}, {
			refresh: function() {
				Prototype.BrowserFeatures.ElementExtensions || (Object.extend(i, Element.Methods), Object.extend(i, Element.Methods.Simulated))
			}
		});
	return o.refresh(), o
}(), Element.hasAttribute = document.documentElement.hasAttribute ? function(e, t) {
	return e.hasAttribute(t)
} : Element.Methods.Simulated.hasAttribute, Element.addMethods = function(e) {
	function t(t) {
		t = t.toUpperCase(), Element.Methods.ByTag[t] || (Element.Methods.ByTag[t] = {}), Object.extend(Element.Methods.ByTag[t], e)
	}

	function n(e, t, n) {
		n = n || !1;
		for (var i in e) {
			var r = e[i];
			Object.isFunction(r) && (n && i in t || (t[i] = r.methodize()))
		}
	}

	function i(e) {
		var t, n = {
			OPTGROUP: "OptGroup",
			TEXTAREA: "TextArea",
			P: "Paragraph",
			FIELDSET: "FieldSet",
			UL: "UList",
			OL: "OList",
			DL: "DList",
			DIR: "Directory",
			H1: "Heading",
			H2: "Heading",
			H3: "Heading",
			H4: "Heading",
			H5: "Heading",
			H6: "Heading",
			Q: "Quote",
			INS: "Mod",
			DEL: "Mod",
			A: "Anchor",
			IMG: "Image",
			CAPTION: "TableCaption",
			COL: "TableCol",
			COLGROUP: "TableCol",
			THEAD: "TableSection",
			TFOOT: "TableSection",
			TBODY: "TableSection",
			TR: "TableRow",
			TH: "TableCell",
			TD: "TableCell",
			FRAMESET: "FrameSet",
			IFRAME: "IFrame"
		};
		if (n[e] && (t = "HTML" + n[e] + "Element"), window[t]) return window[t];
		if (t = "HTML" + e + "Element", window[t]) return window[t];
		if (t = "HTML" + e.capitalize() + "Element", window[t]) return window[t];
		var i = document.createElement(e),
			r = i.__proto__ || i.constructor.prototype;
		return i = null, r
	}
	var r = Prototype.BrowserFeatures,
		o = Element.Methods.ByTag;
	if (e || (Object.extend(Form, Form.Methods), Object.extend(Form.Element, Form.Element.Methods), Object.extend(Element.Methods.ByTag, {
		FORM: Object.clone(Form.Methods),
		INPUT: Object.clone(Form.Element.Methods),
		SELECT: Object.clone(Form.Element.Methods),
		TEXTAREA: Object.clone(Form.Element.Methods),
		BUTTON: Object.clone(Form.Element.Methods)
	})), 2 == arguments.length) {
		var a = e;
		e = arguments[1]
	}
	a ? Object.isArray(a) ? a.each(t) : t(a) : Object.extend(Element.Methods, e || {});
	var s = window.HTMLElement ? HTMLElement.prototype : Element.prototype;
	if (r.ElementExtensions && (n(Element.Methods, s), n(Element.Methods.Simulated, s, !0)), r.SpecificElementExtensions)
		for (var l in Element.Methods.ByTag) {
			var c = i(l);
			Object.isUndefined(c) || n(o[l], c.prototype)
		}
	Object.extend(Element, Element.Methods), delete Element.ByTag, Element.extend.refresh && Element.extend.refresh(), Element.cache = {}
}, document.viewport = {
	getDimensions: function() {
		return {
			width: this.getWidth(),
			height: this.getHeight()
		}
	},
	getScrollOffsets: function() {
		return Element._returnOffset(window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft, window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop)
	}
},
	function(e) {
		function t() {
			return r.WebKit && !o.evaluate ? document : r.Opera && window.parseFloat(window.opera.version()) < 9.5 ? document.body : document.documentElement
		}

		function n(n) {
			return i || (i = t()), a[n] = "client" + n, e["get" + n] = function() {
				return i[a[n]]
			}, e["get" + n]()
		}
		var i, r = Prototype.Browser,
			o = document,
			a = {};
		e.getWidth = n.curry("Width"), e.getHeight = n.curry("Height")
	}(document.viewport), Element.Storage = {
	UID: 1
}, Element.addMethods({
	getStorage: function(e) {
		if (e = $(e)) {
			var t;
			return e === window ? t = 0 : ("undefined" == typeof e._prototypeUID && (e._prototypeUID = Element.Storage.UID++), t = e._prototypeUID), Element.Storage[t] || (Element.Storage[t] = $H()), Element.Storage[t]
		}
	},
	store: function(e, t, n) {
		return (e = $(e)) ? (2 === arguments.length ? Element.getStorage(e).update(t) : Element.getStorage(e).set(t, n), e) : void 0
	},
	retrieve: function(e, t, n) {
		if (e = $(e)) {
			var i = Element.getStorage(e),
				r = i.get(t);
			return Object.isUndefined(r) && (i.set(t, n), r = n), r
		}
	},
	clone: function(e, t) {
		if (e = $(e)) {
			var n = e.cloneNode(t);
			if (n._prototypeUID = void 0, t)
				for (var i = Element.select(n, "*"), r = i.length; r--;) i[r]._prototypeUID = void 0;
			return Element.extend(n)
		}
	},
	purge: function(e) {
		if (e = $(e)) {
			var t = Element._purgeElement;
			t(e);
			for (var n = e.getElementsByTagName("*"), i = n.length; i--;) t(n[i]);
			return null
		}
	}
}),
	function() {
		function e(e) {
			var t = e.match(/^(\d+)%?$/i);
			return t ? Number(t[1]) / 100 : null
		}

		function t(t, n, i) {
			var r = null;
			if (Object.isElement(t) && (r = t, t = r.getStyle(n)), null === t) return null;
			if (/^(?:-)?\d+(\.\d+)?(px)?$/i.test(t)) return window.parseFloat(t);
			var o = t.include("%"),
				a = i === document.viewport;
			if (/\d/.test(t) && r && r.runtimeStyle && (!o || !a)) {
				var s = r.style.left,
					l = r.runtimeStyle.left;
				return r.runtimeStyle.left = r.currentStyle.left, r.style.left = t || 0, t = r.style.pixelLeft, r.style.left = s, r.runtimeStyle.left = l, t
			}
			if (r && o) {
				i = i || r.parentNode;
				var c = e(t),
					u = null,
					d = (r.getStyle("position"), n.include("left") || n.include("right") || n.include("width")),
					h = n.include("top") || n.include("bottom") || n.include("height");
				return i === document.viewport ? d ? u = document.viewport.getWidth() : h && (u = document.viewport.getHeight()) : d ? u = $(i).measure("width") : h && (u = $(i).measure("height")), null === u ? 0 : u * c
			}
			return 0
		}

		function n(e) {
			for (; e && e.parentNode;) {
				var t = e.getStyle("display");
				if ("none" === t) return !1;
				e = $(e.parentNode)
			}
			return !0
		}

		function i(e) {
			return e.include("border") && (e += "-width"), e.camelize()
		}

		function r(e, t) {
			return new Element.Layout(e, t)
		}

		function o(e, t) {
			return $(e).getLayout().get(t)
		}

		function a(e) {
			e = $(e);
			var t = Element.getStyle(e, "display");
			if (t && "none" !== t) return {
				width: e.offsetWidth,
				height: e.offsetHeight
			};
			var n = e.style,
				i = {
					visibility: n.visibility,
					position: n.position,
					display: n.display
				},
				r = {
					visibility: "hidden",
					display: "block"
				};
			"fixed" !== i.position && (r.position = "absolute"), Element.setStyle(e, r);
			var o = {
				width: e.offsetWidth,
				height: e.offsetHeight
			};
			return Element.setStyle(e, i), o
		}

		function s(e) {
			if (e = $(e), m(e) || v(e) || f(e) || g(e)) return $(document.body);
			var t = "inline" === Element.getStyle(e, "display");
			if (!t && e.offsetParent) return $(e.offsetParent);
			for (;
				(e = e.parentNode) && e !== document.body;)
				if ("static" !== Element.getStyle(e, "position")) return $(g(e) ? document.body : e);
			return $(document.body)
		}

		function l(e) {
			e = $(e);
			var t = 0,
				n = 0;
			if (e.parentNode)
				do t += e.offsetTop || 0, n += e.offsetLeft || 0, e = e.offsetParent; while (e);
			return new Element.Offset(n, t)
		}

		function c(e) {
			e = $(e);
			var t = e.getLayout(),
				n = 0,
				i = 0;
			do
				if (n += e.offsetTop || 0, i += e.offsetLeft || 0, e = e.offsetParent) {
					if (f(e)) break;
					var r = Element.getStyle(e, "position");
					if ("static" !== r) break
				}
			while (e);
			return i -= t.get("margin-top"), n -= t.get("margin-left"), new Element.Offset(i, n)
		}

		function u(e) {
			var t = 0,
				n = 0;
			do t += e.scrollTop || 0, n += e.scrollLeft || 0, e = e.parentNode; while (e);
			return new Element.Offset(n, t)
		}

		function d(e) {
			r = $(r);
			var t = 0,
				n = 0,
				i = document.body,
				r = e;
			do
				if (t += r.offsetTop || 0, n += r.offsetLeft || 0, r.offsetParent == i && "absolute" == Element.getStyle(r, "position")) break;
			while (r = r.offsetParent);
			r = e;
			do r != i && (t -= r.scrollTop || 0, n -= r.scrollLeft || 0); while (r = r.parentNode);
			return new Element.Offset(n, t)
		}

		function h(e) {
			if (e = $(e), "absolute" === Element.getStyle(e, "position")) return e;
			var t = s(e),
				n = e.viewportOffset(),
				i = t.viewportOffset(),
				r = n.relativeTo(i),
				o = e.getLayout();
			return e.store("prototype_absolutize_original_styles", {
				left: e.getStyle("left"),
				top: e.getStyle("top"),
				width: e.getStyle("width"),
				height: e.getStyle("height")
			}), e.setStyle({
				position: "absolute",
				top: r.top + "px",
				left: r.left + "px",
				width: o.get("width") + "px",
				height: o.get("height") + "px"
			}), e
		}

		function p(e) {
			if (e = $(e), "relative" === Element.getStyle(e, "position")) return e;
			var t = e.retrieve("prototype_absolutize_original_styles");
			return t && e.setStyle(t), e
		}

		function f(e) {
			return "BODY" === e.nodeName.toUpperCase()
		}

		function g(e) {
			return "HTML" === e.nodeName.toUpperCase()
		}

		function m(e) {
			return e.nodeType === Node.DOCUMENT_NODE
		}

		function v(e) {
			return e !== document.body && !Element.descendantOf(e, document.body)
		}
		var _ = Prototype.K;
		"currentStyle" in document.documentElement && (_ = function(e) {
			return e.currentStyle.hasLayout || (e.style.zoom = 1), e
		}), Element.Layout = Class.create(Hash, {
			initialize: function($super, e, t) {
				$super(), this.element = $(e), Element.Layout.PROPERTIES.each(function(e) {
					this._set(e, null)
				}, this), t && (this._preComputing = !0, this._begin(), Element.Layout.PROPERTIES.each(this._compute, this), this._end(), this._preComputing = !1)
			},
			_set: function(e, t) {
				return Hash.prototype.set.call(this, e, t)
			},
			set: function() {
				throw "Properties of Element.Layout are read-only."
			},
			get: function($super, e) {
				var t = $super(e);
				return null === t ? this._compute(e) : t
			},
			_begin: function() {
				if (!this._prepared) {
					var e = this.element;
					if (n(e)) return void(this._prepared = !0);
					var i = {
						position: e.style.position || "",
						width: e.style.width || "",
						visibility: e.style.visibility || "",
						display: e.style.display || ""
					};
					e.store("prototype_original_styles", i);
					var r = e.getStyle("position"),
						o = e.getStyle("width");
					("0px" === o || null === o) && (e.style.display = "block", o = e.getStyle("width"));
					var a = "fixed" === r ? document.viewport : e.parentNode;
					e.setStyle({
						position: "absolute",
						visibility: "hidden",
						display: "block"
					});
					var s, l = e.getStyle("width");
					if (o && l === o) s = t(e, "width", a);
					else if ("absolute" === r || "fixed" === r) s = t(e, "width", a);
					else {
						var c = e.parentNode,
							u = $(c).getLayout();
						s = u.get("width") - this.get("margin-left") - this.get("border-left") - this.get("padding-left") - this.get("padding-right") - this.get("border-right") - this.get("margin-right")
					}
					e.setStyle({
						width: s + "px"
					}), this._prepared = !0
				}
			},
			_end: function() {
				var e = this.element,
					t = e.retrieve("prototype_original_styles");
				e.store("prototype_original_styles", null), e.setStyle(t), this._prepared = !1
			},
			_compute: function(e) {
				var t = Element.Layout.COMPUTATIONS;
				if (!(e in t)) throw "Property not found.";
				return this._set(e, t[e].call(this, this.element))
			},
			toObject: function() {
				var e = $A(arguments),
					t = 0 === e.length ? Element.Layout.PROPERTIES : e.join(" ").split(" "),
					n = {};
				return t.each(function(e) {
					if (Element.Layout.PROPERTIES.include(e)) {
						var t = this.get(e);
						null != t && (n[e] = t)
					}
				}, this), n
			},
			toHash: function() {
				var e = this.toObject.apply(this, arguments);
				return new Hash(e)
			},
			toCSS: function() {
				var e = $A(arguments),
					t = 0 === e.length ? Element.Layout.PROPERTIES : e.join(" ").split(" "),
					n = {};
				return t.each(function(e) {
					if (Element.Layout.PROPERTIES.include(e) && !Element.Layout.COMPOSITE_PROPERTIES.include(e)) {
						var t = this.get(e);
						null != t && (n[i(e)] = t + "px")
					}
				}, this), n
			},
			inspect: function() {
				return "#<Element.Layout>"
			}
		}), Object.extend(Element.Layout, {
			PROPERTIES: $w("height width top left right bottom border-left border-right border-top border-bottom padding-left padding-right padding-top padding-bottom margin-top margin-bottom margin-left margin-right padding-box-width padding-box-height border-box-width border-box-height margin-box-width margin-box-height"),
			COMPOSITE_PROPERTIES: $w("padding-box-width padding-box-height margin-box-width margin-box-height border-box-width border-box-height"),
			COMPUTATIONS: {
				height: function() {
					this._preComputing || this._begin();
					var e = this.get("border-box-height");
					if (0 >= e) return this._preComputing || this._end(), 0;
					var t = this.get("border-top"),
						n = this.get("border-bottom"),
						i = this.get("padding-top"),
						r = this.get("padding-bottom");
					return this._preComputing || this._end(), e - t - n - i - r
				},
				width: function() {
					this._preComputing || this._begin();
					var e = this.get("border-box-width");
					if (0 >= e) return this._preComputing || this._end(), 0;
					var t = this.get("border-left"),
						n = this.get("border-right"),
						i = this.get("padding-left"),
						r = this.get("padding-right");
					return this._preComputing || this._end(), e - t - n - i - r
				},
				"padding-box-height": function() {
					var e = this.get("height"),
						t = this.get("padding-top"),
						n = this.get("padding-bottom");
					return e + t + n
				},
				"padding-box-width": function() {
					var e = this.get("width"),
						t = this.get("padding-left"),
						n = this.get("padding-right");
					return e + t + n
				},
				"border-box-height": function(e) {
					this._preComputing || this._begin();
					var t = e.offsetHeight;
					return this._preComputing || this._end(), t
				},
				"border-box-width": function(e) {
					this._preComputing || this._begin();
					var t = e.offsetWidth;
					return this._preComputing || this._end(), t
				},
				"margin-box-height": function() {
					var e = this.get("border-box-height"),
						t = this.get("margin-top"),
						n = this.get("margin-bottom");
					return 0 >= e ? 0 : e + t + n
				},
				"margin-box-width": function() {
					var e = this.get("border-box-width"),
						t = this.get("margin-left"),
						n = this.get("margin-right");
					return 0 >= e ? 0 : e + t + n
				},
				top: function(e) {
					var t = e.positionedOffset();
					return t.top
				},
				bottom: function(e) {
					var t = e.positionedOffset(),
						n = e.getOffsetParent(),
						i = n.measure("height"),
						r = this.get("border-box-height");
					return i - r - t.top
				},
				left: function(e) {
					var t = e.positionedOffset();
					return t.left
				},
				right: function(e) {
					var t = e.positionedOffset(),
						n = e.getOffsetParent(),
						i = n.measure("width"),
						r = this.get("border-box-width");
					return i - r - t.left
				},
				"padding-top": function(e) {
					return t(e, "paddingTop")
				},
				"padding-bottom": function(e) {
					return t(e, "paddingBottom")
				},
				"padding-left": function(e) {
					return t(e, "paddingLeft")
				},
				"padding-right": function(e) {
					return t(e, "paddingRight")
				},
				"border-top": function(e) {
					return t(e, "borderTopWidth")
				},
				"border-bottom": function(e) {
					return t(e, "borderBottomWidth")
				},
				"border-left": function(e) {
					return t(e, "borderLeftWidth")
				},
				"border-right": function(e) {
					return t(e, "borderRightWidth")
				},
				"margin-top": function(e) {
					return t(e, "marginTop")
				},
				"margin-bottom": function(e) {
					return t(e, "marginBottom")
				},
				"margin-left": function(e) {
					return t(e, "marginLeft")
				},
				"margin-right": function(e) {
					return t(e, "marginRight")
				}
			}
		}), "getBoundingClientRect" in document.documentElement && Object.extend(Element.Layout.COMPUTATIONS, {
			right: function(e) {
				var t = _(e.getOffsetParent()),
					n = e.getBoundingClientRect(),
					i = t.getBoundingClientRect();
				return (i.right - n.right).round()
			},
			bottom: function(e) {
				var t = _(e.getOffsetParent()),
					n = e.getBoundingClientRect(),
					i = t.getBoundingClientRect();
				return (i.bottom - n.bottom).round()
			}
		}), Element.Offset = Class.create({
			initialize: function(e, t) {
				this.left = e.round(), this.top = t.round(), this[0] = this.left, this[1] = this.top
			},
			relativeTo: function(e) {
				return new Element.Offset(this.left - e.left, this.top - e.top)
			},
			inspect: function() {
				return "#<Element.Offset left: #{left} top: #{top}>".interpolate(this)
			},
			toString: function() {
				return "[#{left}, #{top}]".interpolate(this)
			},
			toArray: function() {
				return [this.left, this.top]
			}
		}), Prototype.Browser.IE ? (s = s.wrap(function(e, t) {
			if (t = $(t), m(t) || v(t) || f(t) || g(t)) return $(document.body);
			var n = t.getStyle("position");
			if ("static" !== n) return e(t);
			t.setStyle({
				position: "relative"
			});
			var i = e(t);
			return t.setStyle({
				position: n
			}), i
		}), c = c.wrap(function(e, t) {
			if (t = $(t), !t.parentNode) return new Element.Offset(0, 0);
			var n = t.getStyle("position");
			if ("static" !== n) return e(t);
			var i = t.getOffsetParent();
			i && "fixed" === i.getStyle("position") && _(i), t.setStyle({
				position: "relative"
			});
			var r = e(t);
			return t.setStyle({
				position: n
			}), r
		})) : Prototype.Browser.Webkit && (l = function(e) {
			e = $(e);
			var t = 0,
				n = 0;
			do {
				if (t += e.offsetTop || 0, n += e.offsetLeft || 0, e.offsetParent == document.body && "absolute" == Element.getStyle(e, "position")) break;
				e = e.offsetParent
			} while (e);
			return new Element.Offset(n, t)
		}), Element.addMethods({
			getLayout: r,
			measure: o,
			getDimensions: a,
			getOffsetParent: s,
			cumulativeOffset: l,
			positionedOffset: c,
			cumulativeScrollOffset: u,
			viewportOffset: d,
			absolutize: h,
			relativize: p
		}), "getBoundingClientRect" in document.documentElement && Element.addMethods({
			viewportOffset: function(e) {
				if (e = $(e), v(e)) return new Element.Offset(0, 0);
				var t = e.getBoundingClientRect(),
					n = document.documentElement;
				return new Element.Offset(t.left - n.clientLeft, t.top - n.clientTop)
			}
		})
	}(), window.$$ = function() {
	var e = $A(arguments).join(", ");
	return Prototype.Selector.select(e, document)
}, Prototype.Selector = function() {
	function e() {
		throw new Error('Method "Prototype.Selector.select" must be defined.')
	}

	function t() {
		throw new Error('Method "Prototype.Selector.match" must be defined.')
	}

	function n(e, t, n) {
		n = n || 0;
		var i, r = Prototype.Selector.match,
			o = e.length,
			a = 0;
		for (i = 0; o > i; i++)
			if (r(e[i], t) && n == a++) return Element.extend(e[i])
	}

	function i(e) {
		for (var t = 0, n = e.length; n > t; t++) Element.extend(e[t]);
		return e
	}
	var r = Prototype.K;
	return {
		select: e,
		match: t,
		find: n,
		extendElements: Element.extend === r ? r : i,
		extendElement: Element.extend
	}
}(), Prototype._original_property = window.Sizzle,
	/*!
	 * Sizzle CSS Selector Engine - v1.0
	 *  Copyright 2009, The Dojo Foundation
	 *  Released under the MIT, BSD, and GPL Licenses.
	 *  More information: http://sizzlejs.com/
	 */
	function() {
		function e(e, t, n, i, r, o) {
			for (var a = "previousSibling" == e && !o, s = 0, l = i.length; l > s; s++) {
				var c = i[s];
				if (c) {
					a && 1 === c.nodeType && (c.sizcache = n, c.sizset = s), c = c[e];
					for (var u = !1; c;) {
						if (c.sizcache === n) {
							u = i[c.sizset];
							break
						}
						if (1 !== c.nodeType || o || (c.sizcache = n, c.sizset = s), c.nodeName === t) {
							u = c;
							break
						}
						c = c[e]
					}
					i[s] = u
				}
			}
		}

		function t(e, t, n, i, r, o) {
			for (var a = "previousSibling" == e && !o, l = 0, c = i.length; c > l; l++) {
				var u = i[l];
				if (u) {
					a && 1 === u.nodeType && (u.sizcache = n, u.sizset = l), u = u[e];
					for (var d = !1; u;) {
						if (u.sizcache === n) {
							d = i[u.sizset];
							break
						}
						if (1 === u.nodeType)
							if (o || (u.sizcache = n, u.sizset = l), "string" != typeof t) {
								if (u === t) {
									d = !0;
									break
								}
							} else if (s.filter(t, [u]).length > 0) {
								d = u;
								break
							}
						u = u[e]
					}
					i[l] = d
				}
			}
		}
		var n = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,
			i = 0,
			r = Object.prototype.toString,
			o = !1,
			a = !0;
		[0, 0].sort(function() {
			return a = !1, 0
		});
		var s = function(e, t, i, o) {
			i = i || [];
			var a = t = t || document;
			if (1 !== t.nodeType && 9 !== t.nodeType) return [];
			if (!e || "string" != typeof e) return i;
			for (var u, h, p, v, _ = [], b = !0, y = g(t), w = e; null !== (n.exec(""), u = n.exec(w));)
				if (w = u[3], _.push(u[1]), u[2]) {
					v = u[3];
					break
				}
			if (_.length > 1 && c.exec(e))
				if (2 === _.length && l.relative[_[0]]) h = m(_[0] + _[1], t);
				else
					for (h = l.relative[_[0]] ? [t] : s(_.shift(), t); _.length;) e = _.shift(), l.relative[e] && (e += _.shift()), h = m(e, h);
			else {
				if (!o && _.length > 1 && 9 === t.nodeType && !y && l.match.ID.test(_[0]) && !l.match.ID.test(_[_.length - 1])) {
					var x = s.find(_.shift(), t, y);
					t = x.expr ? s.filter(x.expr, x.set)[0] : x.set[0]
				}
				if (t) {
					var x = o ? {
						expr: _.pop(),
						set: d(o)
					} : s.find(_.pop(), 1 !== _.length || "~" !== _[0] && "+" !== _[0] || !t.parentNode ? t : t.parentNode, y);
					for (h = x.expr ? s.filter(x.expr, x.set) : x.set, _.length > 0 ? p = d(h) : b = !1; _.length;) {
						var E = _.pop(),
							k = E;
						l.relative[E] ? k = _.pop() : E = "", null == k && (k = t), l.relative[E](p, k, y)
					}
				} else p = _ = []
			} if (p || (p = h), !p) throw "Syntax error, unrecognized expression: " + (E || e);
			if ("[object Array]" === r.call(p))
				if (b)
					if (t && 1 === t.nodeType)
						for (var C = 0; null != p[C]; C++) p[C] && (p[C] === !0 || 1 === p[C].nodeType && f(t, p[C])) && i.push(h[C]);
					else
						for (var C = 0; null != p[C]; C++) p[C] && 1 === p[C].nodeType && i.push(h[C]);
				else i.push.apply(i, p);
			else d(p, i);
			return v && (s(v, a, i, o), s.uniqueSort(i)), i
		};
		s.uniqueSort = function(e) {
			if (p && (o = a, e.sort(p), o))
				for (var t = 1; t < e.length; t++) e[t] === e[t - 1] && e.splice(t--, 1);
			return e
		}, s.matches = function(e, t) {
			return s(e, null, null, t)
		}, s.find = function(e, t, n) {
			var i, r;
			if (!e) return [];
			for (var o = 0, a = l.order.length; a > o; o++) {
				var r, s = l.order[o];
				if (r = l.leftMatch[s].exec(e)) {
					var c = r[1];
					if (r.splice(1, 1), "\\" !== c.substr(c.length - 1) && (r[1] = (r[1] || "").replace(/\\/g, ""), i = l.find[s](r, t, n), null != i)) {
						e = e.replace(l.match[s], "");
						break
					}
				}
			}
			return i || (i = t.getElementsByTagName("*")), {
				set: i,
				expr: e
			}
		}, s.filter = function(e, t, n, i) {
			for (var r, o, a = e, s = [], c = t, u = t && t[0] && g(t[0]); e && t.length;) {
				for (var d in l.filter)
					if (null != (r = l.match[d].exec(e))) {
						var h, p, f = l.filter[d];
						if (o = !1, c == s && (s = []), l.preFilter[d])
							if (r = l.preFilter[d](r, c, n, s, i, u)) {
								if (r === !0) continue
							} else o = h = !0;
						if (r)
							for (var m = 0; null != (p = c[m]); m++)
								if (p) {
									h = f(p, r, m, c);
									var v = i ^ !!h;
									n && null != h ? v ? o = !0 : c[m] = !1 : v && (s.push(p), o = !0)
								}
						if (void 0 !== h) {
							if (n || (c = s), e = e.replace(l.match[d], ""), !o) return [];
							break
						}
					}
				if (e == a) {
					if (null == o) throw "Syntax error, unrecognized expression: " + e;
					break
				}
				a = e
			}
			return c
		};
		var l = s.selectors = {
				order: ["ID", "NAME", "TAG"],
				match: {
					ID: /#((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
					CLASS: /\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
					NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/,
					ATTR: /\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,
					TAG: /^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/,
					CHILD: /:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/,
					POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/,
					PSEUDO: /:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]*)((?:\([^\)]+\)|[^\2\(\)]*)+)\2\))?/
				},
				leftMatch: {},
				attrMap: {
					"class": "className",
					"for": "htmlFor"
				},
				attrHandle: {
					href: function(e) {
						return e.getAttribute("href")
					}
				},
				relative: {
					"+": function(e, t, n) {
						var i = "string" == typeof t,
							r = i && !/\W/.test(t),
							o = i && !r;
						r && !n && (t = t.toUpperCase());
						for (var a, l = 0, c = e.length; c > l; l++)
							if (a = e[l]) {
								for (;
									(a = a.previousSibling) && 1 !== a.nodeType;);
								e[l] = o || a && a.nodeName === t ? a || !1 : a === t
							}
						o && s.filter(t, e, !0)
					},
					">": function(e, t, n) {
						var i = "string" == typeof t;
						if (i && !/\W/.test(t)) {
							t = n ? t : t.toUpperCase();
							for (var r = 0, o = e.length; o > r; r++) {
								var a = e[r];
								if (a) {
									var l = a.parentNode;
									e[r] = l.nodeName === t ? l : !1
								}
							}
						} else {
							for (var r = 0, o = e.length; o > r; r++) {
								var a = e[r];
								a && (e[r] = i ? a.parentNode : a.parentNode === t)
							}
							i && s.filter(t, e, !0)
						}
					},
					"": function(n, r, o) {
						var a = i++,
							s = t;
						if (!/\W/.test(r)) {
							var l = r = o ? r : r.toUpperCase();
							s = e
						}
						s("parentNode", r, a, n, l, o)
					},
					"~": function(n, r, o) {
						var a = i++,
							s = t;
						if ("string" == typeof r && !/\W/.test(r)) {
							var l = r = o ? r : r.toUpperCase();
							s = e
						}
						s("previousSibling", r, a, n, l, o)
					}
				},
				find: {
					ID: function(e, t, n) {
						if ("undefined" != typeof t.getElementById && !n) {
							var i = t.getElementById(e[1]);
							return i ? [i] : []
						}
					},
					NAME: function(e, t) {
						if ("undefined" != typeof t.getElementsByName) {
							for (var n = [], i = t.getElementsByName(e[1]), r = 0, o = i.length; o > r; r++) i[r].getAttribute("name") === e[1] && n.push(i[r]);
							return 0 === n.length ? null : n
						}
					},
					TAG: function(e, t) {
						return t.getElementsByTagName(e[1])
					}
				},
				preFilter: {
					CLASS: function(e, t, n, i, r, o) {
						if (e = " " + e[1].replace(/\\/g, "") + " ", o) return e;
						for (var a, s = 0; null != (a = t[s]); s++) a && (r ^ (a.className && (" " + a.className + " ").indexOf(e) >= 0) ? n || i.push(a) : n && (t[s] = !1));
						return !1
					},
					ID: function(e) {
						return e[1].replace(/\\/g, "")
					},
					TAG: function(e, t) {
						for (var n = 0; t[n] === !1; n++);
						return t[n] && g(t[n]) ? e[1] : e[1].toUpperCase()
					},
					CHILD: function(e) {
						if ("nth" == e[1]) {
							var t = /(-?)(\d*)n((?:\+|-)?\d*)/.exec("even" == e[2] && "2n" || "odd" == e[2] && "2n+1" || !/\D/.test(e[2]) && "0n+" + e[2] || e[2]);
							e[2] = t[1] + (t[2] || 1) - 0, e[3] = t[3] - 0
						}
						return e[0] = i++, e
					},
					ATTR: function(e, t, n, i, r, o) {
						var a = e[1].replace(/\\/g, "");
						return !o && l.attrMap[a] && (e[1] = l.attrMap[a]), "~=" === e[2] && (e[4] = " " + e[4] + " "), e
					},
					PSEUDO: function(e, t, i, r, o) {
						if ("not" === e[1]) {
							if (!((n.exec(e[3]) || "").length > 1 || /^\w/.test(e[3]))) {
								var a = s.filter(e[3], t, i, !0 ^ o);
								return i || r.push.apply(r, a), !1
							}
							e[3] = s(e[3], null, null, t)
						} else if (l.match.POS.test(e[0]) || l.match.CHILD.test(e[0])) return !0;
						return e
					},
					POS: function(e) {
						return e.unshift(!0), e
					}
				},
				filters: {
					enabled: function(e) {
						return e.disabled === !1 && "hidden" !== e.type
					},
					disabled: function(e) {
						return e.disabled === !0
					},
					checked: function(e) {
						return e.checked === !0
					},
					selected: function(e) {
						return e.parentNode.selectedIndex, e.selected === !0
					},
					parent: function(e) {
						return !!e.firstChild
					},
					empty: function(e) {
						return !e.firstChild
					},
					has: function(e, t, n) {
						return !!s(n[3], e).length
					},
					header: function(e) {
						return /h\d/i.test(e.nodeName)
					},
					text: function(e) {
						return "text" === e.type
					},
					radio: function(e) {
						return "radio" === e.type
					},
					checkbox: function(e) {
						return "checkbox" === e.type
					},
					file: function(e) {
						return "file" === e.type
					},
					password: function(e) {
						return "password" === e.type
					},
					submit: function(e) {
						return "submit" === e.type
					},
					image: function(e) {
						return "image" === e.type
					},
					reset: function(e) {
						return "reset" === e.type
					},
					button: function(e) {
						return "button" === e.type || "BUTTON" === e.nodeName.toUpperCase()
					},
					input: function(e) {
						return /input|select|textarea|button/i.test(e.nodeName)
					}
				},
				setFilters: {
					first: function(e, t) {
						return 0 === t
					},
					last: function(e, t, n, i) {
						return t === i.length - 1
					},
					even: function(e, t) {
						return t % 2 === 0
					},
					odd: function(e, t) {
						return t % 2 === 1
					},
					lt: function(e, t, n) {
						return t < n[3] - 0
					},
					gt: function(e, t, n) {
						return t > n[3] - 0
					},
					nth: function(e, t, n) {
						return n[3] - 0 == t
					},
					eq: function(e, t, n) {
						return n[3] - 0 == t
					}
				},
				filter: {
					PSEUDO: function(e, t, n, i) {
						var r = t[1],
							o = l.filters[r];
						if (o) return o(e, n, t, i);
						if ("contains" === r) return (e.textContent || e.innerText || "").indexOf(t[3]) >= 0;
						if ("not" === r) {
							for (var a = t[3], n = 0, s = a.length; s > n; n++)
								if (a[n] === e) return !1;
							return !0
						}
					},
					CHILD: function(e, t) {
						var n = t[1],
							i = e;
						switch (n) {
							case "only":
							case "first":
								for (; i = i.previousSibling;)
									if (1 === i.nodeType) return !1;
								if ("first" == n) return !0;
								i = e;
							case "last":
								for (; i = i.nextSibling;)
									if (1 === i.nodeType) return !1;
								return !0;
							case "nth":
								var r = t[2],
									o = t[3];
								if (1 == r && 0 == o) return !0;
								var a = t[0],
									s = e.parentNode;
								if (s && (s.sizcache !== a || !e.nodeIndex)) {
									var l = 0;
									for (i = s.firstChild; i; i = i.nextSibling) 1 === i.nodeType && (i.nodeIndex = ++l);
									s.sizcache = a
								}
								var c = e.nodeIndex - o;
								return 0 == r ? 0 == c : c % r == 0 && c / r >= 0
						}
					},
					ID: function(e, t) {
						return 1 === e.nodeType && e.getAttribute("id") === t
					},
					TAG: function(e, t) {
						return "*" === t && 1 === e.nodeType || e.nodeName === t
					},
					CLASS: function(e, t) {
						return (" " + (e.className || e.getAttribute("class")) + " ").indexOf(t) > -1
					},
					ATTR: function(e, t) {
						var n = t[1],
							i = l.attrHandle[n] ? l.attrHandle[n](e) : null != e[n] ? e[n] : e.getAttribute(n),
							r = i + "",
							o = t[2],
							a = t[4];
						return null == i ? "!=" === o : "=" === o ? r === a : "*=" === o ? r.indexOf(a) >= 0 : "~=" === o ? (" " + r + " ").indexOf(a) >= 0 : a ? "!=" === o ? r != a : "^=" === o ? 0 === r.indexOf(a) : "$=" === o ? r.substr(r.length - a.length) === a : "|=" === o ? r === a || r.substr(0, a.length + 1) === a + "-" : !1 : r && i !== !1
					},
					POS: function(e, t, n, i) {
						var r = t[2],
							o = l.setFilters[r];
						return o ? o(e, n, t, i) : void 0
					}
				}
			},
			c = l.match.POS;
		for (var u in l.match) l.match[u] = new RegExp(l.match[u].source + /(?![^\[]*\])(?![^\(]*\))/.source), l.leftMatch[u] = new RegExp(/(^(?:.|\r|\n)*?)/.source + l.match[u].source);
		var d = function(e, t) {
			return e = Array.prototype.slice.call(e, 0), t ? (t.push.apply(t, e), t) : e
		};
		try {
			Array.prototype.slice.call(document.documentElement.childNodes, 0)
		} catch (h) {
			d = function(e, t) {
				var n = t || [];
				if ("[object Array]" === r.call(e)) Array.prototype.push.apply(n, e);
				else if ("number" == typeof e.length)
					for (var i = 0, o = e.length; o > i; i++) n.push(e[i]);
				else
					for (var i = 0; e[i]; i++) n.push(e[i]);
				return n
			}
		}
		var p;
		document.documentElement.compareDocumentPosition ? p = function(e, t) {
			if (!e.compareDocumentPosition || !t.compareDocumentPosition) return e == t && (o = !0), 0;
			var n = 4 & e.compareDocumentPosition(t) ? -1 : e === t ? 0 : 1;
			return 0 === n && (o = !0), n
		} : "sourceIndex" in document.documentElement ? p = function(e, t) {
			if (!e.sourceIndex || !t.sourceIndex) return e == t && (o = !0), 0;
			var n = e.sourceIndex - t.sourceIndex;
			return 0 === n && (o = !0), n
		} : document.createRange && (p = function(e, t) {
			if (!e.ownerDocument || !t.ownerDocument) return e == t && (o = !0), 0;
			var n = e.ownerDocument.createRange(),
				i = t.ownerDocument.createRange();
			n.setStart(e, 0), n.setEnd(e, 0), i.setStart(t, 0), i.setEnd(t, 0);
			var r = n.compareBoundaryPoints(Range.START_TO_END, i);
			return 0 === r && (o = !0), r
		}),
			function() {
				var e = document.createElement("div"),
					t = "script" + (new Date).getTime();
				e.innerHTML = "<a name='" + t + "'/>";
				var n = document.documentElement;
				n.insertBefore(e, n.firstChild), document.getElementById(t) && (l.find.ID = function(e, t, n) {
					if ("undefined" != typeof t.getElementById && !n) {
						var i = t.getElementById(e[1]);
						return i ? i.id === e[1] || "undefined" != typeof i.getAttributeNode && i.getAttributeNode("id").nodeValue === e[1] ? [i] : void 0 : []
					}
				}, l.filter.ID = function(e, t) {
					var n = "undefined" != typeof e.getAttributeNode && e.getAttributeNode("id");
					return 1 === e.nodeType && n && n.nodeValue === t
				}), n.removeChild(e), n = e = null
			}(),
			function() {
				var e = document.createElement("div");
				e.appendChild(document.createComment("")), e.getElementsByTagName("*").length > 0 && (l.find.TAG = function(e, t) {
					var n = t.getElementsByTagName(e[1]);
					if ("*" === e[1]) {
						for (var i = [], r = 0; n[r]; r++) 1 === n[r].nodeType && i.push(n[r]);
						n = i
					}
					return n
				}), e.innerHTML = "<a href='#'></a>", e.firstChild && "undefined" != typeof e.firstChild.getAttribute && "#" !== e.firstChild.getAttribute("href") && (l.attrHandle.href = function(e) {
					return e.getAttribute("href", 2)
				}), e = null
			}(), document.querySelectorAll && function() {
			var e = s,
				t = document.createElement("div");
			if (t.innerHTML = "<p class='TEST'></p>", !t.querySelectorAll || 0 !== t.querySelectorAll(".TEST").length) {
				s = function(t, n, i, r) {
					if (n = n || document, !r && 9 === n.nodeType && !g(n)) try {
						return d(n.querySelectorAll(t), i)
					} catch (o) {}
					return e(t, n, i, r)
				};
				for (var n in e) s[n] = e[n];
				t = null
			}
		}(), document.getElementsByClassName && document.documentElement.getElementsByClassName && function() {
			var e = document.createElement("div");
			e.innerHTML = "<div class='test e'></div><div class='test'></div>", 0 !== e.getElementsByClassName("e").length && (e.lastChild.className = "e", 1 !== e.getElementsByClassName("e").length && (l.order.splice(1, 0, "CLASS"), l.find.CLASS = function(e, t, n) {
				return "undefined" == typeof t.getElementsByClassName || n ? void 0 : t.getElementsByClassName(e[1])
			}, e = null))
		}();
		var f = document.compareDocumentPosition ? function(e, t) {
				return 16 & e.compareDocumentPosition(t)
			} : function(e, t) {
				return e !== t && (e.contains ? e.contains(t) : !0)
			},
			g = function(e) {
				return 9 === e.nodeType && "HTML" !== e.documentElement.nodeName || !!e.ownerDocument && "HTML" !== e.ownerDocument.documentElement.nodeName
			},
			m = function(e, t) {
				for (var n, i = [], r = "", o = t.nodeType ? [t] : t; n = l.match.PSEUDO.exec(e);) r += n[0], e = e.replace(l.match.PSEUDO, "");
				e = l.relative[e] ? e + "*" : e;
				for (var a = 0, c = o.length; c > a; a++) s(e, o[a], i);
				return s.filter(r, i)
			};
		window.Sizzle = s
	}(),
	function(e) {
		function t(t, n) {
			return i(e(t, n || document))
		}

		function n(t, n) {
			return 1 == e.matches(n, [t]).length
		}
		var i = Prototype.Selector.extendElements;
		Prototype.Selector.engine = e, Prototype.Selector.select = t, Prototype.Selector.match = n
	}(Sizzle), window.Sizzle = Prototype._original_property, delete Prototype._original_property;
var Form = {
	reset: function(e) {
		return e = $(e), e.reset(), e
	},
	serializeElements: function(e, t) {
		"object" != typeof t ? t = {
			hash: !!t
		} : Object.isUndefined(t.hash) && (t.hash = !0);
		var n, i, r, o, a = !1,
			s = t.submit;
		return t.hash ? (o = {}, r = function(e, t, n) {
			return t in e ? (Object.isArray(e[t]) || (e[t] = [e[t]]), e[t].push(n)) : e[t] = n, e
		}) : (o = "", r = function(e, t, n) {
			return e + (e ? "&" : "") + encodeURIComponent(t) + "=" + encodeURIComponent(n)
		}), e.inject(o, function(e, t) {
			return !t.disabled && t.name && (n = t.name, i = $(t).getValue(), null == i || "file" == t.type || "submit" == t.type && (a || s === !1 || s && n != s || !(a = !0)) || (e = r(e, n, i))), e
		})
	}
};
Form.Methods = {
	serialize: function(e, t) {
		return Form.serializeElements(Form.getElements(e), t)
	},
	getElements: function(e) {
		for (var t, n = $(e).getElementsByTagName("*"), i = [], r = Form.Element.Serializers, o = 0; t = n[o]; o++) i.push(t);
		return i.inject([], function(e, t) {
			return r[t.tagName.toLowerCase()] && e.push(Element.extend(t)), e
		})
	},
	getInputs: function(e, t, n) {
		e = $(e);
		var i = e.getElementsByTagName("input");
		if (!t && !n) return $A(i).map(Element.extend);
		for (var r = 0, o = [], a = i.length; a > r; r++) {
			var s = i[r];
			t && s.type != t || n && s.name != n || o.push(Element.extend(s))
		}
		return o
	},
	disable: function(e) {
		return e = $(e), Form.getElements(e).invoke("disable"), e
	},
	enable: function(e) {
		return e = $(e), Form.getElements(e).invoke("enable"), e
	},
	findFirstElement: function(e) {
		var t = $(e).getElements().findAll(function(e) {
				return "hidden" != e.type && !e.disabled
			}),
			n = t.findAll(function(e) {
				return e.hasAttribute("tabIndex") && e.tabIndex >= 0
			}).sortBy(function(e) {
				return e.tabIndex
			}).first();
		return n ? n : t.find(function(e) {
			return /^(?:input|select|textarea)$/i.test(e.tagName)
		})
	},
	focusFirstElement: function(e) {
		e = $(e);
		var t = e.findFirstElement();
		return t && t.activate(), e
	},
	request: function(e, t) {
		e = $(e), t = Object.clone(t || {});
		var n = t.parameters,
			i = e.readAttribute("action") || "";
		return i.blank() && (i = window.location.href), t.parameters = e.serialize(!0), n && (Object.isString(n) && (n = n.toQueryParams()), Object.extend(t.parameters, n)), e.hasAttribute("method") && !t.method && (t.method = e.method), new Ajax.Request(i, t)
	}
}, Form.Element = {
	focus: function(e) {
		return $(e).focus(), e
	},
	select: function(e) {
		return $(e).select(), e
	}
}, Form.Element.Methods = {
	serialize: function(e) {
		if (e = $(e), !e.disabled && e.name) {
			var t = e.getValue();
			if (void 0 != t) {
				var n = {};
				return n[e.name] = t, Object.toQueryString(n)
			}
		}
		return ""
	},
	getValue: function(e) {
		e = $(e);
		var t = e.tagName.toLowerCase();
		return Form.Element.Serializers[t](e)
	},
	setValue: function(e, t) {
		e = $(e);
		var n = e.tagName.toLowerCase();
		return Form.Element.Serializers[n](e, t), e
	},
	clear: function(e) {
		return $(e).value = "", e
	},
	present: function(e) {
		return "" != $(e).value
	},
	activate: function(e) {
		e = $(e);
		try {
			e.focus(), !e.select || "input" == e.tagName.toLowerCase() && /^(?:button|reset|submit)$/i.test(e.type) || e.select()
		} catch (t) {}
		return e
	},
	disable: function(e) {
		return e = $(e), e.disabled = !0, e
	},
	enable: function(e) {
		return e = $(e), e.disabled = !1, e
	}
};
var Field = Form.Element,
	$F = Form.Element.Methods.getValue;
Form.Element.Serializers = function() {
	function e(e, i) {
		switch (e.type.toLowerCase()) {
			case "checkbox":
			case "radio":
				return t(e, i);
			default:
				return n(e, i)
		}
	}

	function t(e, t) {
		return Object.isUndefined(t) ? e.checked ? e.value : null : void(e.checked = !!t)
	}

	function n(e, t) {
		return Object.isUndefined(t) ? e.value : void(e.value = t)
	}

	function i(e, t) {
		if (Object.isUndefined(t)) return ("select-one" === e.type ? r : o)(e);
		for (var n, i, a = !Object.isArray(t), s = 0, l = e.length; l > s; s++)
			if (n = e.options[s], i = this.optionValue(n), a) {
				if (i == t) return void(n.selected = !0)
			} else n.selected = t.include(i)
	}

	function r(e) {
		var t = e.selectedIndex;
		return t >= 0 ? a(e.options[t]) : null
	}

	function o(e) {
		var t, n = e.length;
		if (!n) return null;
		for (var i = 0, t = []; n > i; i++) {
			var r = e.options[i];
			r.selected && t.push(a(r))
		}
		return t
	}

	function a(e) {
		return Element.hasAttribute(e, "value") ? e.value : e.text
	}
	return {
		input: e,
		inputSelector: t,
		textarea: n,
		select: i,
		selectOne: r,
		selectMany: o,
		optionValue: a,
		button: n
	}
}(), Abstract.TimedObserver = Class.create(PeriodicalExecuter, {
	initialize: function($super, e, t, n) {
		$super(n, t), this.element = $(e), this.lastValue = this.getValue()
	},
	execute: function() {
		var e = this.getValue();
		(Object.isString(this.lastValue) && Object.isString(e) ? this.lastValue != e : String(this.lastValue) != String(e)) && (this.callback(this.element, e), this.lastValue = e)
	}
}), Form.Element.Observer = Class.create(Abstract.TimedObserver, {
	getValue: function() {
		return Form.Element.getValue(this.element)
	}
}), Form.Observer = Class.create(Abstract.TimedObserver, {
	getValue: function() {
		return Form.serialize(this.element)
	}
}), Abstract.EventObserver = Class.create({
	initialize: function(e, t) {
		this.element = $(e), this.callback = t, this.lastValue = this.getValue(), "form" == this.element.tagName.toLowerCase() ? this.registerFormCallbacks() : this.registerCallback(this.element)
	},
	onElementEvent: function() {
		var e = this.getValue();
		this.lastValue != e && (this.callback(this.element, e), this.lastValue = e)
	},
	registerFormCallbacks: function() {
		Form.getElements(this.element).each(this.registerCallback, this)
	},
	registerCallback: function(e) {
		if (e.type) switch (e.type.toLowerCase()) {
			case "checkbox":
			case "radio":
				Event.observe(e, "click", this.onElementEvent.bind(this));
				break;
			default:
				Event.observe(e, "change", this.onElementEvent.bind(this))
		}
	}
}), Form.Element.EventObserver = Class.create(Abstract.EventObserver, {
	getValue: function() {
		return Form.Element.getValue(this.element)
	}
}), Form.EventObserver = Class.create(Abstract.EventObserver, {
	getValue: function() {
		return Form.serialize(this.element)
	}
}),
	function() {
		function e(e, t) {
			return e.which ? e.which === t + 1 : e.button === t
		}

		function t(e, t) {
			return e.button === k[t]
		}

		function n(e, t) {
			switch (t) {
				case 0:
					return 1 == e.which && !e.metaKey;
				case 1:
					return 2 == e.which || 1 == e.which && e.metaKey;
				case 2:
					return 3 == e.which;
				default:
					return !1
			}
		}

		function i(e) {
			return E(e, 0)
		}

		function r(e) {
			return E(e, 1)
		}

		function o(e) {
			return E(e, 2)
		}

		function a(e) {
			e = b.extend(e);
			var t = e.target,
				n = e.type,
				i = e.currentTarget;
			return i && i.tagName && ("load" === n || "error" === n || "click" === n && "input" === i.tagName.toLowerCase() && "radio" === i.type) && (t = i), t.nodeType == Node.TEXT_NODE && (t = t.parentNode), Element.extend(t)
		}

		function s(e, t) {
			var n = b.element(e);
			if (!t) return n;
			for (; n;) {
				if (Object.isElement(n) && Prototype.Selector.match(n, t)) return Element.extend(n);
				n = n.parentNode
			}
		}

		function l(e) {
			return {
				x: c(e),
				y: u(e)
			}
		}

		function c(e) {
			var t = document.documentElement,
				n = document.body || {
					scrollLeft: 0
				};
			return e.pageX || e.clientX + (t.scrollLeft || n.scrollLeft) - (t.clientLeft || 0)
		}

		function u(e) {
			var t = document.documentElement,
				n = document.body || {
					scrollTop: 0
				};
			return e.pageY || e.clientY + (t.scrollTop || n.scrollTop) - (t.clientTop || 0)
		}

		function d(e) {
			b.extend(e), e.preventDefault(), e.stopPropagation(), e.stopped = !0
		}

		function h(e) {
			var t;
			switch (e.type) {
				case "mouseover":
				case "mouseenter":
					t = e.fromElement;
					break;
				case "mouseout":
				case "mouseleave":
					t = e.toElement;
					break;
				default:
					return null
			}
			return Element.extend(t)
		}

		function p(e, t, n) {
			var i = Element.retrieve(e, "prototype_event_registry");
			Object.isUndefined(i) && (S.push(e), i = Element.retrieve(e, "prototype_event_registry", $H()));
			var r = i.get(t);
			if (Object.isUndefined(r) && (r = [], i.set(t, r)), r.pluck("handler").include(n)) return !1;
			var o;
			return t.include(":") ? o = function(i) {
				return Object.isUndefined(i.eventName) ? !1 : i.eventName !== t ? !1 : (b.extend(i, e), void n.call(e, i))
			} : w || "mouseenter" !== t && "mouseleave" !== t ? o = function(t) {
				b.extend(t, e), n.call(e, t)
			} : ("mouseenter" === t || "mouseleave" === t) && (o = function(t) {
				b.extend(t, e);
				for (var i = t.relatedTarget; i && i !== e;) try {
					i = i.parentNode
				} catch (r) {
					i = e
				}
				i !== e && n.call(e, t)
			}), o.handler = n, r.push(o), o
		}

		function f() {
			for (var e = 0, t = S.length; t > e; e++) b.stopObserving(S[e]), S[e] = null
		}

		function g(e, t, n) {
			e = $(e);
			var i = p(e, t, n);
			if (!i) return e;
			if (t.include(":")) e.addEventListener ? e.addEventListener("dataavailable", i, !1) : (e.attachEvent("ondataavailable", i), e.attachEvent("onlosecapture", i));
			else {
				var r = O(t);
				e.addEventListener ? e.addEventListener(r, i, !1) : e.attachEvent("on" + r, i)
			}
			return e
		}

		function m(e, t, n) {
			e = $(e);
			var i = Element.retrieve(e, "prototype_event_registry");
			if (!i) return e;
			if (!t) return i.each(function(t) {
				var n = t.key;
				m(e, n)
			}), e;
			var r = i.get(t);
			if (!r) return e;
			if (!n) return r.each(function(n) {
				m(e, t, n.handler)
			}), e;
			for (var o, a = r.length; a--;)
				if (r[a].handler === n) {
					o = r[a];
					break
				}
			if (!o) return e;
			if (t.include(":")) e.removeEventListener ? e.removeEventListener("dataavailable", o, !1) : (e.detachEvent("ondataavailable", o), e.detachEvent("onlosecapture", o));
			else {
				var s = O(t);
				e.removeEventListener ? e.removeEventListener(s, o, !1) : e.detachEvent("on" + s, o)
			}
			return i.set(t, r.without(o)), e
		}

		function v(e, t, n, i) {
			e = $(e), Object.isUndefined(i) && (i = !0), e == document && document.createEvent && !e.dispatchEvent && (e = document.documentElement);
			var r;
			return document.createEvent ? (r = document.createEvent("HTMLEvents"), r.initEvent("dataavailable", i, !0)) : (r = document.createEventObject(), r.eventType = i ? "ondataavailable" : "onlosecapture"), r.eventName = t, r.memo = n || {}, document.createEvent ? e.dispatchEvent(r) : e.fireEvent(r.eventType, r), b.extend(r)
		}

		function _(e, t, n, i) {
			return e = $(e), Object.isFunction(n) && Object.isUndefined(i) && (i = n, n = null), new b.Handler(e, t, n, i).start()
		}
		var b = {
				KEY_BACKSPACE: 8,
				KEY_TAB: 9,
				KEY_RETURN: 13,
				KEY_ESC: 27,
				KEY_LEFT: 37,
				KEY_UP: 38,
				KEY_RIGHT: 39,
				KEY_DOWN: 40,
				KEY_DELETE: 46,
				KEY_HOME: 36,
				KEY_END: 35,
				KEY_PAGEUP: 33,
				KEY_PAGEDOWN: 34,
				KEY_INSERT: 45,
				cache: {}
			},
			y = document.documentElement,
			w = "onmouseenter" in y && "onmouseleave" in y,
			x = function() {
				return !1
			};
		window.attachEvent && (x = window.addEventListener ? function(e) {
			return !(e instanceof window.Event)
		} : function() {
			return !0
		});
		var E, k = {
			0: 1,
			1: 4,
			2: 2
		};
		E = window.attachEvent ? window.addEventListener ? function(n, i) {
			return x(n) ? t(n, i) : e(n, i)
		} : t : Prototype.Browser.WebKit ? n : e, b.Methods = {
			isLeftClick: i,
			isMiddleClick: r,
			isRightClick: o,
			element: a,
			findElement: s,
			pointer: l,
			pointerX: c,
			pointerY: u,
			stop: d
		};
		var C = Object.keys(b.Methods).inject({}, function(e, t) {
			return e[t] = b.Methods[t].methodize(), e
		});
		if (window.attachEvent) {
			var T = {
				stopPropagation: function() {
					this.cancelBubble = !0
				},
				preventDefault: function() {
					this.returnValue = !1
				},
				inspect: function() {
					return "[object Event]"
				}
			};
			b.extend = function(e, t) {
				if (!e) return !1;
				if (!x(e)) return e;
				if (e._extendedByPrototype) return e;
				e._extendedByPrototype = Prototype.emptyFunction;
				var n = b.pointer(e);
				return Object.extend(e, {
					target: e.srcElement || t,
					relatedTarget: h(e),
					pageX: n.x,
					pageY: n.y
				}), Object.extend(e, C), Object.extend(e, T), e
			}
		} else b.extend = Prototype.K;
		window.addEventListener && (b.prototype = window.Event.prototype || document.createEvent("HTMLEvents").__proto__, Object.extend(b.prototype, C));
		var S = [];
		Prototype.Browser.IE && window.attachEvent("onunload", f), Prototype.Browser.WebKit && window.addEventListener("unload", Prototype.emptyFunction, !1);
		var O = Prototype.K,
			D = {
				mouseenter: "mouseover",
				mouseleave: "mouseout"
			};
		w || (O = function(e) {
			return D[e] || e
		}), b.Handler = Class.create({
			initialize: function(e, t, n, i) {
				this.element = $(e), this.eventName = t, this.selector = n, this.callback = i, this.handler = this.handleEvent.bind(this)
			},
			start: function() {
				return b.observe(this.element, this.eventName, this.handler), this
			},
			stop: function() {
				return b.stopObserving(this.element, this.eventName, this.handler), this
			},
			handleEvent: function(e) {
				var t = b.findElement(e, this.selector);
				t && this.callback.call(this.element, e, t)
			}
		}), Object.extend(b, b.Methods), Object.extend(b, {
			fire: v,
			observe: g,
			stopObserving: m,
			on: _
		}), Element.addMethods({
			fire: v,
			observe: g,
			stopObserving: m,
			on: _
		}), Object.extend(document, {
			fire: v.methodize(),
			observe: g.methodize(),
			stopObserving: m.methodize(),
			on: _.methodize(),
			loaded: !1
		}), window.Event ? Object.extend(window.Event, b) : window.Event = b
	}(),
	function() {
		function e() {
			document.loaded || (i && window.clearTimeout(i), document.loaded = !0, document.fire("dom:loaded"))
		}

		function t() {
			"complete" === document.readyState && (document.stopObserving("readystatechange", t), e())
		}

		function n() {
			try {
				document.documentElement.doScroll("left")
			} catch (t) {
				return void(i = n.defer())
			}
			e()
		}
		var i;
		document.addEventListener ? document.addEventListener("DOMContentLoaded", e, !1) : (document.observe("readystatechange", t), window == top && (i = n.defer())), Event.observe(window, "load", e)
	}(), Element.addMethods(), Hash.toQueryString = Object.toQueryString;
var Toggle = {
	display: Element.toggle
};
Element.Methods.childOf = Element.Methods.descendantOf;
var Insertion = {
		Before: function(e, t) {
			return Element.insert(e, {
				before: t
			})
		},
		Top: function(e, t) {
			return Element.insert(e, {
				top: t
			})
		},
		Bottom: function(e, t) {
			return Element.insert(e, {
				bottom: t
			})
		},
		After: function(e, t) {
			return Element.insert(e, {
				after: t
			})
		}
	},
	$continue = new Error('"throw $continue" is deprecated, use "return" instead'),
	Position = {
		includeScrollOffsets: !1,
		prepare: function() {
			this.deltaX = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft || 0, this.deltaY = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0
		},
		within: function(e, t, n) {
			return this.includeScrollOffsets ? this.withinIncludingScrolloffsets(e, t, n) : (this.xcomp = t, this.ycomp = n, this.offset = Element.cumulativeOffset(e), n >= this.offset[1] && n < this.offset[1] + e.offsetHeight && t >= this.offset[0] && t < this.offset[0] + e.offsetWidth)
		},
		withinIncludingScrolloffsets: function(e, t, n) {
			var i = Element.cumulativeScrollOffset(e);
			return this.xcomp = t + i[0] - this.deltaX, this.ycomp = n + i[1] - this.deltaY, this.offset = Element.cumulativeOffset(e), this.ycomp >= this.offset[1] && this.ycomp < this.offset[1] + e.offsetHeight && this.xcomp >= this.offset[0] && this.xcomp < this.offset[0] + e.offsetWidth
		},
		overlap: function(e, t) {
			return e ? "vertical" == e ? (this.offset[1] + t.offsetHeight - this.ycomp) / t.offsetHeight : "horizontal" == e ? (this.offset[0] + t.offsetWidth - this.xcomp) / t.offsetWidth : void 0 : 0
		},
		cumulativeOffset: Element.Methods.cumulativeOffset,
		positionedOffset: Element.Methods.positionedOffset,
		absolutize: function(e) {
			return Position.prepare(), Element.absolutize(e)
		},
		relativize: function(e) {
			return Position.prepare(), Element.relativize(e)
		},
		realOffset: Element.Methods.cumulativeScrollOffset,
		offsetParent: Element.Methods.getOffsetParent,
		page: Element.Methods.viewportOffset,
		clone: function(e, t, n) {
			return n = n || {}, Element.clonePosition(t, e, n)
		}
	};
document.getElementsByClassName || (document.getElementsByClassName = function(e) {
	function t(e) {
		return e.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + e + " ')]"
	}
	return e.getElementsByClassName = Prototype.BrowserFeatures.XPath ? function(e, n) {
		n = n.toString().strip();
		var i = /\s/.test(n) ? $w(n).map(t).join("") : t(n);
		return i ? document._getElementsByXPath(".//*" + i, e) : []
	} : function(e, t) {
		t = t.toString().strip();
		var n = [],
			i = /\s/.test(t) ? $w(t) : null;
		if (!i && !t) return n;
		var r = $(e).getElementsByTagName("*");
		t = " " + t + " ";
		for (var o, a, s = 0; o = r[s]; s++) o.className && (a = " " + o.className + " ") && (a.include(t) || i && i.all(function(e) {
			return !e.toString().blank() && a.include(" " + e + " ")
		})) && n.push(Element.extend(o));
		return n
	},
		function(e, t) {
			return $(t || document.body).getElementsByClassName(e)
		}
}(Element.Methods)), Element.ClassNames = Class.create(), Element.ClassNames.prototype = {
	initialize: function(e) {
		this.element = $(e)
	},
	_each: function(e) {
		this.element.className.split(/\s+/).select(function(e) {
			return e.length > 0
		})._each(e)
	},
	set: function(e) {
		this.element.className = e
	},
	add: function(e) {
		this.include(e) || this.set($A(this).concat(e).join(" "))
	},
	remove: function(e) {
		this.include(e) && this.set($A(this).without(e).join(" "))
	},
	toString: function() {
		return $A(this).join(" ")
	}
}, Object.extend(Element.ClassNames.prototype, Enumerable),
	function() {
		window.Selector = Class.create({
			initialize: function(e) {
				this.expression = e.strip()
			},
			findElements: function(e) {
				return Prototype.Selector.select(this.expression, e)
			},
			match: function(e) {
				return Prototype.Selector.match(e, this.expression)
			},
			toString: function() {
				return this.expression
			},
			inspect: function() {
				return "#<Selector: " + this.expression + ">"
			}
		}), Object.extend(Selector, {
			matchElements: function(e, t) {
				for (var n = Prototype.Selector.match, i = [], r = 0, o = e.length; o > r; r++) {
					var a = e[r];
					n(a, t) && i.push(Element.extend(a))
				}
				return i
			},
			findElement: function(e, t, n) {
				n = n || 0;
				for (var i, r = 0, o = 0, a = e.length; a > o; o++)
					if (i = e[o], Prototype.Selector.match(i, t) && n === r++) return Element.extend(i)
			},
			findChildElements: function(e, t) {
				var n = t.toArray().join(", ");
				return Prototype.Selector.select(n, e || document)
			}
		})
	}(), // Copyright (c) 2005-2010 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
	String.prototype.parseColor = function() {
		var e = "#";
		if ("rgb(" == this.slice(0, 4)) {
			var t = this.slice(4, this.length - 1).split(","),
				n = 0;
			do e += parseInt(t[n]).toColorPart(); while (++n < 3)
		} else if ("#" == this.slice(0, 1)) {
			if (4 == this.length)
				for (var n = 1; 4 > n; n++) e += (this.charAt(n) + this.charAt(n)).toLowerCase();
			7 == this.length && (e = this.toLowerCase())
		}
		return 7 == e.length ? e : arguments[0] || this
	}, Element.collectTextNodes = function(e) {
	return $A($(e).childNodes).collect(function(e) {
		return 3 == e.nodeType ? e.nodeValue : e.hasChildNodes() ? Element.collectTextNodes(e) : ""
	}).flatten().join("")
}, Element.collectTextNodesIgnoreClass = function(e, t) {
	return $A($(e).childNodes).collect(function(e) {
		return 3 == e.nodeType ? e.nodeValue : e.hasChildNodes() && !Element.hasClassName(e, t) ? Element.collectTextNodesIgnoreClass(e, t) : ""
	}).flatten().join("")
}, Element.setContentZoom = function(e, t) {
	return e = $(e), e.setStyle({
		fontSize: t / 100 + "em"
	}), Prototype.Browser.WebKit && window.scrollBy(0, 0), e
}, Element.getInlineOpacity = function(e) {
	return $(e).style.opacity || ""
}, Element.forceRerendering = function(e) {
	try {
		e = $(e);
		var t = document.createTextNode(" ");
		e.appendChild(t), e.removeChild(t)
	} catch (n) {}
};
var Effect = {
	_elementDoesNotExistError: {
		name: "ElementDoesNotExistError",
		message: "The specified DOM element does not exist, but is required for this effect to operate"
	},
	Transitions: {
		linear: Prototype.K,
		sinoidal: function(e) {
			return -Math.cos(e * Math.PI) / 2 + .5
		},
		reverse: function(e) {
			return 1 - e
		},
		flicker: function(e) {
			var e = -Math.cos(e * Math.PI) / 4 + .75 + Math.random() / 4;
			return e > 1 ? 1 : e
		},
		wobble: function(e) {
			return -Math.cos(e * Math.PI * 9 * e) / 2 + .5
		},
		pulse: function(e, t) {
			return -Math.cos(e * ((t || 5) - .5) * 2 * Math.PI) / 2 + .5
		},
		spring: function(e) {
			return 1 - Math.cos(4.5 * e * Math.PI) * Math.exp(6 * -e)
		},
		none: function() {
			return 0
		},
		full: function() {
			return 1
		}
	},
	DefaultOptions: {
		duration: 1,
		fps: 100,
		sync: !1,
		from: 0,
		to: 1,
		delay: 0,
		queue: "parallel"
	},
	tagifyText: function(e) {
		var t = "position:relative";
		Prototype.Browser.IE && (t += ";zoom:1"), e = $(e), $A(e.childNodes).each(function(n) {
			3 == n.nodeType && (n.nodeValue.toArray().each(function(i) {
				e.insertBefore(new Element("span", {
					style: t
				}).update(" " == i ? String.fromCharCode(160) : i), n)
			}), Element.remove(n))
		})
	},
	multiple: function(e, t) {
		var n;
		n = ("object" == typeof e || Object.isFunction(e)) && e.length ? e : $(e).childNodes;
		var i = Object.extend({
				speed: .1,
				delay: 0
			}, arguments[2] || {}),
			r = i.delay;
		$A(n).each(function(e, n) {
			new t(e, Object.extend(i, {
				delay: n * i.speed + r
			}))
		})
	},
	PAIRS: {
		slide: ["SlideDown", "SlideUp"],
		blind: ["BlindDown", "BlindUp"],
		appear: ["Appear", "Fade"]
	},
	toggle: function(e, t, n) {
		return e = $(e), t = (t || "appear").toLowerCase(), Effect[Effect.PAIRS[t][e.visible() ? 1 : 0]](e, Object.extend({
			queue: {
				position: "end",
				scope: e.id || "global",
				limit: 1
			}
		}, n || {}))
	}
}; // Copyright (c) 2005-2010 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
if (Effect.DefaultOptions.transition = Effect.Transitions.sinoidal, Effect.ScopedQueue = Class.create(Enumerable, {
	initialize: function() {
		this.effects = [], this.interval = null
	},
	_each: function(e) {
		this.effects._each(e)
	},
	add: function(e) {
		var t = (new Date).getTime(),
			n = Object.isString(e.options.queue) ? e.options.queue : e.options.queue.position;
		switch (n) {
			case "front":
				this.effects.findAll(function(e) {
					return "idle" == e.state
				}).each(function(t) {
					t.startOn += e.finishOn, t.finishOn += e.finishOn
				});
				break;
			case "with-last":
				t = this.effects.pluck("startOn").max() || t;
				break;
			case "end":
				t = this.effects.pluck("finishOn").max() || t
		}
		e.startOn += t, e.finishOn += t, (!e.options.queue.limit || this.effects.length < e.options.queue.limit) && this.effects.push(e), this.interval || (this.interval = setInterval(this.loop.bind(this), 15))
	},
	remove: function(e) {
		this.effects = this.effects.reject(function(t) {
			return t == e
		}), 0 == this.effects.length && (clearInterval(this.interval), this.interval = null)
	},
	loop: function() {
		for (var e = (new Date).getTime(), t = 0, n = this.effects.length; n > t; t++) this.effects[t] && this.effects[t].loop(e)
	}
}), Effect.Queues = {
	instances: $H(),
	get: function(e) {
		return Object.isString(e) ? this.instances.get(e) || this.instances.set(e, new Effect.ScopedQueue) : e
	}
}, Effect.Queue = Effect.Queues.get("global"), Effect.Base = Class.create({
	position: null,
	start: function(e) {
		e && e.transition === !1 && (e.transition = Effect.Transitions.linear), this.options = Object.extend(Object.extend({}, Effect.DefaultOptions), e || {}), this.currentFrame = 0, this.state = "idle", this.startOn = 1e3 * this.options.delay, this.finishOn = this.startOn + 1e3 * this.options.duration, this.fromToDelta = this.options.to - this.options.from, this.totalTime = this.finishOn - this.startOn, this.totalFrames = this.options.fps * this.options.duration, this.render = function() {
			function e(e, t) {
				e.options[t + "Internal"] && e.options[t + "Internal"](e), e.options[t] && e.options[t](e)
			}
			return function(t) {
				"idle" === this.state && (this.state = "running", e(this, "beforeSetup"), this.setup && this.setup(), e(this, "afterSetup")), "running" === this.state && (t = this.options.transition(t) * this.fromToDelta + this.options.from, this.position = t, e(this, "beforeUpdate"), this.update && this.update(t), e(this, "afterUpdate"))
			}
		}(), this.event("beforeStart"), this.options.sync || Effect.Queues.get(Object.isString(this.options.queue) ? "global" : this.options.queue.scope).add(this)
	},
	loop: function(e) {
		if (e >= this.startOn) {
			if (e >= this.finishOn) return this.render(1), this.cancel(), this.event("beforeFinish"), this.finish && this.finish(), void this.event("afterFinish");
			var t = (e - this.startOn) / this.totalTime,
				n = (t * this.totalFrames).round();
			n > this.currentFrame && (this.render(t), this.currentFrame = n)
		}
	},
	cancel: function() {
		this.options.sync || Effect.Queues.get(Object.isString(this.options.queue) ? "global" : this.options.queue.scope).remove(this), this.state = "finished"
	},
	event: function(e) {
		this.options[e + "Internal"] && this.options[e + "Internal"](this), this.options[e] && this.options[e](this)
	},
	inspect: function() {
		var e = $H();
		for (property in this) Object.isFunction(this[property]) || e.set(property, this[property]);
		return "#<Effect:" + e.inspect() + ",options:" + $H(this.options).inspect() + ">"
	}
}), Effect.Parallel = Class.create(Effect.Base, {
	initialize: function(e) {
		this.effects = e || [], this.start(arguments[1])
	},
	update: function(e) {
		this.effects.invoke("render", e)
	},
	finish: function(e) {
		this.effects.each(function(t) {
			t.render(1), t.cancel(), t.event("beforeFinish"), t.finish && t.finish(e), t.event("afterFinish")
		})
	}
}), Effect.Tween = Class.create(Effect.Base, {
	initialize: function(e, t, n) {
		e = Object.isString(e) ? $(e) : e;
		var i = $A(arguments),
			r = i.last(),
			o = 5 == i.length ? i[3] : null;
		this.method = Object.isFunction(r) ? r.bind(e) : Object.isFunction(e[r]) ? e[r].bind(e) : function(t) {
			e[r] = t
		}, this.start(Object.extend({
			from: t,
			to: n
		}, o || {}))
	},
	update: function(e) {
		this.method(e)
	}
}), Effect.Event = Class.create(Effect.Base, {
	initialize: function() {
		this.start(Object.extend({
			duration: 0
		}, arguments[0] || {}))
	},
	update: Prototype.emptyFunction
}), Effect.Opacity = Class.create(Effect.Base, {
	initialize: function(e) {
		if (this.element = $(e), !this.element) throw Effect._elementDoesNotExistError;
		Prototype.Browser.IE && !this.element.currentStyle.hasLayout && this.element.setStyle({
			zoom: 1
		});
		var t = Object.extend({
			from: this.element.getOpacity() || 0,
			to: 1
		}, arguments[1] || {});
		this.start(t)
	},
	update: function(e) {
		this.element.setOpacity(e)
	}
}), Effect.Move = Class.create(Effect.Base, {
	initialize: function(e) {
		if (this.element = $(e), !this.element) throw Effect._elementDoesNotExistError;
		var t = Object.extend({
			x: 0,
			y: 0,
			mode: "relative"
		}, arguments[1] || {});
		this.start(t)
	},
	setup: function() {
		this.element.makePositioned(), this.originalLeft = parseFloat(this.element.getStyle("left") || "0"), this.originalTop = parseFloat(this.element.getStyle("top") || "0"), "absolute" == this.options.mode && (this.options.x = this.options.x - this.originalLeft, this.options.y = this.options.y - this.originalTop)
	},
	update: function(e) {
		this.element.setStyle({
			left: (this.options.x * e + this.originalLeft).round() + "px",
			top: (this.options.y * e + this.originalTop).round() + "px"
		})
	}
}), Effect.MoveBy = function(e, t, n) {
	return new Effect.Move(e, Object.extend({
		x: n,
		y: t
	}, arguments[3] || {}))
}, Effect.Scale = Class.create(Effect.Base, {
	initialize: function(e, t) {
		if (this.element = $(e), !this.element) throw Effect._elementDoesNotExistError;
		var n = Object.extend({
			scaleX: !0,
			scaleY: !0,
			scaleContent: !0,
			scaleFromCenter: !1,
			scaleMode: "box",
			scaleFrom: 100,
			scaleTo: t
		}, arguments[2] || {});
		this.start(n)
	},
	setup: function() {
		this.restoreAfterFinish = this.options.restoreAfterFinish || !1, this.elementPositioning = this.element.getStyle("position"), this.originalStyle = {}, ["top", "left", "width", "height", "fontSize"].each(function(e) {
			this.originalStyle[e] = this.element.style[e]
		}.bind(this)), this.originalTop = this.element.offsetTop, this.originalLeft = this.element.offsetLeft;
		var e = this.element.getStyle("font-size") || "100%";
		["em", "px", "%", "pt"].each(function(t) {
			e.indexOf(t) > 0 && (this.fontSize = parseFloat(e), this.fontSizeType = t)
		}.bind(this)), this.factor = (this.options.scaleTo - this.options.scaleFrom) / 100, this.dims = null, "box" == this.options.scaleMode && (this.dims = [this.element.offsetHeight, this.element.offsetWidth]), /^content/.test(this.options.scaleMode) && (this.dims = [this.element.scrollHeight, this.element.scrollWidth]), this.dims || (this.dims = [this.options.scaleMode.originalHeight, this.options.scaleMode.originalWidth])
	},
	update: function(e) {
		var t = this.options.scaleFrom / 100 + this.factor * e;
		this.options.scaleContent && this.fontSize && this.element.setStyle({
			fontSize: this.fontSize * t + this.fontSizeType
		}), this.setDimensions(this.dims[0] * t, this.dims[1] * t)
	},
	finish: function() {
		this.restoreAfterFinish && this.element.setStyle(this.originalStyle)
	},
	setDimensions: function(e, t) {
		var n = {};
		if (this.options.scaleX && (n.width = t.round() + "px"), this.options.scaleY && (n.height = e.round() + "px"), this.options.scaleFromCenter) {
			var i = (e - this.dims[0]) / 2,
				r = (t - this.dims[1]) / 2;
			"absolute" == this.elementPositioning ? (this.options.scaleY && (n.top = this.originalTop - i + "px"), this.options.scaleX && (n.left = this.originalLeft - r + "px")) : (this.options.scaleY && (n.top = -i + "px"), this.options.scaleX && (n.left = -r + "px"))
		}
		this.element.setStyle(n)
	}
}), Effect.Highlight = Class.create(Effect.Base, {
	initialize: function(e) {
		if (this.element = $(e), !this.element) throw Effect._elementDoesNotExistError;
		var t = Object.extend({
			startcolor: "#ffff99"
		}, arguments[1] || {});
		this.start(t)
	},
	setup: function() {
		return "none" == this.element.getStyle("display") ? void this.cancel() : (this.oldStyle = {}, this.options.keepBackgroundImage || (this.oldStyle.backgroundImage = this.element.getStyle("background-image"), this.element.setStyle({
			backgroundImage: "none"
		})), this.options.endcolor || (this.options.endcolor = this.element.getStyle("background-color").parseColor("#ffffff")), this.options.restorecolor || (this.options.restorecolor = this.element.getStyle("background-color")), this._base = $R(0, 2).map(function(e) {
			return parseInt(this.options.startcolor.slice(2 * e + 1, 2 * e + 3), 16)
		}.bind(this)), void(this._delta = $R(0, 2).map(function(e) {
			return parseInt(this.options.endcolor.slice(2 * e + 1, 2 * e + 3), 16) - this._base[e]
		}.bind(this))))
	},
	update: function(e) {
		this.element.setStyle({
			backgroundColor: $R(0, 2).inject("#", function(t, n, i) {
				return t + (this._base[i] + this._delta[i] * e).round().toColorPart()
			}.bind(this))
		})
	},
	finish: function() {
		this.element.setStyle(Object.extend(this.oldStyle, {
			backgroundColor: this.options.restorecolor
		}))
	}
}), Effect.ScrollTo = function(e) {
	var t = arguments[1] || {},
		n = document.viewport.getScrollOffsets(),
		i = $(e).cumulativeOffset();
	return t.offset && (i[1] += t.offset), new Effect.Tween(null, n.top, i[1], t, function(e) {
		scrollTo(n.left, e.round())
	})
}, Effect.Fade = function(e) {
	e = $(e);
	var t = e.getInlineOpacity(),
		n = Object.extend({
			from: e.getOpacity() || 1,
			to: 0,
			afterFinishInternal: function(e) {
				0 == e.options.to && e.element.hide().setStyle({
					opacity: t
				})
			}
		}, arguments[1] || {});
	return new Effect.Opacity(e, n)
}, Effect.Appear = function(e) {
	e = $(e);
	var t = Object.extend({
		from: "none" == e.getStyle("display") ? 0 : e.getOpacity() || 0,
		to: 1,
		afterFinishInternal: function(e) {
			e.element.forceRerendering()
		},
		beforeSetup: function(e) {
			e.element.setOpacity(e.options.from).show()
		}
	}, arguments[1] || {});
	return new Effect.Opacity(e, t)
}, Effect.Puff = function(e) {
	e = $(e);
	var t = {
		opacity: e.getInlineOpacity(),
		position: e.getStyle("position"),
		top: e.style.top,
		left: e.style.left,
		width: e.style.width,
		height: e.style.height
	};
	return new Effect.Parallel([new Effect.Scale(e, 200, {
		sync: !0,
		scaleFromCenter: !0,
		scaleContent: !0,
		restoreAfterFinish: !0
	}), new Effect.Opacity(e, {
		sync: !0,
		to: 0
	})], Object.extend({
		duration: 1,
		beforeSetupInternal: function(e) {
			Position.absolutize(e.effects[0].element)
		},
		afterFinishInternal: function(e) {
			e.effects[0].element.hide().setStyle(t)
		}
	}, arguments[1] || {}))
}, Effect.BlindUp = function(e) {
	return e = $(e), e.makeClipping(), new Effect.Scale(e, 0, Object.extend({
		scaleContent: !1,
		scaleX: !1,
		restoreAfterFinish: !0,
		afterFinishInternal: function(e) {
			e.element.hide().undoClipping()
		}
	}, arguments[1] || {}))
}, Effect.BlindDown = function(e) {
	e = $(e);
	var t = e.getDimensions();
	return new Effect.Scale(e, 100, Object.extend({
		scaleContent: !1,
		scaleX: !1,
		scaleFrom: 0,
		scaleMode: {
			originalHeight: t.height,
			originalWidth: t.width
		},
		restoreAfterFinish: !0,
		afterSetup: function(e) {
			e.element.makeClipping().setStyle({
				height: "0px"
			}).show()
		},
		afterFinishInternal: function(e) {
			e.element.undoClipping()
		}
	}, arguments[1] || {}))
}, Effect.SwitchOff = function(e) {
	e = $(e);
	var t = e.getInlineOpacity();
	return new Effect.Appear(e, Object.extend({
		duration: .4,
		from: 0,
		transition: Effect.Transitions.flicker,
		afterFinishInternal: function(e) {
			new Effect.Scale(e.element, 1, {
				duration: .3,
				scaleFromCenter: !0,
				scaleX: !1,
				scaleContent: !1,
				restoreAfterFinish: !0,
				beforeSetup: function(e) {
					e.element.makePositioned().makeClipping()
				},
				afterFinishInternal: function(e) {
					e.element.hide().undoClipping().undoPositioned().setStyle({
						opacity: t
					})
				}
			})
		}
	}, arguments[1] || {}))
}, Effect.DropOut = function(e) {
	e = $(e);
	var t = {
		top: e.getStyle("top"),
		left: e.getStyle("left"),
		opacity: e.getInlineOpacity()
	};
	return new Effect.Parallel([new Effect.Move(e, {
		x: 0,
		y: 100,
		sync: !0
	}), new Effect.Opacity(e, {
		sync: !0,
		to: 0
	})], Object.extend({
		duration: .5,
		beforeSetup: function(e) {
			e.effects[0].element.makePositioned()
		},
		afterFinishInternal: function(e) {
			e.effects[0].element.hide().undoPositioned().setStyle(t)
		}
	}, arguments[1] || {}))
}, Effect.Shake = function(e) {
	e = $(e);
	var t = Object.extend({
			distance: 20,
			duration: .5
		}, arguments[1] || {}),
		n = parseFloat(t.distance),
		i = parseFloat(t.duration) / 10,
		r = {
			top: e.getStyle("top"),
			left: e.getStyle("left")
		};
	return new Effect.Move(e, {
		x: n,
		y: 0,
		duration: i,
		afterFinishInternal: function(e) {
			new Effect.Move(e.element, {
				x: 2 * -n,
				y: 0,
				duration: 2 * i,
				afterFinishInternal: function(e) {
					new Effect.Move(e.element, {
						x: 2 * n,
						y: 0,
						duration: 2 * i,
						afterFinishInternal: function(e) {
							new Effect.Move(e.element, {
								x: 2 * -n,
								y: 0,
								duration: 2 * i,
								afterFinishInternal: function(e) {
									new Effect.Move(e.element, {
										x: 2 * n,
										y: 0,
										duration: 2 * i,
										afterFinishInternal: function(e) {
											new Effect.Move(e.element, {
												x: -n,
												y: 0,
												duration: i,
												afterFinishInternal: function(e) {
													e.element.undoPositioned().setStyle(r)
												}
											})
										}
									})
								}
							})
						}
					})
				}
			})
		}
	})
}, Effect.SlideDown = function(e) {
	e = $(e).cleanWhitespace();
	var t = e.down().getStyle("bottom"),
		n = e.getDimensions();
	return new Effect.Scale(e, 100, Object.extend({
		scaleContent: !1,
		scaleX: !1,
		scaleFrom: window.opera ? 0 : 1,
		scaleMode: {
			originalHeight: n.height,
			originalWidth: n.width
		},
		restoreAfterFinish: !0,
		afterSetup: function(e) {
			e.element.makePositioned(), e.element.down().makePositioned(), window.opera && e.element.setStyle({
				top: ""
			}), e.element.makeClipping().setStyle({
				height: "0px"
			}).show()
		},
		afterUpdateInternal: function(e) {
			e.element.down().setStyle({
				bottom: e.dims[0] - e.element.clientHeight + "px"
			})
		},
		afterFinishInternal: function(e) {
			e.element.undoClipping().undoPositioned(), e.element.down().undoPositioned().setStyle({
				bottom: t
			})
		}
	}, arguments[1] || {}))
}, Effect.SlideUp = function(e) {
	e = $(e).cleanWhitespace();
	var t = e.down().getStyle("bottom"),
		n = e.getDimensions();
	return new Effect.Scale(e, window.opera ? 0 : 1, Object.extend({
		scaleContent: !1,
		scaleX: !1,
		scaleMode: "box",
		scaleFrom: 100,
		scaleMode: {
			originalHeight: n.height,
			originalWidth: n.width
		},
		restoreAfterFinish: !0,
		afterSetup: function(e) {
			e.element.makePositioned(), e.element.down().makePositioned(), window.opera && e.element.setStyle({
				top: ""
			}), e.element.makeClipping().show()
		},
		afterUpdateInternal: function(e) {
			e.element.down().setStyle({
				bottom: e.dims[0] - e.element.clientHeight + "px"
			})
		},
		afterFinishInternal: function(e) {
			e.element.hide().undoClipping().undoPositioned(), e.element.down().undoPositioned().setStyle({
				bottom: t
			})
		}
	}, arguments[1] || {}))
}, Effect.Squish = function(e) {
	return new Effect.Scale(e, window.opera ? 1 : 0, {
		restoreAfterFinish: !0,
		beforeSetup: function(e) {
			e.element.makeClipping()
		},
		afterFinishInternal: function(e) {
			e.element.hide().undoClipping()
		}
	})
}, Effect.Grow = function(e) {
	e = $(e);
	var t, n, i, r, o = Object.extend({
			direction: "center",
			moveTransition: Effect.Transitions.sinoidal,
			scaleTransition: Effect.Transitions.sinoidal,
			opacityTransition: Effect.Transitions.full
		}, arguments[1] || {}),
		a = {
			top: e.style.top,
			left: e.style.left,
			height: e.style.height,
			width: e.style.width,
			opacity: e.getInlineOpacity()
		},
		s = e.getDimensions();
	switch (o.direction) {
		case "top-left":
			t = n = i = r = 0;
			break;
		case "top-right":
			t = s.width, n = r = 0, i = -s.width;
			break;
		case "bottom-left":
			t = i = 0, n = s.height, r = -s.height;
			break;
		case "bottom-right":
			t = s.width, n = s.height, i = -s.width, r = -s.height;
			break;
		case "center":
			t = s.width / 2, n = s.height / 2, i = -s.width / 2, r = -s.height / 2
	}
	return new Effect.Move(e, {
		x: t,
		y: n,
		duration: .01,
		beforeSetup: function(e) {
			e.element.hide().makeClipping().makePositioned()
		},
		afterFinishInternal: function(e) {
			new Effect.Parallel([new Effect.Opacity(e.element, {
				sync: !0,
				to: 1,
				from: 0,
				transition: o.opacityTransition
			}), new Effect.Move(e.element, {
				x: i,
				y: r,
				sync: !0,
				transition: o.moveTransition
			}), new Effect.Scale(e.element, 100, {
				scaleMode: {
					originalHeight: s.height,
					originalWidth: s.width
				},
				sync: !0,
				scaleFrom: window.opera ? 1 : 0,
				transition: o.scaleTransition,
				restoreAfterFinish: !0
			})], Object.extend({
				beforeSetup: function(e) {
					e.effects[0].element.setStyle({
						height: "0px"
					}).show()
				},
				afterFinishInternal: function(e) {
					e.effects[0].element.undoClipping().undoPositioned().setStyle(a)
				}
			}, o))
		}
	})
}, Effect.Shrink = function(e) {
	e = $(e);
	var t, n, i = Object.extend({
			direction: "center",
			moveTransition: Effect.Transitions.sinoidal,
			scaleTransition: Effect.Transitions.sinoidal,
			opacityTransition: Effect.Transitions.none
		}, arguments[1] || {}),
		r = {
			top: e.style.top,
			left: e.style.left,
			height: e.style.height,
			width: e.style.width,
			opacity: e.getInlineOpacity()
		},
		o = e.getDimensions();
	switch (i.direction) {
		case "top-left":
			t = n = 0;
			break;
		case "top-right":
			t = o.width, n = 0;
			break;
		case "bottom-left":
			t = 0, n = o.height;
			break;
		case "bottom-right":
			t = o.width, n = o.height;
			break;
		case "center":
			t = o.width / 2, n = o.height / 2
	}
	return new Effect.Parallel([new Effect.Opacity(e, {
		sync: !0,
		to: 0,
		from: 1,
		transition: i.opacityTransition
	}), new Effect.Scale(e, window.opera ? 1 : 0, {
		sync: !0,
		transition: i.scaleTransition,
		restoreAfterFinish: !0
	}), new Effect.Move(e, {
		x: t,
		y: n,
		sync: !0,
		transition: i.moveTransition
	})], Object.extend({
		beforeStartInternal: function(e) {
			e.effects[0].element.makePositioned().makeClipping()
		},
		afterFinishInternal: function(e) {
			e.effects[0].element.hide().undoClipping().undoPositioned().setStyle(r)
		}
	}, i))
}, Effect.Pulsate = function(e) {
	e = $(e);
	var t = arguments[1] || {},
		n = e.getInlineOpacity(),
		i = t.transition || Effect.Transitions.linear,
		r = function(e) {
			return 1 - i(-Math.cos(e * (t.pulses || 5) * 2 * Math.PI) / 2 + .5)
		};
	return new Effect.Opacity(e, Object.extend(Object.extend({
		duration: 2,
		from: 0,
		afterFinishInternal: function(e) {
			e.element.setStyle({
				opacity: n
			})
		}
	}, t), {
		transition: r
	}))
}, Effect.Fold = function(e) {
	e = $(e);
	var t = {
		top: e.style.top,
		left: e.style.left,
		width: e.style.width,
		height: e.style.height
	};
	return e.makeClipping(), new Effect.Scale(e, 5, Object.extend({
		scaleContent: !1,
		scaleX: !1,
		afterFinishInternal: function() {
			new Effect.Scale(e, 1, {
				scaleContent: !1,
				scaleY: !1,
				afterFinishInternal: function(e) {
					e.element.hide().undoClipping().setStyle(t)
				}
			})
		}
	}, arguments[1] || {}))
}, Effect.Morph = Class.create(Effect.Base, {
	initialize: function(e) {
		if (this.element = $(e), !this.element) throw Effect._elementDoesNotExistError;
		var t = Object.extend({
			style: {}
		}, arguments[1] || {});
		if (Object.isString(t.style))
			if (t.style.include(":")) this.style = t.style.parseStyle();
			else {
				this.element.addClassName(t.style), this.style = $H(this.element.getStyles()), this.element.removeClassName(t.style);
				var n = this.element.getStyles();
				this.style = this.style.reject(function(e) {
					return e.value == n[e.key]
				}), t.afterFinishInternal = function(e) {
					e.element.addClassName(e.options.style), e.transforms.each(function(t) {
						e.element.style[t.style] = ""
					})
				}
			} else this.style = $H(t.style);
		this.start(t)
	},
	setup: function() {
		function e(e) {
			return (!e || ["rgba(0, 0, 0, 0)", "transparent"].include(e)) && (e = "#ffffff"), e = e.parseColor(), $R(0, 2).map(function(t) {
				return parseInt(e.slice(2 * t + 1, 2 * t + 3), 16)
			})
		}
		this.transforms = this.style.map(function(t) {
			var n = t[0],
				i = t[1],
				r = null;
			if ("#zzzzzz" != i.parseColor("#zzzzzz")) i = i.parseColor(), r = "color";
			else if ("opacity" == n) i = parseFloat(i), Prototype.Browser.IE && !this.element.currentStyle.hasLayout && this.element.setStyle({
				zoom: 1
			});
			else if (Element.CSS_LENGTH.test(i)) {
				var o = i.match(/^([\+\-]?[0-9\.]+)(.*)$/);
				i = parseFloat(o[1]), r = 3 == o.length ? o[2] : null
			}
			var a = this.element.getStyle(n);
			return {
				style: n.camelize(),
				originalValue: "color" == r ? e(a) : parseFloat(a || 0),
				targetValue: "color" == r ? e(i) : i,
				unit: r
			}
		}.bind(this)).reject(function(e) {
			return e.originalValue == e.targetValue || "color" != e.unit && (isNaN(e.originalValue) || isNaN(e.targetValue))
		})
	},
	update: function(e) {
		for (var t, n = {}, i = this.transforms.length; i--;) n[(t = this.transforms[i]).style] = "color" == t.unit ? "#" + Math.round(t.originalValue[0] + (t.targetValue[0] - t.originalValue[0]) * e).toColorPart() + Math.round(t.originalValue[1] + (t.targetValue[1] - t.originalValue[1]) * e).toColorPart() + Math.round(t.originalValue[2] + (t.targetValue[2] - t.originalValue[2]) * e).toColorPart() : (t.originalValue + (t.targetValue - t.originalValue) * e).toFixed(3) + (null === t.unit ? "" : t.unit);
		this.element.setStyle(n, !0)
	}
}), Effect.Transform = Class.create({
	initialize: function(e) {
		this.tracks = [], this.options = arguments[1] || {}, this.addTracks(e)
	},
	addTracks: function(e) {
		return e.each(function(e) {
			e = $H(e);
			var t = e.values().first();
			this.tracks.push($H({
				ids: e.keys().first(),
				effect: Effect.Morph,
				options: {
					style: t
				}
			}))
		}.bind(this)), this
	},
	play: function() {
		return new Effect.Parallel(this.tracks.map(function(e) {
			var t = e.get("ids"),
				n = e.get("effect"),
				i = e.get("options"),
				r = [$(t) || $$(t)].flatten();
			return r.map(function(e) {
				return new n(e, Object.extend({
					sync: !0
				}, i))
			})
		}).flatten(), this.options)
	}
}), Element.CSS_PROPERTIES = $w("backgroundColor backgroundPosition borderBottomColor borderBottomStyle borderBottomWidth borderLeftColor borderLeftStyle borderLeftWidth borderRightColor borderRightStyle borderRightWidth borderSpacing borderTopColor borderTopStyle borderTopWidth bottom clip color fontSize fontWeight height left letterSpacing lineHeight marginBottom marginLeft marginRight marginTop markerOffset maxHeight maxWidth minHeight minWidth opacity outlineColor outlineOffset outlineWidth paddingBottom paddingLeft paddingRight paddingTop right textIndent top width wordSpacing zIndex"), Element.CSS_LENGTH = /^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/, String.__parseStyleElement = document.createElement("div"), String.prototype.parseStyle = function() {
	var e, t = $H();
	return Prototype.Browser.WebKit ? e = new Element("div", {
		style: this
	}).style : (String.__parseStyleElement.innerHTML = '<div style="' + this + '"></div>', e = String.__parseStyleElement.childNodes[0].style), Element.CSS_PROPERTIES.each(function(n) {
		e[n] && t.set(n, e[n])
	}), Prototype.Browser.IE && this.include("opacity") && t.set("opacity", this.match(/opacity:\s*((?:0|1)?(?:\.\d*)?)/)[1]), t
}, Element.getStyles = document.defaultView && document.defaultView.getComputedStyle ? function(e) {
	var t = document.defaultView.getComputedStyle($(e), null);
	return Element.CSS_PROPERTIES.inject({}, function(e, n) {
		return e[n] = t[n], e
	})
} : function(e) {
	e = $(e);
	var t, n = e.currentStyle;
	return t = Element.CSS_PROPERTIES.inject({}, function(e, t) {
		return e[t] = n[t], e
	}), t.opacity || (t.opacity = e.getOpacity()), t
}, Effect.Methods = {
	morph: function(e, t) {
		return e = $(e), new Effect.Morph(e, Object.extend({
			style: t
		}, arguments[2] || {})), e
	},
	visualEffect: function(e, t, n) {
		e = $(e);
		var i = t.dasherize().camelize(),
			r = i.charAt(0).toUpperCase() + i.substring(1);
		return new Effect[r](e, n), e
	},
	highlight: function(e, t) {
		return e = $(e), new Effect.Highlight(e, t), e
	}
}, $w("fade appear grow shrink fold blindUp blindDown slideUp slideDown pulsate shake puff squish switchOff dropOut").each(function(e) {
	Effect.Methods[e] = function(t, n) {
		return t = $(t), Effect[e.charAt(0).toUpperCase() + e.substring(1)](t, n), t
	}
}), $w("getInlineOpacity forceRerendering setContentZoom collectTextNodes collectTextNodesIgnoreClass getStyles").each(function(e) {
	Effect.Methods[e] = Element[e]
}), Element.addMethods(Effect.Methods), "undefined" == typeof Effect) throw "controls.js requires including script.aculo.us' effects.js library";
var Autocompleter = {}; // Copyright (c) 2005-2010 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
if (Autocompleter.Base = Class.create({
	baseInitialize: function(e, t, n) {
		e = $(e), this.element = e, this.update = $(t), this.hasFocus = !1, this.changed = !1, this.active = !1, this.index = 0, this.entryCount = 0, this.oldElementValue = this.element.value, this.setOptions ? this.setOptions(n) : this.options = n || {}, this.options.paramName = this.options.paramName || this.element.name, this.options.tokens = this.options.tokens || [], this.options.frequency = this.options.frequency || .4, this.options.minChars = this.options.minChars || 1, this.options.onShow = this.options.onShow || function(e, t) {
			t.style.position && "absolute" != t.style.position || (t.style.position = "absolute", Position.clone(e, t, {
				setHeight: !1,
				offsetTop: e.offsetHeight
			})), Effect.Appear(t, {
				duration: .15
			})
		}, this.options.onHide = this.options.onHide || function(e, t) {
			new Effect.Fade(t, {
				duration: .15
			})
		}, "string" == typeof this.options.tokens && (this.options.tokens = new Array(this.options.tokens)), this.options.tokens.include("\n") || this.options.tokens.push("\n"), this.observer = null, this.element.setAttribute("autocomplete", "off"), Element.hide(this.update), Event.observe(this.element, "blur", this.onBlur.bindAsEventListener(this)), Event.observe(this.element, "keydown", this.onKeyPress.bindAsEventListener(this))
	},
	show: function() {
		"none" == Element.getStyle(this.update, "display") && this.options.onShow(this.element, this.update), !this.iefix && Prototype.Browser.IE && "absolute" == Element.getStyle(this.update, "position") && (new Insertion.After(this.update, '<iframe id="' + this.update.id + '_iefix" style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" src="javascript:false;" frameborder="0" scrolling="no"></iframe>'), this.iefix = $(this.update.id + "_iefix")), this.iefix && setTimeout(this.fixIEOverlapping.bind(this), 50)
	},
	fixIEOverlapping: function() {
		Position.clone(this.update, this.iefix, {
			setTop: !this.update.style.height
		}), this.iefix.style.zIndex = 1, this.update.style.zIndex = 2, Element.show(this.iefix)
	},
	hide: function() {
		this.stopIndicator(), "none" != Element.getStyle(this.update, "display") && this.options.onHide(this.element, this.update), this.iefix && Element.hide(this.iefix)
	},
	startIndicator: function() {
		this.options.indicator && Element.show(this.options.indicator)
	},
	stopIndicator: function() {
		this.options.indicator && Element.hide(this.options.indicator)
	},
	onKeyPress: function(e) {
		if (this.active) switch (e.keyCode) {
			case Event.KEY_TAB:
			case Event.KEY_RETURN:
				this.selectEntry(), Event.stop(e);
			case Event.KEY_ESC:
				return this.hide(), this.active = !1, void Event.stop(e);
			case Event.KEY_LEFT:
			case Event.KEY_RIGHT:
				return;
			case Event.KEY_UP:
				return this.markPrevious(), this.render(), void Event.stop(e);
			case Event.KEY_DOWN:
				return this.markNext(), this.render(), void Event.stop(e)
		} else if (e.keyCode == Event.KEY_TAB || e.keyCode == Event.KEY_RETURN || Prototype.Browser.WebKit > 0 && 0 == e.keyCode) return;
		this.changed = !0, this.hasFocus = !0, this.observer && clearTimeout(this.observer), this.observer = setTimeout(this.onObserverEvent.bind(this), 1e3 * this.options.frequency)
	},
	activate: function() {
		this.changed = !1, this.hasFocus = !0, this.getUpdatedChoices()
	},
	onHover: function(e) {
		var t = Event.findElement(e, "LI");
		this.index != t.autocompleteIndex && (this.index = t.autocompleteIndex, this.render()), Event.stop(e)
	},
	onClick: function(e) {
		var t = Event.findElement(e, "LI");
		this.index = t.autocompleteIndex, this.selectEntry(), this.hide()
	},
	onBlur: function() {
		setTimeout(this.hide.bind(this), 250), this.hasFocus = !1, this.active = !1
	},
	render: function() {
		if (this.entryCount > 0) {
			for (var e = 0; e < this.entryCount; e++) this.index == e ? Element.addClassName(this.getEntry(e), "selected") : Element.removeClassName(this.getEntry(e), "selected");
			this.hasFocus && (this.show(), this.active = !0)
		} else this.active = !1, this.hide()
	},
	markPrevious: function() {
		this.index > 0 ? this.index-- : this.index = this.entryCount - 1, this.getEntry(this.index).scrollIntoView(!0)
	},
	markNext: function() {
		this.index < this.entryCount - 1 ? this.index++ : this.index = 0, this.getEntry(this.index).scrollIntoView(!1)
	},
	getEntry: function(e) {
		return this.update.firstChild.childNodes[e]
	},
	getCurrentEntry: function() {
		return this.getEntry(this.index)
	},
	selectEntry: function() {
		this.active = !1, this.updateElement(this.getCurrentEntry())
	},
	updateElement: function(e) {
		if (this.options.updateElement) return void this.options.updateElement(e);
		var t = "";
		if (this.options.select) {
			var n = $(e).select("." + this.options.select) || [];
			n.length > 0 && (t = Element.collectTextNodes(n[0], this.options.select))
		} else t = Element.collectTextNodesIgnoreClass(e, "informal");
		var i = this.getTokenBounds();
		if (-1 != i[0]) {
			var r = this.element.value.substr(0, i[0]),
				o = this.element.value.substr(i[0]).match(/^\s+/);
			o && (r += o[0]), this.element.value = r + t + this.element.value.substr(i[1])
		} else this.element.value = t;
		this.oldElementValue = this.element.value, this.element.focus(), this.options.afterUpdateElement && this.options.afterUpdateElement(this.element, e)
	},
	updateChoices: function(e) {
		if (!this.changed && this.hasFocus) {
			if (this.update.innerHTML = e, Element.cleanWhitespace(this.update), Element.cleanWhitespace(this.update.down()), this.update.firstChild && this.update.down().childNodes) {
				this.entryCount = this.update.down().childNodes.length;
				for (var t = 0; t < this.entryCount; t++) {
					var n = this.getEntry(t);
					n.autocompleteIndex = t, this.addObservers(n)
				}
			} else this.entryCount = 0;
			this.stopIndicator(), this.index = 0, 1 == this.entryCount && this.options.autoSelect ? (this.selectEntry(), this.hide()) : this.render()
		}
	},
	addObservers: function(e) {
		Event.observe(e, "mouseover", this.onHover.bindAsEventListener(this)), Event.observe(e, "click", this.onClick.bindAsEventListener(this))
	},
	onObserverEvent: function() {
		this.changed = !1, this.tokenBounds = null, this.getToken().length >= this.options.minChars ? this.getUpdatedChoices() : (this.active = !1, this.hide()), this.oldElementValue = this.element.value
	},
	getToken: function() {
		var e = this.getTokenBounds();
		return this.element.value.substring(e[0], e[1]).strip()
	},
	getTokenBounds: function() {
		if (null != this.tokenBounds) return this.tokenBounds;
		var e = this.element.value;
		if (e.strip().empty()) return [-1, 0];
		for (var t, n = arguments.callee.getFirstDifferencePos(e, this.oldElementValue), i = n == this.oldElementValue.length ? 1 : 0, r = -1, o = e.length, a = 0, s = this.options.tokens.length; s > a; ++a) t = e.lastIndexOf(this.options.tokens[a], n + i - 1), t > r && (r = t), t = e.indexOf(this.options.tokens[a], n + i), -1 != t && o > t && (o = t);
		return this.tokenBounds = [r + 1, o]
	}
}), Autocompleter.Base.prototype.getTokenBounds.getFirstDifferencePos = function(e, t) {
	for (var n = Math.min(e.length, t.length), i = 0; n > i; ++i)
		if (e[i] != t[i]) return i;
	return n
}, Ajax.Autocompleter = Class.create(Autocompleter.Base, {
	initialize: function(e, t, n, i) {
		this.baseInitialize(e, t, i), this.options.asynchronous = !0, this.options.onComplete = this.onComplete.bind(this), this.options.defaultParams = this.options.parameters || null, this.url = n
	},
	getUpdatedChoices: function() {
		this.startIndicator();
		var e = encodeURIComponent(this.options.paramName) + "=" + encodeURIComponent(this.getToken());
		this.options.parameters = this.options.callback ? this.options.callback(this.element, e) : e, this.options.defaultParams && (this.options.parameters += "&" + this.options.defaultParams), new Ajax.Request(this.url, this.options)
	},
	onComplete: function(e) {
		this.updateChoices(e.responseText)
	}
}), Autocompleter.Local = Class.create(Autocompleter.Base, {
	initialize: function(e, t, n, i) {
		this.baseInitialize(e, t, i), this.options.array = n
	},
	getUpdatedChoices: function() {
		this.updateChoices(this.options.selector(this))
	},
	setOptions: function(e) {
		this.options = Object.extend({
			choices: 10,
			partialSearch: !0,
			partialChars: 2,
			ignoreCase: !0,
			fullSearch: !1,
			selector: function(e) {
				for (var t = [], n = [], i = e.getToken(), r = 0; r < e.options.array.length && t.length < e.options.choices; r++)
					for (var o = e.options.array[r], a = e.options.ignoreCase ? o.toLowerCase().indexOf(i.toLowerCase()) : o.indexOf(i); - 1 != a;) {
						if (0 == a && o.length != i.length) {
							t.push("<li><strong>" + o.substr(0, i.length) + "</strong>" + o.substr(i.length) + "</li>");
							break
						}
						if (i.length >= e.options.partialChars && e.options.partialSearch && -1 != a && (e.options.fullSearch || /\s/.test(o.substr(a - 1, 1)))) {
							n.push("<li>" + o.substr(0, a) + "<strong>" + o.substr(a, i.length) + "</strong>" + o.substr(a + i.length) + "</li>");
							break
						}
						a = e.options.ignoreCase ? o.toLowerCase().indexOf(i.toLowerCase(), a + 1) : o.indexOf(i, a + 1)
					}
				return n.length && (t = t.concat(n.slice(0, e.options.choices - t.length))), "<ul>" + t.join("") + "</ul>"
			}
		}, e || {})
	}
}), Field.scrollFreeActivate = function(e) {
	setTimeout(function() {
		Field.activate(e)
	}, 1)
}, Ajax.InPlaceEditor = Class.create({
	initialize: function(e, t, n) {
		this.url = t, this.element = e = $(e), this.prepareOptions(), this._controls = {}, arguments.callee.dealWithDeprecatedOptions(n), Object.extend(this.options, n || {}), !this.options.formId && this.element.id && (this.options.formId = this.element.id + "-inplaceeditor", $(this.options.formId) && (this.options.formId = "")), this.options.externalControl && (this.options.externalControl = $(this.options.externalControl)), this.options.externalControl || (this.options.externalControlOnly = !1), this._originalBackground = this.element.getStyle("background-color") || "transparent", this.element.title = this.options.clickToEditText, this._boundCancelHandler = this.handleFormCancellation.bind(this), this._boundComplete = (this.options.onComplete || Prototype.emptyFunction).bind(this), this._boundFailureHandler = this.handleAJAXFailure.bind(this), this._boundSubmitHandler = this.handleFormSubmission.bind(this), this._boundWrapperHandler = this.wrapUp.bind(this), this.registerListeners()
	},
	checkForEscapeOrReturn: function(e) {
		!this._editing || e.ctrlKey || e.altKey || e.shiftKey || (Event.KEY_ESC == e.keyCode ? this.handleFormCancellation(e) : Event.KEY_RETURN == e.keyCode && this.handleFormSubmission(e))
	},
	createControl: function(e, t, n) {
		var i = this.options[e + "Control"],
			r = this.options[e + "Text"];
		if ("button" == i) {
			var o = document.createElement("input");
			o.type = "submit", o.value = r, o.className = "editor_" + e + "_button", "cancel" == e && (o.onclick = this._boundCancelHandler), this._form.appendChild(o), this._controls[e] = o
		} else if ("link" == i) {
			var a = document.createElement("a");
			a.href = "#", a.appendChild(document.createTextNode(r)), a.onclick = "cancel" == e ? this._boundCancelHandler : this._boundSubmitHandler, a.className = "editor_" + e + "_link", n && (a.className += " " + n), this._form.appendChild(a), this._controls[e] = a
		}
	},
	createEditField: function() {
		var e, t = this.options.loadTextURL ? this.options.loadingText : this.getText();
		if (1 >= this.options.rows && !/\r|\n/.test(this.getText())) {
			e = document.createElement("input"), e.type = "text";
			var n = this.options.size || this.options.cols || 0;
			n > 0 && (e.size = n)
		} else e = document.createElement("textarea"), e.rows = 1 >= this.options.rows ? this.options.autoRows : this.options.rows, e.cols = this.options.cols || 40;
		e.name = this.options.paramName, e.value = t, e.className = "editor_field", this.options.submitOnBlur && (e.onblur = this._boundSubmitHandler), this._controls.editor = e, this.options.loadTextURL && this.loadExternalText(), this._form.appendChild(this._controls.editor)
	},
	createForm: function() {
		function e(e, n) {
			var i = t.options["text" + e + "Controls"];
			i && n !== !1 && t._form.appendChild(document.createTextNode(i))
		}
		var t = this;
		this._form = $(document.createElement("form")), this._form.id = this.options.formId, this._form.addClassName(this.options.formClassName), this._form.onsubmit = this._boundSubmitHandler, this.createEditField(), "textarea" == this._controls.editor.tagName.toLowerCase() && this._form.appendChild(document.createElement("br")), this.options.onFormCustomization && this.options.onFormCustomization(this, this._form), e("Before", this.options.okControl || this.options.cancelControl), this.createControl("ok", this._boundSubmitHandler), e("Between", this.options.okControl && this.options.cancelControl), this.createControl("cancel", this._boundCancelHandler, "editor_cancel"), e("After", this.options.okControl || this.options.cancelControl)
	},
	destroy: function() {
		this._oldInnerHTML && (this.element.innerHTML = this._oldInnerHTML), this.leaveEditMode(), this.unregisterListeners()
	},
	enterEditMode: function(e) {
		this._saving || this._editing || (this._editing = !0, this.triggerCallback("onEnterEditMode"), this.options.externalControl && this.options.externalControl.hide(), this.element.hide(), this.createForm(), this.element.parentNode.insertBefore(this._form, this.element), this.options.loadTextURL || this.postProcessEditField(), e && Event.stop(e))
	},
	enterHover: function() {
		this.options.hoverClassName && this.element.addClassName(this.options.hoverClassName), this._saving || this.triggerCallback("onEnterHover")
	},
	getText: function() {
		return this.element.innerHTML.unescapeHTML()
	},
	handleAJAXFailure: function(e) {
		this.triggerCallback("onFailure", e), this._oldInnerHTML && (this.element.innerHTML = this._oldInnerHTML, this._oldInnerHTML = null)
	},
	handleFormCancellation: function(e) {
		this.wrapUp(), e && Event.stop(e)
	},
	handleFormSubmission: function(e) {
		var t = this._form,
			n = $F(this._controls.editor);
		this.prepareSubmission();
		var i = this.options.callback(t, n) || "";
		if (Object.isString(i) && (i = i.toQueryParams()), i.editorId = this.element.id, this.options.htmlResponse) {
			var r = Object.extend({
				evalScripts: !0
			}, this.options.ajaxOptions);
			Object.extend(r, {
				parameters: i,
				onComplete: this._boundWrapperHandler,
				onFailure: this._boundFailureHandler
			}), new Ajax.Updater({
				success: this.element
			}, this.url, r)
		} else {
			var r = Object.extend({
				method: "get"
			}, this.options.ajaxOptions);
			Object.extend(r, {
				parameters: i,
				onComplete: this._boundWrapperHandler,
				onFailure: this._boundFailureHandler
			}), new Ajax.Request(this.url, r)
		}
		e && Event.stop(e)
	},
	leaveEditMode: function() {
		this.element.removeClassName(this.options.savingClassName), this.removeForm(), this.leaveHover(), this.element.style.backgroundColor = this._originalBackground, this.element.show(), this.options.externalControl && this.options.externalControl.show(), this._saving = !1, this._editing = !1, this._oldInnerHTML = null, this.triggerCallback("onLeaveEditMode")
	},
	leaveHover: function() {
		this.options.hoverClassName && this.element.removeClassName(this.options.hoverClassName), this._saving || this.triggerCallback("onLeaveHover")
	},
	loadExternalText: function() {
		this._form.addClassName(this.options.loadingClassName), this._controls.editor.disabled = !0;
		var e = Object.extend({
			method: "get"
		}, this.options.ajaxOptions);
		Object.extend(e, {
			parameters: "editorId=" + encodeURIComponent(this.element.id),
			onComplete: Prototype.emptyFunction,
			onSuccess: function(e) {
				this._form.removeClassName(this.options.loadingClassName);
				var t = e.responseText;
				this.options.stripLoadedTextTags && (t = t.stripTags()), this._controls.editor.value = t, this._controls.editor.disabled = !1, this.postProcessEditField()
			}.bind(this),
			onFailure: this._boundFailureHandler
		}), new Ajax.Request(this.options.loadTextURL, e)
	},
	postProcessEditField: function() {
		var e = this.options.fieldPostCreation;
		e && $(this._controls.editor)["focus" == e ? "focus" : "activate"]()
	},
	prepareOptions: function() {
		this.options = Object.clone(Ajax.InPlaceEditor.DefaultOptions), Object.extend(this.options, Ajax.InPlaceEditor.DefaultCallbacks), [this._extraDefaultOptions].flatten().compact().each(function(e) {
			Object.extend(this.options, e)
		}.bind(this))
	},
	prepareSubmission: function() {
		this._saving = !0, this.removeForm(), this.leaveHover(), this.showSaving()
	},
	registerListeners: function() {
		this._listeners = {};
		var e;
		$H(Ajax.InPlaceEditor.Listeners).each(function(t) {
			e = this[t.value].bind(this), this._listeners[t.key] = e, this.options.externalControlOnly || this.element.observe(t.key, e), this.options.externalControl && this.options.externalControl.observe(t.key, e)
		}.bind(this))
	},
	removeForm: function() {
		this._form && (this._form.remove(), this._form = null, this._controls = {})
	},
	showSaving: function() {
		this._oldInnerHTML = this.element.innerHTML, this.element.innerHTML = this.options.savingText, this.element.addClassName(this.options.savingClassName), this.element.style.backgroundColor = this._originalBackground, this.element.show()
	},
	triggerCallback: function(e, t) {
		"function" == typeof this.options[e] && this.options[e](this, t)
	},
	unregisterListeners: function() {
		$H(this._listeners).each(function(e) {
			this.options.externalControlOnly || this.element.stopObserving(e.key, e.value), this.options.externalControl && this.options.externalControl.stopObserving(e.key, e.value)
		}.bind(this))
	},
	wrapUp: function(e) {
		this.leaveEditMode(), this._boundComplete(e, this.element)
	}
}), Object.extend(Ajax.InPlaceEditor.prototype, {
	dispose: Ajax.InPlaceEditor.prototype.destroy
}), Ajax.InPlaceCollectionEditor = Class.create(Ajax.InPlaceEditor, {
	initialize: function($super, e, t, n) {
		this._extraDefaultOptions = Ajax.InPlaceCollectionEditor.DefaultOptions, $super(e, t, n)
	},
	createEditField: function() {
		var e = document.createElement("select");
		e.name = this.options.paramName, e.size = 1, this._controls.editor = e, this._collection = this.options.collection || [], this.options.loadCollectionURL ? this.loadCollection() : this.checkForExternalText(), this._form.appendChild(this._controls.editor)
	},
	loadCollection: function() {
		this._form.addClassName(this.options.loadingClassName), this.showLoadingText(this.options.loadingCollectionText);
		var options = Object.extend({
			method: "get"
		}, this.options.ajaxOptions);
		Object.extend(options, {
			parameters: "editorId=" + encodeURIComponent(this.element.id),
			onComplete: Prototype.emptyFunction,
			onSuccess: function(transport) {
				var js = transport.responseText.strip();
				if (!/^\[.*\]$/.test(js)) throw "Server returned an invalid collection representation.";
				this._collection = eval(js), this.checkForExternalText()
			}.bind(this),
			onFailure: this.onFailure
		}), new Ajax.Request(this.options.loadCollectionURL, options)
	},
	showLoadingText: function(e) {
		this._controls.editor.disabled = !0;
		var t = this._controls.editor.firstChild;
		t || (t = document.createElement("option"), t.value = "", this._controls.editor.appendChild(t), t.selected = !0), t.update((e || "").stripScripts().stripTags())
	},
	checkForExternalText: function() {
		this._text = this.getText(), this.options.loadTextURL ? this.loadExternalText() : this.buildOptionList()
	},
	loadExternalText: function() {
		this.showLoadingText(this.options.loadingText);
		var e = Object.extend({
			method: "get"
		}, this.options.ajaxOptions);
		Object.extend(e, {
			parameters: "editorId=" + encodeURIComponent(this.element.id),
			onComplete: Prototype.emptyFunction,
			onSuccess: function(e) {
				this._text = e.responseText.strip(), this.buildOptionList()
			}.bind(this),
			onFailure: this.onFailure
		}), new Ajax.Request(this.options.loadTextURL, e)
	},
	buildOptionList: function() {
		this._form.removeClassName(this.options.loadingClassName), this._collection = this._collection.map(function(e) {
			return 2 === e.length ? e : [e, e].flatten()
		});
		var e = "value" in this.options ? this.options.value : this._text,
			t = this._collection.any(function(t) {
				return t[0] == e
			}.bind(this));
		this._controls.editor.update("");
		var n;
		this._collection.each(function(i, r) {
			n = document.createElement("option"), n.value = i[0], n.selected = t ? i[0] == e : 0 == r, n.appendChild(document.createTextNode(i[1])), this._controls.editor.appendChild(n)
		}.bind(this)), this._controls.editor.disabled = !1, Field.scrollFreeActivate(this._controls.editor)
	}
}), Ajax.InPlaceEditor.prototype.initialize.dealWithDeprecatedOptions = function(e) {
	function t(t, n) {
		t in e || void 0 === n || (e[t] = n)
	}
	e && (t("cancelControl", e.cancelLink ? "link" : e.cancelButton ? "button" : e.cancelLink == e.cancelButton == 0 ? !1 : void 0), t("okControl", e.okLink ? "link" : e.okButton ? "button" : e.okLink == e.okButton == 0 ? !1 : void 0), t("highlightColor", e.highlightcolor), t("highlightEndColor", e.highlightendcolor))
}, Object.extend(Ajax.InPlaceEditor, {
	DefaultOptions: {
		ajaxOptions: {},
		autoRows: 3,
		cancelControl: "link",
		cancelText: "cancel",
		clickToEditText: "Click to edit",
		externalControl: null,
		externalControlOnly: !1,
		fieldPostCreation: "activate",
		formClassName: "inplaceeditor-form",
		formId: null,
		highlightColor: "#ffff99",
		highlightEndColor: "#ffffff",
		hoverClassName: "",
		htmlResponse: !0,
		loadingClassName: "inplaceeditor-loading",
		loadingText: "Loading...",
		okControl: "button",
		okText: "ok",
		paramName: "value",
		rows: 1,
		savingClassName: "inplaceeditor-saving",
		savingText: "Saving...",
		size: 0,
		stripLoadedTextTags: !1,
		submitOnBlur: !1,
		textAfterControls: "",
		textBeforeControls: "",
		textBetweenControls: ""
	},
	DefaultCallbacks: {
		callback: function(e) {
			return Form.serialize(e)
		},
		onComplete: function(e, t) {
			new Effect.Highlight(t, {
				startcolor: this.options.highlightColor,
				keepBackgroundImage: !0
			})
		},
		onEnterEditMode: null,
		onEnterHover: function(e) {
			e.element.style.backgroundColor = e.options.highlightColor, e._effect && e._effect.cancel()
		},
		onFailure: function(e) {
			alert("Error communication with the server: " + e.responseText.stripTags())
		},
		onFormCustomization: null,
		onLeaveEditMode: null,
		onLeaveHover: function(e) {
			e._effect = new Effect.Highlight(e.element, {
				startcolor: e.options.highlightColor,
				endcolor: e.options.highlightEndColor,
				restorecolor: e._originalBackground,
				keepBackgroundImage: !0
			})
		}
	},
	Listeners: {
		click: "enterEditMode",
		keydown: "checkForEscapeOrReturn",
		mouseover: "enterHover",
		mouseout: "leaveHover"
	}
}), Ajax.InPlaceCollectionEditor.DefaultOptions = {
	loadingCollectionText: "Loading options..."
}, Form.Element.DelayedObserver = Class.create({
	initialize: function(e, t, n) {
		this.delay = t || .5, this.element = $(e), this.callback = n, this.timer = null, this.lastValue = $F(this.element), Event.observe(this.element, "keyup", this.delayedListener.bindAsEventListener(this))
	},
	delayedListener: function() {
		this.lastValue != $F(this.element) && (this.timer && clearTimeout(this.timer), this.timer = setTimeout(this.onTimerEvent.bind(this), 1e3 * this.delay), this.lastValue = $F(this.element))
	},
	onTimerEvent: function() {
		this.timer = null, this.callback(this.element, $F(this.element))
	}
}), Object.isUndefined(Effect)) throw "dragdrop.js requires including script.aculo.us' effects.js library";
var Droppables = {
		drops: [],
		remove: function(e) {
			this.drops = this.drops.reject(function(t) {
				return t.element == $(e)
			})
		},
		add: function(e) {
			e = $(e);
			var t = Object.extend({
				greedy: !0,
				hoverclass: null,
				tree: !1
			}, arguments[1] || {});
			if (t.containment) {
				t._containers = [];
				var n = t.containment;
				Object.isArray(n) ? n.each(function(e) {
					t._containers.push($(e))
				}) : t._containers.push($(n))
			}
			t.accept && (t.accept = [t.accept].flatten()), Element.makePositioned(e), t.element = e, this.drops.push(t)
		},
		findDeepestChild: function(e) {
			for (deepest = e[0], i = 1; i < e.length; ++i) Element.isParent(e[i].element, deepest.element) && (deepest = e[i]);
			return deepest
		},
		isContained: function(e, t) {
			var n;
			return n = t.tree ? e.treeNode : e.parentNode, t._containers.detect(function(e) {
				return n == e
			})
		},
		isAffected: function(e, t, n) {
			return n.element != t && (!n._containers || this.isContained(t, n)) && (!n.accept || Element.classNames(t).detect(function(e) {
				return n.accept.include(e)
			})) && Position.within(n.element, e[0], e[1])
		},
		deactivate: function(e) {
			e.hoverclass && Element.removeClassName(e.element, e.hoverclass), this.last_active = null
		},
		activate: function(e) {
			e.hoverclass && Element.addClassName(e.element, e.hoverclass), this.last_active = e
		},
		show: function(e, t) {
			if (this.drops.length) {
				var n, i = [];
				this.drops.each(function(n) {
					Droppables.isAffected(e, t, n) && i.push(n)
				}), i.length > 0 && (n = Droppables.findDeepestChild(i)), this.last_active && this.last_active != n && this.deactivate(this.last_active), n && (Position.within(n.element, e[0], e[1]), n.onHover && n.onHover(t, n.element, Position.overlap(n.overlap, n.element)), n != this.last_active && Droppables.activate(n))
			}
		},
		fire: function(e, t) {
			return this.last_active ? (Position.prepare(), this.isAffected([Event.pointerX(e), Event.pointerY(e)], t, this.last_active) && this.last_active.onDrop ? (this.last_active.onDrop(t, this.last_active.element, e), !0) : void 0) : void 0
		},
		reset: function() {
			this.last_active && this.deactivate(this.last_active)
		}
	},
	Draggables = {
		drags: [],
		observers: [],
		register: function(e) {
			0 == this.drags.length && (this.eventMouseUp = this.endDrag.bindAsEventListener(this), this.eventMouseMove = this.updateDrag.bindAsEventListener(this), this.eventKeypress = this.keyPress.bindAsEventListener(this), Event.observe(document, "mouseup", this.eventMouseUp), Event.observe(document, "mousemove", this.eventMouseMove), Event.observe(document, "keypress", this.eventKeypress)), this.drags.push(e)
		},
		unregister: function(e) {
			this.drags = this.drags.reject(function(t) {
				return t == e
			}), 0 == this.drags.length && (Event.stopObserving(document, "mouseup", this.eventMouseUp), Event.stopObserving(document, "mousemove", this.eventMouseMove), Event.stopObserving(document, "keypress", this.eventKeypress))
		},
		activate: function(e) {
			e.options.delay ? this._timeout = setTimeout(function() {
				Draggables._timeout = null, window.focus(), Draggables.activeDraggable = e
			}.bind(this), e.options.delay) : (window.focus(), this.activeDraggable = e)
		},
		deactivate: function() {
			this.activeDraggable = null
		},
		updateDrag: function(e) {
			if (this.activeDraggable) {
				var t = [Event.pointerX(e), Event.pointerY(e)];
				this._lastPointer && this._lastPointer.inspect() == t.inspect() || (this._lastPointer = t, this.activeDraggable.updateDrag(e, t))
			}
		},
		endDrag: function(e) {
			this._timeout && (clearTimeout(this._timeout), this._timeout = null), this.activeDraggable && (this._lastPointer = null, this.activeDraggable.endDrag(e), this.activeDraggable = null)
		},
		keyPress: function(e) {
			this.activeDraggable && this.activeDraggable.keyPress(e)
		},
		addObserver: function(e) {
			this.observers.push(e), this._cacheObserverCallbacks()
		},
		removeObserver: function(e) {
			this.observers = this.observers.reject(function(t) {
				return t.element == e
			}), this._cacheObserverCallbacks()
		},
		notify: function(e, t, n) {
			this[e + "Count"] > 0 && this.observers.each(function(i) {
				i[e] && i[e](e, t, n)
			}), t.options[e] && t.options[e](t, n)
		},
		_cacheObserverCallbacks: function() {
			["onStart", "onEnd", "onDrag"].each(function(e) {
				Draggables[e + "Count"] = Draggables.observers.select(function(t) {
					return t[e]
				}).length
			})
		}
	},
	Draggable = Class.create({
		initialize: function(e) {
			var t = {
				handle: !1,
				reverteffect: function(e, t, n) {
					var i = .02 * Math.sqrt(Math.abs(2 ^ t) + Math.abs(2 ^ n));
					new Effect.Move(e, {
						x: -n,
						y: -t,
						duration: i,
						queue: {
							scope: "_draggable",
							position: "end"
						}
					})
				},
				endeffect: function(e) {
					var t = Object.isNumber(e._opacity) ? e._opacity : 1;
					new Effect.Opacity(e, {
						duration: .2,
						from: .7,
						to: t,
						queue: {
							scope: "_draggable",
							position: "end"
						},
						afterFinish: function() {
							Draggable._dragging[e] = !1
						}
					})
				},
				zindex: 1e3,
				revert: !1,
				quiet: !1,
				scroll: !1,
				scrollSensitivity: 20,
				scrollSpeed: 15,
				snap: !1,
				delay: 0
			};
			(!arguments[1] || Object.isUndefined(arguments[1].endeffect)) && Object.extend(t, {
				starteffect: function(e) {
					e._opacity = Element.getOpacity(e), Draggable._dragging[e] = !0, new Effect.Opacity(e, {
						duration: .2,
						from: e._opacity,
						to: .7
					})
				}
			});
			var n = Object.extend(t, arguments[1] || {});
			this.element = $(e), n.handle && Object.isString(n.handle) && (this.handle = this.element.down("." + n.handle, 0)), this.handle || (this.handle = $(n.handle)), this.handle || (this.handle = this.element), !n.scroll || n.scroll.scrollTo || n.scroll.outerHTML || (n.scroll = $(n.scroll), this._isScrollChild = Element.childOf(this.element, n.scroll)), Element.makePositioned(this.element), this.options = n, this.dragging = !1, this.eventMouseDown = this.initDrag.bindAsEventListener(this), Event.observe(this.handle, "mousedown", this.eventMouseDown), Draggables.register(this)
		},
		destroy: function() {
			Event.stopObserving(this.handle, "mousedown", this.eventMouseDown), Draggables.unregister(this)
		},
		currentDelta: function() {
			return [parseInt(Element.getStyle(this.element, "left") || "0"), parseInt(Element.getStyle(this.element, "top") || "0")]
		},
		initDrag: function(e) {
			if ((Object.isUndefined(Draggable._dragging[this.element]) || !Draggable._dragging[this.element]) && Event.isLeftClick(e)) {
				var t = Event.element(e);
				if ((tag_name = t.tagName.toUpperCase()) && ("INPUT" == tag_name || "SELECT" == tag_name || "OPTION" == tag_name || "BUTTON" == tag_name || "TEXTAREA" == tag_name)) return;
				var n = [Event.pointerX(e), Event.pointerY(e)],
					i = this.element.cumulativeOffset();
				this.offset = [0, 1].map(function(e) {
					return n[e] - i[e]
				}), Draggables.activate(this), Event.stop(e)
			}
		},
		startDrag: function(e) {
			if (this.dragging = !0, this.delta || (this.delta = this.currentDelta()), this.options.zindex && (this.originalZ = parseInt(Element.getStyle(this.element, "z-index") || 0), this.element.style.zIndex = this.options.zindex), this.options.ghosting && (this._clone = this.element.cloneNode(!0), this._originallyAbsolute = "absolute" == this.element.getStyle("position"), this._originallyAbsolute || Position.absolutize(this.element), this.element.parentNode.insertBefore(this._clone, this.element)), this.options.scroll)
				if (this.options.scroll == window) {
					var t = this._getWindowScroll(this.options.scroll);
					this.originalScrollLeft = t.left, this.originalScrollTop = t.top
				} else this.originalScrollLeft = this.options.scroll.scrollLeft, this.originalScrollTop = this.options.scroll.scrollTop;
			Draggables.notify("onStart", this, e), this.options.starteffect && this.options.starteffect(this.element)
		},
		updateDrag: function(event, pointer) {
			if (this.dragging || this.startDrag(event), this.options.quiet || (Position.prepare(), Droppables.show(pointer, this.element)), Draggables.notify("onDrag", this, event), this.draw(pointer), this.options.change && this.options.change(this), this.options.scroll) {
				this.stopScrolling();
				var p;
				if (this.options.scroll == window) with(this._getWindowScroll(this.options.scroll)) p = [left, top, left + width, top + height];
				else p = Position.page(this.options.scroll).toArray(), p[0] += this.options.scroll.scrollLeft + Position.deltaX, p[1] += this.options.scroll.scrollTop + Position.deltaY, p.push(p[0] + this.options.scroll.offsetWidth), p.push(p[1] + this.options.scroll.offsetHeight);
				var speed = [0, 0];
				pointer[0] < p[0] + this.options.scrollSensitivity && (speed[0] = pointer[0] - (p[0] + this.options.scrollSensitivity)), pointer[1] < p[1] + this.options.scrollSensitivity && (speed[1] = pointer[1] - (p[1] + this.options.scrollSensitivity)), pointer[0] > p[2] - this.options.scrollSensitivity && (speed[0] = pointer[0] - (p[2] - this.options.scrollSensitivity)), pointer[1] > p[3] - this.options.scrollSensitivity && (speed[1] = pointer[1] - (p[3] - this.options.scrollSensitivity)), this.startScrolling(speed)
			}
			Prototype.Browser.WebKit && window.scrollBy(0, 0), Event.stop(event)
		},
		finishDrag: function(e, t) {
			if (this.dragging = !1, this.options.quiet) {
				Position.prepare();
				var n = [Event.pointerX(e), Event.pointerY(e)];
				Droppables.show(n, this.element)
			}
			this.options.ghosting && (this._originallyAbsolute || Position.relativize(this.element), delete this._originallyAbsolute, Element.remove(this._clone), this._clone = null);
			var i = !1;
			t && (i = Droppables.fire(e, this.element), i || (i = !1)), i && this.options.onDropped && this.options.onDropped(this.element), Draggables.notify("onEnd", this, e);
			var r = this.options.revert;
			r && Object.isFunction(r) && (r = r(this.element));
			var o = this.currentDelta();
			r && this.options.reverteffect ? (0 == i || "failure" != r) && this.options.reverteffect(this.element, o[1] - this.delta[1], o[0] - this.delta[0]) : this.delta = o, this.options.zindex && (this.element.style.zIndex = this.originalZ), this.options.endeffect && this.options.endeffect(this.element), Draggables.deactivate(this), Droppables.reset()
		},
		keyPress: function(e) {
			e.keyCode == Event.KEY_ESC && (this.finishDrag(e, !1), Event.stop(e))
		},
		endDrag: function(e) {
			this.dragging && (this.stopScrolling(), this.finishDrag(e, !0), Event.stop(e))
		},
		draw: function(e) {
			var t = this.element.cumulativeOffset();
			if (this.options.ghosting) {
				var n = Position.realOffset(this.element);
				t[0] += n[0] - Position.deltaX, t[1] += n[1] - Position.deltaY
			}
			var i = this.currentDelta();
			t[0] -= i[0], t[1] -= i[1], this.options.scroll && this.options.scroll != window && this._isScrollChild && (t[0] -= this.options.scroll.scrollLeft - this.originalScrollLeft, t[1] -= this.options.scroll.scrollTop - this.originalScrollTop);
			var r = [0, 1].map(function(n) {
				return e[n] - t[n] - this.offset[n]
			}.bind(this));
			this.options.snap && (r = Object.isFunction(this.options.snap) ? this.options.snap(r[0], r[1], this) : r.map(Object.isArray(this.options.snap) ? function(e, t) {
				return (e / this.options.snap[t]).round() * this.options.snap[t]
			}.bind(this) : function(e) {
				return (e / this.options.snap).round() * this.options.snap
			}.bind(this)));
			var o = this.element.style;
			this.options.constraint && "horizontal" != this.options.constraint || (o.left = r[0] + "px"), this.options.constraint && "vertical" != this.options.constraint || (o.top = r[1] + "px"), "hidden" == o.visibility && (o.visibility = "")
		},
		stopScrolling: function() {
			this.scrollInterval && (clearInterval(this.scrollInterval), this.scrollInterval = null, Draggables._lastScrollPointer = null)
		},
		startScrolling: function(e) {
			(e[0] || e[1]) && (this.scrollSpeed = [e[0] * this.options.scrollSpeed, e[1] * this.options.scrollSpeed], this.lastScrolled = new Date, this.scrollInterval = setInterval(this.scroll.bind(this), 10))
		},
		scroll: function() {
			var current = new Date,
				delta = current - this.lastScrolled;
			if (this.lastScrolled = current, this.options.scroll == window) {
				with(this._getWindowScroll(this.options.scroll)) if (this.scrollSpeed[0] || this.scrollSpeed[1]) {
					var d = delta / 1e3;
					this.options.scroll.scrollTo(left + d * this.scrollSpeed[0], top + d * this.scrollSpeed[1])
				}
			} else this.options.scroll.scrollLeft += this.scrollSpeed[0] * delta / 1e3, this.options.scroll.scrollTop += this.scrollSpeed[1] * delta / 1e3;
			Position.prepare(), Droppables.show(Draggables._lastPointer, this.element), Draggables.notify("onDrag", this), this._isScrollChild && (Draggables._lastScrollPointer = Draggables._lastScrollPointer || $A(Draggables._lastPointer), Draggables._lastScrollPointer[0] += this.scrollSpeed[0] * delta / 1e3, Draggables._lastScrollPointer[1] += this.scrollSpeed[1] * delta / 1e3, Draggables._lastScrollPointer[0] < 0 && (Draggables._lastScrollPointer[0] = 0), Draggables._lastScrollPointer[1] < 0 && (Draggables._lastScrollPointer[1] = 0), this.draw(Draggables._lastScrollPointer)), this.options.change && this.options.change(this)
		},
		_getWindowScroll: function(w) {
			var T, L, W, H;
			with(w.document) w.document.documentElement && documentElement.scrollTop ? (T = documentElement.scrollTop, L = documentElement.scrollLeft) : w.document.body && (T = body.scrollTop, L = body.scrollLeft), w.innerWidth ? (W = w.innerWidth, H = w.innerHeight) : w.document.documentElement && documentElement.clientWidth ? (W = documentElement.clientWidth, H = documentElement.clientHeight) : (W = body.offsetWidth, H = body.offsetHeight);
			return {
				top: T,
				left: L,
				width: W,
				height: H
			}
		}
	});
Draggable._dragging = {};
var SortableObserver = Class.create({
		initialize: function(e, t) {
			this.element = $(e), this.observer = t, this.lastValue = Sortable.serialize(this.element)
		},
		onStart: function() {
			this.lastValue = Sortable.serialize(this.element)
		},
		onEnd: function() {
			Sortable.unmark(), this.lastValue != Sortable.serialize(this.element) && this.observer(this.element)
		}
	}),
	Sortable = {
		SERIALIZE_RULE: /^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,
		sortables: {},
		_findRootElement: function(e) {
			for (;
				"BODY" != e.tagName.toUpperCase();) {
				if (e.id && Sortable.sortables[e.id]) return e;
				e = e.parentNode
			}
		},
		options: function(e) {
			return (e = Sortable._findRootElement($(e))) ? Sortable.sortables[e.id] : void 0
		},
		destroy: function(e) {
			e = $(e);
			var t = Sortable.sortables[e.id];
			t && (Draggables.removeObserver(t.element), t.droppables.each(function(e) {
				Droppables.remove(e)
			}), t.draggables.invoke("destroy"), delete Sortable.sortables[t.element.id])
		},
		create: function(e) {
			e = $(e);
			var t = Object.extend({
				element: e,
				tag: "li",
				dropOnEmpty: !1,
				tree: !1,
				treeTag: "ul",
				overlap: "vertical",
				constraint: "vertical",
				containment: e,
				handle: !1,
				only: !1,
				delay: 0,
				hoverclass: null,
				ghosting: !1,
				quiet: !1,
				scroll: !1,
				scrollSensitivity: 20,
				scrollSpeed: 15,
				format: this.SERIALIZE_RULE,
				elements: !1,
				handles: !1,
				onChange: Prototype.emptyFunction,
				onUpdate: Prototype.emptyFunction
			}, arguments[1] || {});
			this.destroy(e);
			var n = {
				revert: !0,
				quiet: t.quiet,
				scroll: t.scroll,
				scrollSpeed: t.scrollSpeed,
				scrollSensitivity: t.scrollSensitivity,
				delay: t.delay,
				ghosting: t.ghosting,
				constraint: t.constraint,
				handle: t.handle
			};
			t.starteffect && (n.starteffect = t.starteffect), t.reverteffect ? n.reverteffect = t.reverteffect : t.ghosting && (n.reverteffect = function(e) {
				e.style.top = 0, e.style.left = 0
			}), t.endeffect && (n.endeffect = t.endeffect), t.zindex && (n.zindex = t.zindex);
			var i = {
					overlap: t.overlap,
					containment: t.containment,
					tree: t.tree,
					hoverclass: t.hoverclass,
					onHover: Sortable.onHover
				},
				r = {
					onHover: Sortable.onEmptyHover,
					overlap: t.overlap,
					containment: t.containment,
					hoverclass: t.hoverclass
				};
			Element.cleanWhitespace(e), t.draggables = [], t.droppables = [], (t.dropOnEmpty || t.tree) && (Droppables.add(e, r), t.droppables.push(e)), (t.elements || this.findElements(e, t) || []).each(function(r, o) {
				var a = t.handles ? $(t.handles[o]) : t.handle ? $(r).select("." + t.handle)[0] : r;
				t.draggables.push(new Draggable(r, Object.extend(n, {
					handle: a
				}))), Droppables.add(r, i), t.tree && (r.treeNode = e), t.droppables.push(r)
			}), t.tree && (Sortable.findTreeElements(e, t) || []).each(function(n) {
				Droppables.add(n, r), n.treeNode = e, t.droppables.push(n)
			}), this.sortables[e.identify()] = t, Draggables.addObserver(new SortableObserver(e, t.onUpdate))
		},
		findElements: function(e, t) {
			return Element.findChildren(e, t.only, t.tree ? !0 : !1, t.tag)
		},
		findTreeElements: function(e, t) {
			return Element.findChildren(e, t.only, t.tree ? !0 : !1, t.treeTag)
		},
		onHover: function(e, t, n) {
			if (!(Element.isParent(t, e) || n > .33 && .66 > n && Sortable.options(t).tree))
				if (n > .5) {
					if (Sortable.mark(t, "before"), t.previousSibling != e) {
						var i = e.parentNode;
						e.style.visibility = "hidden", t.parentNode.insertBefore(e, t), t.parentNode != i && Sortable.options(i).onChange(e), Sortable.options(t.parentNode).onChange(e)
					}
				} else {
					Sortable.mark(t, "after");
					var r = t.nextSibling || null;
					if (r != e) {
						var i = e.parentNode;
						e.style.visibility = "hidden", t.parentNode.insertBefore(e, r), t.parentNode != i && Sortable.options(i).onChange(e), Sortable.options(t.parentNode).onChange(e)
					}
				}
		},
		onEmptyHover: function(e, t, n) {
			var i = e.parentNode,
				r = Sortable.options(t);
			if (!Element.isParent(t, e)) {
				var o, a = Sortable.findElements(t, {
						tag: r.tag,
						only: r.only
					}),
					s = null;
				if (a) {
					var l = Element.offsetSize(t, r.overlap) * (1 - n);
					for (o = 0; o < a.length; o += 1) {
						if (!(l - Element.offsetSize(a[o], r.overlap) >= 0)) {
							if (l - Element.offsetSize(a[o], r.overlap) / 2 >= 0) {
								s = o + 1 < a.length ? a[o + 1] : null;
								break
							}
							s = a[o];
							break
						}
						l -= Element.offsetSize(a[o], r.overlap)
					}
				}
				t.insertBefore(e, s), Sortable.options(i).onChange(e), r.onChange(e)
			}
		},
		unmark: function() {
			Sortable._marker && Sortable._marker.hide()
		},
		mark: function(e, t) {
			var n = Sortable.options(e.parentNode);
			if (!n || n.ghosting) {
				Sortable._marker || (Sortable._marker = ($("dropmarker") || Element.extend(document.createElement("DIV"))).hide().addClassName("dropmarker").setStyle({
					position: "absolute"
				}), document.getElementsByTagName("body").item(0).appendChild(Sortable._marker));
				var i = e.cumulativeOffset();
				Sortable._marker.setStyle({
					left: i[0] + "px",
					top: i[1] + "px"
				}), "after" == t && Sortable._marker.setStyle("horizontal" == n.overlap ? {
					left: i[0] + e.clientWidth + "px"
				} : {
					top: i[1] + e.clientHeight + "px"
				}), Sortable._marker.show()
			}
		},
		_tree: function(e, t, n) {
			for (var i = Sortable.findElements(e, t) || [], r = 0; r < i.length; ++r) {
				var o = i[r].id.match(t.format);
				if (o) {
					var a = {
						id: encodeURIComponent(o ? o[1] : null),
						element: e,
						parent: n,
						children: [],
						position: n.children.length,
						container: $(i[r]).down(t.treeTag)
					};
					a.container && this._tree(a.container, t, a), n.children.push(a)
				}
			}
			return n
		},
		tree: function(e) {
			e = $(e);
			var t = this.options(e),
				n = Object.extend({
					tag: t.tag,
					treeTag: t.treeTag,
					only: t.only,
					name: e.id,
					format: t.format
				}, arguments[1] || {}),
				i = {
					id: null,
					parent: null,
					children: [],
					container: e,
					position: 0
				};
			return Sortable._tree(e, n, i)
		},
		_constructIndex: function(e) {
			var t = "";
			do e.id && (t = "[" + e.position + "]" + t); while (null != (e = e.parent));
			return t
		},
		sequence: function(e) {
			e = $(e);
			var t = Object.extend(this.options(e), arguments[1] || {});
			return $(this.findElements(e, t) || []).map(function(e) {
				return e.id.match(t.format) ? e.id.match(t.format)[1] : ""
			})
		},
		setSequence: function(e, t) {
			e = $(e);
			var n = Object.extend(this.options(e), arguments[2] || {}),
				i = {};
			this.findElements(e, n).each(function(e) {
				e.id.match(n.format) && (i[e.id.match(n.format)[1]] = [e, e.parentNode]), e.parentNode.removeChild(e)
			}), t.each(function(e) {
				var t = i[e];
				t && (t[1].appendChild(t[0]), delete i[e])
			})
		},
		serialize: function(e) {
			e = $(e);
			var t = Object.extend(Sortable.options(e), arguments[1] || {}),
				n = encodeURIComponent(arguments[1] && arguments[1].name ? arguments[1].name : e.id);
			return t.tree ? Sortable.tree(e, arguments[1]).children.map(function(e) {
				return [n + Sortable._constructIndex(e) + "[id]=" + encodeURIComponent(e.id)].concat(e.children.map(arguments.callee))
			}).flatten().join("&") : Sortable.sequence(e, arguments[1]).map(function(e) {
				return n + "[]=" + encodeURIComponent(e)
			}).join("&")
		}
	};
Element.isParent = function(e, t) {
	return e.parentNode && e != t ? e.parentNode == t ? !0 : Element.isParent(e.parentNode, t) : !1
}, Element.findChildren = function(e, t, n, i) {
	if (!e.hasChildNodes()) return null;
	i = i.toUpperCase(), t && (t = [t].flatten());
	var r = [];
	return $A(e.childNodes).each(function(e) {
		if (!e.tagName || e.tagName.toUpperCase() != i || t && !Element.classNames(e).detect(function(e) {
			return t.include(e)
		}) || r.push(e), n) {
			var o = Element.findChildren(e, t, n, i);
			o && r.push(o)
		}
	}), r.length > 0 ? r.flatten() : []
}, Element.offsetSize = function(e, t) {
	return e["offset" + ("vertical" == t || "height" == t ? "Height" : "Width")]
},
	function() {
		function e(e) {
			var t = document.createElement("div");
			e = "on" + e;
			var n = e in t;
			return n || (t.setAttribute(e, "return;"), n = "function" == typeof t[e]), t = null, n
		}

		function t(e) {
			return Object.isElement(e) && "FORM" == e.nodeName.toUpperCase()
		}

		function n(e) {
			if (Object.isElement(e)) {
				var t = e.nodeName.toUpperCase();
				return "INPUT" == t || "SELECT" == t || "TEXTAREA" == t
			}
			return !1
		}

		function i(e) {
			var t, n, i, r = e.fire("ajax:before");
			return r.stopped ? !1 : ("form" === e.tagName.toLowerCase() ? (t = e.readAttribute("method") || "post", n = e.readAttribute("action"), i = e.serialize()) : (t = e.readAttribute("data-method") || "get", n = e.readAttribute("href"), i = {}), new Ajax.Request(n, {
				method: t,
				parameters: i,
				evalScripts: !0,
				onComplete: function(t) {
					e.fire("ajax:complete", t)
				},
				onSuccess: function(t) {
					e.fire("ajax:success", t)
				},
				onFailure: function(t) {
					e.fire("ajax:failure", t)
				}
			}), void e.fire("ajax:after"))
		}

		function r(e) {
			var t = e.readAttribute("data-method"),
				n = e.readAttribute("href"),
				i = $$("meta[name=csrf-param]")[0],
				r = $$("meta[name=csrf-token]")[0],
				o = new Element("form", {
					method: "POST",
					action: n,
					style: "display: none;"
				});
			if (e.parentNode.insert(o), "post" !== t) {
				var a = new Element("input", {
					type: "hidden",
					name: "_method",
					value: t
				});
				o.insert(a)
			}
			if (i) {
				var s = i.readAttribute("content"),
					l = r.readAttribute("content"),
					a = new Element("input", {
						type: "hidden",
						name: s,
						value: l
					});
				o.insert(a)
			}
			o.submit()
		}
		var o = e("submit"),
			a = e("change");
		o && a || (Event.Handler.prototype.initialize = Event.Handler.prototype.initialize.wrap(function(e, i, r, s, l) {
			e(i, r, s, l), (!o && "submit" == this.eventName && !t(this.element) || !a && "change" == this.eventName && !n(this.element)) && (this.eventName = "emulated:" + this.eventName)
		})), o || document.on("focusin", "form", function(e, t) {
			t.retrieve("emulated:submit") || (t.on("submit", function(e) {
				var n = t.fire("emulated:submit", e, !0);
				n.returnValue === !1 && e.preventDefault()
			}), t.store("emulated:submit", !0))
		}), a || document.on("focusin", "input, select, texarea", function(e, t) {
			t.retrieve("emulated:change") || (t.on("change", function(e) {
				t.fire("emulated:change", e, !0)
			}), t.store("emulated:change", !0))
		}), document.on("click", "*[data-confirm]", function(e, t) {
			var n = t.readAttribute("data-confirm");
			confirm(n) || e.stop()
		}), document.on("click", "a[data-remote]", function(e, t) {
			e.stopped || (i(t), e.stop())
		}), document.on("click", "a[data-method]", function(e, t) {
			e.stopped || (r(t), e.stop())
		}), document.on("submit", function(e) {
			var t = e.findElement(),
				n = t.readAttribute("data-confirm");
			if (n && !confirm(n)) return e.stop(), !1;
			var r = t.select("input[type=submit][data-disable-with]");
			r.each(function(e) {
				e.disabled = !0, e.writeAttribute("data-original-value", e.value), e.value = e.readAttribute("data-disable-with")
			});
			var t = e.findElement("form[data-remote]");
			t && (i(t), e.stop())
		}), document.on("ajax:after", "form", function(e, t) {
			var n = t.select("input[type=submit][disabled=true][data-disable-with]");
			n.each(function(e) {
				e.value = e.readAttribute("data-original-value"), e.removeAttribute("data-original-value"), e.disabled = !1
			})
		})
	}(),
	/*!
	 * jQuery JavaScript Library v1.11.1
	 * http://jquery.com/
	 *
	 * Includes Sizzle.js
	 * http://sizzlejs.com/
	 *
	 * Copyright 2005, 2014 jQuery Foundation, Inc. and other contributors
	 * Released under the MIT license
	 * http://jquery.org/license
	 *
	 * Date: 2014-05-01T17:42Z
	 */
	function(e, t) {
		"object" == typeof module && "object" == typeof module.exports ? module.exports = e.document ? t(e, !0) : function(e) {
			if (!e.document) throw new Error("jQuery requires a window with a document");
			return t(e)
		} : t(e)
	}("undefined" != typeof window ? window : this, function(e, t) {
		function n(e) {
			var t = e.length,
				n = rt.type(e);
			return "function" === n || rt.isWindow(e) ? !1 : 1 === e.nodeType && t ? !0 : "array" === n || 0 === t || "number" == typeof t && t > 0 && t - 1 in e
		}

		function i(e, t, n) {
			if (rt.isFunction(t)) return rt.grep(e, function(e, i) {
				return !!t.call(e, i, e) !== n
			});
			if (t.nodeType) return rt.grep(e, function(e) {
				return e === t !== n
			});
			if ("string" == typeof t) {
				if (ht.test(t)) return rt.filter(t, e, n);
				t = rt.filter(t, e)
			}
			return rt.grep(e, function(e) {
				return rt.inArray(e, t) >= 0 !== n
			})
		}

		function r(e, t) {
			do e = e[t]; while (e && 1 !== e.nodeType);
			return e
		}

		function o(e) {
			var t = yt[e] = {};
			return rt.each(e.match(bt) || [], function(e, n) {
				t[n] = !0
			}), t
		}

		function a() {
			ft.addEventListener ? (ft.removeEventListener("DOMContentLoaded", s, !1), e.removeEventListener("load", s, !1)) : (ft.detachEvent("onreadystatechange", s), e.detachEvent("onload", s))
		}

		function s() {
			(ft.addEventListener || "load" === event.type || "complete" === ft.readyState) && (a(), rt.ready())
		}

		function l(e, t, n) {
			if (void 0 === n && 1 === e.nodeType) {
				var i = "data-" + t.replace(Ct, "-$1").toLowerCase();
				if (n = e.getAttribute(i), "string" == typeof n) {
					try {
						n = "true" === n ? !0 : "false" === n ? !1 : "null" === n ? null : +n + "" === n ? +n : kt.test(n) ? rt.parseJSON(n) : n
					} catch (r) {}
					rt.data(e, t, n)
				} else n = void 0
			}
			return n
		}

		function c(e) {
			var t;
			for (t in e)
				if (("data" !== t || !rt.isEmptyObject(e[t])) && "toJSON" !== t) return !1;
			return !0
		}

		function u(e, t, n, i) {
			if (rt.acceptData(e)) {
				var r, o, a = rt.expando,
					s = e.nodeType,
					l = s ? rt.cache : e,
					c = s ? e[a] : e[a] && a;
				if (c && l[c] && (i || l[c].data) || void 0 !== n || "string" != typeof t) return c || (c = s ? e[a] = Y.pop() || rt.guid++ : a), l[c] || (l[c] = s ? {} : {
					toJSON: rt.noop
				}), ("object" == typeof t || "function" == typeof t) && (i ? l[c] = rt.extend(l[c], t) : l[c].data = rt.extend(l[c].data, t)), o = l[c], i || (o.data || (o.data = {}), o = o.data), void 0 !== n && (o[rt.camelCase(t)] = n), "string" == typeof t ? (r = o[t], null == r && (r = o[rt.camelCase(t)])) : r = o, r
			}
		}

		function d(e, t, n) {
			if (rt.acceptData(e)) {
				var i, r, o = e.nodeType,
					a = o ? rt.cache : e,
					s = o ? e[rt.expando] : rt.expando;
				if (a[s]) {
					if (t && (i = n ? a[s] : a[s].data)) {
						rt.isArray(t) ? t = t.concat(rt.map(t, rt.camelCase)) : t in i ? t = [t] : (t = rt.camelCase(t), t = t in i ? [t] : t.split(" ")), r = t.length;
						for (; r--;) delete i[t[r]];
						if (n ? !c(i) : !rt.isEmptyObject(i)) return
					}(n || (delete a[s].data, c(a[s]))) && (o ? rt.cleanData([e], !0) : nt.deleteExpando || a != a.window ? delete a[s] : a[s] = null)
				}
			}
		}

		function h() {
			return !0
		}

		function p() {
			return !1
		}

		function f() {
			try {
				return ft.activeElement
			} catch (e) {}
		}

		function g(e) {
			var t = Pt.split("|"),
				n = e.createDocumentFragment();
			if (n.createElement)
				for (; t.length;) n.createElement(t.pop());
			return n
		}

		function m(e, t) {
			var n, i, r = 0,
				o = typeof e.getElementsByTagName !== Et ? e.getElementsByTagName(t || "*") : typeof e.querySelectorAll !== Et ? e.querySelectorAll(t || "*") : void 0;
			if (!o)
				for (o = [], n = e.childNodes || e; null != (i = n[r]); r++) !t || rt.nodeName(i, t) ? o.push(i) : rt.merge(o, m(i, t));
			return void 0 === t || t && rt.nodeName(e, t) ? rt.merge([e], o) : o
		}

		function v(e) {
			At.test(e.type) && (e.defaultChecked = e.checked)
		}

		function _(e, t) {
			return rt.nodeName(e, "table") && rt.nodeName(11 !== t.nodeType ? t : t.firstChild, "tr") ? e.getElementsByTagName("tbody")[0] || e.appendChild(e.ownerDocument.createElement("tbody")) : e
		}

		function b(e) {
			return e.type = (null !== rt.find.attr(e, "type")) + "/" + e.type, e
		}

		function y(e) {
			var t = Qt.exec(e.type);
			return t ? e.type = t[1] : e.removeAttribute("type"), e
		}

		function w(e, t) {
			for (var n, i = 0; null != (n = e[i]); i++) rt._data(n, "globalEval", !t || rt._data(t[i], "globalEval"))
		}

		function x(e, t) {
			if (1 === t.nodeType && rt.hasData(e)) {
				var n, i, r, o = rt._data(e),
					a = rt._data(t, o),
					s = o.events;
				if (s) {
					delete a.handle, a.events = {};
					for (n in s)
						for (i = 0, r = s[n].length; r > i; i++) rt.event.add(t, n, s[n][i])
				}
				a.data && (a.data = rt.extend({}, a.data))
			}
		}

		function E(e, t) {
			var n, i, r;
			if (1 === t.nodeType) {
				if (n = t.nodeName.toLowerCase(), !nt.noCloneEvent && t[rt.expando]) {
					r = rt._data(t);
					for (i in r.events) rt.removeEvent(t, i, r.handle);
					t.removeAttribute(rt.expando)
				}
				"script" === n && t.text !== e.text ? (b(t).text = e.text, y(t)) : "object" === n ? (t.parentNode && (t.outerHTML = e.outerHTML), nt.html5Clone && e.innerHTML && !rt.trim(t.innerHTML) && (t.innerHTML = e.innerHTML)) : "input" === n && At.test(e.type) ? (t.defaultChecked = t.checked = e.checked, t.value !== e.value && (t.value = e.value)) : "option" === n ? t.defaultSelected = t.selected = e.defaultSelected : ("input" === n || "textarea" === n) && (t.defaultValue = e.defaultValue)
			}
		}

		function k(t, n) {
			var i, r = rt(n.createElement(t)).appendTo(n.body),
				o = e.getDefaultComputedStyle && (i = e.getDefaultComputedStyle(r[0])) ? i.display : rt.css(r[0], "display");
			return r.detach(), o
		}

		function C(e) {
			var t = ft,
				n = Zt[e];
			return n || (n = k(e, t), "none" !== n && n || (Jt = (Jt || rt("<iframe frameborder='0' width='0' height='0'/>")).appendTo(t.documentElement), t = (Jt[0].contentWindow || Jt[0].contentDocument).document, t.write(), t.close(), n = k(e, t), Jt.detach()), Zt[e] = n), n
		}

		function T(e, t) {
			return {
				get: function() {
					var n = e();
					if (null != n) return n ? void delete this.get : (this.get = t).apply(this, arguments)
				}
			}
		}

		function S(e, t) {
			if (t in e) return t;
			for (var n = t.charAt(0).toUpperCase() + t.slice(1), i = t, r = pn.length; r--;)
				if (t = pn[r] + n, t in e) return t;
			return i
		}

		function O(e, t) {
			for (var n, i, r, o = [], a = 0, s = e.length; s > a; a++) i = e[a], i.style && (o[a] = rt._data(i, "olddisplay"), n = i.style.display, t ? (o[a] || "none" !== n || (i.style.display = ""), "" === i.style.display && Ot(i) && (o[a] = rt._data(i, "olddisplay", C(i.nodeName)))) : (r = Ot(i), (n && "none" !== n || !r) && rt._data(i, "olddisplay", r ? n : rt.css(i, "display"))));
			for (a = 0; s > a; a++) i = e[a], i.style && (t && "none" !== i.style.display && "" !== i.style.display || (i.style.display = t ? o[a] || "" : "none"));
			return e
		}

		function D(e, t, n) {
			var i = cn.exec(t);
			return i ? Math.max(0, i[1] - (n || 0)) + (i[2] || "px") : t
		}

		function A(e, t, n, i, r) {
			for (var o = n === (i ? "border" : "content") ? 4 : "width" === t ? 1 : 0, a = 0; 4 > o; o += 2) "margin" === n && (a += rt.css(e, n + St[o], !0, r)), i ? ("content" === n && (a -= rt.css(e, "padding" + St[o], !0, r)), "margin" !== n && (a -= rt.css(e, "border" + St[o] + "Width", !0, r))) : (a += rt.css(e, "padding" + St[o], !0, r), "padding" !== n && (a += rt.css(e, "border" + St[o] + "Width", !0, r)));
			return a
		}

		function N(e, t, n) {
			var i = !0,
				r = "width" === t ? e.offsetWidth : e.offsetHeight,
				o = en(e),
				a = nt.boxSizing && "border-box" === rt.css(e, "boxSizing", !1, o);
			if (0 >= r || null == r) {
				if (r = tn(e, t, o), (0 > r || null == r) && (r = e.style[t]), rn.test(r)) return r;
				i = a && (nt.boxSizingReliable() || r === e.style[t]), r = parseFloat(r) || 0
			}
			return r + A(e, t, n || (a ? "border" : "content"), i, o) + "px"
		}

		function I(e, t, n, i, r) {
			return new I.prototype.init(e, t, n, i, r)
		}

		function j() {
			return setTimeout(function() {
				fn = void 0
			}), fn = rt.now()
		}

		function F(e, t) {
			var n, i = {
					height: e
				},
				r = 0;
			for (t = t ? 1 : 0; 4 > r; r += 2 - t) n = St[r], i["margin" + n] = i["padding" + n] = e;
			return t && (i.opacity = i.width = e), i
		}

		function L(e, t, n) {
			for (var i, r = (yn[t] || []).concat(yn["*"]), o = 0, a = r.length; a > o; o++)
				if (i = r[o].call(n, t, e)) return i
		}

		function P(e, t, n) {
			var i, r, o, a, s, l, c, u, d = this,
				h = {},
				p = e.style,
				f = e.nodeType && Ot(e),
				g = rt._data(e, "fxshow");
			n.queue || (s = rt._queueHooks(e, "fx"), null == s.unqueued && (s.unqueued = 0, l = s.empty.fire, s.empty.fire = function() {
				s.unqueued || l()
			}), s.unqueued++, d.always(function() {
				d.always(function() {
					s.unqueued--, rt.queue(e, "fx").length || s.empty.fire()
				})
			})), 1 === e.nodeType && ("height" in t || "width" in t) && (n.overflow = [p.overflow, p.overflowX, p.overflowY], c = rt.css(e, "display"), u = "none" === c ? rt._data(e, "olddisplay") || C(e.nodeName) : c, "inline" === u && "none" === rt.css(e, "float") && (nt.inlineBlockNeedsLayout && "inline" !== C(e.nodeName) ? p.zoom = 1 : p.display = "inline-block")), n.overflow && (p.overflow = "hidden", nt.shrinkWrapBlocks() || d.always(function() {
				p.overflow = n.overflow[0], p.overflowX = n.overflow[1], p.overflowY = n.overflow[2]
			}));
			for (i in t)
				if (r = t[i], mn.exec(r)) {
					if (delete t[i], o = o || "toggle" === r, r === (f ? "hide" : "show")) {
						if ("show" !== r || !g || void 0 === g[i]) continue;
						f = !0
					}
					h[i] = g && g[i] || rt.style(e, i)
				} else c = void 0;
			if (rt.isEmptyObject(h)) "inline" === ("none" === c ? C(e.nodeName) : c) && (p.display = c);
			else {
				g ? "hidden" in g && (f = g.hidden) : g = rt._data(e, "fxshow", {}), o && (g.hidden = !f), f ? rt(e).show() : d.done(function() {
					rt(e).hide()
				}), d.done(function() {
					var t;
					rt._removeData(e, "fxshow");
					for (t in h) rt.style(e, t, h[t])
				});
				for (i in h) a = L(f ? g[i] : 0, i, d), i in g || (g[i] = a.start, f && (a.end = a.start, a.start = "width" === i || "height" === i ? 1 : 0))
			}
		}

		function H(e, t) {
			var n, i, r, o, a;
			for (n in e)
				if (i = rt.camelCase(n), r = t[i], o = e[n], rt.isArray(o) && (r = o[1], o = e[n] = o[0]), n !== i && (e[i] = o, delete e[n]), a = rt.cssHooks[i], a && "expand" in a) {
					o = a.expand(o), delete e[i];
					for (n in o) n in e || (e[n] = o[n], t[n] = r)
				} else t[i] = r
		}

		function M(e, t, n) {
			var i, r, o = 0,
				a = bn.length,
				s = rt.Deferred().always(function() {
					delete l.elem
				}),
				l = function() {
					if (r) return !1;
					for (var t = fn || j(), n = Math.max(0, c.startTime + c.duration - t), i = n / c.duration || 0, o = 1 - i, a = 0, l = c.tweens.length; l > a; a++) c.tweens[a].run(o);
					return s.notifyWith(e, [c, o, n]), 1 > o && l ? n : (s.resolveWith(e, [c]), !1)
				},
				c = s.promise({
					elem: e,
					props: rt.extend({}, t),
					opts: rt.extend(!0, {
						specialEasing: {}
					}, n),
					originalProperties: t,
					originalOptions: n,
					startTime: fn || j(),
					duration: n.duration,
					tweens: [],
					createTween: function(t, n) {
						var i = rt.Tween(e, c.opts, t, n, c.opts.specialEasing[t] || c.opts.easing);
						return c.tweens.push(i), i
					},
					stop: function(t) {
						var n = 0,
							i = t ? c.tweens.length : 0;
						if (r) return this;
						for (r = !0; i > n; n++) c.tweens[n].run(1);
						return t ? s.resolveWith(e, [c, t]) : s.rejectWith(e, [c, t]), this
					}
				}),
				u = c.props;
			for (H(u, c.opts.specialEasing); a > o; o++)
				if (i = bn[o].call(c, e, u, c.opts)) return i;
			return rt.map(u, L, c), rt.isFunction(c.opts.start) && c.opts.start.call(e, c), rt.fx.timer(rt.extend(l, {
				elem: e,
				anim: c,
				queue: c.opts.queue
			})), c.progress(c.opts.progress).done(c.opts.done, c.opts.complete).fail(c.opts.fail).always(c.opts.always)
		}

		function $(e) {
			return function(t, n) {
				"string" != typeof t && (n = t, t = "*");
				var i, r = 0,
					o = t.toLowerCase().match(bt) || [];
				if (rt.isFunction(n))
					for (; i = o[r++];) "+" === i.charAt(0) ? (i = i.slice(1) || "*", (e[i] = e[i] || []).unshift(n)) : (e[i] = e[i] || []).push(n)
			}
		}

		function W(e, t, n, i) {
			function r(s) {
				var l;
				return o[s] = !0, rt.each(e[s] || [], function(e, s) {
					var c = s(t, n, i);
					return "string" != typeof c || a || o[c] ? a ? !(l = c) : void 0 : (t.dataTypes.unshift(c), r(c), !1)
				}), l
			}
			var o = {},
				a = e === Bn;
			return r(t.dataTypes[0]) || !o["*"] && r("*")
		}

		function R(e, t) {
			var n, i, r = rt.ajaxSettings.flatOptions || {};
			for (i in t) void 0 !== t[i] && ((r[i] ? e : n || (n = {}))[i] = t[i]);
			return n && rt.extend(!0, e, n), e
		}

		function z(e, t, n) {
			for (var i, r, o, a, s = e.contents, l = e.dataTypes;
				 "*" === l[0];) l.shift(), void 0 === r && (r = e.mimeType || t.getResponseHeader("Content-Type"));
			if (r)
				for (a in s)
					if (s[a] && s[a].test(r)) {
						l.unshift(a);
						break
					}
			if (l[0] in n) o = l[0];
			else {
				for (a in n) {
					if (!l[0] || e.converters[a + " " + l[0]]) {
						o = a;
						break
					}
					i || (i = a)
				}
				o = o || i
			}
			return o ? (o !== l[0] && l.unshift(o), n[o]) : void 0
		}

		function U(e, t, n, i) {
			var r, o, a, s, l, c = {},
				u = e.dataTypes.slice();
			if (u[1])
				for (a in e.converters) c[a.toLowerCase()] = e.converters[a];
			for (o = u.shift(); o;)
				if (e.responseFields[o] && (n[e.responseFields[o]] = t), !l && i && e.dataFilter && (t = e.dataFilter(t, e.dataType)), l = o, o = u.shift())
					if ("*" === o) o = l;
					else if ("*" !== l && l !== o) {
						if (a = c[l + " " + o] || c["* " + o], !a)
							for (r in c)
								if (s = r.split(" "), s[1] === o && (a = c[l + " " + s[0]] || c["* " + s[0]])) {
									a === !0 ? a = c[r] : c[r] !== !0 && (o = s[0], u.unshift(s[1]));
									break
								}
						if (a !== !0)
							if (a && e["throws"]) t = a(t);
							else try {
								t = a(t)
							} catch (d) {
								return {
									state: "parsererror",
									error: a ? d : "No conversion from " + l + " to " + o
								}
							}
					}
			return {
				state: "success",
				data: t
			}
		}

		function B(e, t, n, i) {
			var r;
			if (rt.isArray(t)) rt.each(t, function(t, r) {
				n || Yn.test(e) ? i(e, r) : B(e + "[" + ("object" == typeof r ? t : "") + "]", r, n, i)
			});
			else if (n || "object" !== rt.type(t)) i(e, t);
			else
				for (r in t) B(e + "[" + r + "]", t[r], n, i)
		}

		function q() {
			try {
				return new e.XMLHttpRequest
			} catch (t) {}
		}

		function G() {
			try {
				return new e.ActiveXObject("Microsoft.XMLHTTP")
			} catch (t) {}
		}

		function Q(e) {
			return rt.isWindow(e) ? e : 9 === e.nodeType ? e.defaultView || e.parentWindow : !1
		}
		var Y = [],
			V = Y.slice,
			K = Y.concat,
			X = Y.push,
			J = Y.indexOf,
			Z = {},
			et = Z.toString,
			tt = Z.hasOwnProperty,
			nt = {},
			it = "1.11.1",
			rt = function(e, t) {
				return new rt.fn.init(e, t)
			},
			ot = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,
			at = /^-ms-/,
			st = /-([\da-z])/gi,
			lt = function(e, t) {
				return t.toUpperCase()
			};
		rt.fn = rt.prototype = {
			jquery: it,
			constructor: rt,
			selector: "",
			length: 0,
			toArray: function() {
				return V.call(this)
			},
			get: function(e) {
				return null != e ? 0 > e ? this[e + this.length] : this[e] : V.call(this)
			},
			pushStack: function(e) {
				var t = rt.merge(this.constructor(), e);
				return t.prevObject = this, t.context = this.context, t
			},
			each: function(e, t) {
				return rt.each(this, e, t)
			},
			map: function(e) {
				return this.pushStack(rt.map(this, function(t, n) {
					return e.call(t, n, t)
				}))
			},
			slice: function() {
				return this.pushStack(V.apply(this, arguments))
			},
			first: function() {
				return this.eq(0)
			},
			last: function() {
				return this.eq(-1)
			},
			eq: function(e) {
				var t = this.length,
					n = +e + (0 > e ? t : 0);
				return this.pushStack(n >= 0 && t > n ? [this[n]] : [])
			},
			end: function() {
				return this.prevObject || this.constructor(null)
			},
			push: X,
			sort: Y.sort,
			splice: Y.splice
		}, rt.extend = rt.fn.extend = function() {
			var e, t, n, i, r, o, a = arguments[0] || {},
				s = 1,
				l = arguments.length,
				c = !1;
			for ("boolean" == typeof a && (c = a, a = arguments[s] || {}, s++), "object" == typeof a || rt.isFunction(a) || (a = {}), s === l && (a = this, s--); l > s; s++)
				if (null != (r = arguments[s]))
					for (i in r) e = a[i], n = r[i], a !== n && (c && n && (rt.isPlainObject(n) || (t = rt.isArray(n))) ? (t ? (t = !1, o = e && rt.isArray(e) ? e : []) : o = e && rt.isPlainObject(e) ? e : {}, a[i] = rt.extend(c, o, n)) : void 0 !== n && (a[i] = n));
			return a
		}, rt.extend({
			expando: "jQuery" + (it + Math.random()).replace(/\D/g, ""),
			isReady: !0,
			error: function(e) {
				throw new Error(e)
			},
			noop: function() {},
			isFunction: function(e) {
				return "function" === rt.type(e)
			},
			isArray: Array.isArray || function(e) {
				return "array" === rt.type(e)
			},
			isWindow: function(e) {
				return null != e && e == e.window
			},
			isNumeric: function(e) {
				return !rt.isArray(e) && e - parseFloat(e) >= 0
			},
			isEmptyObject: function(e) {
				var t;
				for (t in e) return !1;
				return !0
			},
			isPlainObject: function(e) {
				var t;
				if (!e || "object" !== rt.type(e) || e.nodeType || rt.isWindow(e)) return !1;
				try {
					if (e.constructor && !tt.call(e, "constructor") && !tt.call(e.constructor.prototype, "isPrototypeOf")) return !1
				} catch (n) {
					return !1
				}
				if (nt.ownLast)
					for (t in e) return tt.call(e, t);
				for (t in e);
				return void 0 === t || tt.call(e, t)
			},
			type: function(e) {
				return null == e ? e + "" : "object" == typeof e || "function" == typeof e ? Z[et.call(e)] || "object" : typeof e
			},
			globalEval: function(t) {
				t && rt.trim(t) && (e.execScript || function(t) {
					e.eval.call(e, t)
				})(t)
			},
			camelCase: function(e) {
				return e.replace(at, "ms-").replace(st, lt)
			},
			nodeName: function(e, t) {
				return e.nodeName && e.nodeName.toLowerCase() === t.toLowerCase()
			},
			each: function(e, t, i) {
				var r, o = 0,
					a = e.length,
					s = n(e);
				if (i) {
					if (s)
						for (; a > o && (r = t.apply(e[o], i), r !== !1); o++);
					else
						for (o in e)
							if (r = t.apply(e[o], i), r === !1) break
				} else if (s)
					for (; a > o && (r = t.call(e[o], o, e[o]), r !== !1); o++);
				else
					for (o in e)
						if (r = t.call(e[o], o, e[o]), r === !1) break; return e
			},
			trim: function(e) {
				return null == e ? "" : (e + "").replace(ot, "")
			},
			makeArray: function(e, t) {
				var i = t || [];
				return null != e && (n(Object(e)) ? rt.merge(i, "string" == typeof e ? [e] : e) : X.call(i, e)), i
			},
			inArray: function(e, t, n) {
				var i;
				if (t) {
					if (J) return J.call(t, e, n);
					for (i = t.length, n = n ? 0 > n ? Math.max(0, i + n) : n : 0; i > n; n++)
						if (n in t && t[n] === e) return n
				}
				return -1
			},
			merge: function(e, t) {
				for (var n = +t.length, i = 0, r = e.length; n > i;) e[r++] = t[i++];
				if (n !== n)
					for (; void 0 !== t[i];) e[r++] = t[i++];
				return e.length = r, e
			},
			grep: function(e, t, n) {
				for (var i, r = [], o = 0, a = e.length, s = !n; a > o; o++) i = !t(e[o], o), i !== s && r.push(e[o]);
				return r
			},
			map: function(e, t, i) {
				var r, o = 0,
					a = e.length,
					s = n(e),
					l = [];
				if (s)
					for (; a > o; o++) r = t(e[o], o, i), null != r && l.push(r);
				else
					for (o in e) r = t(e[o], o, i), null != r && l.push(r);
				return K.apply([], l)
			},
			guid: 1,
			proxy: function(e, t) {
				var n, i, r;
				return "string" == typeof t && (r = e[t], t = e, e = r), rt.isFunction(e) ? (n = V.call(arguments, 2), i = function() {
					return e.apply(t || this, n.concat(V.call(arguments)))
				}, i.guid = e.guid = e.guid || rt.guid++, i) : void 0
			},
			now: function() {
				return +new Date
			},
			support: nt
		}), rt.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(e, t) {
			Z["[object " + t + "]"] = t.toLowerCase()
		});
		var ct =
			/*!
			 * Sizzle CSS Selector Engine v1.10.19
			 * http://sizzlejs.com/
			 *
			 * Copyright 2013 jQuery Foundation, Inc. and other contributors
			 * Released under the MIT license
			 * http://jquery.org/license
			 *
			 * Date: 2014-04-18
			 */
			function(e) {
				function t(e, t, n, i) {
					var r, o, a, s, l, c, d, p, f, g;
					if ((t ? t.ownerDocument || t : W) !== I && N(t), t = t || I, n = n || [], !e || "string" != typeof e) return n;
					if (1 !== (s = t.nodeType) && 9 !== s) return [];
					if (F && !i) {
						if (r = _t.exec(e))
							if (a = r[1]) {
								if (9 === s) {
									if (o = t.getElementById(a), !o || !o.parentNode) return n;
									if (o.id === a) return n.push(o), n
								} else if (t.ownerDocument && (o = t.ownerDocument.getElementById(a)) && M(t, o) && o.id === a) return n.push(o), n
							} else {
								if (r[2]) return Z.apply(n, t.getElementsByTagName(e)), n;
								if ((a = r[3]) && w.getElementsByClassName && t.getElementsByClassName) return Z.apply(n, t.getElementsByClassName(a)), n
							}
						if (w.qsa && (!L || !L.test(e))) {
							if (p = d = $, f = t, g = 9 === s && e, 1 === s && "object" !== t.nodeName.toLowerCase()) {
								for (c = C(e), (d = t.getAttribute("id")) ? p = d.replace(yt, "\\$&") : t.setAttribute("id", p), p = "[id='" + p + "'] ", l = c.length; l--;) c[l] = p + h(c[l]);
								f = bt.test(e) && u(t.parentNode) || t, g = c.join(",")
							}
							if (g) try {
								return Z.apply(n, f.querySelectorAll(g)), n
							} catch (m) {} finally {
								d || t.removeAttribute("id")
							}
						}
					}
					return S(e.replace(lt, "$1"), t, n, i)
				}

				function n() {
					function e(n, i) {
						return t.push(n + " ") > x.cacheLength && delete e[t.shift()], e[n + " "] = i
					}
					var t = [];
					return e
				}

				function i(e) {
					return e[$] = !0, e
				}

				function r(e) {
					var t = I.createElement("div");
					try {
						return !!e(t)
					} catch (n) {
						return !1
					} finally {
						t.parentNode && t.parentNode.removeChild(t), t = null
					}
				}

				function o(e, t) {
					for (var n = e.split("|"), i = e.length; i--;) x.attrHandle[n[i]] = t
				}

				function a(e, t) {
					var n = t && e,
						i = n && 1 === e.nodeType && 1 === t.nodeType && (~t.sourceIndex || Y) - (~e.sourceIndex || Y);
					if (i) return i;
					if (n)
						for (; n = n.nextSibling;)
							if (n === t) return -1;
					return e ? 1 : -1
				}

				function s(e) {
					return function(t) {
						var n = t.nodeName.toLowerCase();
						return "input" === n && t.type === e
					}
				}

				function l(e) {
					return function(t) {
						var n = t.nodeName.toLowerCase();
						return ("input" === n || "button" === n) && t.type === e
					}
				}

				function c(e) {
					return i(function(t) {
						return t = +t, i(function(n, i) {
							for (var r, o = e([], n.length, t), a = o.length; a--;) n[r = o[a]] && (n[r] = !(i[r] = n[r]))
						})
					})
				}

				function u(e) {
					return e && typeof e.getElementsByTagName !== Q && e
				}

				function d() {}

				function h(e) {
					for (var t = 0, n = e.length, i = ""; n > t; t++) i += e[t].value;
					return i
				}

				function p(e, t, n) {
					var i = t.dir,
						r = n && "parentNode" === i,
						o = z++;
					return t.first ? function(t, n, o) {
						for (; t = t[i];)
							if (1 === t.nodeType || r) return e(t, n, o)
					} : function(t, n, a) {
						var s, l, c = [R, o];
						if (a) {
							for (; t = t[i];)
								if ((1 === t.nodeType || r) && e(t, n, a)) return !0
						} else
							for (; t = t[i];)
								if (1 === t.nodeType || r) {
									if (l = t[$] || (t[$] = {}), (s = l[i]) && s[0] === R && s[1] === o) return c[2] = s[2];
									if (l[i] = c, c[2] = e(t, n, a)) return !0
								}
					}
				}

				function f(e) {
					return e.length > 1 ? function(t, n, i) {
						for (var r = e.length; r--;)
							if (!e[r](t, n, i)) return !1;
						return !0
					} : e[0]
				}

				function g(e, n, i) {
					for (var r = 0, o = n.length; o > r; r++) t(e, n[r], i);
					return i
				}

				function m(e, t, n, i, r) {
					for (var o, a = [], s = 0, l = e.length, c = null != t; l > s; s++)(o = e[s]) && (!n || n(o, i, r)) && (a.push(o), c && t.push(s));
					return a
				}

				function v(e, t, n, r, o, a) {
					return r && !r[$] && (r = v(r)), o && !o[$] && (o = v(o, a)), i(function(i, a, s, l) {
						var c, u, d, h = [],
							p = [],
							f = a.length,
							v = i || g(t || "*", s.nodeType ? [s] : s, []),
							_ = !e || !i && t ? v : m(v, h, e, s, l),
							b = n ? o || (i ? e : f || r) ? [] : a : _;
						if (n && n(_, b, s, l), r)
							for (c = m(b, p), r(c, [], s, l), u = c.length; u--;)(d = c[u]) && (b[p[u]] = !(_[p[u]] = d));
						if (i) {
							if (o || e) {
								if (o) {
									for (c = [], u = b.length; u--;)(d = b[u]) && c.push(_[u] = d);
									o(null, b = [], c, l)
								}
								for (u = b.length; u--;)(d = b[u]) && (c = o ? tt.call(i, d) : h[u]) > -1 && (i[c] = !(a[c] = d))
							}
						} else b = m(b === a ? b.splice(f, b.length) : b), o ? o(null, a, b, l) : Z.apply(a, b)
					})
				}

				function _(e) {
					for (var t, n, i, r = e.length, o = x.relative[e[0].type], a = o || x.relative[" "], s = o ? 1 : 0, l = p(function(e) {
						return e === t
					}, a, !0), c = p(function(e) {
						return tt.call(t, e) > -1
					}, a, !0), u = [
						function(e, n, i) {
							return !o && (i || n !== O) || ((t = n).nodeType ? l(e, n, i) : c(e, n, i))
						}
					]; r > s; s++)
						if (n = x.relative[e[s].type]) u = [p(f(u), n)];
						else {
							if (n = x.filter[e[s].type].apply(null, e[s].matches), n[$]) {
								for (i = ++s; r > i && !x.relative[e[i].type]; i++);
								return v(s > 1 && f(u), s > 1 && h(e.slice(0, s - 1).concat({
									value: " " === e[s - 2].type ? "*" : ""
								})).replace(lt, "$1"), n, i > s && _(e.slice(s, i)), r > i && _(e = e.slice(i)), r > i && h(e))
							}
							u.push(n)
						}
					return f(u)
				}

				function b(e, n) {
					var r = n.length > 0,
						o = e.length > 0,
						a = function(i, a, s, l, c) {
							var u, d, h, p = 0,
								f = "0",
								g = i && [],
								v = [],
								_ = O,
								b = i || o && x.find.TAG("*", c),
								y = R += null == _ ? 1 : Math.random() || .1,
								w = b.length;
							for (c && (O = a !== I && a); f !== w && null != (u = b[f]); f++) {
								if (o && u) {
									for (d = 0; h = e[d++];)
										if (h(u, a, s)) {
											l.push(u);
											break
										}
									c && (R = y)
								}
								r && ((u = !h && u) && p--, i && g.push(u))
							}
							if (p += f, r && f !== p) {
								for (d = 0; h = n[d++];) h(g, v, a, s);
								if (i) {
									if (p > 0)
										for (; f--;) g[f] || v[f] || (v[f] = X.call(l));
									v = m(v)
								}
								Z.apply(l, v), c && !i && v.length > 0 && p + n.length > 1 && t.uniqueSort(l)
							}
							return c && (R = y, O = _), g
						};
					return r ? i(a) : a
				}
				var y, w, x, E, k, C, T, S, O, D, A, N, I, j, F, L, P, H, M, $ = "sizzle" + -new Date,
					W = e.document,
					R = 0,
					z = 0,
					U = n(),
					B = n(),
					q = n(),
					G = function(e, t) {
						return e === t && (A = !0), 0
					},
					Q = "undefined",
					Y = 1 << 31,
					V = {}.hasOwnProperty,
					K = [],
					X = K.pop,
					J = K.push,
					Z = K.push,
					et = K.slice,
					tt = K.indexOf || function(e) {
						for (var t = 0, n = this.length; n > t; t++)
							if (this[t] === e) return t;
						return -1
					},
					nt = "checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",
					it = "[\\x20\\t\\r\\n\\f]",
					rt = "(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",
					ot = rt.replace("w", "w#"),
					at = "\\[" + it + "*(" + rt + ")(?:" + it + "*([*^$|!~]?=)" + it + "*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|(" + ot + "))|)" + it + "*\\]",
					st = ":(" + rt + ")(?:\\((('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|" + at + ")*)|.*)\\)|)",
					lt = new RegExp("^" + it + "+|((?:^|[^\\\\])(?:\\\\.)*)" + it + "+$", "g"),
					ct = new RegExp("^" + it + "*," + it + "*"),
					ut = new RegExp("^" + it + "*([>+~]|" + it + ")" + it + "*"),
					dt = new RegExp("=" + it + "*([^\\]'\"]*?)" + it + "*\\]", "g"),
					ht = new RegExp(st),
					pt = new RegExp("^" + ot + "$"),
					ft = {
						ID: new RegExp("^#(" + rt + ")"),
						CLASS: new RegExp("^\\.(" + rt + ")"),
						TAG: new RegExp("^(" + rt.replace("w", "w*") + ")"),
						ATTR: new RegExp("^" + at),
						PSEUDO: new RegExp("^" + st),
						CHILD: new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(" + it + "*(even|odd|(([+-]|)(\\d*)n|)" + it + "*(?:([+-]|)" + it + "*(\\d+)|))" + it + "*\\)|)", "i"),
						bool: new RegExp("^(?:" + nt + ")$", "i"),
						needsContext: new RegExp("^" + it + "*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + it + "*((?:-\\d)?\\d*)" + it + "*\\)|)(?=[^-]|$)", "i")
					},
					gt = /^(?:input|select|textarea|button)$/i,
					mt = /^h\d$/i,
					vt = /^[^{]+\{\s*\[native \w/,
					_t = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,
					bt = /[+~]/,
					yt = /'|\\/g,
					wt = new RegExp("\\\\([\\da-f]{1,6}" + it + "?|(" + it + ")|.)", "ig"),
					xt = function(e, t, n) {
						var i = "0x" + t - 65536;
						return i !== i || n ? t : 0 > i ? String.fromCharCode(i + 65536) : String.fromCharCode(i >> 10 | 55296, 1023 & i | 56320)
					};
				try {
					Z.apply(K = et.call(W.childNodes), W.childNodes), K[W.childNodes.length].nodeType
				} catch (Et) {
					Z = {
						apply: K.length ? function(e, t) {
							J.apply(e, et.call(t))
						} : function(e, t) {
							for (var n = e.length, i = 0; e[n++] = t[i++];);
							e.length = n - 1
						}
					}
				}
				w = t.support = {}, k = t.isXML = function(e) {
					var t = e && (e.ownerDocument || e).documentElement;
					return t ? "HTML" !== t.nodeName : !1
				}, N = t.setDocument = function(e) {
					var t, n = e ? e.ownerDocument || e : W,
						i = n.defaultView;
					return n !== I && 9 === n.nodeType && n.documentElement ? (I = n, j = n.documentElement, F = !k(n), i && i !== i.top && (i.addEventListener ? i.addEventListener("unload", function() {
						N()
					}, !1) : i.attachEvent && i.attachEvent("onunload", function() {
						N()
					})), w.attributes = r(function(e) {
						return e.className = "i", !e.getAttribute("className")
					}), w.getElementsByTagName = r(function(e) {
						return e.appendChild(n.createComment("")), !e.getElementsByTagName("*").length
					}), w.getElementsByClassName = vt.test(n.getElementsByClassName) && r(function(e) {
						return e.innerHTML = "<div class='a'></div><div class='a i'></div>", e.firstChild.className = "i", 2 === e.getElementsByClassName("i").length
					}), w.getById = r(function(e) {
						return j.appendChild(e).id = $, !n.getElementsByName || !n.getElementsByName($).length
					}), w.getById ? (x.find.ID = function(e, t) {
						if (typeof t.getElementById !== Q && F) {
							var n = t.getElementById(e);
							return n && n.parentNode ? [n] : []
						}
					}, x.filter.ID = function(e) {
						var t = e.replace(wt, xt);
						return function(e) {
							return e.getAttribute("id") === t
						}
					}) : (delete x.find.ID, x.filter.ID = function(e) {
						var t = e.replace(wt, xt);
						return function(e) {
							var n = typeof e.getAttributeNode !== Q && e.getAttributeNode("id");
							return n && n.value === t
						}
					}), x.find.TAG = w.getElementsByTagName ? function(e, t) {
						return typeof t.getElementsByTagName !== Q ? t.getElementsByTagName(e) : void 0
					} : function(e, t) {
						var n, i = [],
							r = 0,
							o = t.getElementsByTagName(e);
						if ("*" === e) {
							for (; n = o[r++];) 1 === n.nodeType && i.push(n);
							return i
						}
						return o
					}, x.find.CLASS = w.getElementsByClassName && function(e, t) {
						return typeof t.getElementsByClassName !== Q && F ? t.getElementsByClassName(e) : void 0
					}, P = [], L = [], (w.qsa = vt.test(n.querySelectorAll)) && (r(function(e) {
						e.innerHTML = "<select msallowclip=''><option selected=''></option></select>", e.querySelectorAll("[msallowclip^='']").length && L.push("[*^$]=" + it + "*(?:''|\"\")"), e.querySelectorAll("[selected]").length || L.push("\\[" + it + "*(?:value|" + nt + ")"), e.querySelectorAll(":checked").length || L.push(":checked")
					}), r(function(e) {
						var t = n.createElement("input");
						t.setAttribute("type", "hidden"), e.appendChild(t).setAttribute("name", "D"), e.querySelectorAll("[name=d]").length && L.push("name" + it + "*[*^$|!~]?="), e.querySelectorAll(":enabled").length || L.push(":enabled", ":disabled"), e.querySelectorAll("*,:x"), L.push(",.*:")
					})), (w.matchesSelector = vt.test(H = j.matches || j.webkitMatchesSelector || j.mozMatchesSelector || j.oMatchesSelector || j.msMatchesSelector)) && r(function(e) {
						w.disconnectedMatch = H.call(e, "div"), H.call(e, "[s!='']:x"), P.push("!=", st)
					}), L = L.length && new RegExp(L.join("|")), P = P.length && new RegExp(P.join("|")), t = vt.test(j.compareDocumentPosition), M = t || vt.test(j.contains) ? function(e, t) {
						var n = 9 === e.nodeType ? e.documentElement : e,
							i = t && t.parentNode;
						return e === i || !(!i || 1 !== i.nodeType || !(n.contains ? n.contains(i) : e.compareDocumentPosition && 16 & e.compareDocumentPosition(i)))
					} : function(e, t) {
						if (t)
							for (; t = t.parentNode;)
								if (t === e) return !0;
						return !1
					}, G = t ? function(e, t) {
						if (e === t) return A = !0, 0;
						var i = !e.compareDocumentPosition - !t.compareDocumentPosition;
						return i ? i : (i = (e.ownerDocument || e) === (t.ownerDocument || t) ? e.compareDocumentPosition(t) : 1, 1 & i || !w.sortDetached && t.compareDocumentPosition(e) === i ? e === n || e.ownerDocument === W && M(W, e) ? -1 : t === n || t.ownerDocument === W && M(W, t) ? 1 : D ? tt.call(D, e) - tt.call(D, t) : 0 : 4 & i ? -1 : 1)
					} : function(e, t) {
						if (e === t) return A = !0, 0;
						var i, r = 0,
							o = e.parentNode,
							s = t.parentNode,
							l = [e],
							c = [t];
						if (!o || !s) return e === n ? -1 : t === n ? 1 : o ? -1 : s ? 1 : D ? tt.call(D, e) - tt.call(D, t) : 0;
						if (o === s) return a(e, t);
						for (i = e; i = i.parentNode;) l.unshift(i);
						for (i = t; i = i.parentNode;) c.unshift(i);
						for (; l[r] === c[r];) r++;
						return r ? a(l[r], c[r]) : l[r] === W ? -1 : c[r] === W ? 1 : 0
					}, n) : I
				}, t.matches = function(e, n) {
					return t(e, null, null, n)
				}, t.matchesSelector = function(e, n) {
					if ((e.ownerDocument || e) !== I && N(e), n = n.replace(dt, "='$1']"), !(!w.matchesSelector || !F || P && P.test(n) || L && L.test(n))) try {
						var i = H.call(e, n);
						if (i || w.disconnectedMatch || e.document && 11 !== e.document.nodeType) return i
					} catch (r) {}
					return t(n, I, null, [e]).length > 0
				}, t.contains = function(e, t) {
					return (e.ownerDocument || e) !== I && N(e), M(e, t)
				}, t.attr = function(e, t) {
					(e.ownerDocument || e) !== I && N(e);
					var n = x.attrHandle[t.toLowerCase()],
						i = n && V.call(x.attrHandle, t.toLowerCase()) ? n(e, t, !F) : void 0;
					return void 0 !== i ? i : w.attributes || !F ? e.getAttribute(t) : (i = e.getAttributeNode(t)) && i.specified ? i.value : null
				}, t.error = function(e) {
					throw new Error("Syntax error, unrecognized expression: " + e)
				}, t.uniqueSort = function(e) {
					var t, n = [],
						i = 0,
						r = 0;
					if (A = !w.detectDuplicates, D = !w.sortStable && e.slice(0), e.sort(G), A) {
						for (; t = e[r++];) t === e[r] && (i = n.push(r));
						for (; i--;) e.splice(n[i], 1)
					}
					return D = null, e
				}, E = t.getText = function(e) {
					var t, n = "",
						i = 0,
						r = e.nodeType;
					if (r) {
						if (1 === r || 9 === r || 11 === r) {
							if ("string" == typeof e.textContent) return e.textContent;
							for (e = e.firstChild; e; e = e.nextSibling) n += E(e)
						} else if (3 === r || 4 === r) return e.nodeValue
					} else
						for (; t = e[i++];) n += E(t);
					return n
				}, x = t.selectors = {
					cacheLength: 50,
					createPseudo: i,
					match: ft,
					attrHandle: {},
					find: {},
					relative: {
						">": {
							dir: "parentNode",
							first: !0
						},
						" ": {
							dir: "parentNode"
						},
						"+": {
							dir: "previousSibling",
							first: !0
						},
						"~": {
							dir: "previousSibling"
						}
					},
					preFilter: {
						ATTR: function(e) {
							return e[1] = e[1].replace(wt, xt), e[3] = (e[3] || e[4] || e[5] || "").replace(wt, xt), "~=" === e[2] && (e[3] = " " + e[3] + " "), e.slice(0, 4)
						},
						CHILD: function(e) {
							return e[1] = e[1].toLowerCase(), "nth" === e[1].slice(0, 3) ? (e[3] || t.error(e[0]), e[4] = +(e[4] ? e[5] + (e[6] || 1) : 2 * ("even" === e[3] || "odd" === e[3])), e[5] = +(e[7] + e[8] || "odd" === e[3])) : e[3] && t.error(e[0]), e
						},
						PSEUDO: function(e) {
							var t, n = !e[6] && e[2];
							return ft.CHILD.test(e[0]) ? null : (e[3] ? e[2] = e[4] || e[5] || "" : n && ht.test(n) && (t = C(n, !0)) && (t = n.indexOf(")", n.length - t) - n.length) && (e[0] = e[0].slice(0, t), e[2] = n.slice(0, t)), e.slice(0, 3))
						}
					},
					filter: {
						TAG: function(e) {
							var t = e.replace(wt, xt).toLowerCase();
							return "*" === e ? function() {
								return !0
							} : function(e) {
								return e.nodeName && e.nodeName.toLowerCase() === t
							}
						},
						CLASS: function(e) {
							var t = U[e + " "];
							return t || (t = new RegExp("(^|" + it + ")" + e + "(" + it + "|$)")) && U(e, function(e) {
								return t.test("string" == typeof e.className && e.className || typeof e.getAttribute !== Q && e.getAttribute("class") || "")
							})
						},
						ATTR: function(e, n, i) {
							return function(r) {
								var o = t.attr(r, e);
								return null == o ? "!=" === n : n ? (o += "", "=" === n ? o === i : "!=" === n ? o !== i : "^=" === n ? i && 0 === o.indexOf(i) : "*=" === n ? i && o.indexOf(i) > -1 : "$=" === n ? i && o.slice(-i.length) === i : "~=" === n ? (" " + o + " ").indexOf(i) > -1 : "|=" === n ? o === i || o.slice(0, i.length + 1) === i + "-" : !1) : !0
							}
						},
						CHILD: function(e, t, n, i, r) {
							var o = "nth" !== e.slice(0, 3),
								a = "last" !== e.slice(-4),
								s = "of-type" === t;
							return 1 === i && 0 === r ? function(e) {
								return !!e.parentNode
							} : function(t, n, l) {
								var c, u, d, h, p, f, g = o !== a ? "nextSibling" : "previousSibling",
									m = t.parentNode,
									v = s && t.nodeName.toLowerCase(),
									_ = !l && !s;
								if (m) {
									if (o) {
										for (; g;) {
											for (d = t; d = d[g];)
												if (s ? d.nodeName.toLowerCase() === v : 1 === d.nodeType) return !1;
											f = g = "only" === e && !f && "nextSibling"
										}
										return !0
									}
									if (f = [a ? m.firstChild : m.lastChild], a && _) {
										for (u = m[$] || (m[$] = {}), c = u[e] || [], p = c[0] === R && c[1], h = c[0] === R && c[2], d = p && m.childNodes[p]; d = ++p && d && d[g] || (h = p = 0) || f.pop();)
											if (1 === d.nodeType && ++h && d === t) {
												u[e] = [R, p, h];
												break
											}
									} else if (_ && (c = (t[$] || (t[$] = {}))[e]) && c[0] === R) h = c[1];
									else
										for (;
											(d = ++p && d && d[g] || (h = p = 0) || f.pop()) && ((s ? d.nodeName.toLowerCase() !== v : 1 !== d.nodeType) || !++h || (_ && ((d[$] || (d[$] = {}))[e] = [R, h]), d !== t)););
									return h -= r, h === i || h % i === 0 && h / i >= 0
								}
							}
						},
						PSEUDO: function(e, n) {
							var r, o = x.pseudos[e] || x.setFilters[e.toLowerCase()] || t.error("unsupported pseudo: " + e);
							return o[$] ? o(n) : o.length > 1 ? (r = [e, e, "", n], x.setFilters.hasOwnProperty(e.toLowerCase()) ? i(function(e, t) {
								for (var i, r = o(e, n), a = r.length; a--;) i = tt.call(e, r[a]), e[i] = !(t[i] = r[a])
							}) : function(e) {
								return o(e, 0, r)
							}) : o
						}
					},
					pseudos: {
						not: i(function(e) {
							var t = [],
								n = [],
								r = T(e.replace(lt, "$1"));
							return r[$] ? i(function(e, t, n, i) {
								for (var o, a = r(e, null, i, []), s = e.length; s--;)(o = a[s]) && (e[s] = !(t[s] = o))
							}) : function(e, i, o) {
								return t[0] = e, r(t, null, o, n), !n.pop()
							}
						}),
						has: i(function(e) {
							return function(n) {
								return t(e, n).length > 0
							}
						}),
						contains: i(function(e) {
							return function(t) {
								return (t.textContent || t.innerText || E(t)).indexOf(e) > -1
							}
						}),
						lang: i(function(e) {
							return pt.test(e || "") || t.error("unsupported lang: " + e), e = e.replace(wt, xt).toLowerCase(),
								function(t) {
									var n;
									do
										if (n = F ? t.lang : t.getAttribute("xml:lang") || t.getAttribute("lang")) return n = n.toLowerCase(), n === e || 0 === n.indexOf(e + "-");
									while ((t = t.parentNode) && 1 === t.nodeType);
									return !1
								}
						}),
						target: function(t) {
							var n = e.location && e.location.hash;
							return n && n.slice(1) === t.id
						},
						root: function(e) {
							return e === j
						},
						focus: function(e) {
							return e === I.activeElement && (!I.hasFocus || I.hasFocus()) && !!(e.type || e.href || ~e.tabIndex)
						},
						enabled: function(e) {
							return e.disabled === !1
						},
						disabled: function(e) {
							return e.disabled === !0
						},
						checked: function(e) {
							var t = e.nodeName.toLowerCase();
							return "input" === t && !!e.checked || "option" === t && !!e.selected
						},
						selected: function(e) {
							return e.parentNode && e.parentNode.selectedIndex, e.selected === !0
						},
						empty: function(e) {
							for (e = e.firstChild; e; e = e.nextSibling)
								if (e.nodeType < 6) return !1;
							return !0
						},
						parent: function(e) {
							return !x.pseudos.empty(e)
						},
						header: function(e) {
							return mt.test(e.nodeName)
						},
						input: function(e) {
							return gt.test(e.nodeName)
						},
						button: function(e) {
							var t = e.nodeName.toLowerCase();
							return "input" === t && "button" === e.type || "button" === t
						},
						text: function(e) {
							var t;
							return "input" === e.nodeName.toLowerCase() && "text" === e.type && (null == (t = e.getAttribute("type")) || "text" === t.toLowerCase())
						},
						first: c(function() {
							return [0]
						}),
						last: c(function(e, t) {
							return [t - 1]
						}),
						eq: c(function(e, t, n) {
							return [0 > n ? n + t : n]
						}),
						even: c(function(e, t) {
							for (var n = 0; t > n; n += 2) e.push(n);
							return e
						}),
						odd: c(function(e, t) {
							for (var n = 1; t > n; n += 2) e.push(n);
							return e
						}),
						lt: c(function(e, t, n) {
							for (var i = 0 > n ? n + t : n; --i >= 0;) e.push(i);
							return e
						}),
						gt: c(function(e, t, n) {
							for (var i = 0 > n ? n + t : n; ++i < t;) e.push(i);
							return e
						})
					}
				}, x.pseudos.nth = x.pseudos.eq;
				for (y in {
					radio: !0,
					checkbox: !0,
					file: !0,
					password: !0,
					image: !0
				}) x.pseudos[y] = s(y);
				for (y in {
					submit: !0,
					reset: !0
				}) x.pseudos[y] = l(y);
				return d.prototype = x.filters = x.pseudos, x.setFilters = new d, C = t.tokenize = function(e, n) {
					var i, r, o, a, s, l, c, u = B[e + " "];
					if (u) return n ? 0 : u.slice(0);
					for (s = e, l = [], c = x.preFilter; s;) {
						(!i || (r = ct.exec(s))) && (r && (s = s.slice(r[0].length) || s), l.push(o = [])), i = !1, (r = ut.exec(s)) && (i = r.shift(), o.push({
							value: i,
							type: r[0].replace(lt, " ")
						}), s = s.slice(i.length));
						for (a in x.filter) !(r = ft[a].exec(s)) || c[a] && !(r = c[a](r)) || (i = r.shift(), o.push({
							value: i,
							type: a,
							matches: r
						}), s = s.slice(i.length));
						if (!i) break
					}
					return n ? s.length : s ? t.error(e) : B(e, l).slice(0)
				}, T = t.compile = function(e, t) {
					var n, i = [],
						r = [],
						o = q[e + " "];
					if (!o) {
						for (t || (t = C(e)), n = t.length; n--;) o = _(t[n]), o[$] ? i.push(o) : r.push(o);
						o = q(e, b(r, i)), o.selector = e
					}
					return o
				}, S = t.select = function(e, t, n, i) {
					var r, o, a, s, l, c = "function" == typeof e && e,
						d = !i && C(e = c.selector || e);
					if (n = n || [], 1 === d.length) {
						if (o = d[0] = d[0].slice(0), o.length > 2 && "ID" === (a = o[0]).type && w.getById && 9 === t.nodeType && F && x.relative[o[1].type]) {
							if (t = (x.find.ID(a.matches[0].replace(wt, xt), t) || [])[0], !t) return n;
							c && (t = t.parentNode), e = e.slice(o.shift().value.length)
						}
						for (r = ft.needsContext.test(e) ? 0 : o.length; r-- && (a = o[r], !x.relative[s = a.type]);)
							if ((l = x.find[s]) && (i = l(a.matches[0].replace(wt, xt), bt.test(o[0].type) && u(t.parentNode) || t))) {
								if (o.splice(r, 1), e = i.length && h(o), !e) return Z.apply(n, i), n;
								break
							}
					}
					return (c || T(e, d))(i, t, !F, n, bt.test(e) && u(t.parentNode) || t), n
				}, w.sortStable = $.split("").sort(G).join("") === $, w.detectDuplicates = !!A, N(), w.sortDetached = r(function(e) {
					return 1 & e.compareDocumentPosition(I.createElement("div"))
				}), r(function(e) {
					return e.innerHTML = "<a href='#'></a>", "#" === e.firstChild.getAttribute("href")
				}) || o("type|href|height|width", function(e, t, n) {
					return n ? void 0 : e.getAttribute(t, "type" === t.toLowerCase() ? 1 : 2)
				}), w.attributes && r(function(e) {
					return e.innerHTML = "<input/>", e.firstChild.setAttribute("value", ""), "" === e.firstChild.getAttribute("value")
				}) || o("value", function(e, t, n) {
					return n || "input" !== e.nodeName.toLowerCase() ? void 0 : e.defaultValue
				}), r(function(e) {
					return null == e.getAttribute("disabled")
				}) || o(nt, function(e, t, n) {
					var i;
					return n ? void 0 : e[t] === !0 ? t.toLowerCase() : (i = e.getAttributeNode(t)) && i.specified ? i.value : null
				}), t
			}(e);
		rt.find = ct, rt.expr = ct.selectors, rt.expr[":"] = rt.expr.pseudos, rt.unique = ct.uniqueSort, rt.text = ct.getText, rt.isXMLDoc = ct.isXML, rt.contains = ct.contains;
		var ut = rt.expr.match.needsContext,
			dt = /^<(\w+)\s*\/?>(?:<\/\1>|)$/,
			ht = /^.[^:#\[\.,]*$/;
		rt.filter = function(e, t, n) {
			var i = t[0];
			return n && (e = ":not(" + e + ")"), 1 === t.length && 1 === i.nodeType ? rt.find.matchesSelector(i, e) ? [i] : [] : rt.find.matches(e, rt.grep(t, function(e) {
				return 1 === e.nodeType
			}))
		}, rt.fn.extend({
			find: function(e) {
				var t, n = [],
					i = this,
					r = i.length;
				if ("string" != typeof e) return this.pushStack(rt(e).filter(function() {
					for (t = 0; r > t; t++)
						if (rt.contains(i[t], this)) return !0
				}));
				for (t = 0; r > t; t++) rt.find(e, i[t], n);
				return n = this.pushStack(r > 1 ? rt.unique(n) : n), n.selector = this.selector ? this.selector + " " + e : e, n
			},
			filter: function(e) {
				return this.pushStack(i(this, e || [], !1))
			},
			not: function(e) {
				return this.pushStack(i(this, e || [], !0))
			},
			is: function(e) {
				return !!i(this, "string" == typeof e && ut.test(e) ? rt(e) : e || [], !1).length
			}
		});
		var pt, ft = e.document,
			gt = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,
			mt = rt.fn.init = function(e, t) {
				var n, i;
				if (!e) return this;
				if ("string" == typeof e) {
					if (n = "<" === e.charAt(0) && ">" === e.charAt(e.length - 1) && e.length >= 3 ? [null, e, null] : gt.exec(e), !n || !n[1] && t) return !t || t.jquery ? (t || pt).find(e) : this.constructor(t).find(e);
					if (n[1]) {
						if (t = t instanceof rt ? t[0] : t, rt.merge(this, rt.parseHTML(n[1], t && t.nodeType ? t.ownerDocument || t : ft, !0)), dt.test(n[1]) && rt.isPlainObject(t))
							for (n in t) rt.isFunction(this[n]) ? this[n](t[n]) : this.attr(n, t[n]);
						return this
					}
					if (i = ft.getElementById(n[2]), i && i.parentNode) {
						if (i.id !== n[2]) return pt.find(e);
						this.length = 1, this[0] = i
					}
					return this.context = ft, this.selector = e, this
				}
				return e.nodeType ? (this.context = this[0] = e, this.length = 1, this) : rt.isFunction(e) ? "undefined" != typeof pt.ready ? pt.ready(e) : e(rt) : (void 0 !== e.selector && (this.selector = e.selector, this.context = e.context), rt.makeArray(e, this))
			};
		mt.prototype = rt.fn, pt = rt(ft);
		var vt = /^(?:parents|prev(?:Until|All))/,
			_t = {
				children: !0,
				contents: !0,
				next: !0,
				prev: !0
			};
		rt.extend({
			dir: function(e, t, n) {
				for (var i = [], r = e[t]; r && 9 !== r.nodeType && (void 0 === n || 1 !== r.nodeType || !rt(r).is(n));) 1 === r.nodeType && i.push(r), r = r[t];
				return i
			},
			sibling: function(e, t) {
				for (var n = []; e; e = e.nextSibling) 1 === e.nodeType && e !== t && n.push(e);
				return n
			}
		}), rt.fn.extend({
			has: function(e) {
				var t, n = rt(e, this),
					i = n.length;
				return this.filter(function() {
					for (t = 0; i > t; t++)
						if (rt.contains(this, n[t])) return !0
				})
			},
			closest: function(e, t) {
				for (var n, i = 0, r = this.length, o = [], a = ut.test(e) || "string" != typeof e ? rt(e, t || this.context) : 0; r > i; i++)
					for (n = this[i]; n && n !== t; n = n.parentNode)
						if (n.nodeType < 11 && (a ? a.index(n) > -1 : 1 === n.nodeType && rt.find.matchesSelector(n, e))) {
							o.push(n);
							break
						}
				return this.pushStack(o.length > 1 ? rt.unique(o) : o)
			},
			index: function(e) {
				return e ? "string" == typeof e ? rt.inArray(this[0], rt(e)) : rt.inArray(e.jquery ? e[0] : e, this) : this[0] && this[0].parentNode ? this.first().prevAll().length : -1
			},
			add: function(e, t) {
				return this.pushStack(rt.unique(rt.merge(this.get(), rt(e, t))))
			},
			addBack: function(e) {
				return this.add(null == e ? this.prevObject : this.prevObject.filter(e))
			}
		}), rt.each({
			parent: function(e) {
				var t = e.parentNode;
				return t && 11 !== t.nodeType ? t : null
			},
			parents: function(e) {
				return rt.dir(e, "parentNode")
			},
			parentsUntil: function(e, t, n) {
				return rt.dir(e, "parentNode", n)
			},
			next: function(e) {
				return r(e, "nextSibling")
			},
			prev: function(e) {
				return r(e, "previousSibling")
			},
			nextAll: function(e) {
				return rt.dir(e, "nextSibling")
			},
			prevAll: function(e) {
				return rt.dir(e, "previousSibling")
			},
			nextUntil: function(e, t, n) {
				return rt.dir(e, "nextSibling", n)
			},
			prevUntil: function(e, t, n) {
				return rt.dir(e, "previousSibling", n)
			},
			siblings: function(e) {
				return rt.sibling((e.parentNode || {}).firstChild, e)
			},
			children: function(e) {
				return rt.sibling(e.firstChild)
			},
			contents: function(e) {
				return rt.nodeName(e, "iframe") ? e.contentDocument || e.contentWindow.document : rt.merge([], e.childNodes)
			}
		}, function(e, t) {
			rt.fn[e] = function(n, i) {
				var r = rt.map(this, t, n);
				return "Until" !== e.slice(-5) && (i = n), i && "string" == typeof i && (r = rt.filter(i, r)), this.length > 1 && (_t[e] || (r = rt.unique(r)), vt.test(e) && (r = r.reverse())), this.pushStack(r)
			}
		});
		var bt = /\S+/g,
			yt = {};
		rt.Callbacks = function(e) {
			e = "string" == typeof e ? yt[e] || o(e) : rt.extend({}, e);
			var t, n, i, r, a, s, l = [],
				c = !e.once && [],
				u = function(o) {
					for (n = e.memory && o, i = !0, a = s || 0, s = 0, r = l.length, t = !0; l && r > a; a++)
						if (l[a].apply(o[0], o[1]) === !1 && e.stopOnFalse) {
							n = !1;
							break
						}
					t = !1, l && (c ? c.length && u(c.shift()) : n ? l = [] : d.disable())
				},
				d = {
					add: function() {
						if (l) {
							var i = l.length;
							! function o(t) {
								rt.each(t, function(t, n) {
									var i = rt.type(n);
									"function" === i ? e.unique && d.has(n) || l.push(n) : n && n.length && "string" !== i && o(n)
								})
							}(arguments), t ? r = l.length : n && (s = i, u(n))
						}
						return this
					},
					remove: function() {
						return l && rt.each(arguments, function(e, n) {
							for (var i;
								 (i = rt.inArray(n, l, i)) > -1;) l.splice(i, 1), t && (r >= i && r--, a >= i && a--)
						}), this
					},
					has: function(e) {
						return e ? rt.inArray(e, l) > -1 : !(!l || !l.length)
					},
					empty: function() {
						return l = [], r = 0, this
					},
					disable: function() {
						return l = c = n = void 0, this
					},
					disabled: function() {
						return !l
					},
					lock: function() {
						return c = void 0, n || d.disable(), this
					},
					locked: function() {
						return !c
					},
					fireWith: function(e, n) {
						return !l || i && !c || (n = n || [], n = [e, n.slice ? n.slice() : n], t ? c.push(n) : u(n)), this
					},
					fire: function() {
						return d.fireWith(this, arguments), this
					},
					fired: function() {
						return !!i
					}
				};
			return d
		}, rt.extend({
			Deferred: function(e) {
				var t = [
						["resolve", "done", rt.Callbacks("once memory"), "resolved"],
						["reject", "fail", rt.Callbacks("once memory"), "rejected"],
						["notify", "progress", rt.Callbacks("memory")]
					],
					n = "pending",
					i = {
						state: function() {
							return n
						},
						always: function() {
							return r.done(arguments).fail(arguments), this
						},
						then: function() {
							var e = arguments;
							return rt.Deferred(function(n) {
								rt.each(t, function(t, o) {
									var a = rt.isFunction(e[t]) && e[t];
									r[o[1]](function() {
										var e = a && a.apply(this, arguments);
										e && rt.isFunction(e.promise) ? e.promise().done(n.resolve).fail(n.reject).progress(n.notify) : n[o[0] + "With"](this === i ? n.promise() : this, a ? [e] : arguments)
									})
								}), e = null
							}).promise()
						},
						promise: function(e) {
							return null != e ? rt.extend(e, i) : i
						}
					},
					r = {};
				return i.pipe = i.then, rt.each(t, function(e, o) {
					var a = o[2],
						s = o[3];
					i[o[1]] = a.add, s && a.add(function() {
						n = s
					}, t[1 ^ e][2].disable, t[2][2].lock), r[o[0]] = function() {
						return r[o[0] + "With"](this === r ? i : this, arguments), this
					}, r[o[0] + "With"] = a.fireWith
				}), i.promise(r), e && e.call(r, r), r
			},
			when: function(e) {
				var t, n, i, r = 0,
					o = V.call(arguments),
					a = o.length,
					s = 1 !== a || e && rt.isFunction(e.promise) ? a : 0,
					l = 1 === s ? e : rt.Deferred(),
					c = function(e, n, i) {
						return function(r) {
							n[e] = this, i[e] = arguments.length > 1 ? V.call(arguments) : r, i === t ? l.notifyWith(n, i) : --s || l.resolveWith(n, i)
						}
					};
				if (a > 1)
					for (t = new Array(a), n = new Array(a), i = new Array(a); a > r; r++) o[r] && rt.isFunction(o[r].promise) ? o[r].promise().done(c(r, i, o)).fail(l.reject).progress(c(r, n, t)) : --s;
				return s || l.resolveWith(i, o), l.promise()
			}
		});
		var wt;
		rt.fn.ready = function(e) {
			return rt.ready.promise().done(e), this
		}, rt.extend({
			isReady: !1,
			readyWait: 1,
			holdReady: function(e) {
				e ? rt.readyWait++ : rt.ready(!0)
			},
			ready: function(e) {
				if (e === !0 ? !--rt.readyWait : !rt.isReady) {
					if (!ft.body) return setTimeout(rt.ready);
					rt.isReady = !0, e !== !0 && --rt.readyWait > 0 || (wt.resolveWith(ft, [rt]), rt.fn.triggerHandler && (rt(ft).triggerHandler("ready"), rt(ft).off("ready")))
				}
			}
		}), rt.ready.promise = function(t) {
			if (!wt)
				if (wt = rt.Deferred(), "complete" === ft.readyState) setTimeout(rt.ready);
				else if (ft.addEventListener) ft.addEventListener("DOMContentLoaded", s, !1), e.addEventListener("load", s, !1);
				else {
					ft.attachEvent("onreadystatechange", s), e.attachEvent("onload", s);
					var n = !1;
					try {
						n = null == e.frameElement && ft.documentElement
					} catch (i) {}
					n && n.doScroll && ! function r() {
						if (!rt.isReady) {
							try {
								n.doScroll("left")
							} catch (e) {
								return setTimeout(r, 50)
							}
							a(), rt.ready()
						}
					}()
				}
			return wt.promise(t)
		};
		var xt, Et = "undefined";
		for (xt in rt(nt)) break;
		nt.ownLast = "0" !== xt, nt.inlineBlockNeedsLayout = !1, rt(function() {
			var e, t, n, i;
			n = ft.getElementsByTagName("body")[0], n && n.style && (t = ft.createElement("div"), i = ft.createElement("div"), i.style.cssText = "position:absolute;border:0;width:0;height:0;top:0;left:-9999px", n.appendChild(i).appendChild(t), typeof t.style.zoom !== Et && (t.style.cssText = "display:inline;margin:0;border:0;padding:1px;width:1px;zoom:1", nt.inlineBlockNeedsLayout = e = 3 === t.offsetWidth, e && (n.style.zoom = 1)), n.removeChild(i))
		}),
			function() {
				var e = ft.createElement("div");
				if (null == nt.deleteExpando) {
					nt.deleteExpando = !0;
					try {
						delete e.test
					} catch (t) {
						nt.deleteExpando = !1
					}
				}
				e = null
			}(), rt.acceptData = function(e) {
			var t = rt.noData[(e.nodeName + " ").toLowerCase()],
				n = +e.nodeType || 1;
			return 1 !== n && 9 !== n ? !1 : !t || t !== !0 && e.getAttribute("classid") === t
		};
		var kt = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,
			Ct = /([A-Z])/g;
		rt.extend({
			cache: {},
			noData: {
				"applet ": !0,
				"embed ": !0,
				"object ": "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			},
			hasData: function(e) {
				return e = e.nodeType ? rt.cache[e[rt.expando]] : e[rt.expando], !!e && !c(e)
			},
			data: function(e, t, n) {
				return u(e, t, n)
			},
			removeData: function(e, t) {
				return d(e, t)
			},
			_data: function(e, t, n) {
				return u(e, t, n, !0)
			},
			_removeData: function(e, t) {
				return d(e, t, !0)
			}
		}), rt.fn.extend({
			data: function(e, t) {
				var n, i, r, o = this[0],
					a = o && o.attributes;
				if (void 0 === e) {
					if (this.length && (r = rt.data(o), 1 === o.nodeType && !rt._data(o, "parsedAttrs"))) {
						for (n = a.length; n--;) a[n] && (i = a[n].name, 0 === i.indexOf("data-") && (i = rt.camelCase(i.slice(5)), l(o, i, r[i])));
						rt._data(o, "parsedAttrs", !0)
					}
					return r
				}
				return "object" == typeof e ? this.each(function() {
					rt.data(this, e)
				}) : arguments.length > 1 ? this.each(function() {
					rt.data(this, e, t)
				}) : o ? l(o, e, rt.data(o, e)) : void 0
			},
			removeData: function(e) {
				return this.each(function() {
					rt.removeData(this, e)
				})
			}
		}), rt.extend({
			queue: function(e, t, n) {
				var i;
				return e ? (t = (t || "fx") + "queue", i = rt._data(e, t), n && (!i || rt.isArray(n) ? i = rt._data(e, t, rt.makeArray(n)) : i.push(n)), i || []) : void 0
			},
			dequeue: function(e, t) {
				t = t || "fx";
				var n = rt.queue(e, t),
					i = n.length,
					r = n.shift(),
					o = rt._queueHooks(e, t),
					a = function() {
						rt.dequeue(e, t)
					};
				"inprogress" === r && (r = n.shift(), i--), r && ("fx" === t && n.unshift("inprogress"), delete o.stop, r.call(e, a, o)), !i && o && o.empty.fire()
			},
			_queueHooks: function(e, t) {
				var n = t + "queueHooks";
				return rt._data(e, n) || rt._data(e, n, {
					empty: rt.Callbacks("once memory").add(function() {
						rt._removeData(e, t + "queue"), rt._removeData(e, n)
					})
				})
			}
		}), rt.fn.extend({
			queue: function(e, t) {
				var n = 2;
				return "string" != typeof e && (t = e, e = "fx", n--), arguments.length < n ? rt.queue(this[0], e) : void 0 === t ? this : this.each(function() {
					var n = rt.queue(this, e, t);
					rt._queueHooks(this, e), "fx" === e && "inprogress" !== n[0] && rt.dequeue(this, e)
				})
			},
			dequeue: function(e) {
				return this.each(function() {
					rt.dequeue(this, e)
				})
			},
			clearQueue: function(e) {
				return this.queue(e || "fx", [])
			},
			promise: function(e, t) {
				var n, i = 1,
					r = rt.Deferred(),
					o = this,
					a = this.length,
					s = function() {
						--i || r.resolveWith(o, [o])
					};
				for ("string" != typeof e && (t = e, e = void 0), e = e || "fx"; a--;) n = rt._data(o[a], e + "queueHooks"), n && n.empty && (i++, n.empty.add(s));
				return s(), r.promise(t)
			}
		});
		var Tt = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,
			St = ["Top", "Right", "Bottom", "Left"],
			Ot = function(e, t) {
				return e = t || e, "none" === rt.css(e, "display") || !rt.contains(e.ownerDocument, e)
			},
			Dt = rt.access = function(e, t, n, i, r, o, a) {
				var s = 0,
					l = e.length,
					c = null == n;
				if ("object" === rt.type(n)) {
					r = !0;
					for (s in n) rt.access(e, t, s, n[s], !0, o, a)
				} else if (void 0 !== i && (r = !0, rt.isFunction(i) || (a = !0), c && (a ? (t.call(e, i), t = null) : (c = t, t = function(e, t, n) {
					return c.call(rt(e), n)
				})), t))
					for (; l > s; s++) t(e[s], n, a ? i : i.call(e[s], s, t(e[s], n)));
				return r ? e : c ? t.call(e) : l ? t(e[0], n) : o
			},
			At = /^(?:checkbox|radio)$/i;
		! function() {
			var e = ft.createElement("input"),
				t = ft.createElement("div"),
				n = ft.createDocumentFragment();
			if (t.innerHTML = "  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>", nt.leadingWhitespace = 3 === t.firstChild.nodeType, nt.tbody = !t.getElementsByTagName("tbody").length, nt.htmlSerialize = !!t.getElementsByTagName("link").length, nt.html5Clone = "<:nav></:nav>" !== ft.createElement("nav").cloneNode(!0).outerHTML, e.type = "checkbox", e.checked = !0, n.appendChild(e), nt.appendChecked = e.checked, t.innerHTML = "<textarea>x</textarea>", nt.noCloneChecked = !!t.cloneNode(!0).lastChild.defaultValue, n.appendChild(t), t.innerHTML = "<input type='radio' checked='checked' name='t'/>", nt.checkClone = t.cloneNode(!0).cloneNode(!0).lastChild.checked, nt.noCloneEvent = !0, t.attachEvent && (t.attachEvent("onclick", function() {
				nt.noCloneEvent = !1
			}), t.cloneNode(!0).click()), null == nt.deleteExpando) {
				nt.deleteExpando = !0;
				try {
					delete t.test
				} catch (i) {
					nt.deleteExpando = !1
				}
			}
		}(),
			function() {
				var t, n, i = ft.createElement("div");
				for (t in {
					submit: !0,
					change: !0,
					focusin: !0
				}) n = "on" + t, (nt[t + "Bubbles"] = n in e) || (i.setAttribute(n, "t"), nt[t + "Bubbles"] = i.attributes[n].expando === !1);
				i = null
			}();
		var Nt = /^(?:input|select|textarea)$/i,
			It = /^key/,
			jt = /^(?:mouse|pointer|contextmenu)|click/,
			Ft = /^(?:focusinfocus|focusoutblur)$/,
			Lt = /^([^.]*)(?:\.(.+)|)$/;
		rt.event = {
			global: {},
			add: function(e, t, n, i, r) {
				var o, a, s, l, c, u, d, h, p, f, g, m = rt._data(e);
				if (m) {
					for (n.handler && (l = n, n = l.handler, r = l.selector), n.guid || (n.guid = rt.guid++), (a = m.events) || (a = m.events = {}), (u = m.handle) || (u = m.handle = function(e) {
						return typeof rt === Et || e && rt.event.triggered === e.type ? void 0 : rt.event.dispatch.apply(u.elem, arguments)
					}, u.elem = e), t = (t || "").match(bt) || [""], s = t.length; s--;) o = Lt.exec(t[s]) || [], p = g = o[1], f = (o[2] || "").split(".").sort(), p && (c = rt.event.special[p] || {}, p = (r ? c.delegateType : c.bindType) || p, c = rt.event.special[p] || {}, d = rt.extend({
						type: p,
						origType: g,
						data: i,
						handler: n,
						guid: n.guid,
						selector: r,
						needsContext: r && rt.expr.match.needsContext.test(r),
						namespace: f.join(".")
					}, l), (h = a[p]) || (h = a[p] = [], h.delegateCount = 0, c.setup && c.setup.call(e, i, f, u) !== !1 || (e.addEventListener ? e.addEventListener(p, u, !1) : e.attachEvent && e.attachEvent("on" + p, u))), c.add && (c.add.call(e, d), d.handler.guid || (d.handler.guid = n.guid)), r ? h.splice(h.delegateCount++, 0, d) : h.push(d), rt.event.global[p] = !0);
					e = null
				}
			},
			remove: function(e, t, n, i, r) {
				var o, a, s, l, c, u, d, h, p, f, g, m = rt.hasData(e) && rt._data(e);
				if (m && (u = m.events)) {
					for (t = (t || "").match(bt) || [""], c = t.length; c--;)
						if (s = Lt.exec(t[c]) || [], p = g = s[1], f = (s[2] || "").split(".").sort(), p) {
							for (d = rt.event.special[p] || {}, p = (i ? d.delegateType : d.bindType) || p, h = u[p] || [], s = s[2] && new RegExp("(^|\\.)" + f.join("\\.(?:.*\\.|)") + "(\\.|$)"), l = o = h.length; o--;) a = h[o], !r && g !== a.origType || n && n.guid !== a.guid || s && !s.test(a.namespace) || i && i !== a.selector && ("**" !== i || !a.selector) || (h.splice(o, 1), a.selector && h.delegateCount--, d.remove && d.remove.call(e, a));
							l && !h.length && (d.teardown && d.teardown.call(e, f, m.handle) !== !1 || rt.removeEvent(e, p, m.handle), delete u[p])
						} else
							for (p in u) rt.event.remove(e, p + t[c], n, i, !0);
					rt.isEmptyObject(u) && (delete m.handle, rt._removeData(e, "events"))
				}
			},
			trigger: function(t, n, i, r) {
				var o, a, s, l, c, u, d, h = [i || ft],
					p = tt.call(t, "type") ? t.type : t,
					f = tt.call(t, "namespace") ? t.namespace.split(".") : [];
				if (s = u = i = i || ft, 3 !== i.nodeType && 8 !== i.nodeType && !Ft.test(p + rt.event.triggered) && (p.indexOf(".") >= 0 && (f = p.split("."), p = f.shift(), f.sort()), a = p.indexOf(":") < 0 && "on" + p, t = t[rt.expando] ? t : new rt.Event(p, "object" == typeof t && t), t.isTrigger = r ? 2 : 3, t.namespace = f.join("."), t.namespace_re = t.namespace ? new RegExp("(^|\\.)" + f.join("\\.(?:.*\\.|)") + "(\\.|$)") : null, t.result = void 0, t.target || (t.target = i), n = null == n ? [t] : rt.makeArray(n, [t]), c = rt.event.special[p] || {}, r || !c.trigger || c.trigger.apply(i, n) !== !1)) {
					if (!r && !c.noBubble && !rt.isWindow(i)) {
						for (l = c.delegateType || p, Ft.test(l + p) || (s = s.parentNode); s; s = s.parentNode) h.push(s), u = s;
						u === (i.ownerDocument || ft) && h.push(u.defaultView || u.parentWindow || e)
					}
					for (d = 0;
						 (s = h[d++]) && !t.isPropagationStopped();) t.type = d > 1 ? l : c.bindType || p, o = (rt._data(s, "events") || {})[t.type] && rt._data(s, "handle"), o && o.apply(s, n), o = a && s[a], o && o.apply && rt.acceptData(s) && (t.result = o.apply(s, n), t.result === !1 && t.preventDefault());
					if (t.type = p, !r && !t.isDefaultPrevented() && (!c._default || c._default.apply(h.pop(), n) === !1) && rt.acceptData(i) && a && i[p] && !rt.isWindow(i)) {
						u = i[a], u && (i[a] = null), rt.event.triggered = p;
						try {
							i[p]()
						} catch (g) {}
						rt.event.triggered = void 0, u && (i[a] = u)
					}
					return t.result
				}
			},
			dispatch: function(e) {
				e = rt.event.fix(e);
				var t, n, i, r, o, a = [],
					s = V.call(arguments),
					l = (rt._data(this, "events") || {})[e.type] || [],
					c = rt.event.special[e.type] || {};
				if (s[0] = e, e.delegateTarget = this, !c.preDispatch || c.preDispatch.call(this, e) !== !1) {
					for (a = rt.event.handlers.call(this, e, l), t = 0;
						 (r = a[t++]) && !e.isPropagationStopped();)
						for (e.currentTarget = r.elem, o = 0;
							 (i = r.handlers[o++]) && !e.isImmediatePropagationStopped();)(!e.namespace_re || e.namespace_re.test(i.namespace)) && (e.handleObj = i, e.data = i.data, n = ((rt.event.special[i.origType] || {}).handle || i.handler).apply(r.elem, s), void 0 !== n && (e.result = n) === !1 && (e.preventDefault(), e.stopPropagation()));
					return c.postDispatch && c.postDispatch.call(this, e), e.result
				}
			},
			handlers: function(e, t) {
				var n, i, r, o, a = [],
					s = t.delegateCount,
					l = e.target;
				if (s && l.nodeType && (!e.button || "click" !== e.type))
					for (; l != this; l = l.parentNode || this)
						if (1 === l.nodeType && (l.disabled !== !0 || "click" !== e.type)) {
							for (r = [], o = 0; s > o; o++) i = t[o], n = i.selector + " ", void 0 === r[n] && (r[n] = i.needsContext ? rt(n, this).index(l) >= 0 : rt.find(n, this, null, [l]).length), r[n] && r.push(i);
							r.length && a.push({
								elem: l,
								handlers: r
							})
						}
				return s < t.length && a.push({
					elem: this,
					handlers: t.slice(s)
				}), a
			},
			fix: function(e) {
				if (e[rt.expando]) return e;
				var t, n, i, r = e.type,
					o = e,
					a = this.fixHooks[r];
				for (a || (this.fixHooks[r] = a = jt.test(r) ? this.mouseHooks : It.test(r) ? this.keyHooks : {}), i = a.props ? this.props.concat(a.props) : this.props, e = new rt.Event(o), t = i.length; t--;) n = i[t], e[n] = o[n];
				return e.target || (e.target = o.srcElement || ft), 3 === e.target.nodeType && (e.target = e.target.parentNode), e.metaKey = !!e.metaKey, a.filter ? a.filter(e, o) : e
			},
			props: "altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),
			fixHooks: {},
			keyHooks: {
				props: "char charCode key keyCode".split(" "),
				filter: function(e, t) {
					return null == e.which && (e.which = null != t.charCode ? t.charCode : t.keyCode), e
				}
			},
			mouseHooks: {
				props: "button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),
				filter: function(e, t) {
					var n, i, r, o = t.button,
						a = t.fromElement;
					return null == e.pageX && null != t.clientX && (i = e.target.ownerDocument || ft, r = i.documentElement, n = i.body, e.pageX = t.clientX + (r && r.scrollLeft || n && n.scrollLeft || 0) - (r && r.clientLeft || n && n.clientLeft || 0), e.pageY = t.clientY + (r && r.scrollTop || n && n.scrollTop || 0) - (r && r.clientTop || n && n.clientTop || 0)), !e.relatedTarget && a && (e.relatedTarget = a === e.target ? t.toElement : a), e.which || void 0 === o || (e.which = 1 & o ? 1 : 2 & o ? 3 : 4 & o ? 2 : 0), e
				}
			},
			special: {
				load: {
					noBubble: !0
				},
				focus: {
					trigger: function() {
						if (this !== f() && this.focus) try {
							return this.focus(), !1
						} catch (e) {}
					},
					delegateType: "focusin"
				},
				blur: {
					trigger: function() {
						return this === f() && this.blur ? (this.blur(), !1) : void 0
					},
					delegateType: "focusout"
				},
				click: {
					trigger: function() {
						return rt.nodeName(this, "input") && "checkbox" === this.type && this.click ? (this.click(), !1) : void 0
					},
					_default: function(e) {
						return rt.nodeName(e.target, "a")
					}
				},
				beforeunload: {
					postDispatch: function(e) {
						void 0 !== e.result && e.originalEvent && (e.originalEvent.returnValue = e.result)
					}
				}
			},
			simulate: function(e, t, n, i) {
				var r = rt.extend(new rt.Event, n, {
					type: e,
					isSimulated: !0,
					originalEvent: {}
				});
				i ? rt.event.trigger(r, null, t) : rt.event.dispatch.call(t, r), r.isDefaultPrevented() && n.preventDefault()
			}
		}, rt.removeEvent = ft.removeEventListener ? function(e, t, n) {
			e.removeEventListener && e.removeEventListener(t, n, !1)
		} : function(e, t, n) {
			var i = "on" + t;
			e.detachEvent && (typeof e[i] === Et && (e[i] = null), e.detachEvent(i, n))
		}, rt.Event = function(e, t) {
			return this instanceof rt.Event ? (e && e.type ? (this.originalEvent = e, this.type = e.type, this.isDefaultPrevented = e.defaultPrevented || void 0 === e.defaultPrevented && e.returnValue === !1 ? h : p) : this.type = e, t && rt.extend(this, t), this.timeStamp = e && e.timeStamp || rt.now(), void(this[rt.expando] = !0)) : new rt.Event(e, t)
		}, rt.Event.prototype = {
			isDefaultPrevented: p,
			isPropagationStopped: p,
			isImmediatePropagationStopped: p,
			preventDefault: function() {
				var e = this.originalEvent;
				this.isDefaultPrevented = h, e && (e.preventDefault ? e.preventDefault() : e.returnValue = !1)
			},
			stopPropagation: function() {
				var e = this.originalEvent;
				this.isPropagationStopped = h, e && (e.stopPropagation && e.stopPropagation(), e.cancelBubble = !0)
			},
			stopImmediatePropagation: function() {
				var e = this.originalEvent;
				this.isImmediatePropagationStopped = h, e && e.stopImmediatePropagation && e.stopImmediatePropagation(), this.stopPropagation()
			}
		}, rt.each({
			mouseenter: "mouseover",
			mouseleave: "mouseout",
			pointerenter: "pointerover",
			pointerleave: "pointerout"
		}, function(e, t) {
			rt.event.special[e] = {
				delegateType: t,
				bindType: t,
				handle: function(e) {
					var n, i = this,
						r = e.relatedTarget,
						o = e.handleObj;
					return (!r || r !== i && !rt.contains(i, r)) && (e.type = o.origType, n = o.handler.apply(this, arguments), e.type = t), n
				}
			}
		}), nt.submitBubbles || (rt.event.special.submit = {
			setup: function() {
				return rt.nodeName(this, "form") ? !1 : void rt.event.add(this, "click._submit keypress._submit", function(e) {
					var t = e.target,
						n = rt.nodeName(t, "input") || rt.nodeName(t, "button") ? t.form : void 0;
					n && !rt._data(n, "submitBubbles") && (rt.event.add(n, "submit._submit", function(e) {
						e._submit_bubble = !0
					}), rt._data(n, "submitBubbles", !0))
				})
			},
			postDispatch: function(e) {
				e._submit_bubble && (delete e._submit_bubble, this.parentNode && !e.isTrigger && rt.event.simulate("submit", this.parentNode, e, !0))
			},
			teardown: function() {
				return rt.nodeName(this, "form") ? !1 : void rt.event.remove(this, "._submit")
			}
		}), nt.changeBubbles || (rt.event.special.change = {
			setup: function() {
				return Nt.test(this.nodeName) ? (("checkbox" === this.type || "radio" === this.type) && (rt.event.add(this, "propertychange._change", function(e) {
					"checked" === e.originalEvent.propertyName && (this._just_changed = !0)
				}), rt.event.add(this, "click._change", function(e) {
					this._just_changed && !e.isTrigger && (this._just_changed = !1), rt.event.simulate("change", this, e, !0)
				})), !1) : void rt.event.add(this, "beforeactivate._change", function(e) {
					var t = e.target;
					Nt.test(t.nodeName) && !rt._data(t, "changeBubbles") && (rt.event.add(t, "change._change", function(e) {
						!this.parentNode || e.isSimulated || e.isTrigger || rt.event.simulate("change", this.parentNode, e, !0)
					}), rt._data(t, "changeBubbles", !0))
				})
			},
			handle: function(e) {
				var t = e.target;
				return this !== t || e.isSimulated || e.isTrigger || "radio" !== t.type && "checkbox" !== t.type ? e.handleObj.handler.apply(this, arguments) : void 0
			},
			teardown: function() {
				return rt.event.remove(this, "._change"), !Nt.test(this.nodeName)
			}
		}), nt.focusinBubbles || rt.each({
			focus: "focusin",
			blur: "focusout"
		}, function(e, t) {
			var n = function(e) {
				rt.event.simulate(t, e.target, rt.event.fix(e), !0)
			};
			rt.event.special[t] = {
				setup: function() {
					var i = this.ownerDocument || this,
						r = rt._data(i, t);
					r || i.addEventListener(e, n, !0), rt._data(i, t, (r || 0) + 1)
				},
				teardown: function() {
					var i = this.ownerDocument || this,
						r = rt._data(i, t) - 1;
					r ? rt._data(i, t, r) : (i.removeEventListener(e, n, !0), rt._removeData(i, t))
				}
			}
		}), rt.fn.extend({
			on: function(e, t, n, i, r) {
				var o, a;
				if ("object" == typeof e) {
					"string" != typeof t && (n = n || t, t = void 0);
					for (o in e) this.on(o, t, n, e[o], r);
					return this
				}
				if (null == n && null == i ? (i = t, n = t = void 0) : null == i && ("string" == typeof t ? (i = n, n = void 0) : (i = n, n = t, t = void 0)), i === !1) i = p;
				else if (!i) return this;
				return 1 === r && (a = i, i = function(e) {
					return rt().off(e), a.apply(this, arguments)
				}, i.guid = a.guid || (a.guid = rt.guid++)), this.each(function() {
					rt.event.add(this, e, i, n, t)
				})
			},
			one: function(e, t, n, i) {
				return this.on(e, t, n, i, 1)
			},
			off: function(e, t, n) {
				var i, r;
				if (e && e.preventDefault && e.handleObj) return i = e.handleObj, rt(e.delegateTarget).off(i.namespace ? i.origType + "." + i.namespace : i.origType, i.selector, i.handler), this;
				if ("object" == typeof e) {
					for (r in e) this.off(r, t, e[r]);
					return this
				}
				return (t === !1 || "function" == typeof t) && (n = t, t = void 0), n === !1 && (n = p), this.each(function() {
					rt.event.remove(this, e, n, t)
				})
			},
			trigger: function(e, t) {
				return this.each(function() {
					rt.event.trigger(e, t, this)
				})
			},
			triggerHandler: function(e, t) {
				var n = this[0];
				return n ? rt.event.trigger(e, t, n, !0) : void 0
			}
		});
		var Pt = "abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",
			Ht = / jQuery\d+="(?:null|\d+)"/g,
			Mt = new RegExp("<(?:" + Pt + ")[\\s/>]", "i"),
			$t = /^\s+/,
			Wt = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,
			Rt = /<([\w:]+)/,
			zt = /<tbody/i,
			Ut = /<|&#?\w+;/,
			Bt = /<(?:script|style|link)/i,
			qt = /checked\s*(?:[^=]|=\s*.checked.)/i,
			Gt = /^$|\/(?:java|ecma)script/i,
			Qt = /^true\/(.*)/,
			Yt = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,
			Vt = {
				option: [1, "<select multiple='multiple'>", "</select>"],
				legend: [1, "<fieldset>", "</fieldset>"],
				area: [1, "<map>", "</map>"],
				param: [1, "<object>", "</object>"],
				thead: [1, "<table>", "</table>"],
				tr: [2, "<table><tbody>", "</tbody></table>"],
				col: [2, "<table><tbody></tbody><colgroup>", "</colgroup></table>"],
				td: [3, "<table><tbody><tr>", "</tr></tbody></table>"],
				_default: nt.htmlSerialize ? [0, "", ""] : [1, "X<div>", "</div>"]
			},
			Kt = g(ft),
			Xt = Kt.appendChild(ft.createElement("div"));
		Vt.optgroup = Vt.option, Vt.tbody = Vt.tfoot = Vt.colgroup = Vt.caption = Vt.thead, Vt.th = Vt.td, rt.extend({
			clone: function(e, t, n) {
				var i, r, o, a, s, l = rt.contains(e.ownerDocument, e);
				if (nt.html5Clone || rt.isXMLDoc(e) || !Mt.test("<" + e.nodeName + ">") ? o = e.cloneNode(!0) : (Xt.innerHTML = e.outerHTML, Xt.removeChild(o = Xt.firstChild)), !(nt.noCloneEvent && nt.noCloneChecked || 1 !== e.nodeType && 11 !== e.nodeType || rt.isXMLDoc(e)))
					for (i = m(o), s = m(e), a = 0; null != (r = s[a]); ++a) i[a] && E(r, i[a]);
				if (t)
					if (n)
						for (s = s || m(e), i = i || m(o), a = 0; null != (r = s[a]); a++) x(r, i[a]);
					else x(e, o);
				return i = m(o, "script"), i.length > 0 && w(i, !l && m(e, "script")), i = s = r = null, o
			},
			buildFragment: function(e, t, n, i) {
				for (var r, o, a, s, l, c, u, d = e.length, h = g(t), p = [], f = 0; d > f; f++)
					if (o = e[f], o || 0 === o)
						if ("object" === rt.type(o)) rt.merge(p, o.nodeType ? [o] : o);
						else if (Ut.test(o)) {
							for (s = s || h.appendChild(t.createElement("div")), l = (Rt.exec(o) || ["", ""])[1].toLowerCase(), u = Vt[l] || Vt._default, s.innerHTML = u[1] + o.replace(Wt, "<$1></$2>") + u[2], r = u[0]; r--;) s = s.lastChild;
							if (!nt.leadingWhitespace && $t.test(o) && p.push(t.createTextNode($t.exec(o)[0])), !nt.tbody)
								for (o = "table" !== l || zt.test(o) ? "<table>" !== u[1] || zt.test(o) ? 0 : s : s.firstChild, r = o && o.childNodes.length; r--;) rt.nodeName(c = o.childNodes[r], "tbody") && !c.childNodes.length && o.removeChild(c);
							for (rt.merge(p, s.childNodes), s.textContent = ""; s.firstChild;) s.removeChild(s.firstChild);
							s = h.lastChild
						} else p.push(t.createTextNode(o));
				for (s && h.removeChild(s), nt.appendChecked || rt.grep(m(p, "input"), v), f = 0; o = p[f++];)
					if ((!i || -1 === rt.inArray(o, i)) && (a = rt.contains(o.ownerDocument, o), s = m(h.appendChild(o), "script"), a && w(s), n))
						for (r = 0; o = s[r++];) Gt.test(o.type || "") && n.push(o);
				return s = null, h
			},
			cleanData: function(e, t) {
				for (var n, i, r, o, a = 0, s = rt.expando, l = rt.cache, c = nt.deleteExpando, u = rt.event.special; null != (n = e[a]); a++)
					if ((t || rt.acceptData(n)) && (r = n[s], o = r && l[r])) {
						if (o.events)
							for (i in o.events) u[i] ? rt.event.remove(n, i) : rt.removeEvent(n, i, o.handle);
						l[r] && (delete l[r], c ? delete n[s] : typeof n.removeAttribute !== Et ? n.removeAttribute(s) : n[s] = null, Y.push(r))
					}
			}
		}), rt.fn.extend({
			text: function(e) {
				return Dt(this, function(e) {
					return void 0 === e ? rt.text(this) : this.empty().append((this[0] && this[0].ownerDocument || ft).createTextNode(e))
				}, null, e, arguments.length)
			},
			append: function() {
				return this.domManip(arguments, function(e) {
					if (1 === this.nodeType || 11 === this.nodeType || 9 === this.nodeType) {
						var t = _(this, e);
						t.appendChild(e)
					}
				})
			},
			prepend: function() {
				return this.domManip(arguments, function(e) {
					if (1 === this.nodeType || 11 === this.nodeType || 9 === this.nodeType) {
						var t = _(this, e);
						t.insertBefore(e, t.firstChild)
					}
				})
			},
			before: function() {
				return this.domManip(arguments, function(e) {
					this.parentNode && this.parentNode.insertBefore(e, this)
				})
			},
			after: function() {
				return this.domManip(arguments, function(e) {
					this.parentNode && this.parentNode.insertBefore(e, this.nextSibling)
				})
			},
			remove: function(e, t) {
				for (var n, i = e ? rt.filter(e, this) : this, r = 0; null != (n = i[r]); r++) t || 1 !== n.nodeType || rt.cleanData(m(n)), n.parentNode && (t && rt.contains(n.ownerDocument, n) && w(m(n, "script")), n.parentNode.removeChild(n));
				return this
			},
			empty: function() {
				for (var e, t = 0; null != (e = this[t]); t++) {
					for (1 === e.nodeType && rt.cleanData(m(e, !1)); e.firstChild;) e.removeChild(e.firstChild);
					e.options && rt.nodeName(e, "select") && (e.options.length = 0)
				}
				return this
			},
			clone: function(e, t) {
				return e = null == e ? !1 : e, t = null == t ? e : t, this.map(function() {
					return rt.clone(this, e, t)
				})
			},
			html: function(e) {
				return Dt(this, function(e) {
					var t = this[0] || {},
						n = 0,
						i = this.length;
					if (void 0 === e) return 1 === t.nodeType ? t.innerHTML.replace(Ht, "") : void 0;
					if (!("string" != typeof e || Bt.test(e) || !nt.htmlSerialize && Mt.test(e) || !nt.leadingWhitespace && $t.test(e) || Vt[(Rt.exec(e) || ["", ""])[1].toLowerCase()])) {
						e = e.replace(Wt, "<$1></$2>");
						try {
							for (; i > n; n++) t = this[n] || {}, 1 === t.nodeType && (rt.cleanData(m(t, !1)), t.innerHTML = e);
							t = 0
						} catch (r) {}
					}
					t && this.empty().append(e)
				}, null, e, arguments.length)
			},
			replaceWith: function() {
				var e = arguments[0];
				return this.domManip(arguments, function(t) {
					e = this.parentNode, rt.cleanData(m(this)), e && e.replaceChild(t, this)
				}), e && (e.length || e.nodeType) ? this : this.remove()
			},
			detach: function(e) {
				return this.remove(e, !0)
			},
			domManip: function(e, t) {
				e = K.apply([], e);
				var n, i, r, o, a, s, l = 0,
					c = this.length,
					u = this,
					d = c - 1,
					h = e[0],
					p = rt.isFunction(h);
				if (p || c > 1 && "string" == typeof h && !nt.checkClone && qt.test(h)) return this.each(function(n) {
					var i = u.eq(n);
					p && (e[0] = h.call(this, n, i.html())), i.domManip(e, t)
				});
				if (c && (s = rt.buildFragment(e, this[0].ownerDocument, !1, this), n = s.firstChild, 1 === s.childNodes.length && (s = n), n)) {
					for (o = rt.map(m(s, "script"), b), r = o.length; c > l; l++) i = s, l !== d && (i = rt.clone(i, !0, !0), r && rt.merge(o, m(i, "script"))), t.call(this[l], i, l);
					if (r)
						for (a = o[o.length - 1].ownerDocument, rt.map(o, y), l = 0; r > l; l++) i = o[l], Gt.test(i.type || "") && !rt._data(i, "globalEval") && rt.contains(a, i) && (i.src ? rt._evalUrl && rt._evalUrl(i.src) : rt.globalEval((i.text || i.textContent || i.innerHTML || "").replace(Yt, "")));
					s = n = null
				}
				return this
			}
		}), rt.each({
			appendTo: "append",
			prependTo: "prepend",
			insertBefore: "before",
			insertAfter: "after",
			replaceAll: "replaceWith"
		}, function(e, t) {
			rt.fn[e] = function(e) {
				for (var n, i = 0, r = [], o = rt(e), a = o.length - 1; a >= i; i++) n = i === a ? this : this.clone(!0), rt(o[i])[t](n), X.apply(r, n.get());
				return this.pushStack(r)
			}
		});
		var Jt, Zt = {};
		! function() {
			var e;
			nt.shrinkWrapBlocks = function() {
				if (null != e) return e;
				e = !1;
				var t, n, i;
				return n = ft.getElementsByTagName("body")[0], n && n.style ? (t = ft.createElement("div"), i = ft.createElement("div"), i.style.cssText = "position:absolute;border:0;width:0;height:0;top:0;left:-9999px", n.appendChild(i).appendChild(t), typeof t.style.zoom !== Et && (t.style.cssText = "-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:1px;width:1px;zoom:1", t.appendChild(ft.createElement("div")).style.width = "5px", e = 3 !== t.offsetWidth), n.removeChild(i), e) : void 0
			}
		}();
		var en, tn, nn = /^margin/,
			rn = new RegExp("^(" + Tt + ")(?!px)[a-z%]+$", "i"),
			on = /^(top|right|bottom|left)$/;
		e.getComputedStyle ? (en = function(e) {
			return e.ownerDocument.defaultView.getComputedStyle(e, null)
		}, tn = function(e, t, n) {
			var i, r, o, a, s = e.style;
			return n = n || en(e), a = n ? n.getPropertyValue(t) || n[t] : void 0, n && ("" !== a || rt.contains(e.ownerDocument, e) || (a = rt.style(e, t)), rn.test(a) && nn.test(t) && (i = s.width, r = s.minWidth, o = s.maxWidth, s.minWidth = s.maxWidth = s.width = a, a = n.width, s.width = i, s.minWidth = r, s.maxWidth = o)), void 0 === a ? a : a + ""
		}) : ft.documentElement.currentStyle && (en = function(e) {
			return e.currentStyle
		}, tn = function(e, t, n) {
			var i, r, o, a, s = e.style;
			return n = n || en(e), a = n ? n[t] : void 0, null == a && s && s[t] && (a = s[t]), rn.test(a) && !on.test(t) && (i = s.left, r = e.runtimeStyle, o = r && r.left, o && (r.left = e.currentStyle.left), s.left = "fontSize" === t ? "1em" : a, a = s.pixelLeft + "px", s.left = i, o && (r.left = o)), void 0 === a ? a : a + "" || "auto"
		}),
			function() {
				function t() {
					var t, n, i, r;
					n = ft.getElementsByTagName("body")[0], n && n.style && (t = ft.createElement("div"), i = ft.createElement("div"), i.style.cssText = "position:absolute;border:0;width:0;height:0;top:0;left:-9999px", n.appendChild(i).appendChild(t), t.style.cssText = "-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;display:block;margin-top:1%;top:1%;border:1px;padding:1px;width:4px;position:absolute", o = a = !1, l = !0, e.getComputedStyle && (o = "1%" !== (e.getComputedStyle(t, null) || {}).top, a = "4px" === (e.getComputedStyle(t, null) || {
						width: "4px"
					}).width, r = t.appendChild(ft.createElement("div")), r.style.cssText = t.style.cssText = "-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:0", r.style.marginRight = r.style.width = "0", t.style.width = "1px", l = !parseFloat((e.getComputedStyle(r, null) || {}).marginRight)), t.innerHTML = "<table><tr><td></td><td>t</td></tr></table>", r = t.getElementsByTagName("td"), r[0].style.cssText = "margin:0;border:0;padding:0;display:none", s = 0 === r[0].offsetHeight, s && (r[0].style.display = "", r[1].style.display = "none", s = 0 === r[0].offsetHeight), n.removeChild(i))
				}
				var n, i, r, o, a, s, l;
				n = ft.createElement("div"), n.innerHTML = "  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>", r = n.getElementsByTagName("a")[0], i = r && r.style, i && (i.cssText = "float:left;opacity:.5", nt.opacity = "0.5" === i.opacity, nt.cssFloat = !!i.cssFloat, n.style.backgroundClip = "content-box", n.cloneNode(!0).style.backgroundClip = "", nt.clearCloneStyle = "content-box" === n.style.backgroundClip, nt.boxSizing = "" === i.boxSizing || "" === i.MozBoxSizing || "" === i.WebkitBoxSizing, rt.extend(nt, {
					reliableHiddenOffsets: function() {
						return null == s && t(), s
					},
					boxSizingReliable: function() {
						return null == a && t(), a
					},
					pixelPosition: function() {
						return null == o && t(), o
					},
					reliableMarginRight: function() {
						return null == l && t(), l
					}
				}))
			}(), rt.swap = function(e, t, n, i) {
			var r, o, a = {};
			for (o in t) a[o] = e.style[o], e.style[o] = t[o];
			r = n.apply(e, i || []);
			for (o in t) e.style[o] = a[o];
			return r
		};
		var an = /alpha\([^)]*\)/i,
			sn = /opacity\s*=\s*([^)]*)/,
			ln = /^(none|table(?!-c[ea]).+)/,
			cn = new RegExp("^(" + Tt + ")(.*)$", "i"),
			un = new RegExp("^([+-])=(" + Tt + ")", "i"),
			dn = {
				position: "absolute",
				visibility: "hidden",
				display: "block"
			},
			hn = {
				letterSpacing: "0",
				fontWeight: "400"
			},
			pn = ["Webkit", "O", "Moz", "ms"];
		rt.extend({
			cssHooks: {
				opacity: {
					get: function(e, t) {
						if (t) {
							var n = tn(e, "opacity");
							return "" === n ? "1" : n
						}
					}
				}
			},
			cssNumber: {
				columnCount: !0,
				fillOpacity: !0,
				flexGrow: !0,
				flexShrink: !0,
				fontWeight: !0,
				lineHeight: !0,
				opacity: !0,
				order: !0,
				orphans: !0,
				widows: !0,
				zIndex: !0,
				zoom: !0
			},
			cssProps: {
				"float": nt.cssFloat ? "cssFloat" : "styleFloat"
			},
			style: function(e, t, n, i) {
				if (e && 3 !== e.nodeType && 8 !== e.nodeType && e.style) {
					var r, o, a, s = rt.camelCase(t),
						l = e.style;
					if (t = rt.cssProps[s] || (rt.cssProps[s] = S(l, s)), a = rt.cssHooks[t] || rt.cssHooks[s], void 0 === n) return a && "get" in a && void 0 !== (r = a.get(e, !1, i)) ? r : l[t];
					if (o = typeof n, "string" === o && (r = un.exec(n)) && (n = (r[1] + 1) * r[2] + parseFloat(rt.css(e, t)), o = "number"), null != n && n === n && ("number" !== o || rt.cssNumber[s] || (n += "px"), nt.clearCloneStyle || "" !== n || 0 !== t.indexOf("background") || (l[t] = "inherit"), !(a && "set" in a && void 0 === (n = a.set(e, n, i))))) try {
						l[t] = n
					} catch (c) {}
				}
			},
			css: function(e, t, n, i) {
				var r, o, a, s = rt.camelCase(t);
				return t = rt.cssProps[s] || (rt.cssProps[s] = S(e.style, s)), a = rt.cssHooks[t] || rt.cssHooks[s], a && "get" in a && (o = a.get(e, !0, n)), void 0 === o && (o = tn(e, t, i)), "normal" === o && t in hn && (o = hn[t]), "" === n || n ? (r = parseFloat(o), n === !0 || rt.isNumeric(r) ? r || 0 : o) : o
			}
		}), rt.each(["height", "width"], function(e, t) {
			rt.cssHooks[t] = {
				get: function(e, n, i) {
					return n ? ln.test(rt.css(e, "display")) && 0 === e.offsetWidth ? rt.swap(e, dn, function() {
						return N(e, t, i)
					}) : N(e, t, i) : void 0
				},
				set: function(e, n, i) {
					var r = i && en(e);
					return D(e, n, i ? A(e, t, i, nt.boxSizing && "border-box" === rt.css(e, "boxSizing", !1, r), r) : 0)
				}
			}
		}), nt.opacity || (rt.cssHooks.opacity = {
			get: function(e, t) {
				return sn.test((t && e.currentStyle ? e.currentStyle.filter : e.style.filter) || "") ? .01 * parseFloat(RegExp.$1) + "" : t ? "1" : ""
			},
			set: function(e, t) {
				var n = e.style,
					i = e.currentStyle,
					r = rt.isNumeric(t) ? "alpha(opacity=" + 100 * t + ")" : "",
					o = i && i.filter || n.filter || "";
				n.zoom = 1, (t >= 1 || "" === t) && "" === rt.trim(o.replace(an, "")) && n.removeAttribute && (n.removeAttribute("filter"), "" === t || i && !i.filter) || (n.filter = an.test(o) ? o.replace(an, r) : o + " " + r)
			}
		}), rt.cssHooks.marginRight = T(nt.reliableMarginRight, function(e, t) {
			return t ? rt.swap(e, {
				display: "inline-block"
			}, tn, [e, "marginRight"]) : void 0
		}), rt.each({
			margin: "",
			padding: "",
			border: "Width"
		}, function(e, t) {
			rt.cssHooks[e + t] = {
				expand: function(n) {
					for (var i = 0, r = {}, o = "string" == typeof n ? n.split(" ") : [n]; 4 > i; i++) r[e + St[i] + t] = o[i] || o[i - 2] || o[0];
					return r
				}
			}, nn.test(e) || (rt.cssHooks[e + t].set = D)
		}), rt.fn.extend({
			css: function(e, t) {
				return Dt(this, function(e, t, n) {
					var i, r, o = {},
						a = 0;
					if (rt.isArray(t)) {
						for (i = en(e), r = t.length; r > a; a++) o[t[a]] = rt.css(e, t[a], !1, i);
						return o
					}
					return void 0 !== n ? rt.style(e, t, n) : rt.css(e, t)
				}, e, t, arguments.length > 1)
			},
			show: function() {
				return O(this, !0)
			},
			hide: function() {
				return O(this)
			},
			toggle: function(e) {
				return "boolean" == typeof e ? e ? this.show() : this.hide() : this.each(function() {
					Ot(this) ? rt(this).show() : rt(this).hide()
				})
			}
		}), rt.Tween = I, I.prototype = {
			constructor: I,
			init: function(e, t, n, i, r, o) {
				this.elem = e, this.prop = n, this.easing = r || "swing", this.options = t, this.start = this.now = this.cur(), this.end = i, this.unit = o || (rt.cssNumber[n] ? "" : "px")
			},
			cur: function() {
				var e = I.propHooks[this.prop];
				return e && e.get ? e.get(this) : I.propHooks._default.get(this)
			},
			run: function(e) {
				var t, n = I.propHooks[this.prop];
				return this.pos = t = this.options.duration ? rt.easing[this.easing](e, this.options.duration * e, 0, 1, this.options.duration) : e, this.now = (this.end - this.start) * t + this.start, this.options.step && this.options.step.call(this.elem, this.now, this), n && n.set ? n.set(this) : I.propHooks._default.set(this), this
			}
		}, I.prototype.init.prototype = I.prototype, I.propHooks = {
			_default: {
				get: function(e) {
					var t;
					return null == e.elem[e.prop] || e.elem.style && null != e.elem.style[e.prop] ? (t = rt.css(e.elem, e.prop, ""), t && "auto" !== t ? t : 0) : e.elem[e.prop]
				},
				set: function(e) {
					rt.fx.step[e.prop] ? rt.fx.step[e.prop](e) : e.elem.style && (null != e.elem.style[rt.cssProps[e.prop]] || rt.cssHooks[e.prop]) ? rt.style(e.elem, e.prop, e.now + e.unit) : e.elem[e.prop] = e.now
				}
			}
		}, I.propHooks.scrollTop = I.propHooks.scrollLeft = {
			set: function(e) {
				e.elem.nodeType && e.elem.parentNode && (e.elem[e.prop] = e.now)
			}
		}, rt.easing = {
			linear: function(e) {
				return e
			},
			swing: function(e) {
				return .5 - Math.cos(e * Math.PI) / 2
			}
		}, rt.fx = I.prototype.init, rt.fx.step = {};
		var fn, gn, mn = /^(?:toggle|show|hide)$/,
			vn = new RegExp("^(?:([+-])=|)(" + Tt + ")([a-z%]*)$", "i"),
			_n = /queueHooks$/,
			bn = [P],
			yn = {
				"*": [
					function(e, t) {
						var n = this.createTween(e, t),
							i = n.cur(),
							r = vn.exec(t),
							o = r && r[3] || (rt.cssNumber[e] ? "" : "px"),
							a = (rt.cssNumber[e] || "px" !== o && +i) && vn.exec(rt.css(n.elem, e)),
							s = 1,
							l = 20;
						if (a && a[3] !== o) {
							o = o || a[3], r = r || [], a = +i || 1;
							do s = s || ".5", a /= s, rt.style(n.elem, e, a + o); while (s !== (s = n.cur() / i) && 1 !== s && --l)
						}
						return r && (a = n.start = +a || +i || 0, n.unit = o, n.end = r[1] ? a + (r[1] + 1) * r[2] : +r[2]), n
					}
				]
			};
		rt.Animation = rt.extend(M, {
			tweener: function(e, t) {
				rt.isFunction(e) ? (t = e, e = ["*"]) : e = e.split(" ");
				for (var n, i = 0, r = e.length; r > i; i++) n = e[i], yn[n] = yn[n] || [], yn[n].unshift(t)
			},
			prefilter: function(e, t) {
				t ? bn.unshift(e) : bn.push(e)
			}
		}), rt.speed = function(e, t, n) {
			var i = e && "object" == typeof e ? rt.extend({}, e) : {
				complete: n || !n && t || rt.isFunction(e) && e,
				duration: e,
				easing: n && t || t && !rt.isFunction(t) && t
			};
			return i.duration = rt.fx.off ? 0 : "number" == typeof i.duration ? i.duration : i.duration in rt.fx.speeds ? rt.fx.speeds[i.duration] : rt.fx.speeds._default, (null == i.queue || i.queue === !0) && (i.queue = "fx"), i.old = i.complete, i.complete = function() {
				rt.isFunction(i.old) && i.old.call(this), i.queue && rt.dequeue(this, i.queue)
			}, i
		}, rt.fn.extend({
			fadeTo: function(e, t, n, i) {
				return this.filter(Ot).css("opacity", 0).show().end().animate({
					opacity: t
				}, e, n, i)
			},
			animate: function(e, t, n, i) {
				var r = rt.isEmptyObject(e),
					o = rt.speed(t, n, i),
					a = function() {
						var t = M(this, rt.extend({}, e), o);
						(r || rt._data(this, "finish")) && t.stop(!0)
					};
				return a.finish = a, r || o.queue === !1 ? this.each(a) : this.queue(o.queue, a)
			},
			stop: function(e, t, n) {
				var i = function(e) {
					var t = e.stop;
					delete e.stop, t(n)
				};
				return "string" != typeof e && (n = t, t = e, e = void 0), t && e !== !1 && this.queue(e || "fx", []), this.each(function() {
					var t = !0,
						r = null != e && e + "queueHooks",
						o = rt.timers,
						a = rt._data(this);
					if (r) a[r] && a[r].stop && i(a[r]);
					else
						for (r in a) a[r] && a[r].stop && _n.test(r) && i(a[r]);
					for (r = o.length; r--;) o[r].elem !== this || null != e && o[r].queue !== e || (o[r].anim.stop(n), t = !1, o.splice(r, 1));
					(t || !n) && rt.dequeue(this, e)
				})
			},
			finish: function(e) {
				return e !== !1 && (e = e || "fx"), this.each(function() {
					var t, n = rt._data(this),
						i = n[e + "queue"],
						r = n[e + "queueHooks"],
						o = rt.timers,
						a = i ? i.length : 0;
					for (n.finish = !0, rt.queue(this, e, []), r && r.stop && r.stop.call(this, !0), t = o.length; t--;) o[t].elem === this && o[t].queue === e && (o[t].anim.stop(!0), o.splice(t, 1));
					for (t = 0; a > t; t++) i[t] && i[t].finish && i[t].finish.call(this);
					delete n.finish
				})
			}
		}), rt.each(["toggle", "show", "hide"], function(e, t) {
			var n = rt.fn[t];
			rt.fn[t] = function(e, i, r) {
				return null == e || "boolean" == typeof e ? n.apply(this, arguments) : this.animate(F(t, !0), e, i, r)
			}
		}), rt.each({
			slideDown: F("show"),
			slideUp: F("hide"),
			slideToggle: F("toggle"),
			fadeIn: {
				opacity: "show"
			},
			fadeOut: {
				opacity: "hide"
			},
			fadeToggle: {
				opacity: "toggle"
			}
		}, function(e, t) {
			rt.fn[e] = function(e, n, i) {
				return this.animate(t, e, n, i)
			}
		}), rt.timers = [], rt.fx.tick = function() {
			var e, t = rt.timers,
				n = 0;
			for (fn = rt.now(); n < t.length; n++) e = t[n], e() || t[n] !== e || t.splice(n--, 1);
			t.length || rt.fx.stop(), fn = void 0
		}, rt.fx.timer = function(e) {
			rt.timers.push(e), e() ? rt.fx.start() : rt.timers.pop()
		}, rt.fx.interval = 13, rt.fx.start = function() {
			gn || (gn = setInterval(rt.fx.tick, rt.fx.interval))
		}, rt.fx.stop = function() {
			clearInterval(gn), gn = null
		}, rt.fx.speeds = {
			slow: 600,
			fast: 200,
			_default: 400
		}, rt.fn.delay = function(e, t) {
			return e = rt.fx ? rt.fx.speeds[e] || e : e, t = t || "fx", this.queue(t, function(t, n) {
				var i = setTimeout(t, e);
				n.stop = function() {
					clearTimeout(i)
				}
			})
		},
			function() {
				var e, t, n, i, r;
				t = ft.createElement("div"), t.setAttribute("className", "t"), t.innerHTML = "  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>", i = t.getElementsByTagName("a")[0], n = ft.createElement("select"), r = n.appendChild(ft.createElement("option")), e = t.getElementsByTagName("input")[0], i.style.cssText = "top:1px", nt.getSetAttribute = "t" !== t.className, nt.style = /top/.test(i.getAttribute("style")), nt.hrefNormalized = "/a" === i.getAttribute("href"), nt.checkOn = !!e.value, nt.optSelected = r.selected, nt.enctype = !!ft.createElement("form").enctype, n.disabled = !0, nt.optDisabled = !r.disabled, e = ft.createElement("input"), e.setAttribute("value", ""), nt.input = "" === e.getAttribute("value"), e.value = "t", e.setAttribute("type", "radio"), nt.radioValue = "t" === e.value
			}();
		var wn = /\r/g;
		rt.fn.extend({
			val: function(e) {
				var t, n, i, r = this[0]; {
					if (arguments.length) return i = rt.isFunction(e), this.each(function(n) {
						var r;
						1 === this.nodeType && (r = i ? e.call(this, n, rt(this).val()) : e, null == r ? r = "" : "number" == typeof r ? r += "" : rt.isArray(r) && (r = rt.map(r, function(e) {
							return null == e ? "" : e + ""
						})), t = rt.valHooks[this.type] || rt.valHooks[this.nodeName.toLowerCase()], t && "set" in t && void 0 !== t.set(this, r, "value") || (this.value = r))
					});
					if (r) return t = rt.valHooks[r.type] || rt.valHooks[r.nodeName.toLowerCase()], t && "get" in t && void 0 !== (n = t.get(r, "value")) ? n : (n = r.value, "string" == typeof n ? n.replace(wn, "") : null == n ? "" : n)
				}
			}
		}), rt.extend({
			valHooks: {
				option: {
					get: function(e) {
						var t = rt.find.attr(e, "value");
						return null != t ? t : rt.trim(rt.text(e))
					}
				},
				select: {
					get: function(e) {
						for (var t, n, i = e.options, r = e.selectedIndex, o = "select-one" === e.type || 0 > r, a = o ? null : [], s = o ? r + 1 : i.length, l = 0 > r ? s : o ? r : 0; s > l; l++)
							if (n = i[l], !(!n.selected && l !== r || (nt.optDisabled ? n.disabled : null !== n.getAttribute("disabled")) || n.parentNode.disabled && rt.nodeName(n.parentNode, "optgroup"))) {
								if (t = rt(n).val(), o) return t;
								a.push(t)
							}
						return a
					},
					set: function(e, t) {
						for (var n, i, r = e.options, o = rt.makeArray(t), a = r.length; a--;)
							if (i = r[a], rt.inArray(rt.valHooks.option.get(i), o) >= 0) try {
								i.selected = n = !0
							} catch (s) {
								i.scrollHeight
							} else i.selected = !1;
						return n || (e.selectedIndex = -1), r
					}
				}
			}
		}), rt.each(["radio", "checkbox"], function() {
			rt.valHooks[this] = {
				set: function(e, t) {
					return rt.isArray(t) ? e.checked = rt.inArray(rt(e).val(), t) >= 0 : void 0
				}
			}, nt.checkOn || (rt.valHooks[this].get = function(e) {
				return null === e.getAttribute("value") ? "on" : e.value
			})
		});
		var xn, En, kn = rt.expr.attrHandle,
			Cn = /^(?:checked|selected)$/i,
			Tn = nt.getSetAttribute,
			Sn = nt.input;
		rt.fn.extend({
			attr: function(e, t) {
				return Dt(this, rt.attr, e, t, arguments.length > 1)
			},
			removeAttr: function(e) {
				return this.each(function() {
					rt.removeAttr(this, e)
				})
			}
		}), rt.extend({
			attr: function(e, t, n) {
				var i, r, o = e.nodeType;
				if (e && 3 !== o && 8 !== o && 2 !== o) return typeof e.getAttribute === Et ? rt.prop(e, t, n) : (1 === o && rt.isXMLDoc(e) || (t = t.toLowerCase(), i = rt.attrHooks[t] || (rt.expr.match.bool.test(t) ? En : xn)), void 0 === n ? i && "get" in i && null !== (r = i.get(e, t)) ? r : (r = rt.find.attr(e, t), null == r ? void 0 : r) : null !== n ? i && "set" in i && void 0 !== (r = i.set(e, n, t)) ? r : (e.setAttribute(t, n + ""), n) : void rt.removeAttr(e, t))
			},
			removeAttr: function(e, t) {
				var n, i, r = 0,
					o = t && t.match(bt);
				if (o && 1 === e.nodeType)
					for (; n = o[r++];) i = rt.propFix[n] || n, rt.expr.match.bool.test(n) ? Sn && Tn || !Cn.test(n) ? e[i] = !1 : e[rt.camelCase("default-" + n)] = e[i] = !1 : rt.attr(e, n, ""), e.removeAttribute(Tn ? n : i)
			},
			attrHooks: {
				type: {
					set: function(e, t) {
						if (!nt.radioValue && "radio" === t && rt.nodeName(e, "input")) {
							var n = e.value;
							return e.setAttribute("type", t), n && (e.value = n), t
						}
					}
				}
			}
		}), En = {
			set: function(e, t, n) {
				return t === !1 ? rt.removeAttr(e, n) : Sn && Tn || !Cn.test(n) ? e.setAttribute(!Tn && rt.propFix[n] || n, n) : e[rt.camelCase("default-" + n)] = e[n] = !0, n
			}
		}, rt.each(rt.expr.match.bool.source.match(/\w+/g), function(e, t) {
			var n = kn[t] || rt.find.attr;
			kn[t] = Sn && Tn || !Cn.test(t) ? function(e, t, i) {
				var r, o;
				return i || (o = kn[t], kn[t] = r, r = null != n(e, t, i) ? t.toLowerCase() : null, kn[t] = o), r
			} : function(e, t, n) {
				return n ? void 0 : e[rt.camelCase("default-" + t)] ? t.toLowerCase() : null
			}
		}), Sn && Tn || (rt.attrHooks.value = {
			set: function(e, t, n) {
				return rt.nodeName(e, "input") ? void(e.defaultValue = t) : xn && xn.set(e, t, n)
			}
		}), Tn || (xn = {
			set: function(e, t, n) {
				var i = e.getAttributeNode(n);
				return i || e.setAttributeNode(i = e.ownerDocument.createAttribute(n)), i.value = t += "", "value" === n || t === e.getAttribute(n) ? t : void 0
			}
		}, kn.id = kn.name = kn.coords = function(e, t, n) {
			var i;
			return n ? void 0 : (i = e.getAttributeNode(t)) && "" !== i.value ? i.value : null
		}, rt.valHooks.button = {
			get: function(e, t) {
				var n = e.getAttributeNode(t);
				return n && n.specified ? n.value : void 0
			},
			set: xn.set
		}, rt.attrHooks.contenteditable = {
			set: function(e, t, n) {
				xn.set(e, "" === t ? !1 : t, n)
			}
		}, rt.each(["width", "height"], function(e, t) {
			rt.attrHooks[t] = {
				set: function(e, n) {
					return "" === n ? (e.setAttribute(t, "auto"), n) : void 0
				}
			}
		})), nt.style || (rt.attrHooks.style = {
			get: function(e) {
				return e.style.cssText || void 0
			},
			set: function(e, t) {
				return e.style.cssText = t + ""
			}
		});
		var On = /^(?:input|select|textarea|button|object)$/i,
			Dn = /^(?:a|area)$/i;
		rt.fn.extend({
			prop: function(e, t) {
				return Dt(this, rt.prop, e, t, arguments.length > 1)
			},
			removeProp: function(e) {
				return e = rt.propFix[e] || e, this.each(function() {
					try {
						this[e] = void 0, delete this[e]
					} catch (t) {}
				})
			}
		}), rt.extend({
			propFix: {
				"for": "htmlFor",
				"class": "className"
			},
			prop: function(e, t, n) {
				var i, r, o, a = e.nodeType;
				if (e && 3 !== a && 8 !== a && 2 !== a) return o = 1 !== a || !rt.isXMLDoc(e), o && (t = rt.propFix[t] || t, r = rt.propHooks[t]), void 0 !== n ? r && "set" in r && void 0 !== (i = r.set(e, n, t)) ? i : e[t] = n : r && "get" in r && null !== (i = r.get(e, t)) ? i : e[t]
			},
			propHooks: {
				tabIndex: {
					get: function(e) {
						var t = rt.find.attr(e, "tabindex");
						return t ? parseInt(t, 10) : On.test(e.nodeName) || Dn.test(e.nodeName) && e.href ? 0 : -1
					}
				}
			}
		}), nt.hrefNormalized || rt.each(["href", "src"], function(e, t) {
			rt.propHooks[t] = {
				get: function(e) {
					return e.getAttribute(t, 4)
				}
			}
		}), nt.optSelected || (rt.propHooks.selected = {
			get: function(e) {
				var t = e.parentNode;
				return t && (t.selectedIndex, t.parentNode && t.parentNode.selectedIndex), null
			}
		}), rt.each(["tabIndex", "readOnly", "maxLength", "cellSpacing", "cellPadding", "rowSpan", "colSpan", "useMap", "frameBorder", "contentEditable"], function() {
			rt.propFix[this.toLowerCase()] = this
		}), nt.enctype || (rt.propFix.enctype = "encoding");
		var An = /[\t\r\n\f]/g;
		rt.fn.extend({
			addClass: function(e) {
				var t, n, i, r, o, a, s = 0,
					l = this.length,
					c = "string" == typeof e && e;
				if (rt.isFunction(e)) return this.each(function(t) {
					rt(this).addClass(e.call(this, t, this.className))
				});
				if (c)
					for (t = (e || "").match(bt) || []; l > s; s++)
						if (n = this[s], i = 1 === n.nodeType && (n.className ? (" " + n.className + " ").replace(An, " ") : " ")) {
							for (o = 0; r = t[o++];) i.indexOf(" " + r + " ") < 0 && (i += r + " ");
							a = rt.trim(i), n.className !== a && (n.className = a)
						}
				return this
			},
			removeClass: function(e) {
				var t, n, i, r, o, a, s = 0,
					l = this.length,
					c = 0 === arguments.length || "string" == typeof e && e;
				if (rt.isFunction(e)) return this.each(function(t) {
					rt(this).removeClass(e.call(this, t, this.className))
				});
				if (c)
					for (t = (e || "").match(bt) || []; l > s; s++)
						if (n = this[s], i = 1 === n.nodeType && (n.className ? (" " + n.className + " ").replace(An, " ") : "")) {
							for (o = 0; r = t[o++];)
								for (; i.indexOf(" " + r + " ") >= 0;) i = i.replace(" " + r + " ", " ");
							a = e ? rt.trim(i) : "", n.className !== a && (n.className = a)
						}
				return this
			},
			toggleClass: function(e, t) {
				var n = typeof e;
				return "boolean" == typeof t && "string" === n ? t ? this.addClass(e) : this.removeClass(e) : this.each(rt.isFunction(e) ? function(n) {
					rt(this).toggleClass(e.call(this, n, this.className, t), t)
				} : function() {
					if ("string" === n)
						for (var t, i = 0, r = rt(this), o = e.match(bt) || []; t = o[i++];) r.hasClass(t) ? r.removeClass(t) : r.addClass(t);
					else(n === Et || "boolean" === n) && (this.className && rt._data(this, "__className__", this.className), this.className = this.className || e === !1 ? "" : rt._data(this, "__className__") || "")
				})
			},
			hasClass: function(e) {
				for (var t = " " + e + " ", n = 0, i = this.length; i > n; n++)
					if (1 === this[n].nodeType && (" " + this[n].className + " ").replace(An, " ").indexOf(t) >= 0) return !0;
				return !1
			}
		}), rt.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "), function(e, t) {
			rt.fn[t] = function(e, n) {
				return arguments.length > 0 ? this.on(t, null, e, n) : this.trigger(t)
			}
		}), rt.fn.extend({
			hover: function(e, t) {
				return this.mouseenter(e).mouseleave(t || e)
			},
			bind: function(e, t, n) {
				return this.on(e, null, t, n)
			},
			unbind: function(e, t) {
				return this.off(e, null, t)
			},
			delegate: function(e, t, n, i) {
				return this.on(t, e, n, i)
			},
			undelegate: function(e, t, n) {
				return 1 === arguments.length ? this.off(e, "**") : this.off(t, e || "**", n)
			}
		});
		var Nn = rt.now(),
			In = /\?/,
			jn = /(,)|(\[|{)|(}|])|"(?:[^"\\\r\n]|\\["\\\/bfnrt]|\\u[\da-fA-F]{4})*"\s*:?|true|false|null|-?(?!0\d)\d+(?:\.\d+|)(?:[eE][+-]?\d+|)/g;
		rt.parseJSON = function(t) {
			if (e.JSON && e.JSON.parse) return e.JSON.parse(t + "");
			var n, i = null,
				r = rt.trim(t + "");
			return r && !rt.trim(r.replace(jn, function(e, t, r, o) {
				return n && t && (i = 0), 0 === i ? e : (n = r || t, i += !o - !r, "")
			})) ? Function("return " + r)() : rt.error("Invalid JSON: " + t)
		}, rt.parseXML = function(t) {
			var n, i;
			if (!t || "string" != typeof t) return null;
			try {
				e.DOMParser ? (i = new DOMParser, n = i.parseFromString(t, "text/xml")) : (n = new ActiveXObject("Microsoft.XMLDOM"), n.async = "false", n.loadXML(t))
			} catch (r) {
				n = void 0
			}
			return n && n.documentElement && !n.getElementsByTagName("parsererror").length || rt.error("Invalid XML: " + t), n
		};
		var Fn, Ln, Pn = /#.*$/,
			Hn = /([?&])_=[^&]*/,
			Mn = /^(.*?):[ \t]*([^\r\n]*)\r?$/gm,
			$n = /^(?:about|app|app-storage|.+-extension|file|res|widget):$/,
			Wn = /^(?:GET|HEAD)$/,
			Rn = /^\/\//,
			zn = /^([\w.+-]+:)(?:\/\/(?:[^\/?#]*@|)([^\/?#:]*)(?::(\d+)|)|)/,
			Un = {},
			Bn = {},
			qn = "*/".concat("*");
		try {
			Ln = location.href
		} catch (Gn) {
			Ln = ft.createElement("a"), Ln.href = "", Ln = Ln.href
		}
		Fn = zn.exec(Ln.toLowerCase()) || [], rt.extend({
			active: 0,
			lastModified: {},
			etag: {},
			ajaxSettings: {
				url: Ln,
				type: "GET",
				isLocal: $n.test(Fn[1]),
				global: !0,
				processData: !0,
				async: !0,
				contentType: "application/x-www-form-urlencoded; charset=UTF-8",
				accepts: {
					"*": qn,
					text: "text/plain",
					html: "text/html",
					xml: "application/xml, text/xml",
					json: "application/json, text/javascript"
				},
				contents: {
					xml: /xml/,
					html: /html/,
					json: /json/
				},
				responseFields: {
					xml: "responseXML",
					text: "responseText",
					json: "responseJSON"
				},
				converters: {
					"* text": String,
					"text html": !0,
					"text json": rt.parseJSON,
					"text xml": rt.parseXML
				},
				flatOptions: {
					url: !0,
					context: !0
				}
			},
			ajaxSetup: function(e, t) {
				return t ? R(R(e, rt.ajaxSettings), t) : R(rt.ajaxSettings, e)
			},
			ajaxPrefilter: $(Un),
			ajaxTransport: $(Bn),
			ajax: function(e, t) {
				function n(e, t, n, i) {
					var r, u, v, _, y, x = t;
					2 !== b && (b = 2, s && clearTimeout(s), c = void 0, a = i || "", w.readyState = e > 0 ? 4 : 0, r = e >= 200 && 300 > e || 304 === e, n && (_ = z(d, w, n)), _ = U(d, _, w, r), r ? (d.ifModified && (y = w.getResponseHeader("Last-Modified"), y && (rt.lastModified[o] = y), y = w.getResponseHeader("etag"), y && (rt.etag[o] = y)), 204 === e || "HEAD" === d.type ? x = "nocontent" : 304 === e ? x = "notmodified" : (x = _.state, u = _.data, v = _.error, r = !v)) : (v = x, (e || !x) && (x = "error", 0 > e && (e = 0))), w.status = e, w.statusText = (t || x) + "", r ? f.resolveWith(h, [u, x, w]) : f.rejectWith(h, [w, x, v]), w.statusCode(m), m = void 0, l && p.trigger(r ? "ajaxSuccess" : "ajaxError", [w, d, r ? u : v]), g.fireWith(h, [w, x]), l && (p.trigger("ajaxComplete", [w, d]), --rt.active || rt.event.trigger("ajaxStop")))
				}
				"object" == typeof e && (t = e, e = void 0), t = t || {};
				var i, r, o, a, s, l, c, u, d = rt.ajaxSetup({}, t),
					h = d.context || d,
					p = d.context && (h.nodeType || h.jquery) ? rt(h) : rt.event,
					f = rt.Deferred(),
					g = rt.Callbacks("once memory"),
					m = d.statusCode || {},
					v = {},
					_ = {},
					b = 0,
					y = "canceled",
					w = {
						readyState: 0,
						getResponseHeader: function(e) {
							var t;
							if (2 === b) {
								if (!u)
									for (u = {}; t = Mn.exec(a);) u[t[1].toLowerCase()] = t[2];
								t = u[e.toLowerCase()]
							}
							return null == t ? null : t
						},
						getAllResponseHeaders: function() {
							return 2 === b ? a : null
						},
						setRequestHeader: function(e, t) {
							var n = e.toLowerCase();
							return b || (e = _[n] = _[n] || e, v[e] = t), this
						},
						overrideMimeType: function(e) {
							return b || (d.mimeType = e), this
						},
						statusCode: function(e) {
							var t;
							if (e)
								if (2 > b)
									for (t in e) m[t] = [m[t], e[t]];
								else w.always(e[w.status]);
							return this
						},
						abort: function(e) {
							var t = e || y;
							return c && c.abort(t), n(0, t), this
						}
					};
				if (f.promise(w).complete = g.add, w.success = w.done, w.error = w.fail, d.url = ((e || d.url || Ln) + "").replace(Pn, "").replace(Rn, Fn[1] + "//"), d.type = t.method || t.type || d.method || d.type, d.dataTypes = rt.trim(d.dataType || "*").toLowerCase().match(bt) || [""], null == d.crossDomain && (i = zn.exec(d.url.toLowerCase()), d.crossDomain = !(!i || i[1] === Fn[1] && i[2] === Fn[2] && (i[3] || ("http:" === i[1] ? "80" : "443")) === (Fn[3] || ("http:" === Fn[1] ? "80" : "443")))), d.data && d.processData && "string" != typeof d.data && (d.data = rt.param(d.data, d.traditional)), W(Un, d, t, w), 2 === b) return w;
				l = d.global, l && 0 === rt.active++ && rt.event.trigger("ajaxStart"), d.type = d.type.toUpperCase(), d.hasContent = !Wn.test(d.type), o = d.url, d.hasContent || (d.data && (o = d.url += (In.test(o) ? "&" : "?") + d.data, delete d.data), d.cache === !1 && (d.url = Hn.test(o) ? o.replace(Hn, "$1_=" + Nn++) : o + (In.test(o) ? "&" : "?") + "_=" + Nn++)), d.ifModified && (rt.lastModified[o] && w.setRequestHeader("If-Modified-Since", rt.lastModified[o]), rt.etag[o] && w.setRequestHeader("If-None-Match", rt.etag[o])), (d.data && d.hasContent && d.contentType !== !1 || t.contentType) && w.setRequestHeader("Content-Type", d.contentType), w.setRequestHeader("Accept", d.dataTypes[0] && d.accepts[d.dataTypes[0]] ? d.accepts[d.dataTypes[0]] + ("*" !== d.dataTypes[0] ? ", " + qn + "; q=0.01" : "") : d.accepts["*"]);
				for (r in d.headers) w.setRequestHeader(r, d.headers[r]);
				if (d.beforeSend && (d.beforeSend.call(h, w, d) === !1 || 2 === b)) return w.abort();
				y = "abort";
				for (r in {
					success: 1,
					error: 1,
					complete: 1
				}) w[r](d[r]);
				if (c = W(Bn, d, t, w)) {
					w.readyState = 1, l && p.trigger("ajaxSend", [w, d]), d.async && d.timeout > 0 && (s = setTimeout(function() {
						w.abort("timeout")
					}, d.timeout));
					try {
						b = 1, c.send(v, n)
					} catch (x) {
						if (!(2 > b)) throw x;
						n(-1, x)
					}
				} else n(-1, "No Transport");
				return w
			},
			getJSON: function(e, t, n) {
				return rt.get(e, t, n, "json")
			},
			getScript: function(e, t) {
				return rt.get(e, void 0, t, "script")
			}
		}), rt.each(["get", "post"], function(e, t) {
			rt[t] = function(e, n, i, r) {
				return rt.isFunction(n) && (r = r || i, i = n, n = void 0), rt.ajax({
					url: e,
					type: t,
					dataType: r,
					data: n,
					success: i
				})
			}
		}), rt.each(["ajaxStart", "ajaxStop", "ajaxComplete", "ajaxError", "ajaxSuccess", "ajaxSend"], function(e, t) {
			rt.fn[t] = function(e) {
				return this.on(t, e)
			}
		}), rt._evalUrl = function(e) {
			return rt.ajax({
				url: e,
				type: "GET",
				dataType: "script",
				async: !1,
				global: !1,
				"throws": !0
			})
		}, rt.fn.extend({
			wrapAll: function(e) {
				if (rt.isFunction(e)) return this.each(function(t) {
					rt(this).wrapAll(e.call(this, t))
				});
				if (this[0]) {
					var t = rt(e, this[0].ownerDocument).eq(0).clone(!0);
					this[0].parentNode && t.insertBefore(this[0]), t.map(function() {
						for (var e = this; e.firstChild && 1 === e.firstChild.nodeType;) e = e.firstChild;
						return e
					}).append(this)
				}
				return this
			},
			wrapInner: function(e) {
				return this.each(rt.isFunction(e) ? function(t) {
					rt(this).wrapInner(e.call(this, t))
				} : function() {
					var t = rt(this),
						n = t.contents();
					n.length ? n.wrapAll(e) : t.append(e)
				})
			},
			wrap: function(e) {
				var t = rt.isFunction(e);
				return this.each(function(n) {
					rt(this).wrapAll(t ? e.call(this, n) : e)
				})
			},
			unwrap: function() {
				return this.parent().each(function() {
					rt.nodeName(this, "body") || rt(this).replaceWith(this.childNodes)
				}).end()
			}
		}), rt.expr.filters.hidden = function(e) {
			return e.offsetWidth <= 0 && e.offsetHeight <= 0 || !nt.reliableHiddenOffsets() && "none" === (e.style && e.style.display || rt.css(e, "display"))
		}, rt.expr.filters.visible = function(e) {
			return !rt.expr.filters.hidden(e)
		};
		var Qn = /%20/g,
			Yn = /\[\]$/,
			Vn = /\r?\n/g,
			Kn = /^(?:submit|button|image|reset|file)$/i,
			Xn = /^(?:input|select|textarea|keygen)/i;
		rt.param = function(e, t) {
			var n, i = [],
				r = function(e, t) {
					t = rt.isFunction(t) ? t() : null == t ? "" : t, i[i.length] = encodeURIComponent(e) + "=" + encodeURIComponent(t)
				};
			if (void 0 === t && (t = rt.ajaxSettings && rt.ajaxSettings.traditional), rt.isArray(e) || e.jquery && !rt.isPlainObject(e)) rt.each(e, function() {
				r(this.name, this.value)
			});
			else
				for (n in e) B(n, e[n], t, r);
			return i.join("&").replace(Qn, "+")
		}, rt.fn.extend({
			serialize: function() {
				return rt.param(this.serializeArray())
			},
			serializeArray: function() {
				return this.map(function() {
					var e = rt.prop(this, "elements");
					return e ? rt.makeArray(e) : this
				}).filter(function() {
					var e = this.type;
					return this.name && !rt(this).is(":disabled") && Xn.test(this.nodeName) && !Kn.test(e) && (this.checked || !At.test(e))
				}).map(function(e, t) {
					var n = rt(this).val();
					return null == n ? null : rt.isArray(n) ? rt.map(n, function(e) {
						return {
							name: t.name,
							value: e.replace(Vn, "\r\n")
						}
					}) : {
						name: t.name,
						value: n.replace(Vn, "\r\n")
					}
				}).get()
			}
		}), rt.ajaxSettings.xhr = void 0 !== e.ActiveXObject ? function() {
			return !this.isLocal && /^(get|post|head|put|delete|options)$/i.test(this.type) && q() || G()
		} : q;
		var Jn = 0,
			Zn = {},
			ei = rt.ajaxSettings.xhr();
		e.ActiveXObject && rt(e).on("unload", function() {
			for (var e in Zn) Zn[e](void 0, !0)
		}), nt.cors = !!ei && "withCredentials" in ei, ei = nt.ajax = !!ei, ei && rt.ajaxTransport(function(e) {
			if (!e.crossDomain || nt.cors) {
				var t;
				return {
					send: function(n, i) {
						var r, o = e.xhr(),
							a = ++Jn;
						if (o.open(e.type, e.url, e.async, e.username, e.password), e.xhrFields)
							for (r in e.xhrFields) o[r] = e.xhrFields[r];
						e.mimeType && o.overrideMimeType && o.overrideMimeType(e.mimeType), e.crossDomain || n["X-Requested-With"] || (n["X-Requested-With"] = "XMLHttpRequest");
						for (r in n) void 0 !== n[r] && o.setRequestHeader(r, n[r] + "");
						o.send(e.hasContent && e.data || null), t = function(n, r) {
							var s, l, c;
							if (t && (r || 4 === o.readyState))
								if (delete Zn[a], t = void 0, o.onreadystatechange = rt.noop, r) 4 !== o.readyState && o.abort();
								else {
									c = {}, s = o.status, "string" == typeof o.responseText && (c.text = o.responseText);
									try {
										l = o.statusText
									} catch (u) {
										l = ""
									}
									s || !e.isLocal || e.crossDomain ? 1223 === s && (s = 204) : s = c.text ? 200 : 404
								}
							c && i(s, l, c, o.getAllResponseHeaders())
						}, e.async ? 4 === o.readyState ? setTimeout(t) : o.onreadystatechange = Zn[a] = t : t()
					},
					abort: function() {
						t && t(void 0, !0)
					}
				}
			}
		}), rt.ajaxSetup({
			accepts: {
				script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
			},
			contents: {
				script: /(?:java|ecma)script/
			},
			converters: {
				"text script": function(e) {
					return rt.globalEval(e), e
				}
			}
		}), rt.ajaxPrefilter("script", function(e) {
			void 0 === e.cache && (e.cache = !1), e.crossDomain && (e.type = "GET", e.global = !1)
		}), rt.ajaxTransport("script", function(e) {
			if (e.crossDomain) {
				var t, n = ft.head || rt("head")[0] || ft.documentElement;
				return {
					send: function(i, r) {
						t = ft.createElement("script"), t.async = !0, e.scriptCharset && (t.charset = e.scriptCharset), t.src = e.url, t.onload = t.onreadystatechange = function(e, n) {
							(n || !t.readyState || /loaded|complete/.test(t.readyState)) && (t.onload = t.onreadystatechange = null, t.parentNode && t.parentNode.removeChild(t), t = null, n || r(200, "success"))
						}, n.insertBefore(t, n.firstChild)
					},
					abort: function() {
						t && t.onload(void 0, !0)
					}
				}
			}
		});
		var ti = [],
			ni = /(=)\?(?=&|$)|\?\?/;
		rt.ajaxSetup({
			jsonp: "callback",
			jsonpCallback: function() {
				var e = ti.pop() || rt.expando + "_" + Nn++;
				return this[e] = !0, e
			}
		}), rt.ajaxPrefilter("json jsonp", function(t, n, i) {
			var r, o, a, s = t.jsonp !== !1 && (ni.test(t.url) ? "url" : "string" == typeof t.data && !(t.contentType || "").indexOf("application/x-www-form-urlencoded") && ni.test(t.data) && "data");
			return s || "jsonp" === t.dataTypes[0] ? (r = t.jsonpCallback = rt.isFunction(t.jsonpCallback) ? t.jsonpCallback() : t.jsonpCallback, s ? t[s] = t[s].replace(ni, "$1" + r) : t.jsonp !== !1 && (t.url += (In.test(t.url) ? "&" : "?") + t.jsonp + "=" + r), t.converters["script json"] = function() {
				return a || rt.error(r + " was not called"), a[0]
			}, t.dataTypes[0] = "json", o = e[r], e[r] = function() {
				a = arguments
			}, i.always(function() {
				e[r] = o, t[r] && (t.jsonpCallback = n.jsonpCallback, ti.push(r)), a && rt.isFunction(o) && o(a[0]), a = o = void 0
			}), "script") : void 0
		}), rt.parseHTML = function(e, t, n) {
			if (!e || "string" != typeof e) return null;
			"boolean" == typeof t && (n = t, t = !1), t = t || ft;
			var i = dt.exec(e),
				r = !n && [];
			return i ? [t.createElement(i[1])] : (i = rt.buildFragment([e], t, r), r && r.length && rt(r).remove(), rt.merge([], i.childNodes))
		};
		var ii = rt.fn.load;
		rt.fn.load = function(e, t, n) {
			if ("string" != typeof e && ii) return ii.apply(this, arguments);
			var i, r, o, a = this,
				s = e.indexOf(" ");
			return s >= 0 && (i = rt.trim(e.slice(s, e.length)), e = e.slice(0, s)), rt.isFunction(t) ? (n = t, t = void 0) : t && "object" == typeof t && (o = "POST"), a.length > 0 && rt.ajax({
				url: e,
				type: o,
				dataType: "html",
				data: t
			}).done(function(e) {
				r = arguments, a.html(i ? rt("<div>").append(rt.parseHTML(e)).find(i) : e)
			}).complete(n && function(e, t) {
				a.each(n, r || [e.responseText, t, e])
			}), this
		}, rt.expr.filters.animated = function(e) {
			return rt.grep(rt.timers, function(t) {
				return e === t.elem
			}).length
		};
		var ri = e.document.documentElement;
		rt.offset = {
			setOffset: function(e, t, n) {
				var i, r, o, a, s, l, c, u = rt.css(e, "position"),
					d = rt(e),
					h = {};
				"static" === u && (e.style.position = "relative"), s = d.offset(), o = rt.css(e, "top"), l = rt.css(e, "left"), c = ("absolute" === u || "fixed" === u) && rt.inArray("auto", [o, l]) > -1, c ? (i = d.position(), a = i.top, r = i.left) : (a = parseFloat(o) || 0, r = parseFloat(l) || 0), rt.isFunction(t) && (t = t.call(e, n, s)), null != t.top && (h.top = t.top - s.top + a), null != t.left && (h.left = t.left - s.left + r), "using" in t ? t.using.call(e, h) : d.css(h)
			}
		}, rt.fn.extend({
			offset: function(e) {
				if (arguments.length) return void 0 === e ? this : this.each(function(t) {
					rt.offset.setOffset(this, e, t)
				});
				var t, n, i = {
						top: 0,
						left: 0
					},
					r = this[0],
					o = r && r.ownerDocument;
				if (o) return t = o.documentElement, rt.contains(t, r) ? (typeof r.getBoundingClientRect !== Et && (i = r.getBoundingClientRect()), n = Q(o), {
					top: i.top + (n.pageYOffset || t.scrollTop) - (t.clientTop || 0),
					left: i.left + (n.pageXOffset || t.scrollLeft) - (t.clientLeft || 0)
				}) : i
			},
			position: function() {
				if (this[0]) {
					var e, t, n = {
							top: 0,
							left: 0
						},
						i = this[0];
					return "fixed" === rt.css(i, "position") ? t = i.getBoundingClientRect() : (e = this.offsetParent(), t = this.offset(), rt.nodeName(e[0], "html") || (n = e.offset()), n.top += rt.css(e[0], "borderTopWidth", !0), n.left += rt.css(e[0], "borderLeftWidth", !0)), {
						top: t.top - n.top - rt.css(i, "marginTop", !0),
						left: t.left - n.left - rt.css(i, "marginLeft", !0)
					}
				}
			},
			offsetParent: function() {
				return this.map(function() {
					for (var e = this.offsetParent || ri; e && !rt.nodeName(e, "html") && "static" === rt.css(e, "position");) e = e.offsetParent;
					return e || ri
				})
			}
		}), rt.each({
			scrollLeft: "pageXOffset",
			scrollTop: "pageYOffset"
		}, function(e, t) {
			var n = /Y/.test(t);
			rt.fn[e] = function(i) {
				return Dt(this, function(e, i, r) {
					var o = Q(e);
					return void 0 === r ? o ? t in o ? o[t] : o.document.documentElement[i] : e[i] : void(o ? o.scrollTo(n ? rt(o).scrollLeft() : r, n ? r : rt(o).scrollTop()) : e[i] = r)
				}, e, i, arguments.length, null)
			}
		}), rt.each(["top", "left"], function(e, t) {
			rt.cssHooks[t] = T(nt.pixelPosition, function(e, n) {
				return n ? (n = tn(e, t), rn.test(n) ? rt(e).position()[t] + "px" : n) : void 0
			})
		}), rt.each({
			Height: "height",
			Width: "width"
		}, function(e, t) {
			rt.each({
				padding: "inner" + e,
				content: t,
				"": "outer" + e
			}, function(n, i) {
				rt.fn[i] = function(i, r) {
					var o = arguments.length && (n || "boolean" != typeof i),
						a = n || (i === !0 || r === !0 ? "margin" : "border");
					return Dt(this, function(t, n, i) {
						var r;
						return rt.isWindow(t) ? t.document.documentElement["client" + e] : 9 === t.nodeType ? (r = t.documentElement, Math.max(t.body["scroll" + e], r["scroll" + e], t.body["offset" + e], r["offset" + e], r["client" + e])) : void 0 === i ? rt.css(t, n, a) : rt.style(t, n, i, a)
					}, t, o ? i : void 0, o, null)
				}
			})
		}), rt.fn.size = function() {
			return this.length
		}, rt.fn.andSelf = rt.fn.addBack, "function" == typeof define && define.amd && define("jquery", [], function() {
			return rt
		});
		var oi = e.jQuery,
			ai = e.$;
		return rt.noConflict = function(t) {
			return e.$ === rt && (e.$ = ai), t && e.jQuery === rt && (e.jQuery = oi), rt
		}, typeof t === Et && (e.jQuery = e.$ = rt), rt
	}), jQuery.noConflict(),
	/*
	 * jQuery localtime plugin
	 *
	 * Copyright (c) 2011-2013 Greg Thomas
	 */
	function(e) {
		"use strict";
		e.localtime = function() {
			var t = {
					localtime: "yyyy-MM-dd HH:mm:ss"
				},
				n = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
				i = ["th", "st", "nd", "rd"],
				r = function(e) {
					return e >= 13 ? e - 12 : "0" === e ? 12 : e
				},
				o = function(e, o) {
					var a = e.getFullYear().toString(),
						s = (e.getMonth() + 1).toString(),
						l = e.getDate().toString(),
						c = e.getHours().toString(),
						u = e.getMinutes().toString(),
						d = e.getSeconds().toString(),
						h = e.getMilliseconds().toString(),
						p = e.getTimezoneOffset(),
						f = p > 0 ? "-" : "+";
					if (p = Math.abs(p), void 0 === o) {
						var g;
						for (g in t)
							if (t.hasOwnProperty(g)) {
								o = t[g];
								break
							}
						if (void 0 === o) return e.toString()
					}
					for (var m = "", v = "", _ = 0; _ < o.length; _++)
						if (v += o.charAt(_), "'" === v)
							for (_++; _ < o.length; _++) {
								var b = o.charAt(_);
								if ("'" === b) {
									v = "";
									break
								}
								m += b
							} else if ("\\" === v && _ < o.length - 1 && "'" === o.charAt(_ + 1)) _++, m += "'", v = "";
						else if (_ === o.length - 1 || o.charAt(_) !== o.charAt(_ + 1)) {
							switch (v) {
								case "d":
									m += l;
									break;
								case "dd":
									m += ("0" + l).slice(-2);
									break;
								case "M":
									m += s;
									break;
								case "MM":
									m += ("0" + s).slice(-2);
									break;
								case "MMM":
									m += n[s - 1].substr(0, 3);
									break;
								case "MMMMM":
									m += n[s - 1];
									break;
								case "yy":
									m += a.slice(-2);
									break;
								case "yyyy":
									m += a;
									break;
								case "H":
									m += c;
									break;
								case "HH":
									m += ("0" + c).slice(-2);
									break;
								case "h":
									m += r(c);
									break;
								case "hh":
									m += ("0" + r(c)).slice(-2);
									break;
								case "m":
									m += u;
									break;
								case "mm":
									m += ("0" + u).slice(-2);
									break;
								case "s":
									m += d;
									break;
								case "ss":
									m += ("0" + d).slice(-2);
									break;
								case "S":
									m += h;
									break;
								case "SS":
									m += ("0" + h).slice(-2);
									break;
								case "SSS":
									m += ("00" + h).slice(-3);
									break;
								case "o":
									switch (l) {
										case "11":
										case "12":
										case "13":
											m += i[0];
											break;
										default:
											var y = l % 10;
											y > 3 && (y = 0), m += i[y]
									}
									break;
								case "a":
								case "tt":
									m += c >= 12 ? "PM" : "AM";
									break;
								case "t":
									m += c >= 12 ? "P" : "A";
									break;
								case "z":
									m += f + parseInt(p / 60, 10);
									break;
								case "zz":
									m += f + ("0" + parseInt(p / 60, 10)).slice(-2);
									break;
								case "zzz":
									m += f + ("0" + parseInt(p / 60, 10)).slice(-2) + ":" + ("0" + p % 60).slice(-2);
									break;
								default:
									m += v
							}
							v = ""
						}
					return m
				};
			return {
				setFormat: function(e) {
					t = "object" == typeof e ? e : {
						localtime: e
					}
				},
				getFormat: function() {
					return t
				},
				parseISOTimeString: function(t) {
					t = e.trim(t.toString());
					var n = /^(\d{4})-([01]\d)-([0-3]\d)[T| ]([0-2]\d):([0-5]\d)(?::([0-5]\d)(?:\.(\d{3}))?)?Z$/.exec(t);
					if (n) {
						var i = parseInt(n[1], 10),
							r = parseInt(n[2], 10) - 1,
							o = parseInt(n[3], 10),
							a = parseInt(n[4], 10),
							s = parseInt(n[5], 10),
							l = n[6] ? parseInt(n[6], 10) : 0,
							c = n[7] ? parseInt(n[7], 10) : 0,
							u = new Date(Date.UTC(i, r, o, a, s, l, c));
						if (u.getUTCFullYear() !== i || u.getUTCMonth() !== r || u.getUTCDate() !== o) throw new Error(n[1] + "-" + n[2] + "-" + n[3] + " is not a valid date");
						if (u.getUTCHours() !== a) throw new Error(n[4] + ":" + n[5] + " is not a valid time");
						return u
					}
					throw new Error(t + " is not a supported date/time string")
				},
				toLocalTime: function(t, n) {
					return "[object Date]" !== Object.prototype.toString.call(t) && (t = e.localtime.parseISOTimeString(t)), "" === n && (n = void 0), o(t, n)
				},
				formatObject: function(t, n) {
					t.is(":input") ? t.val(e.localtime.toLocalTime(t.val(), n)) : t.text(e.localtime.toLocalTime(t.text(), n))
				},
				formatPage: function() {
					var t, n, i = function() {
							e.localtime.formatObject(e(this), t)
						},
						r = e.localtime.getFormat();
					for (n in r) r.hasOwnProperty(n) && (t = r[n], e("." + n).each(i));
					e("[data-localtime-format]").each(function() {
						e.localtime.formatObject(e(this), e(this).attr("data-localtime-format"))
					})
				}
			}
		}()
	}(jQuery), jQuery(document).ready(function(e) {
	"use strict";
	e.localtime.formatPage()
}),
	/*!
	 * jQuery Cookie Plugin v1.2
	 * https://github.com/carhartl/jquery-cookie
	 *
	 * Copyright 2011, Klaus Hartl
	 * Dual licensed under the MIT or GPL Version 2 licenses.
	 * http://www.opensource.org/licenses/mit-license.php
	 * http://www.opensource.org/licenses/GPL-2.0
	 */
	function(e, t, n) {
		function i(e) {
			return e
		}

		function r(e) {
			return decodeURIComponent(e.replace(o, " "))
		}
		var o = /\+/g;
		e.cookie = function(o, a, s) {
			if (a !== n && !/Object/.test(Object.prototype.toString.call(a))) {
				if (s = e.extend({}, e.cookie.defaults, s), null === a && (s.expires = -1), "number" == typeof s.expires) {
					var l = s.expires,
						c = s.expires = new Date;
					c.setDate(c.getDate() + l)
				}
				return a = String(a), t.cookie = [encodeURIComponent(o), "=", s.raw ? a : encodeURIComponent(a), s.expires ? "; expires=" + s.expires.toUTCString() : "", s.path ? "; path=" + s.path : "", s.domain ? "; domain=" + s.domain : "", s.secure ? "; secure" : ""].join("")
			}
			s = a || e.cookie.defaults || {};
			for (var u, d = s.raw ? i : r, h = t.cookie.split("; "), p = 0; u = h[p] && h[p].split("="); p++)
				if (d(u.shift()) === o) return d(u.join("="));
			return null
		}, e.cookie.defaults = {}, e.removeCookie = function(t, n) {
			return null !== e.cookie(t, n) ? (e.cookie(t, null, n), !0) : !1
		}
	}(jQuery, document),
	/*!
	 * jQuery UI Core 1.11.0
	 * http://jqueryui.com
	 *
	 * Copyright 2014 jQuery Foundation and other contributors
	 * Released under the MIT license.
	 * http://jquery.org/license
	 *
	 * http://api.jqueryui.com/category/ui-core/
	 */
	function(e) {
		"function" == typeof define && define.amd ? define(["jquery"], e) : e(jQuery)
	}(function(e) {
		function t(t, i) {
			var r, o, a, s = t.nodeName.toLowerCase();
			return "area" === s ? (r = t.parentNode, o = r.name, t.href && o && "map" === r.nodeName.toLowerCase() ? (a = e("img[usemap=#" + o + "]")[0], !!a && n(a)) : !1) : (/input|select|textarea|button|object/.test(s) ? !t.disabled : "a" === s ? t.href || i : i) && n(t)
		}

		function n(t) {
			return e.expr.filters.visible(t) && !e(t).parents().addBack().filter(function() {
				return "hidden" === e.css(this, "visibility")
			}).length
		}
		e.ui = e.ui || {}, e.extend(e.ui, {
			version: "1.11.0",
			keyCode: {
				BACKSPACE: 8,
				COMMA: 188,
				DELETE: 46,
				DOWN: 40,
				END: 35,
				ENTER: 13,
				ESCAPE: 27,
				HOME: 36,
				LEFT: 37,
				PAGE_DOWN: 34,
				PAGE_UP: 33,
				PERIOD: 190,
				RIGHT: 39,
				SPACE: 32,
				TAB: 9,
				UP: 38
			}
		}), e.fn.extend({
			scrollParent: function() {
				var t = this.css("position"),
					n = "absolute" === t,
					i = this.parents().filter(function() {
						var t = e(this);
						return n && "static" === t.css("position") ? !1 : /(auto|scroll)/.test(t.css("overflow") + t.css("overflow-y") + t.css("overflow-x"))
					}).eq(0);
				return "fixed" !== t && i.length ? i : e(this[0].ownerDocument || document)
			},
			uniqueId: function() {
				var e = 0;
				return function() {
					return this.each(function() {
						this.id || (this.id = "ui-id-" + ++e)
					})
				}
			}(),
			removeUniqueId: function() {
				return this.each(function() {
					/^ui-id-\d+$/.test(this.id) && e(this).removeAttr("id")
				})
			}
		}), e.extend(e.expr[":"], {
			data: e.expr.createPseudo ? e.expr.createPseudo(function(t) {
				return function(n) {
					return !!e.data(n, t)
				}
			}) : function(t, n, i) {
				return !!e.data(t, i[3])
			},
			focusable: function(n) {
				return t(n, !isNaN(e.attr(n, "tabindex")))
			},
			tabbable: function(n) {
				var i = e.attr(n, "tabindex"),
					r = isNaN(i);
				return (r || i >= 0) && t(n, !r)
			}
		}), e("<a>").outerWidth(1).jquery || e.each(["Width", "Height"], function(t, n) {
			function i(t, n, i, o) {
				return e.each(r, function() {
					n -= parseFloat(e.css(t, "padding" + this)) || 0, i && (n -= parseFloat(e.css(t, "border" + this + "Width")) || 0), o && (n -= parseFloat(e.css(t, "margin" + this)) || 0)
				}), n
			}
			var r = "Width" === n ? ["Left", "Right"] : ["Top", "Bottom"],
				o = n.toLowerCase(),
				a = {
					innerWidth: e.fn.innerWidth,
					innerHeight: e.fn.innerHeight,
					outerWidth: e.fn.outerWidth,
					outerHeight: e.fn.outerHeight
				};
			e.fn["inner" + n] = function(t) {
				return void 0 === t ? a["inner" + n].call(this) : this.each(function() {
					e(this).css(o, i(this, t) + "px")
				})
			}, e.fn["outer" + n] = function(t, r) {
				return "number" != typeof t ? a["outer" + n].call(this, t) : this.each(function() {
					e(this).css(o, i(this, t, !0, r) + "px")
				})
			}
		}), e.fn.addBack || (e.fn.addBack = function(e) {
			return this.add(null == e ? this.prevObject : this.prevObject.filter(e))
		}), e("<a>").data("a-b", "a").removeData("a-b").data("a-b") && (e.fn.removeData = function(t) {
			return function(n) {
				return arguments.length ? t.call(this, e.camelCase(n)) : t.call(this)
			}
		}(e.fn.removeData)), e.ui.ie = !!/msie [\w.]+/.exec(navigator.userAgent.toLowerCase()), e.fn.extend({
			focus: function(t) {
				return function(n, i) {
					return "number" == typeof n ? this.each(function() {
						var t = this;
						setTimeout(function() {
							e(t).focus(), i && i.call(t)
						}, n)
					}) : t.apply(this, arguments)
				}
			}(e.fn.focus),
			disableSelection: function() {
				var e = "onselectstart" in document.createElement("div") ? "selectstart" : "mousedown";
				return function() {
					return this.bind(e + ".ui-disableSelection", function(e) {
						e.preventDefault()
					})
				}
			}(),
			enableSelection: function() {
				return this.unbind(".ui-disableSelection")
			},
			zIndex: function(t) {
				if (void 0 !== t) return this.css("zIndex", t);
				if (this.length)
					for (var n, i, r = e(this[0]); r.length && r[0] !== document;) {
						if (n = r.css("position"), ("absolute" === n || "relative" === n || "fixed" === n) && (i = parseInt(r.css("zIndex"), 10), !isNaN(i) && 0 !== i)) return i;
						r = r.parent()
					}
				return 0
			}
		}), e.ui.plugin = {
			add: function(t, n, i) {
				var r, o = e.ui[t].prototype;
				for (r in i) o.plugins[r] = o.plugins[r] || [], o.plugins[r].push([n, i[r]])
			},
			call: function(e, t, n, i) {
				var r, o = e.plugins[t];
				if (o && (i || e.element[0].parentNode && 11 !== e.element[0].parentNode.nodeType))
					for (r = 0; r < o.length; r++) e.options[o[r][0]] && o[r][1].apply(e.element, n)
			}
		}
	}),
	/*!
	 * jQuery UI Widget 1.11.0
	 * http://jqueryui.com
	 *
	 * Copyright 2014 jQuery Foundation and other contributors
	 * Released under the MIT license.
	 * http://jquery.org/license
	 *
	 * http://api.jqueryui.com/jQuery.widget/
	 */
	function(e) {
		"function" == typeof define && define.amd ? define(["jquery"], e) : e(jQuery)
	}(function(e) {
		var t = 0,
			n = Array.prototype.slice;
		return e.cleanData = function(t) {
			return function(n) {
				for (var i, r = 0; null != (i = n[r]); r++) try {
					e(i).triggerHandler("remove")
				} catch (o) {}
				t(n)
			}
		}(e.cleanData), e.widget = function(t, n, i) {
			var r, o, a, s, l = {},
				c = t.split(".")[0];
			return t = t.split(".")[1], r = c + "-" + t, i || (i = n, n = e.Widget), e.expr[":"][r.toLowerCase()] = function(t) {
				return !!e.data(t, r)
			}, e[c] = e[c] || {}, o = e[c][t], a = e[c][t] = function(e, t) {
				return this._createWidget ? void(arguments.length && this._createWidget(e, t)) : new a(e, t)
			}, e.extend(a, o, {
				version: i.version,
				_proto: e.extend({}, i),
				_childConstructors: []
			}), s = new n, s.options = e.widget.extend({}, s.options), e.each(i, function(t, i) {
				return e.isFunction(i) ? void(l[t] = function() {
					var e = function() {
							return n.prototype[t].apply(this, arguments)
						},
						r = function(e) {
							return n.prototype[t].apply(this, e)
						};
					return function() {
						var t, n = this._super,
							o = this._superApply;
						return this._super = e, this._superApply = r, t = i.apply(this, arguments), this._super = n, this._superApply = o, t
					}
				}()) : void(l[t] = i)
			}), a.prototype = e.widget.extend(s, {
				widgetEventPrefix: o ? s.widgetEventPrefix || t : t
			}, l, {
				constructor: a,
				namespace: c,
				widgetName: t,
				widgetFullName: r
			}), o ? (e.each(o._childConstructors, function(t, n) {
				var i = n.prototype;
				e.widget(i.namespace + "." + i.widgetName, a, n._proto)
			}), delete o._childConstructors) : n._childConstructors.push(a), e.widget.bridge(t, a), a
		}, e.widget.extend = function(t) {
			for (var i, r, o = n.call(arguments, 1), a = 0, s = o.length; s > a; a++)
				for (i in o[a]) r = o[a][i], o[a].hasOwnProperty(i) && void 0 !== r && (t[i] = e.isPlainObject(r) ? e.isPlainObject(t[i]) ? e.widget.extend({}, t[i], r) : e.widget.extend({}, r) : r);
			return t
		}, e.widget.bridge = function(t, i) {
			var r = i.prototype.widgetFullName || t;
			e.fn[t] = function(o) {
				var a = "string" == typeof o,
					s = n.call(arguments, 1),
					l = this;
				return o = !a && s.length ? e.widget.extend.apply(null, [o].concat(s)) : o, this.each(a ? function() {
					var n, i = e.data(this, r);
					return "instance" === o ? (l = i, !1) : i ? e.isFunction(i[o]) && "_" !== o.charAt(0) ? (n = i[o].apply(i, s), n !== i && void 0 !== n ? (l = n && n.jquery ? l.pushStack(n.get()) : n, !1) : void 0) : e.error("no such method '" + o + "' for " + t + " widget instance") : e.error("cannot call methods on " + t + " prior to initialization; attempted to call method '" + o + "'")
				} : function() {
					var t = e.data(this, r);
					t ? (t.option(o || {}), t._init && t._init()) : e.data(this, r, new i(o, this))
				}), l
			}
		}, e.Widget = function() {}, e.Widget._childConstructors = [], e.Widget.prototype = {
			widgetName: "widget",
			widgetEventPrefix: "",
			defaultElement: "<div>",
			options: {
				disabled: !1,
				create: null
			},
			_createWidget: function(n, i) {
				i = e(i || this.defaultElement || this)[0], this.element = e(i), this.uuid = t++, this.eventNamespace = "." + this.widgetName + this.uuid, this.options = e.widget.extend({}, this.options, this._getCreateOptions(), n), this.bindings = e(), this.hoverable = e(), this.focusable = e(), i !== this && (e.data(i, this.widgetFullName, this), this._on(!0, this.element, {
					remove: function(e) {
						e.target === i && this.destroy()
					}
				}), this.document = e(i.style ? i.ownerDocument : i.document || i), this.window = e(this.document[0].defaultView || this.document[0].parentWindow)), this._create(), this._trigger("create", null, this._getCreateEventData()), this._init()
			},
			_getCreateOptions: e.noop,
			_getCreateEventData: e.noop,
			_create: e.noop,
			_init: e.noop,
			destroy: function() {
				this._destroy(), this.element.unbind(this.eventNamespace).removeData(this.widgetFullName).removeData(e.camelCase(this.widgetFullName)), this.widget().unbind(this.eventNamespace).removeAttr("aria-disabled").removeClass(this.widgetFullName + "-disabled ui-state-disabled"), this.bindings.unbind(this.eventNamespace), this.hoverable.removeClass("ui-state-hover"), this.focusable.removeClass("ui-state-focus")
			},
			_destroy: e.noop,
			widget: function() {
				return this.element
			},
			option: function(t, n) {
				var i, r, o, a = t;
				if (0 === arguments.length) return e.widget.extend({}, this.options);
				if ("string" == typeof t)
					if (a = {}, i = t.split("."), t = i.shift(), i.length) {
						for (r = a[t] = e.widget.extend({}, this.options[t]), o = 0; o < i.length - 1; o++) r[i[o]] = r[i[o]] || {}, r = r[i[o]];
						if (t = i.pop(), 1 === arguments.length) return void 0 === r[t] ? null : r[t];
						r[t] = n
					} else {
						if (1 === arguments.length) return void 0 === this.options[t] ? null : this.options[t];
						a[t] = n
					}
				return this._setOptions(a), this
			},
			_setOptions: function(e) {
				var t;
				for (t in e) this._setOption(t, e[t]);
				return this
			},
			_setOption: function(e, t) {
				return this.options[e] = t, "disabled" === e && (this.widget().toggleClass(this.widgetFullName + "-disabled", !!t), t && (this.hoverable.removeClass("ui-state-hover"), this.focusable.removeClass("ui-state-focus"))), this
			},
			enable: function() {
				return this._setOptions({
					disabled: !1
				})
			},
			disable: function() {
				return this._setOptions({
					disabled: !0
				})
			},
			_on: function(t, n, i) {
				var r, o = this;
				"boolean" != typeof t && (i = n, n = t, t = !1), i ? (n = r = e(n), this.bindings = this.bindings.add(n)) : (i = n, n = this.element, r = this.widget()), e.each(i, function(i, a) {
					function s() {
						return t || o.options.disabled !== !0 && !e(this).hasClass("ui-state-disabled") ? ("string" == typeof a ? o[a] : a).apply(o, arguments) : void 0
					}
					"string" != typeof a && (s.guid = a.guid = a.guid || s.guid || e.guid++);
					var l = i.match(/^([\w:-]*)\s*(.*)$/),
						c = l[1] + o.eventNamespace,
						u = l[2];
					u ? r.delegate(u, c, s) : n.bind(c, s)
				})
			},
			_off: function(e, t) {
				t = (t || "").split(" ").join(this.eventNamespace + " ") + this.eventNamespace, e.unbind(t).undelegate(t)
			},
			_delay: function(e, t) {
				function n() {
					return ("string" == typeof e ? i[e] : e).apply(i, arguments)
				}
				var i = this;
				return setTimeout(n, t || 0)
			},
			_hoverable: function(t) {
				this.hoverable = this.hoverable.add(t), this._on(t, {
					mouseenter: function(t) {
						e(t.currentTarget).addClass("ui-state-hover")
					},
					mouseleave: function(t) {
						e(t.currentTarget).removeClass("ui-state-hover")
					}
				})
			},
			_focusable: function(t) {
				this.focusable = this.focusable.add(t), this._on(t, {
					focusin: function(t) {
						e(t.currentTarget).addClass("ui-state-focus")
					},
					focusout: function(t) {
						e(t.currentTarget).removeClass("ui-state-focus")
					}
				})
			},
			_trigger: function(t, n, i) {
				var r, o, a = this.options[t];
				if (i = i || {}, n = e.Event(n), n.type = (t === this.widgetEventPrefix ? t : this.widgetEventPrefix + t).toLowerCase(), n.target = this.element[0], o = n.originalEvent)
					for (r in o) r in n || (n[r] = o[r]);
				return this.element.trigger(n, i), !(e.isFunction(a) && a.apply(this.element[0], [n].concat(i)) === !1 || n.isDefaultPrevented())
			}
		}, e.each({
			show: "fadeIn",
			hide: "fadeOut"
		}, function(t, n) {
			e.Widget.prototype["_" + t] = function(i, r, o) {
				"string" == typeof r && (r = {
					effect: r
				});
				var a, s = r ? r === !0 || "number" == typeof r ? n : r.effect || n : t;
				r = r || {}, "number" == typeof r && (r = {
					duration: r
				}), a = !e.isEmptyObject(r), r.complete = o, r.delay && i.delay(r.delay), a && e.effects && e.effects.effect[s] ? i[t](r) : s !== t && i[s] ? i[s](r.duration, r.easing, o) : i.queue(function(n) {
					e(this)[t](), o && o.call(i[0]), n()
				})
			}
		}), e.widget
	}),
	/*!
	 * jQuery UI Position 1.11.0
	 * http://jqueryui.com
	 *
	 * Copyright 2014 jQuery Foundation and other contributors
	 * Released under the MIT license.
	 * http://jquery.org/license
	 *
	 * http://api.jqueryui.com/position/
	 */
	function(e) {
		"function" == typeof define && define.amd ? define(["jquery"], e) : e(jQuery)
	}(function(e) {
		return function() {
			function t(e, t, n) {
				return [parseFloat(e[0]) * (p.test(e[0]) ? t / 100 : 1), parseFloat(e[1]) * (p.test(e[1]) ? n / 100 : 1)]
			}

			function n(t, n) {
				return parseInt(e.css(t, n), 10) || 0
			}

			function i(t) {
				var n = t[0];
				return 9 === n.nodeType ? {
					width: t.width(),
					height: t.height(),
					offset: {
						top: 0,
						left: 0
					}
				} : e.isWindow(n) ? {
					width: t.width(),
					height: t.height(),
					offset: {
						top: t.scrollTop(),
						left: t.scrollLeft()
					}
				} : n.preventDefault ? {
					width: 0,
					height: 0,
					offset: {
						top: n.pageY,
						left: n.pageX
					}
				} : {
					width: t.outerWidth(),
					height: t.outerHeight(),
					offset: t.offset()
				}
			}
			e.ui = e.ui || {};
			var r, o, a = Math.max,
				s = Math.abs,
				l = Math.round,
				c = /left|center|right/,
				u = /top|center|bottom/,
				d = /[\+\-]\d+(\.[\d]+)?%?/,
				h = /^\w+/,
				p = /%$/,
				f = e.fn.position;
			e.position = {
				scrollbarWidth: function() {
					if (void 0 !== r) return r;
					var t, n, i = e("<div style='display:block;position:absolute;width:50px;height:50px;overflow:hidden;'><div style='height:100px;width:auto;'></div></div>"),
						o = i.children()[0];
					return e("body").append(i), t = o.offsetWidth, i.css("overflow", "scroll"), n = o.offsetWidth, t === n && (n = i[0].clientWidth), i.remove(), r = t - n
				},
				getScrollInfo: function(t) {
					var n = t.isWindow || t.isDocument ? "" : t.element.css("overflow-x"),
						i = t.isWindow || t.isDocument ? "" : t.element.css("overflow-y"),
						r = "scroll" === n || "auto" === n && t.width < t.element[0].scrollWidth,
						o = "scroll" === i || "auto" === i && t.height < t.element[0].scrollHeight;
					return {
						width: o ? e.position.scrollbarWidth() : 0,
						height: r ? e.position.scrollbarWidth() : 0
					}
				},
				getWithinInfo: function(t) {
					var n = e(t || window),
						i = e.isWindow(n[0]),
						r = !!n[0] && 9 === n[0].nodeType;
					return {
						element: n,
						isWindow: i,
						isDocument: r,
						offset: n.offset() || {
							left: 0,
							top: 0
						},
						scrollLeft: n.scrollLeft(),
						scrollTop: n.scrollTop(),
						width: i ? n.width() : n.outerWidth(),
						height: i ? n.height() : n.outerHeight()
					}
				}
			}, e.fn.position = function(r) {
				if (!r || !r.of) return f.apply(this, arguments);
				r = e.extend({}, r);
				var p, g, m, v, _, b, y = e(r.of),
					w = e.position.getWithinInfo(r.within),
					x = e.position.getScrollInfo(w),
					E = (r.collision || "flip").split(" "),
					k = {};
				return b = i(y), y[0].preventDefault && (r.at = "left top"), g = b.width, m = b.height, v = b.offset, _ = e.extend({}, v), e.each(["my", "at"], function() {
					var e, t, n = (r[this] || "").split(" ");
					1 === n.length && (n = c.test(n[0]) ? n.concat(["center"]) : u.test(n[0]) ? ["center"].concat(n) : ["center", "center"]), n[0] = c.test(n[0]) ? n[0] : "center", n[1] = u.test(n[1]) ? n[1] : "center", e = d.exec(n[0]), t = d.exec(n[1]), k[this] = [e ? e[0] : 0, t ? t[0] : 0], r[this] = [h.exec(n[0])[0], h.exec(n[1])[0]]
				}), 1 === E.length && (E[1] = E[0]), "right" === r.at[0] ? _.left += g : "center" === r.at[0] && (_.left += g / 2), "bottom" === r.at[1] ? _.top += m : "center" === r.at[1] && (_.top += m / 2), p = t(k.at, g, m), _.left += p[0], _.top += p[1], this.each(function() {
					var i, c, u = e(this),
						d = u.outerWidth(),
						h = u.outerHeight(),
						f = n(this, "marginLeft"),
						b = n(this, "marginTop"),
						C = d + f + n(this, "marginRight") + x.width,
						T = h + b + n(this, "marginBottom") + x.height,
						S = e.extend({}, _),
						O = t(k.my, u.outerWidth(), u.outerHeight());
					"right" === r.my[0] ? S.left -= d : "center" === r.my[0] && (S.left -= d / 2), "bottom" === r.my[1] ? S.top -= h : "center" === r.my[1] && (S.top -= h / 2), S.left += O[0], S.top += O[1], o || (S.left = l(S.left), S.top = l(S.top)), i = {
						marginLeft: f,
						marginTop: b
					}, e.each(["left", "top"], function(t, n) {
						e.ui.position[E[t]] && e.ui.position[E[t]][n](S, {
							targetWidth: g,
							targetHeight: m,
							elemWidth: d,
							elemHeight: h,
							collisionPosition: i,
							collisionWidth: C,
							collisionHeight: T,
							offset: [p[0] + O[0], p[1] + O[1]],
							my: r.my,
							at: r.at,
							within: w,
							elem: u
						})
					}), r.using && (c = function(e) {
						var t = v.left - S.left,
							n = t + g - d,
							i = v.top - S.top,
							o = i + m - h,
							l = {
								target: {
									element: y,
									left: v.left,
									top: v.top,
									width: g,
									height: m
								},
								element: {
									element: u,
									left: S.left,
									top: S.top,
									width: d,
									height: h
								},
								horizontal: 0 > n ? "left" : t > 0 ? "right" : "center",
								vertical: 0 > o ? "top" : i > 0 ? "bottom" : "middle"
							};
						d > g && s(t + n) < g && (l.horizontal = "center"), h > m && s(i + o) < m && (l.vertical = "middle"), l.important = a(s(t), s(n)) > a(s(i), s(o)) ? "horizontal" : "vertical", r.using.call(this, e, l)
					}), u.offset(e.extend(S, {
						using: c
					}))
				})
			}, e.ui.position = {
				fit: {
					left: function(e, t) {
						var n, i = t.within,
							r = i.isWindow ? i.scrollLeft : i.offset.left,
							o = i.width,
							s = e.left - t.collisionPosition.marginLeft,
							l = r - s,
							c = s + t.collisionWidth - o - r;
						t.collisionWidth > o ? l > 0 && 0 >= c ? (n = e.left + l + t.collisionWidth - o - r, e.left += l - n) : e.left = c > 0 && 0 >= l ? r : l > c ? r + o - t.collisionWidth : r : l > 0 ? e.left += l : c > 0 ? e.left -= c : e.left = a(e.left - s, e.left)
					},
					top: function(e, t) {
						var n, i = t.within,
							r = i.isWindow ? i.scrollTop : i.offset.top,
							o = t.within.height,
							s = e.top - t.collisionPosition.marginTop,
							l = r - s,
							c = s + t.collisionHeight - o - r;
						t.collisionHeight > o ? l > 0 && 0 >= c ? (n = e.top + l + t.collisionHeight - o - r, e.top += l - n) : e.top = c > 0 && 0 >= l ? r : l > c ? r + o - t.collisionHeight : r : l > 0 ? e.top += l : c > 0 ? e.top -= c : e.top = a(e.top - s, e.top)
					}
				},
				flip: {
					left: function(e, t) {
						var n, i, r = t.within,
							o = r.offset.left + r.scrollLeft,
							a = r.width,
							l = r.isWindow ? r.scrollLeft : r.offset.left,
							c = e.left - t.collisionPosition.marginLeft,
							u = c - l,
							d = c + t.collisionWidth - a - l,
							h = "left" === t.my[0] ? -t.elemWidth : "right" === t.my[0] ? t.elemWidth : 0,
							p = "left" === t.at[0] ? t.targetWidth : "right" === t.at[0] ? -t.targetWidth : 0,
							f = -2 * t.offset[0];
						0 > u ? (n = e.left + h + p + f + t.collisionWidth - a - o, (0 > n || n < s(u)) && (e.left += h + p + f)) : d > 0 && (i = e.left - t.collisionPosition.marginLeft + h + p + f - l, (i > 0 || s(i) < d) && (e.left += h + p + f))
					},
					top: function(e, t) {
						var n, i, r = t.within,
							o = r.offset.top + r.scrollTop,
							a = r.height,
							l = r.isWindow ? r.scrollTop : r.offset.top,
							c = e.top - t.collisionPosition.marginTop,
							u = c - l,
							d = c + t.collisionHeight - a - l,
							h = "top" === t.my[1],
							p = h ? -t.elemHeight : "bottom" === t.my[1] ? t.elemHeight : 0,
							f = "top" === t.at[1] ? t.targetHeight : "bottom" === t.at[1] ? -t.targetHeight : 0,
							g = -2 * t.offset[1];
						0 > u ? (i = e.top + p + f + g + t.collisionHeight - a - o, e.top + p + f + g > u && (0 > i || i < s(u)) && (e.top += p + f + g)) : d > 0 && (n = e.top - t.collisionPosition.marginTop + p + f + g - l, e.top + p + f + g > d && (n > 0 || s(n) < d) && (e.top += p + f + g))
					}
				},
				flipfit: {
					left: function() {
						e.ui.position.flip.left.apply(this, arguments), e.ui.position.fit.left.apply(this, arguments)
					},
					top: function() {
						e.ui.position.flip.top.apply(this, arguments), e.ui.position.fit.top.apply(this, arguments)
					}
				}
			},
				function() {
					var t, n, i, r, a, s = document.getElementsByTagName("body")[0],
						l = document.createElement("div");
					t = document.createElement(s ? "div" : "body"), i = {
						visibility: "hidden",
						width: 0,
						height: 0,
						border: 0,
						margin: 0,
						background: "none"
					}, s && e.extend(i, {
						position: "absolute",
						left: "-1000px",
						top: "-1000px"
					});
					for (a in i) t.style[a] = i[a];
					t.appendChild(l), n = s || document.documentElement, n.insertBefore(t, n.firstChild), l.style.cssText = "position: absolute; left: 10.7432222px;", r = e(l).offset().left, o = r > 10 && 11 > r, t.innerHTML = "", n.removeChild(t)
				}()
		}(), e.ui.position
	}),
	/*!
	 * jQuery UI Menu 1.11.0
	 * http://jqueryui.com
	 *
	 * Copyright 2014 jQuery Foundation and other contributors
	 * Released under the MIT license.
	 * http://jquery.org/license
	 *
	 * http://api.jqueryui.com/menu/
	 */
	function(e) {
		"function" == typeof define && define.amd ? define(["jquery", "./core", "./widget", "./position"], e) : e(jQuery)
	}(function(e) {
		return e.widget("ui.menu", {
			version: "1.11.0",
			defaultElement: "<ul>",
			delay: 300,
			options: {
				icons: {
					submenu: "ui-icon-carat-1-e"
				},
				items: "> *",
				menus: "ul",
				position: {
					my: "left-1 top",
					at: "right top"
				},
				role: "menu",
				blur: null,
				focus: null,
				select: null
			},
			_create: function() {
				this.activeMenu = this.element, this.mouseHandled = !1, this.element.uniqueId().addClass("ui-menu ui-widget ui-widget-content").toggleClass("ui-menu-icons", !!this.element.find(".ui-icon").length).attr({
					role: this.options.role,
					tabIndex: 0
				}), this.options.disabled && this.element.addClass("ui-state-disabled").attr("aria-disabled", "true"), this._on({
					"mousedown .ui-menu-item": function(e) {
						e.preventDefault()
					},
					"click .ui-menu-item": function(t) {
						var n = e(t.target);
						!this.mouseHandled && n.not(".ui-state-disabled").length && (this.select(t), t.isPropagationStopped() || (this.mouseHandled = !0), n.has(".ui-menu").length ? this.expand(t) : !this.element.is(":focus") && e(this.document[0].activeElement).closest(".ui-menu").length && (this.element.trigger("focus", [!0]), this.active && 1 === this.active.parents(".ui-menu").length && clearTimeout(this.timer)))
					},
					"mouseenter .ui-menu-item": function(t) {
						var n = e(t.currentTarget);
						n.siblings(".ui-state-active").removeClass("ui-state-active"), this.focus(t, n)
					},
					mouseleave: "collapseAll",
					"mouseleave .ui-menu": "collapseAll",
					focus: function(e, t) {
						var n = this.active || this.element.find(this.options.items).eq(0);
						t || this.focus(e, n)
					},
					blur: function(t) {
						this._delay(function() {
							e.contains(this.element[0], this.document[0].activeElement) || this.collapseAll(t)
						})
					},
					keydown: "_keydown"
				}), this.refresh(), this._on(this.document, {
					click: function(e) {
						this._closeOnDocumentClick(e) && this.collapseAll(e), this.mouseHandled = !1
					}
				})
			},
			_destroy: function() {
				this.element.removeAttr("aria-activedescendant").find(".ui-menu").addBack().removeClass("ui-menu ui-widget ui-widget-content ui-menu-icons ui-front").removeAttr("role").removeAttr("tabIndex").removeAttr("aria-labelledby").removeAttr("aria-expanded").removeAttr("aria-hidden").removeAttr("aria-disabled").removeUniqueId().show(), this.element.find(".ui-menu-item").removeClass("ui-menu-item").removeAttr("role").removeAttr("aria-disabled").removeUniqueId().removeClass("ui-state-hover").removeAttr("tabIndex").removeAttr("role").removeAttr("aria-haspopup").children().each(function() {
					var t = e(this);
					t.data("ui-menu-submenu-carat") && t.remove()
				}), this.element.find(".ui-menu-divider").removeClass("ui-menu-divider ui-widget-content")
			},
			_keydown: function(t) {
				function n(e) {
					return e.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
				}
				var i, r, o, a, s, l = !0;
				switch (t.keyCode) {
					case e.ui.keyCode.PAGE_UP:
						this.previousPage(t);
						break;
					case e.ui.keyCode.PAGE_DOWN:
						this.nextPage(t);
						break;
					case e.ui.keyCode.HOME:
						this._move("first", "first", t);
						break;
					case e.ui.keyCode.END:
						this._move("last", "last", t);
						break;
					case e.ui.keyCode.UP:
						this.previous(t);
						break;
					case e.ui.keyCode.DOWN:
						this.next(t);
						break;
					case e.ui.keyCode.LEFT:
						this.collapse(t);
						break;
					case e.ui.keyCode.RIGHT:
						this.active && !this.active.is(".ui-state-disabled") && this.expand(t);
						break;
					case e.ui.keyCode.ENTER:
					case e.ui.keyCode.SPACE:
						this._activate(t);
						break;
					case e.ui.keyCode.ESCAPE:
						this.collapse(t);
						break;
					default:
						l = !1, r = this.previousFilter || "", o = String.fromCharCode(t.keyCode), a = !1, clearTimeout(this.filterTimer), o === r ? a = !0 : o = r + o, s = new RegExp("^" + n(o), "i"), i = this.activeMenu.find(this.options.items).filter(function() {
							return s.test(e(this).text())
						}), i = a && -1 !== i.index(this.active.next()) ? this.active.nextAll(".ui-menu-item") : i, i.length || (o = String.fromCharCode(t.keyCode), s = new RegExp("^" + n(o), "i"), i = this.activeMenu.find(this.options.items).filter(function() {
							return s.test(e(this).text())
						})), i.length ? (this.focus(t, i), i.length > 1 ? (this.previousFilter = o, this.filterTimer = this._delay(function() {
							delete this.previousFilter
						}, 1e3)) : delete this.previousFilter) : delete this.previousFilter
				}
				l && t.preventDefault()
			},
			_activate: function(e) {
				this.active.is(".ui-state-disabled") || (this.active.is("[aria-haspopup='true']") ? this.expand(e) : this.select(e))
			},
			refresh: function() {
				var t, n, i = this,
					r = this.options.icons.submenu,
					o = this.element.find(this.options.menus);
				this.element.toggleClass("ui-menu-icons", !!this.element.find(".ui-icon").length), o.filter(":not(.ui-menu)").addClass("ui-menu ui-widget ui-widget-content ui-front").hide().attr({
					role: this.options.role,
					"aria-hidden": "true",
					"aria-expanded": "false"
				}).each(function() {
					var t = e(this),
						n = t.parent(),
						i = e("<span>").addClass("ui-menu-icon ui-icon " + r).data("ui-menu-submenu-carat", !0);
					n.attr("aria-haspopup", "true").prepend(i), t.attr("aria-labelledby", n.attr("id"))
				}), t = o.add(this.element), n = t.find(this.options.items), n.not(".ui-menu-item").each(function() {
					var t = e(this);
					i._isDivider(t) && t.addClass("ui-widget-content ui-menu-divider")
				}), n.not(".ui-menu-item, .ui-menu-divider").addClass("ui-menu-item").uniqueId().attr({
					tabIndex: -1,
					role: this._itemRole()
				}), n.filter(".ui-state-disabled").attr("aria-disabled", "true"), this.active && !e.contains(this.element[0], this.active[0]) && this.blur()
			},
			_itemRole: function() {
				return {
					menu: "menuitem",
					listbox: "option"
				}[this.options.role]
			},
			_setOption: function(e, t) {
				"icons" === e && this.element.find(".ui-menu-icon").removeClass(this.options.icons.submenu).addClass(t.submenu), "disabled" === e && this.element.toggleClass("ui-state-disabled", !!t).attr("aria-disabled", t), this._super(e, t)
			},
			focus: function(e, t) {
				var n, i;
				this.blur(e, e && "focus" === e.type), this._scrollIntoView(t), this.active = t.first(), i = this.active.addClass("ui-state-focus").removeClass("ui-state-active"), this.options.role && this.element.attr("aria-activedescendant", i.attr("id")), this.active.parent().closest(".ui-menu-item").addClass("ui-state-active"), e && "keydown" === e.type ? this._close() : this.timer = this._delay(function() {
					this._close()
				}, this.delay), n = t.children(".ui-menu"), n.length && e && /^mouse/.test(e.type) && this._startOpening(n), this.activeMenu = t.parent(), this._trigger("focus", e, {
					item: t
				})
			},
			_scrollIntoView: function(t) {
				var n, i, r, o, a, s;
				this._hasScroll() && (n = parseFloat(e.css(this.activeMenu[0], "borderTopWidth")) || 0, i = parseFloat(e.css(this.activeMenu[0], "paddingTop")) || 0, r = t.offset().top - this.activeMenu.offset().top - n - i, o = this.activeMenu.scrollTop(), a = this.activeMenu.height(), s = t.outerHeight(), 0 > r ? this.activeMenu.scrollTop(o + r) : r + s > a && this.activeMenu.scrollTop(o + r - a + s))
			},
			blur: function(e, t) {
				t || clearTimeout(this.timer), this.active && (this.active.removeClass("ui-state-focus"), this.active = null, this._trigger("blur", e, {
					item: this.active
				}))
			},
			_startOpening: function(e) {
				clearTimeout(this.timer), "true" === e.attr("aria-hidden") && (this.timer = this._delay(function() {
					this._close(), this._open(e)
				}, this.delay))
			},
			_open: function(t) {
				var n = e.extend({
					of: this.active
				}, this.options.position);
				clearTimeout(this.timer), this.element.find(".ui-menu").not(t.parents(".ui-menu")).hide().attr("aria-hidden", "true"), t.show().removeAttr("aria-hidden").attr("aria-expanded", "true").position(n)
			},
			collapseAll: function(t, n) {
				clearTimeout(this.timer), this.timer = this._delay(function() {
					var i = n ? this.element : e(t && t.target).closest(this.element.find(".ui-menu"));
					i.length || (i = this.element), this._close(i), this.blur(t), this.activeMenu = i
				}, this.delay)
			},
			_close: function(e) {
				e || (e = this.active ? this.active.parent() : this.element), e.find(".ui-menu").hide().attr("aria-hidden", "true").attr("aria-expanded", "false").end().find(".ui-state-active").not(".ui-state-focus").removeClass("ui-state-active")
			},
			_closeOnDocumentClick: function(t) {
				return !e(t.target).closest(".ui-menu").length
			},
			_isDivider: function(e) {
				return !/[^\-\u2014\u2013\s]/.test(e.text())
			},
			collapse: function(e) {
				var t = this.active && this.active.parent().closest(".ui-menu-item", this.element);
				t && t.length && (this._close(), this.focus(e, t))
			},
			expand: function(e) {
				var t = this.active && this.active.children(".ui-menu ").find(this.options.items).first();
				t && t.length && (this._open(t.parent()), this._delay(function() {
					this.focus(e, t)
				}))
			},
			next: function(e) {
				this._move("next", "first", e)
			},
			previous: function(e) {
				this._move("prev", "last", e)
			},
			isFirstItem: function() {
				return this.active && !this.active.prevAll(".ui-menu-item").length
			},
			isLastItem: function() {
				return this.active && !this.active.nextAll(".ui-menu-item").length
			},
			_move: function(e, t, n) {
				var i;
				this.active && (i = "first" === e || "last" === e ? this.active["first" === e ? "prevAll" : "nextAll"](".ui-menu-item").eq(-1) : this.active[e + "All"](".ui-menu-item").eq(0)), i && i.length && this.active || (i = this.activeMenu.find(this.options.items)[t]()), this.focus(n, i)
			},
			nextPage: function(t) {
				var n, i, r;
				return this.active ? void(this.isLastItem() || (this._hasScroll() ? (i = this.active.offset().top, r = this.element.height(), this.active.nextAll(".ui-menu-item").each(function() {
					return n = e(this), n.offset().top - i - r < 0
				}), this.focus(t, n)) : this.focus(t, this.activeMenu.find(this.options.items)[this.active ? "last" : "first"]()))) : void this.next(t)
			},
			previousPage: function(t) {
				var n, i, r;
				return this.active ? void(this.isFirstItem() || (this._hasScroll() ? (i = this.active.offset().top, r = this.element.height(), this.active.prevAll(".ui-menu-item").each(function() {
					return n = e(this), n.offset().top - i + r > 0
				}), this.focus(t, n)) : this.focus(t, this.activeMenu.find(this.options.items).first()))) : void this.next(t)
			},
			_hasScroll: function() {
				return this.element.outerHeight() < this.element.prop("scrollHeight")
			},
			select: function(t) {
				this.active = this.active || e(t.target).closest(".ui-menu-item");
				var n = {
					item: this.active
				};
				this.active.has(".ui-menu").length || this.collapseAll(t, !0), this._trigger("select", t, n)
			}
		})
	}),
	/*!
	 * jQuery UI Autocomplete 1.11.0
	 * http://jqueryui.com
	 *
	 * Copyright 2014 jQuery Foundation and other contributors
	 * Released under the MIT license.
	 * http://jquery.org/license
	 *
	 * http://api.jqueryui.com/autocomplete/
	 */
	function(e) {
		"function" == typeof define && define.amd ? define(["jquery", "./core", "./widget", "./position", "./menu"], e) : e(jQuery)
	}(function(e) {
		return e.widget("ui.autocomplete", {
			version: "1.11.0",
			defaultElement: "<input>",
			options: {
				appendTo: null,
				autoFocus: !1,
				delay: 300,
				minLength: 1,
				position: {
					my: "left top",
					at: "left bottom",
					collision: "none"
				},
				source: null,
				change: null,
				close: null,
				focus: null,
				open: null,
				response: null,
				search: null,
				select: null
			},
			requestIndex: 0,
			pending: 0,
			_create: function() {
				var t, n, i, r = this.element[0].nodeName.toLowerCase(),
					o = "textarea" === r,
					a = "input" === r;
				this.isMultiLine = o ? !0 : a ? !1 : this.element.prop("isContentEditable"), this.valueMethod = this.element[o || a ? "val" : "text"], this.isNewMenu = !0, this.element.addClass("ui-autocomplete-input").attr("autocomplete", "off"), this._on(this.element, {
					keydown: function(r) {
						if (this.element.prop("readOnly")) return t = !0, i = !0, void(n = !0);
						t = !1, i = !1, n = !1;
						var o = e.ui.keyCode;
						switch (r.keyCode) {
							case o.PAGE_UP:
								t = !0, this._move("previousPage", r);
								break;
							case o.PAGE_DOWN:
								t = !0, this._move("nextPage", r);
								break;
							case o.UP:
								t = !0, this._keyEvent("previous", r);
								break;
							case o.DOWN:
								t = !0, this._keyEvent("next", r);
								break;
							case o.ENTER:
								this.menu.active && (t = !0, r.preventDefault(), this.menu.select(r));
								break;
							case o.TAB:
								this.menu.active && this.menu.select(r);
								break;
							case o.ESCAPE:
								this.menu.element.is(":visible") && (this._value(this.term), this.close(r), r.preventDefault());
								break;
							default:
								n = !0, this._searchTimeout(r)
						}
					},
					keypress: function(i) {
						if (t) return t = !1, void((!this.isMultiLine || this.menu.element.is(":visible")) && i.preventDefault());
						if (!n) {
							var r = e.ui.keyCode;
							switch (i.keyCode) {
								case r.PAGE_UP:
									this._move("previousPage", i);
									break;
								case r.PAGE_DOWN:
									this._move("nextPage", i);
									break;
								case r.UP:
									this._keyEvent("previous", i);
									break;
								case r.DOWN:
									this._keyEvent("next", i)
							}
						}
					},
					input: function(e) {
						return i ? (i = !1, void e.preventDefault()) : void this._searchTimeout(e)
					},
					focus: function() {
						this.selectedItem = null, this.previous = this._value()
					},
					blur: function(e) {
						return this.cancelBlur ? void delete this.cancelBlur : (clearTimeout(this.searching), this.close(e), void this._change(e))
					}
				}), this._initSource(), this.menu = e("<ul>").addClass("ui-autocomplete ui-front").appendTo(this._appendTo()).menu({
					role: null
				}).hide().menu("instance"), this._on(this.menu.element, {
					mousedown: function(t) {
						t.preventDefault(), this.cancelBlur = !0, this._delay(function() {
							delete this.cancelBlur
						});
						var n = this.menu.element[0];
						e(t.target).closest(".ui-menu-item").length || this._delay(function() {
							var t = this;
							this.document.one("mousedown", function(i) {
								i.target === t.element[0] || i.target === n || e.contains(n, i.target) || t.close()
							})
						})
					},
					menufocus: function(t, n) {
						var i, r;
						return this.isNewMenu && (this.isNewMenu = !1, t.originalEvent && /^mouse/.test(t.originalEvent.type)) ? (this.menu.blur(), void this.document.one("mousemove", function() {
							e(t.target).trigger(t.originalEvent)
						})) : (r = n.item.data("ui-autocomplete-item"), !1 !== this._trigger("focus", t, {
							item: r
						}) && t.originalEvent && /^key/.test(t.originalEvent.type) && this._value(r.value), i = n.item.attr("aria-label") || r.value, void(i && jQuery.trim(i).length && (this.liveRegion.children().hide(), e("<div>").text(i).appendTo(this.liveRegion))))
					},
					menuselect: function(e, t) {
						var n = t.item.data("ui-autocomplete-item"),
							i = this.previous;
						this.element[0] !== this.document[0].activeElement && (this.element.focus(), this.previous = i, this._delay(function() {
							this.previous = i, this.selectedItem = n
						})), !1 !== this._trigger("select", e, {
							item: n
						}) && this._value(n.value), this.term = this._value(), this.close(e), this.selectedItem = n
					}
				}), this.liveRegion = e("<span>", {
					role: "status",
					"aria-live": "assertive",
					"aria-relevant": "additions"
				}).addClass("ui-helper-hidden-accessible").appendTo(this.document[0].body), this._on(this.window, {
					beforeunload: function() {
						this.element.removeAttr("autocomplete")
					}
				})
			},
			_destroy: function() {
				clearTimeout(this.searching), this.element.removeClass("ui-autocomplete-input").removeAttr("autocomplete"), this.menu.element.remove(), this.liveRegion.remove()
			},
			_setOption: function(e, t) {
				this._super(e, t), "source" === e && this._initSource(), "appendTo" === e && this.menu.element.appendTo(this._appendTo()), "disabled" === e && t && this.xhr && this.xhr.abort()
			},
			_appendTo: function() {
				var t = this.options.appendTo;
				return t && (t = t.jquery || t.nodeType ? e(t) : this.document.find(t).eq(0)), t && t[0] || (t = this.element.closest(".ui-front")), t.length || (t = this.document[0].body), t
			},
			_initSource: function() {
				var t, n, i = this;
				e.isArray(this.options.source) ? (t = this.options.source, this.source = function(n, i) {
					i(e.ui.autocomplete.filter(t, n.term))
				}) : "string" == typeof this.options.source ? (n = this.options.source, this.source = function(t, r) {
					i.xhr && i.xhr.abort(), i.xhr = e.ajax({
						url: n,
						data: t,
						dataType: "json",
						success: function(e) {
							r(e)
						},
						error: function() {
							r([])
						}
					})
				}) : this.source = this.options.source
			},
			_searchTimeout: function(e) {
				clearTimeout(this.searching), this.searching = this._delay(function() {
					var t = this.term === this._value(),
						n = this.menu.element.is(":visible"),
						i = e.altKey || e.ctrlKey || e.metaKey || e.shiftKey;
					(!t || t && !n && !i) && (this.selectedItem = null, this.search(null, e))
				}, this.options.delay)
			},
			search: function(e, t) {
				return e = null != e ? e : this._value(), this.term = this._value(), e.length < this.options.minLength ? this.close(t) : this._trigger("search", t) !== !1 ? this._search(e) : void 0
			},
			_search: function(e) {
				this.pending++, this.element.addClass("ui-autocomplete-loading"), this.cancelSearch = !1, this.source({
					term: e
				}, this._response())
			},
			_response: function() {
				var t = ++this.requestIndex;
				return e.proxy(function(e) {
					t === this.requestIndex && this.__response(e), this.pending--, this.pending || this.element.removeClass("ui-autocomplete-loading")
				}, this)
			},
			__response: function(e) {
				e && (e = this._normalize(e)), this._trigger("response", null, {
					content: e
				}), !this.options.disabled && e && e.length && !this.cancelSearch ? (this._suggest(e), this._trigger("open")) : this._close()
			},
			close: function(e) {
				this.cancelSearch = !0, this._close(e)
			},
			_close: function(e) {
				this.menu.element.is(":visible") && (this.menu.element.hide(), this.menu.blur(), this.isNewMenu = !0, this._trigger("close", e))
			},
			_change: function(e) {
				this.previous !== this._value() && this._trigger("change", e, {
					item: this.selectedItem
				})
			},
			_normalize: function(t) {
				return t.length && t[0].label && t[0].value ? t : e.map(t, function(t) {
					return "string" == typeof t ? {
						label: t,
						value: t
					} : e.extend({}, t, {
						label: t.label || t.value,
						value: t.value || t.label
					})
				})
			},
			_suggest: function(t) {
				var n = this.menu.element.empty();
				this._renderMenu(n, t), this.isNewMenu = !0, this.menu.refresh(), n.show(), this._resizeMenu(), n.position(e.extend({
					of: this.element
				}, this.options.position)), this.options.autoFocus && this.menu.next()
			},
			_resizeMenu: function() {
				var e = this.menu.element;
				e.outerWidth(Math.max(e.width("").outerWidth() + 1, this.element.outerWidth()))
			},
			_renderMenu: function(t, n) {
				var i = this;
				e.each(n, function(e, n) {
					i._renderItemData(t, n)
				})
			},
			_renderItemData: function(e, t) {
				return this._renderItem(e, t).data("ui-autocomplete-item", t)
			},
			_renderItem: function(t, n) {
				return e("<li>").text(n.label).appendTo(t)
			},
			_move: function(e, t) {
				return this.menu.element.is(":visible") ? this.menu.isFirstItem() && /^previous/.test(e) || this.menu.isLastItem() && /^next/.test(e) ? (this.isMultiLine || this._value(this.term), void this.menu.blur()) : void this.menu[e](t) : void this.search(null, t)
			},
			widget: function() {
				return this.menu.element
			},
			_value: function() {
				return this.valueMethod.apply(this.element, arguments)
			},
			_keyEvent: function(e, t) {
				(!this.isMultiLine || this.menu.element.is(":visible")) && (this._move(e, t), t.preventDefault())
			}
		}), e.extend(e.ui.autocomplete, {
			escapeRegex: function(e) {
				return e.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
			},
			filter: function(t, n) {
				var i = new RegExp(e.ui.autocomplete.escapeRegex(n), "i");
				return e.grep(t, function(e) {
					return i.test(e.label || e.value || e)
				})
			}
		}), e.widget("ui.autocomplete", e.ui.autocomplete, {
			options: {
				messages: {
					noResults: "No search results.",
					results: function(e) {
						return e + (e > 1 ? " results are" : " result is") + " available, use up and down arrow keys to navigate."
					}
				}
			},
			__response: function(t) {
				var n;
				this._superApply(arguments), this.options.disabled || this.cancelSearch || (n = t && t.length ? this.options.messages.results(t.length) : this.options.messages.noResults, this.liveRegion.children().hide(), e("<div>").text(n).appendTo(this.liveRegion))
			}
		}), e.ui.autocomplete
	}), window.pss || (window.pss = {}), window.pss.createHtmlTag = function(e, t, n) {
	"use strict";
	var i = "<",
		r = [e];
	for (var o in t)
		if (t.hasOwnProperty(o)) {
			var a = t[o];
			a && "string" == typeof a && (a = a.replace(/'/g, "&apos;")), r.push(o + "='" + a + "'")
		}
	return i += r.join(" "), i += n ? ">" + n + "</" + e + ">" : "/>"
}, window.pss.createHtmlSelectTag = function(e, t, n) {
	"use strict";
	for (var i = "", r = 0; r < t.length; r++) {
		var o = {
			value: t[r].value
		};
		(t[r].value === n || t[r].text === n || "" !== n && t[r].value === parseInt(n, 10)) && (o.selected = "selected");
		var a = t[r].text;
		t[r].i18n && (o["data-i18n"] = t[r].i18n, a = window.helpers.getI18nValue(t[r].i18n)), i += window.pss.createHtmlTag("option", o, a)
	}
	return window.pss.createHtmlTag("select", e, i)
}, //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
	window.escFxn = null, window.dlgThis = null, window.enterFxn = null;
var initializeSelectCtrl = function(e, t, n) {
		var i = new YAHOO.widget.Button(e, {
				type: "menu",
				menu: e + "select",
				selectedMenuItem: new YAHOO.widget.MenuItem(t)
			}),
			r = function(e) {
				var t = e.newValue,
					r = t.cfg.getProperty("text");
				this.set("label", '<span class="yui-button-label">' + r + "</span>"), i.currSelectedValue = t.value, n(t.value)
			};
		return i.setSelection = function(e) {
			i.currSelectedValue = e, i.get("selectedMenuItem").value = e
		}, i.on("selectedMenuItemChange", r), i.currSelectedValue = t, i
	},
	GeneralDialog = Class.create({
		initialize: function(e) {
			this.class_type = "GeneralDialog";
			var t = this,
				n = e.this_id,
				i = e.pages,
				r = e.focus,
				o = e.flash_notice;
			void 0 === o && (o = "");
			var a = e.body_style ? e.body_style : "",
				s = e.row_style,
				l = e.title,
				c = e.width,
				u = n + "_flash",
				d = [],
				h = [],
				p = null,
				f = {},
				g = {},
				m = [],
				v = Class.create({
					initialize: function(e) {
						var t = e.fn_call,
							n = e.call_params;
						this.execute = function() {
							t(n)
						}
					}
				}),
				_ = function(e) {
					var t = $$("meta[name=csrf-param]")[0].content,
						n = $$("meta[name=csrf-token]")[0].content;
					e.appendChild(new Element("input", {
						id: t,
						type: "hidden",
						name: t,
						value: n
					}))
				},
				b = function(e, t) {
					var n = $(this),
						i = n.value,
						r = GeneralDialog.makeId(t.id),
						o = $(r);
					o.value = i, t.callback && t.callback(r, i, t.arg0)
				},
				y = function(e, t, n, i, r, o) {
					var a = new Element("input", {
						id: GeneralDialog.makeId(e),
						name: e
					});
					if (t && t.length > 0) {
						var s = void 0 !== n && null !== n ? n : t[0].value;
						a.writeAttribute("value", s)
					}
					a.addClassName("hidden"), o.appendChild(a);
					var l = null,
						c = function(t, n, o) {
							var s = o.cfg.getProperty("text");
							l.set("label", s), a.writeAttribute("value", o.value), i && i(e, o.value, r)
						},
						u = [],
						d = "";
					if (t)
						for (var h = 0; h < t.length; h++) u.push({
							text: t[h].text,
							value: t[h].value,
							onclick: {
								fn: c
							}
						}), t[h].value === n && (d = t[h].text);
					return l = new YAHOO.widget.Button({
						type: "menu",
						label: d,
						name: e,
						menu: u,
						container: o,
						lazyloadmenu: !1
					})
				},
				w = "gd_modal_dlg_parent",
				x = $(w);
			if (null === x) {
				var E = document.getElementsByTagName("body").item(0);
				$(E).down("div").insert({
					before: new Element("div", {
						id: w,
						style: "text-align:left;"
					})
				})
			}
			this.getOuterDomElement = function() {
				return $(n)
			}, this.getEditor = function(e) {
				return d[e]
			}, this.getAllData = function() {
				var e = $$("#" + n + " input"),
					t = $$("meta[name=csrf-param]")[0].content,
					i = $$("meta[name=csrf-token]")[0].content,
					r = {};
				r[t] = i, e.each(function(e) {
					"checkbox" === e.type ? r[e.name] = e.checked : "radio" === e.type ? e.checked && (r[e.name] = e.value) : "button" !== e.type && (r[e.name] = e.value)
				}), d.each(function(e) {
					e.save()
				}), h.each(function(e) {
					var t = e.getSelection();
					t.field && (r[t.field] = t.value)
				});
				var o = $$("#" + n + " textarea");
				return o.each(function(e) {
					var t = e.name,
						n = e.value;
					r[t] = n
				}), r
			}, this.getTitle = function() {
				return l
			};
			var k = function() {
					this.cancel()
				},
				C = new YAHOO.widget.Dialog(n, {
					constraintoviewport: !0,
					width: c,
					modal: !0,
					close: void 0 !== l,
					draggable: void 0 !== l,
					underlay: "shadow",
					buttons: null
				});
			this.setFlash = function(e, t) {
				var n = $(u);
				n && (C && C.show(), n.update(e), t ? (n.addClassName("gd_flash_notice_error"), n.removeClassName("gd_flash_notice_ok")) : (n.addClassName("gd_flash_notice_ok"), n.removeClassName("gd_flash_notice_error")))
			}, void 0 !== l && C.setHeader(l);
			var T = new YAHOO.util.KeyListener(document, {
					keys: 27
				}, {
					fn: k,
					scope: C,
					correctScope: !0
				}, "keyup"),
				S = function(e, t) {
					f[p] && (f[p](null, g[p]), t[1].preventDefault())
				},
				O = new YAHOO.util.KeyListener(document, {
					keys: 13
				}, {
					fn: S,
					scope: C,
					correctScope: !0
				}, "keydown");
			window.escFxn = k, window.enterFxn = S, window.dlgThis = C, C.cfg.queueProperty("keylisteners", [T, O]);
			var D = [],
				A = [],
				N = new Element("div", {
					id: n + "_" + a
				});
			N.addClassName(a);
			var I = new Element("div", {
				id: u
			}).update(o);
			I.addClassName("gd_flash_notice_ok"), N.appendChild(I);
			var j = function(e, i, r, o, a, s, l) {
					var c = new Element("input", {
						id: n + "_btn" + A.length,
						type: l,
						value: i
					});
					e.appendChild(c);
					var u = r;
					A.push({
						id: n + "_btn" + A.length,
						event: "click",
						klass: u,
						callback: o,
						param: {
							curr_page: a,
							arg0: s,
							dlg: t
						}
					})
				},
				F = function(e, t, n, i) {
					var r = new Element("input", {
						id: GeneralDialog.makeId(t),
						type: "text",
						name: t
					});
					return n && r.addClassName(n), void 0 !== i && r.writeAttribute({
						value: i
					}), e.appendChild(r), r
				},
				L = function(e) {
					new Ajax.Autocompleter(e.input_id, e.results_id, e.url, {
						minChars: 1
					})
				},
				P = function(e, t, n, i, r, o) {
					var a = GeneralDialog.makeId(t),
						s = a + "_wrapper",
						l = new Element("div", {
							id: s
						});
					void 0 !== n && l.addClassName(n);
					var c = new Element("input", {
						id: a,
						type: "text",
						name: t
					});
					void 0 !== o && c.writeAttribute({
						value: o
					}), l.appendChild(c);
					var u = a + "_dd",
						d = new Element("div", {
							id: u
						});
					d.addClassName("gd_autocomplete"), l.appendChild(d), e.appendChild(l), m.push(new v({
						fn_call: L,
						call_params: {
							input_id: a,
							results_id: u,
							url: i,
							token: r
						}
					}))
				},
				H = function() {},
				M = function(e, t, n, i) {
					var r = new Element("input", {
						id: GeneralDialog.makeId(t),
						name: t,
						type: "hidden"
					});
					n && r.addClassName(n), void 0 !== i && null !== i && r.writeAttribute({
						value: i
					}), e.appendChild(r)
				},
				W = function(e, t, i, r, o, a) {
					var s = {
						id: n + "_a" + D.length,
						onclick: "return false;",
						href: "#"
					};
					a && (s.title = a);
					var l = new Element("a", s).update(i);
					t && l.addClassName(t), e.appendChild(l), D.push({
						id: n + "_a" + D.length,
						event: "click",
						callback: r,
						param: o
					})
				},
				R = function(e, i, r, o, a, s) {
					var l = n + "_a" + D.length;
					W(e, r, "", o, {
						curr_page: a.page,
						button_id: l,
						context: s,
						dlg: t
					}, i)
				},
				z = function(e, t) {
					var n = $(t.button_id),
						i = t.context,
						r = i.style,
						o = {},
						a = $(i.dest + "_" + i.value);
					n.hasClassName("gd_pressed") ? (n.removeClassName("gd_pressed"), o[r] = "", $(i.dest).setStyle(o), a.value = 0) : (n.addClassName("gd_pressed"), o[r] = i.value, $(i.dest).setStyle(o), a.value = 1)
				},
				U = function(e, t) {
					var n = this.value;
					"blur" === e.type && "" === n ? ($(this).addClassName("gd_input_hint_style"), this.value = t.prompt) : "focus" === e.type && n === t.prompt ? (this.value = "", $(this).removeClassName("gd_input_hint_style")) : "keyup" === e.type && t.callback(this.value)
				};
			i.each(function(e) {
				var r = new Element("form", {
					id: e.page,
					name: e.page
				});
				r.addClassName(e.page), r.addClassName("gd_switchable_element"), i.length > 1 ? r.addClassName("hidden") : p = e.page, N.appendChild(r), e.rows.each(function(i) {
					var o = new Element("div");
					s && o.addClassName(s), r.appendChild(o), i.each(function(i) {
						if (void 0 !== i.text) {
							var a = new Element("span").update(i.text);
							i.klass && a.addClassName(i.klass), void 0 !== i.id && a.writeAttribute({
								id: GeneralDialog.makeId(i.id)
							}), o.appendChild(a)
						} else if (void 0 !== i.picture) {
							var s = i.alt ? i.alt : i.picture,
								l = new Element("img", {
									src: i.picture,
									alt: s
								});
							i.klass && l.addClassName(i.klass), void 0 !== i.id && l.writeAttribute({
								id: GeneralDialog.makeId(i.id)
							}), o.appendChild(l)
						} else if (void 0 !== i.input) F(o, i.input, i.klass, i.value);
						else if (void 0 !== i.inputFilter) {
							var c = "gd_input_hint_style";
							void 0 !== i.klass && (c += " " + i.klass);
							var u = F(o, i.inputFilter, c, i.value);
							u.value = i.prompt, D.push({
								id: i.inputFilter,
								event: "keyup",
								callback: U,
								param: {
									prompt: i.prompt,
									callback: i.callback
								}
							}), D.push({
								id: i.inputFilter,
								event: "blur",
								callback: U,
								param: {
									prompt: i.prompt,
									callback: i.callback
								}
							}), D.push({
								id: i.inputFilter,
								event: "focus",
								callback: U,
								param: {
									prompt: i.prompt,
									callback: i.callback
								}
							})
						} else if (void 0 !== i.inputWithStyle) {
							var d = i.value ? i.value : {
									text: "",
									isBold: !1,
									isItalic: !1,
									isUnderline: !1
								},
								p = F(o, i.inputWithStyle, i.klass, d.text);
							R(o, "Bold", "gd_bold_button" + (d.isBold ? " gd_pressed" : ""), z, e, {
								dest: i.inputWithStyle,
								style: "fontWeight",
								value: "bold"
							}), M(o, i.inputWithStyle + "_bold", "", d.isBold ? "1" : "0"), R(o, "Italic", "gd_italic_button" + (d.isItalic ? " gd_pressed" : ""), z, e, {
								dest: i.inputWithStyle,
								style: "fontStyle",
								value: "italic"
							}), M(o, i.inputWithStyle + "_italic", "", d.isItalic ? "1" : "0"), R(o, "Underline", "gd_underline_button" + (d.isUnderline ? " gd_pressed" : ""), z, e, {
								dest: i.inputWithStyle,
								style: "textDecoration",
								value: "underline"
							}), M(o, i.inputWithStyle + "_underline", "", d.isUnderline ? "1" : "0"), d.isBold && p.setStyle({
								fontWeight: "bold"
							}), d.isItalic && p.setStyle({
								fontStyle: "italic"
							}), d.isUnderline && p.setStyle({
								textDecoration: "underline"
							})
						} else if (void 0 !== i.autocomplete) P(o, i.autocomplete, i.klass, i.url, i.token, i.value);
						else if (void 0 !== i.hidden) M(o, i.hidden, i.klass, i.value);
						else if (void 0 !== i.password) {
							var m = new Element("input", {
								id: GeneralDialog.makeId(i.password),
								name: i.password,
								type: "password"
							});
							i.klass && m.addClassName(i.klass), void 0 !== i.value && null !== i.value && m.writeAttribute({
								value: i.value
							}), o.appendChild(m)
						} else if (void 0 !== i.colorpick) H(o, i.colorpick, i.klass, i.callback, i.value);
						else if (void 0 !== i.button) {
							var v = i.klass;
							i.isDefault && (f[e.page] = i.callback, g[e.page] = {
								curr_page: e.page,
								arg0: i.arg0,
								dlg: t
							}, v = void 0 === v ? "default" : v + " default"), j(o, i.button, v, i.callback, e.page, i.arg0, i.isSubmit === !0 ? "submit" : "button")
						} else if (void 0 !== i.icon_button) R(o, i.icon_button, i.klass, i.callback, e, i.context);
						else if (void 0 !== i.link) W(o, i.klass, i.link, i.callback, {
							curr_page: e.page,
							arg0: i.arg0,
							dlg: t
						}, i.title);
						else if (void 0 !== i.select)
							if (window.mockAjax) y(i.select, i.options, i.value, i.callback, i.arg0, o);
							else {
								var x = new Element("input", {
									id: GeneralDialog.makeId(i.select),
									name: i.select
								});
								if (i.options && i.options.length > 0) {
									var E = void 0 !== i.value && null !== i.value ? i.value : i.options[0].value;
									x.writeAttribute("value", E)
								}
								x.addClassName("hidden"), o.appendChild(x);
								var k = new Element("select", {
									id: n + "_sel" + D.length
								});
								i.klass && k.addClassName(i.klass), o.appendChild(k), D.push({
									id: n + "_sel" + D.length,
									event: "change",
									callback: b,
									param: {
										id: i.select,
										callback: i.callback,
										arg0: i.arg0
									}
								}), i.options && i.options.each(function(e) {
									var t = new Element("option", {
										value: e.value
									}).update(e.text);
									i.value === e.value && t.writeAttribute("selected", "selected"), k.appendChild(t)
								})
							} else if (void 0 !== i.custom) {
							var C = i.custom;
							h.push(i.custom);
							var T = C.getMarkup();
							i.klass && T.addClassName(i.klass), o.appendChild(T)
						} else if (void 0 !== i.checkbox) {
							var S = new Element("input", {
								id: GeneralDialog.makeId(i.checkbox),
								type: "checkbox",
								value: "1",
								name: i.checkbox
							});
							i.klass && S.addClassName(i.klass), ("1" === i.value || i.value === !0) && (S.checked = !0), o.appendChild(S)
						} else if (void 0 !== i.checkboxList) {
							var O = new Element("table"),
								A = new Element("tbody");
							O.appendChild(A);
							var N = i.columns ? i.columns : 1;
							0 >= N && (N = 1);
							for (var I = Math.ceil(i.items.length / N), L = null, B = function(e) {
								return L === e
							}, q = 0; I > q; q++) {
								var G = new Element("tr");
								O.appendChild(G);
								for (var Q = 0; N > Q; Q++) {
									var Y = Q * I + q;
									if (Y < i.items.length) {
										var V = i.items[Y];
										L = V;
										var K = V;
										"string" != typeof V && (L = V[0], K = V[1]);
										var X = new Element("td", {
												style: "padding: 0 0.5em 0 0.5em;"
											}),
											J = i.checkboxList + "[" + L + "]",
											Z = new Element("input", {
												id: GeneralDialog.makeId(J),
												type: "checkbox",
												value: "1",
												name: J
											});
										i.klass && Z.addClassName(i.klass), i.selections && i.selections.detect(B) && (Z.checked = !0), X.appendChild(Z);
										var et = new Element("span").update(K);
										X.appendChild(et), G.appendChild(X)
									}
								}
								o.appendChild(O)
							}
						} else if (void 0 !== i.radioList) {
							var tt = i.options,
								nt = i.radioList,
								it = i.value,
								rt = i.klass,
								ot = new Element("table");
							rt && ot.addClassName(rt), o.appendChild(ot);
							var at = new Element("tbody");
							ot.appendChild(at), tt.each(function(e) {
								var t = e,
									n = e;
								"string" != typeof e && (t = e.text, n = e.value);
								var i = new Element("tr");
								at.appendChild(i);
								var r = new Element("td");
								i.appendChild(r);
								var o = new Element("input", {
									id: GeneralDialog.makeId(nt + "_" + n),
									type: "radio",
									value: n,
									name: nt
								});
								it === n && o.writeAttribute("checked", "true"), r.appendChild(o), r = new Element("td"), i.appendChild(r), r.appendChild(new Element("span").update(" " + t + "<br />"))
							})
						} else if (void 0 !== i.textarea) {
							var st = new Element("div"),
								lt = new Element("textarea", {
									id: GeneralDialog.makeId(i.textarea),
									name: i.textarea
								});
							if (i.klass && (lt.addClassName(i.klass), st.addClassName(i.klass)), void 0 !== i.value && null !== i.value) {
								var ct = i.value.strip();
								ct = ct.escapeHTML(), lt.update(ct)
							}
							st.appendChild(lt), o.appendChild(st)
						} else if (void 0 !== i.date) {
							for (var ut = i.value ? i.value.split(" ")[0].split("-") : ["", "", ""], dt = new Element("select", {
								id: GeneralDialog.makeId(i.date.gsub("*", "1i")),
								name: i.date.gsub("*", "(1i)")
							}), ht = 2005; 2015 > ht; ht++) dt.appendChild(ut[0] === "" + ht ? new Element("option", {
								value: "" + ht,
								selected: "selected"
							}).update("" + ht) : new Element("option", {
								value: "" + ht
							}).update("" + ht));
							for (var pt = new Element("select", {
								id: GeneralDialog.makeId(i.date.gsub("*", "2i")),
								name: i.date.gsub("*", "(2i)")
							}), ft = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], gt = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"], mt = 0; mt < ft.length; mt++) pt.appendChild(ut[1] === gt[mt] ? new Element("option", {
								value: mt + 1,
								selected: "selected"
							}).update(ft[mt]) : new Element("option", {
								value: mt + 1
							}).update(ft[mt]));
							for (var vt = new Element("select", {
								id: GeneralDialog.makeId(i.date.gsub("*", "3i")),
								name: i.date.gsub("*", "(3i)")
							}), _t = 1; 31 >= _t; _t++) vt.appendChild(ut[2] === (10 > _t ? "0" : "") + _t ? new Element("option", {
								value: "" + _t,
								selected: "selected"
							}).update("" + _t) : new Element("option", {
								value: "" + _t
							}).update("" + _t));
							var bt = i.klass ? i.klass + " " : "";
							dt.addClassName(bt + "gd_year"), pt.addClassName(bt + "gd_month"), vt.addClassName(bt + "gd_day"), o.appendChild(dt), o.appendChild(pt), o.appendChild(vt)
						} else if (void 0 !== i.image) {
							var yt = new Element("div", {
									id: GeneralDialog.makeId(i.image) + "_div"
								}),
								wt = void 0 !== i.value && null !== i.value ? i.value : "";
							if (wt.length > 0) {
								var xt = i.alt ? i.alt : wt;
								yt.appendChild(new Element("img", {
									src: wt,
									id: GeneralDialog.makeId(i.image) + "_img",
									alt: xt
								}))
							}
							var Et = function() {
									var e = new Element("input", {
										id: GeneralDialog.makeId(i.image),
										type: "file",
										name: i.image
									});
									return i.size && e.writeAttribute({
										size: i.size
									}), e
								},
								kt = Et();
							if (yt.appendChild(kt), i.klass && yt.addClassName(i.klass), o.appendChild(yt), _(o), void 0 !== i.removeButton) {
								var Ct = function() {
									var e = $(GeneralDialog.makeId(i.image));
									e.remove(), e = $(GeneralDialog.makeId(i.image) + "_img"), e && (e.src = "");
									var t = Et();
									yt.appendChild(t)
								};
								W(o, n, null, i.removeButton, Ct, {})
							}
							i.no_iframe ? r.writeAttribute({
								enctype: "multipart/form-data",
								method: "post"
							}) : (r.writeAttribute({
								enctype: "multipart/form-data",
								target: "gd_upload_target",
								method: "post"
							}), $(w).appendChild(new Element("iframe", {
								id: "gd_upload_target",
								name: "gd_upload_target",
								src: "",
								style: "display:none;width:0;height:0;border:0px solid #fff;"
							})))
						} else if (void 0 !== i.file) {
							var Tt = new Element("input", {
								id: GeneralDialog.makeId(i.file),
								type: "file",
								name: i.file
							});
							i.size && Tt.writeAttribute({
								size: i.size
							}), o.appendChild(Tt), i.klass && Tt.addClassName(i.klass), o.appendChild(Tt), _(o), i.no_iframe ? r.writeAttribute({
								enctype: "multipart/form-data",
								method: "post"
							}) : (r.writeAttribute({
								enctype: "multipart/form-data",
								target: "gd_upload_target",
								method: "post"
							}), $(w).appendChild(new Element("iframe", {
								id: "gd_upload_target",
								name: "gd_upload_target",
								src: "#",
								style: "display:none;width:0;height:0;border:0px solid #fff;"
							})))
						} else void 0 !== i.rowClass && o.addClassName(i.rowClass)
					})
				});
				var o = new Element("div");
				o.addClassName("clear_both"), r.appendChild(o)
			}), C.setBody(N);
			var B = YAHOO.util.Dom.getViewportHeight() / 2 + YAHOO.util.Dom.getDocumentScrollTop();
			jQuery(C.element).css("top", B + "px"), C.render(w), C.cancelEvent.subscribe(function() {
				setTimeout(function() {
					C.destroy()
				}, 500)
			}), D.each(function(e) {
				YAHOO.util.Event.addListener(e.id, e.event, e.callback, e.param)
			}), A.each(function(e) {
				var t = function(t, n) {
						var i = e.callback.bind($(n));
						i(t, e.param)
					},
					n = $(e.id).type;
				new YAHOO.widget.Button(e.id, {
					onclick: {
						fn: t,
						obj: e.id,
						scope: this
					}
				}), e.klass && YAHOO.util.Event.onContentReady(e.id, function() {
					$(e.id).addClassName(e.klass)
				}), YAHOO.util.Event.onContentReady(e.id, function() {
					$(e.id + "-button").type = n
				})
			}), h.each(function(e) {
				e.delayedSetup && e.delayedSetup()
			}), m.each(function(e) {
				e.execute()
			}), r && $(r) && $(r).focus(), this.changePage = function(e, t) {
				p = e;
				var i = $(n).select(".gd_switchable_element");
				i.each(function(t) {
					t.hasClassName(e) ? t.removeClassName("hidden") : t.addClassName("hidden")
				}), t && $(t) && $(t).focus()
			}, this.cancel = function() {
				C.cancel()
			}, this.hide = function() {
				C.hide()
			}, this.show = function() {
				C.show()
			}, this.center = function() {
				var e = $(n),
					t = parseInt(e.getStyle("width"), 10),
					i = parseInt(e.getStyle("height"), 10),
					r = YAHOO.util.Dom.getViewportWidth(),
					o = YAHOO.util.Dom.getViewportHeight(),
					a = (r - t) / 2,
					s = (o - i) / 2;
				a += YAHOO.util.Dom.getDocumentScrollLeft(), s += YAHOO.util.Dom.getDocumentScrollTop(), 0 > a && (a = 0), 0 > s && (s = 0);
				var l = e.up();
				l.setStyle({
					left: a + "px",
					top: s + "px"
				})
			}, this.initTextAreas = function(e) {
				var t = e.toolbarGroups,
					i = e.linkDlgHandler,
					r = e.footnote,
					o = e.bodyStyle,
					a = e.onlyClass,
					s = $(n),
					l = parseInt(s.getStyle("width"), 10),
					c = s.down(".bd"),
					u = parseInt(c.getStyle("padding-left")),
					h = parseInt(c.getStyle("padding-right")),
					p = l - u - h,
					f = $$("#" + n + " textarea");
				f.each(function(e) {
					if (void 0 === a || e.hasClassName(a)) {
						var n = new RichTextEditor({
							id: e.id,
							toolbarGroups: t,
							linkDlgHandler: i,
							width: p,
							footnote: r,
							populate_exhibit_only: i.getPopulateUrls()[0],
							populate_all: i.getPopulateUrls()[1],
							bodyStyle: o
						});
						n.attachToDialog(C), d.push(n)
					}
				}, this)
			}
		}
	});
GeneralDialog.cancelCallback = function(e, t) {
	t.dlg.cancel()
}, GeneralDialog.makeId = function(e) {
	return e.gsub(/\[/, "_").gsub("]", "")
};
var MessageBoxDlg = Class.create({
		initialize: function(e, t) {
			this.class_type = "MessageBoxDlg";
			var n = {
					page: "layout",
					rows: [
						[{
							text: t,
							klass: "gd_message_box_label"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Close",
							callback: GeneralDialog.cancelCallback,
							isDefault: !0
						}]
					]
				},
				i = {
					this_id: "gd_message_box_dlg",
					pages: [n],
					body_style: "gd_message_box_dlg",
					row_style: "gd_message_box_row",
					title: e
				},
				r = new GeneralDialog(i);
			r.center(), this.cancel = function() {
				r.cancel()
			}
		}
	}),
	ShowDivInLightbox = Class.create({
		initialize: function(e) {
			this.class_type = "ShowDivInLightbox";
			var t = Class.create({
					id: e.id,
					div: e.div,
					getMarkup: function() {
						if (this.div) return this.div;
						var e = $(this.id).innerHTML,
							t = new Element("div").update(e);
						return t
					}
				}),
				n = {
					page: "layout",
					rows: [
						[{
							custom: new t,
							klass: e.klass
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Close",
							callback: GeneralDialog.cancelCallback,
							isDefault: !0
						}]
					]
				},
				i = {
					this_id: "gd_lightbox_dlg",
					pages: [n],
					body_style: "gd_lightbox_dlg",
					row_style: "gd_lightbox_row",
					title: e.title
				},
				r = new GeneralDialog(i);
			r.center(), this.dlg = r
		}
	}),
	ConfirmDlg3 = Class.create({
		initialize: function(e, t, n, i, r, o, a) {
			this.yes = function(e, t) {
				t.dlg.cancel(), o()
			}, this.no = function(e, t) {
				t.dlg.cancel(), a()
			};
			var s = {
					page: "layout",
					rows: [
						[{
							rowClass: "gd_confirm_msg_row"
						}, {
							text: t,
							klass: "gd_confirm_label"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: n,
							callback: this.yes,
							isDefault: !0
						}, {
							button: i,
							callback: this.no
						}, {
							button: r,
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				l = {
					this_id: "gd_confirm_dlg",
					pages: [s],
					body_style: "gd_confirm_dlg",
					row_style: "gd_confirm_row",
					title: e
				},
				c = new GeneralDialog(l);
			c.center()
		}
	}),
	singleInputDlg = function(e, t) {
		var n = e.title,
			i = e.prompt,
			r = e.id,
			o = e.okStr ? e.okStr : "Ok",
			a = e.actions,
			s = e.onSuccess,
			l = e.onFailure,
			c = e.target_els,
			u = e.extraParams ? e.extraParams : {},
			d = e.noDefault,
			h = e.pleaseWaitMsg ? e.pleaseWaitMsg : "Please wait...",
			p = null,
			f = e.verify,
			g = e.verifyFxn,
			m = void 0 === e.body_style ? "gd_message_box_dlg" : e.body_style,
			v = e.populate,
			_ = e.explanation_klass;
		this.class_type = "singleInputDlg";
		var b = function(e) {
				p.cancel(), s && s(e)
			},
			y = function() {
				var e = a;
				Object.isArray(e) || (e = [e]);
				var t = c;
				Object.isArray(t) || (t = [t]), serverAction({
					action: {
						actions: e.clone(),
						els: t.clone(),
						onSuccess: b,
						dlg: p,
						onFailure: l,
						params: u
					}
				})
			};
		this.ok = function(e, t) {
			t.dlg.setFlash(h, !1);
			var n = t.dlg.getAllData();
			if (u[r] = n[r], g) {
				var i = g(u);
				if (i) return void t.dlg.setFlash(i, !0)
			}
			f ? serverAction({
				action: {
					actions: f,
					els: "gd_bit_bucket",
					onSuccess: y,
					dlg: p,
					params: u
				}
			}) : (Object.isArray(a) || (a = [a]), "string" == typeof c ? c = [c] : (null === c || void 0 === c) && (c = [null]), serverAction({
				action: {
					actions: a.clone(),
					els: c.clone(),
					onSuccess: b,
					dlg: p,
					onFailure: l,
					params: u
				}
			}))
		};
		var w = {
			page: "layout",
			rows: [
				[{
					text: i,
					klass: "gd_text_input_dlg_label"
				},
					t
				]
			]
		};
		e.explanation_text && w.rows.push([{
			text: e.explanation_text,
			id: "gd_postExplanation",
			klass: _
		}]), e.noOk ? (w.rows.push([{
			rowClass: "gd_last_row"
		}, {
			button: "Cancel",
			callback: GeneralDialog.cancelCallback,
			isDefault: !0
		}]), d && (w.rows[1][0].isDefault = null)) : (w.rows.push([{
			rowClass: "gd_last_row"
		}, {
			button: o,
			callback: this.ok,
			isDefault: !0
		}, {
			button: "Cancel",
			callback: GeneralDialog.cancelCallback
		}]), d && (w.rows[1][1].isDefault = null));
		var x = {
			this_id: "gd_text_input_dlg",
			pages: [w],
			body_style: m,
			row_style: "gd_message_box_row",
			title: n,
			focus: GeneralDialog.makeId(r)
		};
		p = new GeneralDialog(x), p.center(), v && v(p)
	},
	TextInputDlg = Class.create({
		initialize: function(e) {
			var t = e.id,
				n = e.value,
				i = void 0 === e.inputKlass ? "gd_text_input_dlg_input" : e.inputKlass,
				r = e.autocompleteParams;
			if (r) {
				var o = {
					autocomplete: t,
					klass: i,
					url: r.url,
					token: r.token
				};
				singleInputDlg(e, o)
			} else {
				var a = {
					input: t,
					klass: i,
					value: n
				};
				singleInputDlg(e, a)
			}
		}
	}),
	SelectInputDlg = Class.create({
		initialize: function(e) {
			var t = e.id,
				n = e.options,
				i = e.explanation,
				r = e.value,
				o = e.populateUrl,
				a = {
					select: t,
					klass: "gd_select_dlg_input",
					options: n,
					value: r
				},
				s = function(t) {
					var n = function(e) {
							var n = [];
							t.setFlash("", !1);
							try {
								e.responseText.length > 0 && (n = e.responseText.evalJSON(!0))
							} catch (i) {
								return void t.setFlash(i, !0)
							}
							var r = $$(".gd_select_dlg_input"),
								o = r[0];
							o.update(""), n = n.sortBy(function(e) {
								return e.text
							}), n.each(function(e) {
								o.appendChild(new Element("option", {
									value: e.value
								}).update(e.text))
							})
						},
						i = function(e) {
							genericAjaxFail(t, e, o)
						};
					serverAction({
						action: {
							actions: o,
							els: "gd_bit_bucket",
							onSuccess: n,
							onFailure: i,
							params: e.extraParams
						}
					})
				};
			if (i) {
				var l = function(e) {
						for (var t = 0; t < n.length; t++)
							if (n[t].value === e) return i[t];
						return i[0]
					},
					c = function(e, t) {
						$("gd_postExplanation").update(l(t))
					};
				a.callback = c, e.explanation_text = l(r)
			}
			o && (e.populate = s), singleInputDlg(e, a)
		}
	}),
	RteInputDlg = Class.create({
		initialize: function(e) {
			var t = e.title,
				n = e.okCallback,
				i = e.value,
				r = e.populate_urls,
				o = e.progress_img,
				a = e.extraButton;
			this.class_type = "RteInputDlg", this.ok = function(e, t) {
				t.dlg.cancel();
				var i = t.dlg.getAllData();
				n(i.gd_textareaValue)
			};
			var s = {
				page: "layout",
				rows: [
					[{
						textarea: "gd_textareaValue",
						value: i
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						callback: this.ok
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			};
			void 0 !== a && s.rows[1].push({
				button: a.label,
				callback: a.callback
			});
			var l = {
					this_id: "gd_text_input_dlg",
					pages: [s],
					body_style: "gd_message_box_dlg",
					row_style: "gd_message_box_row",
					title: t
				},
				c = new GeneralDialog(l);
			c.initTextAreas({
				toolbarGroups: ["fontstyle", "link"],
				linkDlgHandler: new LinkDlgHandler(r, o)
			}), c.center();
			var u = $("gd_textareaValue");
			u.select(), u.focus()
		}
	}); //     Copyright 2010 Applied Research in Patacriticism and the University of Virginia
Ajax.Responders.register({
	onCreate: function(e) {
		var t = $$("meta[name=csrf-token]")[0];
		if (t) {
			var n = "X-CSRF-Token",
				i = t.readAttribute("content");
			e.options.requestHeaders || (e.options.requestHeaders = {}), e.options.requestHeaders[n] = i
		}
	}
});
var postLink = function(e, t, n) {
		if (window.mockSubmit) window.mockSubmit(e, t, n);
		else {
			var i = document.createElement("form");
			i.style.display = "none", document.body.appendChild(i), i.method = "POST", i.action = e, n && (i.target = n);
			var r = document.createElement("input");
			r.setAttribute("type", "hidden"), r.setAttribute("name", "_method"), r.setAttribute("value", "post"), i.appendChild(r);
			var o = $$("meta[name=csrf-param]")[0].content,
				a = $$("meta[name=csrf-token]")[0].content;
			i.appendChild(new Element("input", {
				id: o,
				type: "hidden",
				name: o,
				value: a
			})), t && $H(t).each(function(e) {
				"string" == typeof e.value ? i.appendChild(new Element("input", {
					type: "hidden",
					name: e.key,
					value: e.value,
					id: e.key
				})) : "number" == typeof e.value ? i.appendChild(new Element("input", {
					type: "hidden",
					name: e.key,
					value: "" + e.value,
					id: e.key
				})) : $H(e.value).each(function(t) {
					i.appendChild(new Element("input", {
						type: "hidden",
						name: e.key + "[" + t.key + "]",
						value: t.value,
						id: t.key
					}))
				})
			}), i.submit()
		}
	},
	ConfirmDlg = Class.create({
		initialize: function(e, t, n, i, r) {
			this.ok = function(e, t) {
				t.dlg.cancel(), r()
			};
			var o = {
					page: "layout",
					rows: [
						[{
							rowClass: "gd_confirm_msg_row"
						}, {
							text: t,
							klass: "gd_confirm_label"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: n,
							callback: this.ok,
							isDefault: !0
						}, {
							button: i,
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				a = {
					this_id: "gd_confirm_dlg",
					pages: [o],
					body_style: "gd_confirm_dlg",
					row_style: "gd_confirm_row",
					title: e
				},
				s = new GeneralDialog(a);
			s.center()
		}
	}),
	ProgressSpinnerDlg = Class.create({
		initialize: function(e) {
			var t = {
					page: "spinner_layout",
					rows: [
						[{
							text: " ",
							klass: "gd_transparent_progress_spinner"
						}],
						[{
							rowClass: "gd_progress_label_row"
						}, {
							text: e,
							klass: "transparent_progress_label"
						}]
					]
				},
				n = {
					this_id: "gd_progress_spinner_dlg",
					pages: [t],
					body_style: "gd_progress_spinner_div",
					row_style: "gd_progress_spinner_row"
				},
				i = new GeneralDialog(n);
			i.center(), this.cancel = function() {
				i.cancel()
			}, this.hide = function() {
				i.hide()
			}, this.show = function() {
				i.show()
			}
		}
	}),
	serverAction = function(e) {
		var t = e.confirm,
			n = e.action,
			i = e.progress,
			r = e.searching,
			o = function(e, t) {
				var i = null,
					r = function(t) {
						var n = $$("meta[name=csrf-param]")[0].content,
							r = $$("meta[name=csrf-token]")[0].content,
							o = t.params;
						if ("string" != typeof i && (o = Object.clone(o), o._method = i.method, i = i.url), "string" == typeof o ? o += 0 === o.length ? "?" + n + "=" + encodeURIComponent(r) : "&" + n + "=" + encodeURIComponent(r) : void 0 === o[n] && (o[n] = r), void 0 === t.el || null !== t.el && 0 !== t.el.length) {
							var a = function(e) {
								jQuery.ajax({
									url: e.action,
									type: "POST",
									data: e.params,
									success: function(t, n, i) {
										var r = $(e.el);
										r && r.update(i.responseText), e.onSuccess && e.onSuccess(i)
									},
									error: function(t) {
										e.onFailure ? e.onFailure(t) : genericAjaxFail(e.dlg, t, e.action)
									}
								})
							};
							a({
								action: i,
								params: o,
								el: t.el,
								onSuccess: t.onSuccess,
								dlg: t.dlg,
								onFailure: t.onFailure
							})
						} else if ("GET" === o._method) {
							var s = i,
								l = [];
							for (var c in o) o.hasOwnProperty(c) && c !== n && "_method" !== c && l.push(c + "=" + encodeURI(o[c]));
							l.length > 0 && (s += s.indexOf("?") > -1 ? "&" : "?", s += l.join("&")), gotoPage(s)
						} else postLink(i, o, e.target)
					};
				void 0 === e.params && (e.params = {});
				var a = e.actions,
					s = e.els,
					l = e.onSuccess,
					c = e.onFailure,
					u = e.params;
				if ("string" == typeof a ? a = a.split(",") : Object.isArray(a) || (a = [a]), "string" == typeof s && (s = s.split(",")), 0 === a.length) return void(l && l(t));
				i = a.shift();
				var d = s ? s.shift() : null,
					h = {
						action: i,
						el: d,
						onSuccess: function(t) {
							o({
								actions: a,
								els: s,
								target: n.target,
								onSuccess: l,
								dlg: e.dlg,
								onFailure: c,
								params: u
							}, t)
						},
						dlg: e.dlg,
						onFailure: c,
						params: u
					};
				r(h)
			},
			a = null,
			s = n.onSuccess,
			l = function(e) {
				if (i)
					if (void 0 === i.completeMessage) a.cancel();
					else {
						var t = $$(".gd_message_box_label");
						t.length > 0 ? t[0].update(i.completeMessage) : (a.cancel(), new MessageBoxDlg("Success", i.completeMessage))
					}
				s && s(e)
			},
			c = function(e) {
				i && a.cancel(), n.onFailure ? n.onFailure(e) : genericAjaxFail(n.dlg, e, n.actions)
			},
			u = function() {
				i && (r ? progressSpinnerSearchingDialog.show() : a = new ProgressSpinnerDlg(i.waitMessage)), n.actions ? o({
					actions: n.actions,
					els: n.els,
					target: n.target,
					onSuccess: l,
					dlg: n.dlg,
					onFailure: c,
					params: n.params
				}) : l()
			};
		if (t) {
			var d = t.cancelLabel;
			void 0 === d && (d = "No");
			var h = t.okLabel;
			void 0 === h && (h = "Yes"), new ConfirmDlg(t.title, t.message, h, d, u)
		} else u()
	},
	serverNotify = function(e, t) {
		serverAction({
			action: {
				actions: e,
				els: "gd_bit_bucket",
				params: t
			}
		})
	},
	serverRequest = function(e) {
		serverAction({
			action: {
				actions: e.url,
				els: "gd_bit_bucket",
				params: e.params,
				onSuccess: e.onSuccess,
				onFailure: e.onFailure,
				dlg: e.dlg
			}
		})
	},
	progressSpinnerSearchingDialog = null;
Event.observe(window, "load", preload_image); //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var AjaxUpdate = Class.create({
		initialize: function(e, t, n) {
			var i = !1;
			this.sendWithAjax = function(r, o) {
				if (!i) {
					i = !0;
					var a = o.arg0,
						s = o.dlg,
						l = s.getAllData();
					if (s.setFlash(t, !1), n) {
						var c = n(l);
						if (c) return s.setFlash(c, !0), void(i = !1)
					}
					var u = function(t) {
							s.cancel(), $(e).update(t.responseText), i = !1
						},
						d = function(e) {
							genericAjaxFail(s, e, a), i = !1
						};
					serverRequest({
						url: a,
						params: l,
						onSuccess: u,
						onFailure: d
					})
				}
			}
		}
	}),
	AddCategoryDlg = Class.create({
		initialize: function(e, t, n) {
			this.class_type = "AddCategoryDlg";
			var i = null,
				r = [],
				o = function() {
					var e = function(e) {
						i.setFlash("", !1);
						try {
							e.responseText.length > 0 && (r = e.responseText.evalJSON(!0))
						} catch (t) {
							new MessageBoxDlg("Error", t)
						}
						var n = $$(".categories_select"),
							o = n.pop();
						o.update(""), r = r.sortBy(function(e) {
							return e.text
						});
						var a = 0;
						r.each(function(e) {
							"[root]" === e.text ? (a = e.value, o.appendChild(new Element("option", {
								value: e.value,
								selected: "selected"
							}).update(e.text))) : o.appendChild(new Element("option", {
								value: e.value
							}).update(e.text))
						}), $("parent_category_id").value = a
					};
					serverRequest({
						url: n,
						onSuccess: e
					})
				},
				a = function(e) {
					if (e.category_name.length < 1) return "Please enter a name for the Resource Tree.";
					var t = !1;
					return r.each(function(n) {
						n.text === e.category_name && (t = !0)
					}), t ? "That category name has already been used." : null
				},
				s = new AjaxUpdate(e, "Adding Category...", a),
				l = {
					page: "layout",
					rows: [
						[{
							text: "This is a label that sites and other categories can be attached to.",
							klass: "new_exhibit_instructions"
						}],
						[{
							text: "Category Name:",
							klass: "admin_dlg_label"
						}, {
							input: "category_name",
							klass: "new_exhibit_input"
						}],
						[{
							text: "Parent Category:",
							klass: "admin_dlg_label"
						}, {
							select: "parent_category_id",
							klass: "categories_select",
							options: [{
								value: -1,
								text: "Loading categories. Please Wait..."
							}]
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: s.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				c = {
					this_id: "add_category_dlg",
					pages: [l],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Add Category To Resource Tree",
					focus: "category_name"
				};
			i = new GeneralDialog(c), i.center(), o(i)
		}
	}),
	AddSiteDlg = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "AddSiteDlg";
			var r = null,
				o = function() {
					var e = [],
						t = function(t) {
							r.setFlash("", !1);
							try {
								t.responseText.length > 0 && (e = t.responseText.evalJSON(!0))
							} catch (n) {
								new MessageBoxDlg("Error", n)
							}
							var i = $$(".categories_select"),
								o = i.pop();
							o.update(""), e = e.sortBy(function(e) {
								return e.text
							});
							var a = 0;
							e.each(function(e) {
								"[root]" === e.text ? (a = e.value, o.appendChild(new Element("option", {
									value: e.value,
									selected: "selected"
								}).update(e.text))) : o.appendChild(new Element("option", {
									value: e.value
								}).update(e.text))
							}), $("parent_category_id").value = a
						};
					serverRequest({
						url: i,
						onSuccess: t
					})
				},
				a = function(e) {
					return e.display_name.length < 1 ? "Please enter a name for the Resource Tree." : null
				},
				s = new AjaxUpdate(e, "Adding Site...", a),
				l = {
					page: "layout",
					rows: [
						[{
							text: 'Enter the information for the site labeled "' + n + '" in solr.',
							klass: "new_exhibit_instructions"
						}],
						[{
							text: "Name in Resource Tree:",
							klass: "admin_dlg_label"
						}, {
							input: "display_name",
							klass: "new_exhibit_input"
						}],
						[{
							text: "Parent Category:",
							klass: "admin_dlg_label"
						}, {
							select: "parent_category_id",
							klass: "categories_select",
							options: [{
								value: -1,
								text: "Loading categories. Please Wait..."
							}]
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: s.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}, {
							hidden: "site",
							value: n
						}]
					]
				},
				c = {
					this_id: "add_site_dlg",
					pages: [l],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Add Site To Resource Tree",
					focus: "display_name"
				};
			r = new GeneralDialog(c), r.center(), o(r)
		}
	}),
	RemoveSiteDlg = Class.create({
		initialize: function(e, t, n) {
			this.class_type = "RemoveSiteDlg";
			var i = new AjaxUpdate(e, "Removing the site...", null),
				r = {
					page: "layout",
					rows: [
						[{
							text: 'You are about to delete the resource "' + n + "\" from the Resource Tree. This is probably ok because the resource doesn't appear to be returned by solr. However, this could also happen if the solr index is corrupted.",
							klass: "new_exhibit_instructions"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: i.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}, {
							hidden: "site",
							value: n
						}]
					]
				},
				o = {
					this_id: "remove_site_dlg",
					pages: [r],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Remove Site From Resource Tree"
				},
				a = new GeneralDialog(o);
			a.center()
		}
	}),
	DeleteFacetDialog = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "DeleteSiteDlg";
			var r = new AjaxUpdate(e, "Deleting the site...", null),
				o = null;
			o = i ? {
				page: "layout",
				rows: [
					[{
						text: 'You are about to delete the category "' + n + '" from the Resource Tree. All of its children will be moved up to its parent.',
						klass: "new_exhibit_instructions"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						arg0: t,
						callback: r.sendWithAjax
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback,
						isDefault: !0
					}, {
						hidden: "site",
						value: n
					}]
				]
			} : {
				page: "layout",
				rows: [
					[{
						text: 'You are about to delete the site "' + n + '" from the Resource Tree. This resource is indexed in solr so results from this resource can be seen in the search page. Are you sure?',
						klass: "new_exhibit_instructions"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						arg0: t,
						callback: r.sendWithAjax
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback,
						isDefault: !0
					}, {
						hidden: "site",
						value: n
					}]
				]
			};
			var a = {
					this_id: "delete_site_dlg",
					pages: [o],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Delete Site From Resource Tree"
				},
				s = new GeneralDialog(a);
			s.center()
		}
	}),
	EditFacetDialog = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "EditFacetDialog";
			var r = null,
				o = [],
				a = function() {
					r.setFlash("Loading data, please wait...", !1);
					var e = null,
						t = function(t) {
							r.setFlash("", !1);
							try {
								if (t.responseText.length > 0) {
									var i = t.responseText.evalJSON(!0);
									o = i.categories, e = i.details
								}
							} catch (a) {
								new MessageBoxDlg("Error", a)
							}
							var s = $$(".categories_select"),
								l = s.pop();
							l.update(""), o = o.sortBy(function(e) {
								return e.text
							}), o.each(function(e) {
								e.text !== n && l.appendChild(new Element("option", {
									value: e.value
								}).update(e.text))
							});
							var c = $("edit_facet_dlg_sel0");
							if ($A(c.options).each(function(t) {
								parseInt(t.value) === e.parent_id && (t.selected = "selected")
							}), $("parent_category_id").value = e.parent_id, e.is_category) {
								$("display_name").value = n;
								var u = $$(".hide_if_category");
								u.each(function(e) {
									e.hide()
								}), $("carousel_url").value = e.carousel_url
							} else {
								var d = $$(".hide_if_site");
								d.each(function(e) {
									e.hide()
								}), $("display_name").value = e.display_name, $("site_url").value = e.site_url, $("site_thumbnail").value = e.site_thumbnail
							}
							$("carousel_include").checked = 1 === e.carousel_include, $("carousel_description").value = e.carousel_description;
							var h = $("carousel_thumbnail_img");
							h && (h.src = e.image)
						};
					serverRequest({
						url: i,
						params: {
							site: n
						},
						onSuccess: t
					})
				};
			this.sendWithAjax = function(i, r) {
				var a = r.arg0,
					s = r.dlg;
				s.setFlash("Updating Facet...", !1);
				var l = s.getAllData();
				l.site = n;
				var c = !1;
				if (l.display_name !== n && (o.each(function(e) {
					e.text === l.display_name && (c = !0)
				}), c)) return void s.setFlash("That category name has already been used.", !0);
				var u = function() {
					var e = $("carousel_thumbnail"),
						i = e.up("form");
					i.appendChild(new Element("input", {
						type: "hidden",
						name: "value",
						value: n
					})), submitForm("layout", t + "_upload"), s.cancel()
				};
				serverAction({
					action: {
						actions: a,
						els: e,
						params: l,
						onSuccess: u
					}
				})
			};
			var s = {
					page: "layout",
					rows: [
						[{
							text: 'Edit the facet "' + n + '" for both the Resource Tree and the Carousel.',
							klass: "new_exhibit_instructions"
						}],
						[{
							text: "Parent Category:",
							klass: "edit_facet_label"
						}, {
							select: "parent_category_id",
							klass: "categories_select",
							options: [{
								value: -1,
								text: "Loading categories. Please Wait..."
							}]
						}],
						[{
							text: "Name in Resource Tree:",
							klass: "edit_facet_label"
						}, {
							input: "display_name",
							klass: "edit_facet_input"
						}],
						[{
							text: "Site URL:",
							klass: "hide_if_category edit_facet_label"
						}, {
							input: "site_url",
							klass: "hide_if_category edit_facet_input"
						}],
						[{
							text: window.gFederationName + " Thumbnail:",
							klass: "hide_if_category edit_facet_label"
						}, {
							input: "site_thumbnail",
							klass: "hide_if_category edit_facet_input"
						}],
						[{
							text: "Include in Carousel:",
							klass: "edit_facet_label"
						}, {
							checkbox: "carousel_include",
							klass: ""
						}],
						[{
							text: "Carousel Description:",
							klass: "edit_facet_label"
						}, {
							textarea: "carousel_description",
							klass: "edit_facet_textarea"
						}],
						[{
							text: "Carousel URL:",
							klass: "hide_if_site edit_facet_label"
						}, {
							input: "carousel_url",
							klass: "hide_if_site edit_facet_input"
						}],
						[{
							text: "Carousel Thumbnail:",
							klass: "edit_facet_label"
						}, {
							image: "carousel_thumbnail",
							klass: "edit_profile_image",
							removeButton: "Remove Thumbnail",
							value: " "
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				l = {
					this_id: "edit_facet_dlg",
					pages: [s],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Edit Facet",
					focus: "display_name"
				};
			r = new GeneralDialog(l), r.center(), a(r)
		}
	}),
	EditGroupType = Class.create({
		initialize: function(e, t, n, i, r, o, a, s, l, c, u, d) {
			this.class_type = "EditGroupType", r.each(function(e) {
				e.text === i && (i = e.value)
			});
			var h = new AjaxUpdate(e, "Updating Group Type...", null),
				p = {
					page: "layout",
					rows: [
						[{
							text: "Choose the type that this group will appear under in the Exhibit List.",
							klass: "new_exhibit_instructions"
						}],
						[{
							text: "Type:",
							klass: "edit_facet_label"
						}, {
							select: "group_type",
							value: i,
							klass: "categories_select",
							options: r
						}],
						[{
							text: "Badge:",
							klass: "edit_facet_label"
						}, {
							select: "badge_id",
							value: o,
							options: a
						}],
						[{
							text: "Publication Image:",
							klass: "edit_facet_label"
						}, {
							select: "publication_image_id",
							value: s,
							options: l
						}],
						[{
							text: "Header Text Color:",
							klass: "edit_facet_label"
						}, {
							input: "header_text_color",
							value: c
						}],
						[{
							text: "Header Bkgd Color:",
							klass: "edit_facet_label"
						}, {
							input: "header_background_color",
							value: u
						}],
						[{
							text: "Link Color:",
							klass: "edit_facet_label"
						}, {
							input: "link_color",
							value: d
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: h.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}, {
							hidden: "group_id",
							value: n
						}]
					]
				},
				f = {
					this_id: "change_exhibit_category_dlg",
					pages: [p],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Edit Group Type",
					focus: "category_id"
				},
				g = new GeneralDialog(f);
			g.center()
		}
	}),
	addBadgeDlg = null,
	AddBadgeDlg = Class.create({
		initialize: function(e) {
			this.class_type = "AddBadgeDlg";
			var t = this,
				n = null,
				i = function() {
					addBadgeDlg = t, n.setFlash("Adding badge thumbnail...", !1), submitForm("layout", e)
				};
			this.fileUploadError = function(e) {
				n.setFlash(e, !0)
			}, this.fileUploadFinished = function() {
				n.setFlash("Badge updated...", !1), reloadPage()
			};
			var r = function() {
				var e = {
						page: "layout",
						rows: [
							[{
								text: "Choose Badge:"
							}],
							[{
								image: "image",
								size: "47",
								klass: "edit_group_thumbnail"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Upload Badge",
								callback: i
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					t = {
						this_id: "add_badge",
						pages: [e],
						body_style: "add_badge_div",
						row_style: "new_exhibit_row",
						title: "Add Badge"
					};
				n = new GeneralDialog(t), n.center()
			};
			r()
		}
	}),
	addPublicationImageDlg = null,
	AddPublicationImageDlg = Class.create({
		initialize: function(e) {
			var t = this,
				n = null,
				i = function() {
					addPublicationImageDlg = t, n.setFlash("Adding publication image...", !1), submitForm("layout", e)
				};
			this.fileUploadError = function(e) {
				n.setFlash(e, !0)
			}, this.fileUploadFinished = function() {
				n.setFlash("Publication Image updated...", !1), reloadPage()
			};
			var r = function() {
				var e = {
						page: "layout",
						rows: [
							[{
								text: "Choose Publication Image:"
							}],
							[{
								image: "image",
								size: "47",
								klass: "edit_group_thumbnail"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Upload Image",
								callback: i
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					t = {
						this_id: "add_badge",
						pages: [e],
						body_style: "add_badge_div",
						row_style: "new_exhibit_row",
						title: "Add Publication Image"
					};
				n = new GeneralDialog(t), n.center()
			};
			r()
		}
	}),
	BorderDialog = Class.create();
BorderDialog.prototype = {
	initialize: function() {
		var e = this;
		this.myPanel = new YAHOO.widget.Dialog("edit_border_dlg", {
			width: "380px",
			constraintoviewport: !0,
			underlay: "shadow",
			close: !0,
			visible: !0,
			modal: !0,
			draggable: !0
		}), this.myPanel.setHeader("Edit Border");
		var t = [{
			text: "Submit",
			handler: this.handleSubmit
		}, {
			text: "Cancel",
			handler: this.handleCancel
		}];
		this.myPanel.cfg.queueProperty("buttons", t);
		var n = new Element("div", {
				id: "border_outer_container"
			}),
			i = new Element("div", {
				id: "border_dlg_instructions"
			}).update('First, drag the mouse over some sections and then click "Add Border" or "Remove Border".');
		i.addClassName("instructions"), n.appendChild(i);
		var r = new Element("div", {
			id: "border_container"
		});
		n.appendChild(r);
		var o = $$(".selected_page .exhibit_outline_text"),
			a = o[0].innerHTML,
			s = new Element("span").update("&nbsp;&nbsp;" + a);
		s.addClassName("exhibit_outline_text");
		var l = s.wrap("div");
		l.addClassName("unselected_page"), l.addClassName("selected_page"), r.appendChild(l);
		var c = $$(".selected_page .outline_element");
		c.each(function(e) {
			var t = e.up(),
				n = e.previous(),
				i = e.next(),
				o = "border_dlg_element";
			t.hasClassName("outline_section_with_border") && (o += " border_sides", null === n && (o += " border_top"), null === i && (o += " border_bottom"));
			var a = e.innerHTML,
				s = new Element("div", {
					id: "border_" + e.id
				}).update(a);
			s.addClassName(o);
			var l = s.wrap("div", {
				id: "rubberband_" + e.id
			});
			l.addClassName("rubberband_dlg_element"), r.appendChild(l)
		}, this), this.center = function(e, t) {
			var n = $("edit_border_dlg"),
				i = parseInt(n.getStyle("width"), 10),
				r = parseInt(n.getStyle("height"), 10),
				o = YAHOO.util.Dom.getViewportWidth(),
				a = YAHOO.util.Dom.getViewportHeight(),
				s = (o - i) / 2,
				l = (a - r) / 2;
			s += e, l += t, 0 > s && (s = 0), 0 > l && (l = 0);
			var c = n.up();
			c.setStyle({
				left: s + "px",
				top: l + "px"
			}), window.scroll(e, t)
		}, this.myPanel.setBody(n);
		var u = YAHOO.util.Dom.getDocumentScrollLeft(),
			d = YAHOO.util.Dom.getDocumentScrollTop();
		this.myPanel.render(document.body), this.center(u, d), c = $$("#border_container .outline_right_controls"), c.each(function(e) {
			e.remove()
		}, this), c = $$("#border_container .count"), c.each(function(e) {
			var t = e.down().innerHTML;
			e.update(t), e.addClassName("count")
		}, this), c = $$("#border_container [onclick]"), c.each(function(e) {
			e.removeAttribute("onclick")
		}, this);
		var h = $("border_container");
		h.observe("mousedown", this.mouseDown.bind(this)), h.observe("mousemove", this.mouseMove.bind(this)), h.observe("mouseup", this.mouseUp.bind(this)), this.addBorder = function() {
			var t = $$(".rubberband_dlg_element");
			t.each(function(e) {
				e.hasClassName("selection_border_sides") && (e.down().addClassName("border_sides"), e.hasClassName("selection_border_top") ? e.down().addClassName("border_top") : e.down().removeClassName("border_top"), e.hasClassName("selection_border_bottom") ? e.down().addClassName("border_bottom") : e.down().removeClassName("border_bottom"))
			}), e.adjustOverlappingBorder(), e.removeRubberband(), e.selectionMenu.cancel()
		}, this.removeBorder = function() {
			var t = $$(".rubberband_dlg_element");
			t.each(function(e) {
				e.hasClassName("selection_border_sides") && (e.down().removeClassName("border_top"), e.down().removeClassName("border_sides"), e.down().removeClassName("border_bottom"))
			}), e.adjustOverlappingBorder(), e.removeRubberband(), e.selectionMenu.cancel()
		}
	},
	isDragging: !1,
	anchor: null,
	focus: null,
	redrawRubberband: function(e) {
		var t = e > this.anchor ? this.anchor : e,
			n = e < this.anchor ? this.anchor : e;
		this.removeRubberband();
		var i = $$(".rubberband_dlg_element");
		i.each(function(e) {
			var i = parseInt(e.down(".count").innerHTML);
			i === t && e.addClassName("selection_border_top"), i >= t && n >= i && e.addClassName("selection_border_sides"), i === n && e.addClassName("selection_border_bottom")
		}), this.focus = e
	},
	removeRubberband: function() {
		$$(".selection_border_top").each(function(e) {
			e.removeClassName("selection_border_top")
		}), $$(".selection_border_sides").each(function(e) {
			e.removeClassName("selection_border_sides")
		}), $$(".selection_border_bottom").each(function(e) {
			e.removeClassName("selection_border_bottom")
		})
	},
	getCurrentElement: function(e) {
		var t = this.getTarget(e),
			n = t.hasClassName("rubberband_dlg_element") ? t : t.up(".rubberband_dlg_element");
		return void 0 === n ? -1 : parseInt(n.down(".count").innerHTML)
	},
	getTarget: function(e) {
		var t = $(e.originalTarget);
		return void 0 === t && (t = $(e.srcElement)), t
	},
	mouseDown: function(e) {
		this.isDragging = !0, this.anchor = this.getCurrentElement(e), this.redrawRubberband(this.anchor), Event.stop(e)
	},
	mouseMove: function(e) {
		if (this.isDragging) {
			var t = this.getCurrentElement(e);
			t !== this.focus && t >= 0 && this.redrawRubberband(t)
		}
		Event.stop(e)
	},
	selectionMenu: null,
	mouseUp: function(e) {
		if (this.isDragging) {
			this.isDragging = !1;
			var t = {
					page: "layout",
					rows: [
						[{
							button: "Add Border",
							callback: this.addBorder
						}, {
							button: "Remove Border",
							callback: this.removeBorder
						}]
					]
				},
				n = {
					this_id: "border_selection_dlg",
					pages: [t],
					body_style: "border_selection_dlg",
					row_style: "forum_reply_row",
					title: "Add Border"
				};
			this.selectionMenu = new GeneralDialog(n), this.selectionMenu.changePage("layout", null), this.selectionMenu.center()
		}
		Event.stop(e)
	},
	userCanceled: function(e) {
		e.removeRubberband()
	},
	adjustOverlappingBorder: function() {
		var e = $$(".selection_border_top"),
			t = $$(".selection_border_bottom");
		if (1 === e.length && 1 === t.length) {
			var n = e[0].previous();
			n && n.down().hasClassName("border_sides") && n.down().addClassName("border_bottom");
			var i = t[0].next();
			i && i.down().hasClassName("border_sides") && i.down().addClassName("border_top")
		}
	},
	handleCancel: function() {
		this.cancel(), this.destroy()
	},
	handleSubmit: function() {
		var e = $$(".border_dlg_element"),
			t = "";
		e.each(function(e) {
			t += e.hasClassName("border_top") ? "start_border," : e.hasClassName("border_sides") ? "continue_border," : "no_border,"
		});
		var n = $$(".outline_tree_element_selected");
		if (n.length > 0) {
			var i = n[0].id;
			i = i.substring(i.lastIndexOf("_") + 1), serverAction({
				action: {
					actions: ["/builder/modify_border", "/builder/redraw_exhibit_page"],
					els: ["exhibit_builder_outline_content", "exhibit_page"],
					params: {
						borders: t,
						element_id: i
					}
				}
			})
		}
		this.cancel(), this.destroy()
	}
}; //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var BrowseGroupsDlg = Class.create({
		initialize: function(e, t) {
			this.class_type = "BrowseGroupsDlg";
			var n = null,
				i = new CreateListOfObjects(t, null, "all_groups", e),
				r = function() {
					var e = i.getSelection().value;
					e.length > 0 ? (n.setFlash("Fetching group. Please wait...", !1), gotoPage("/groups/" + e)) : n.setFlash("Please click on one of the groups to select it then try again.", !0)
				},
				o = {
					page: "layout",
					rows: [
						[{
							text: "Select a group to get more information.",
							klass: "new_exhibit_instructions"
						}],
						[{
							custom: i
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Go To Group",
							callback: r,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				a = {
					this_id: "group_list_dlg",
					pages: [o],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Browse Groups"
				};
			n = new GeneralDialog(a), n.center(), i.populate(n)
		}
	}),
	newGroupDlg = null,
	CreateGroupWizardDlg = Class.create({
		initialize: function(e, t, n, i, r, o, a, s, l, c, u, d, h, p, f) {
			this.class_type = "CreateGroupWizardDlg";
			var g = this,
				m = null,
				v = function(e, i) {
					var r = i.curr_page,
						o = i.arg0;
					if (m.setFlash("", !1), "group_properties" === r) {
						var a = m.getAllData();
						if (0 === a["group[name]"].strip().length) return m.setFlash("Please enter a name for this group before continuing.", !0), !1;
						if ("classroom" === a["group[group_type]"]) {
							if (0 === a["group[university]"].strip().length) return m.setFlash("Please enter a university for this classroom group before continuing.", !0), !1;
							if (0 === a["group[course_name]"].strip().length) return m.setFlash("Please enter a course name for this classroom group before continuing.", !0), !1;
							if (0 === a["group[course_mnemonic]"].strip().length) return m.setFlash("Please enter a course mnemonic for this classroom group before continuing.", !0), !1
						}
						a["group[owner]"] = t, m.setFlash("Verifying title. Please wait...", !1);
						var s = function() {
							m.setFlash("", !1), m.changePage(o, null)
						};
						return serverRequest({
							url: n,
							params: {
								name: a["group[name]"].strip()
							},
							onSuccess: s
						}), !1
					}
					var l = null;
					switch (o) {
						case "group_properties":
							l = "group_name";
							break;
						case "invite_members":
							l = "emails"
					}
					return m.changePage(o, l), !1
				},
				_ = function(e, t) {
					e.each(t ? function(e) {
						e.removeClassName("hidden")
					} : function(e) {
						e.addClassName("hidden")
					})
				},
				b = function(e, t) {
					if ("classroom" === t) {
						var n = $("group_course_name");
						if (0 === n.value.length) {
							var i = $("group_name"),
								r = i.value;
							n.value = r
						}
					}
					var o = $$(".community_only");
					_(o, "community" === t), o = $$(".classroom_only"), _(o, "classroom" === t), o = $$(".publication_only"), _(o, "peer-reviewed" === t)
				},
				y = function(e, t) {
					newGroupDlg = g;
					var n = t.arg0;
					m.setFlash("Verifying group creation...", !1);
					var i = m.getAllData();
					$("emails").value = i.emails_entry, $("usernames").value = i.usernames_entry, submitForm("group_properties", n)
				};
			this.fileUploadError = function(e) {
				m.setFlash(e, !0)
			}, this.fileUploadFinished = function(e) {
				m.setFlash("Group created...", !1), gotoPage(r + e)
			};
			var w = function() {
				var n = {
						page: "group_properties",
						rows: [
							[{
								text: "Creating New Group",
								klass: "new_exhibit_title"
							}, {
								hidden: "group[owner]",
								value: t
							}, {
								hidden: "emails",
								value: ""
							}, {
								hidden: "usernames",
								value: ""
							}],
							[{
								text: "Step 1: Group Information",
								klass: "new_exhibit_label"
							}],
							[{
								text: "Title:",
								klass: "groups_label"
							}, {
								input: "group[name]",
								klass: "new_exhibit_input_long"
							}],
							[{
								text: "Description:",
								klass: ""
							}],
							[{
								textarea: "group[description]",
								klass: "description groups_textarea"
							}],
							[{
								picture: f,
								klass: "new_group_membership_pic"
							}, {
								text: "Show Membership:",
								klass: "groups_label"
							}, {
								select: "group[show_membership]",
								options: [{
									text: "To All",
									value: "Yes"
								}, {
									text: "To Admins",
									value: "No"
								}]
							}, {
								text: "Choose whether visitors to your group will be able to see the membership list displayed at the upper-right of your group page.",
								klass: "new_group_membership_explanation"
							}],
							[{
								rowClass: "clear_both"
							}, {
								text: "Type:",
								klass: "new_group_type_label"
							}, {
								select: "group[group_type]",
								klass: "new_group_type",
								options: o,
								value: l,
								callback: b
							}, {
								text: "The " + c + " default group type, useful for sharing objects and forum threads.",
								klass: "new_group_membership_explanation community_only"
							}, {
								text: "Groups for using " + c + " in the classroom.",
								klass: "new_group_membership_explanation hidden classroom_only"
							}, {
								text: "&nbsp;",
								klass: "new_group_membership_explanation hidden publication_only"
							}],
							[{
								rowClass: "clear_both"
							}, {
								text: "Thumbnail:",
								klass: "groups_label hidden xcommunity_only"
							}, {
								image: "image",
								size: "37",
								removeButton: "Remove Thumbnail",
								klass: "hidden xcommunity_only"
							}, {
								text: "Publication groups work closely with the " + c + " staff to vet their content. If you select this option a notification will be sent to the " + c + " staff, and someone will be in contact with you soon.",
								klass: "new_group_membership_explanation publication_only hidden"
							}, {
								text: "Course Mnemonic:",
								klass: "groups_label classroom_only hidden"
							}, {
								text: "For easy browsing, use this field to share the course number or mnemonic associated with this class (e.g. ENNC 448).",
								klass: "groups_explanation classroom_only hidden"
							}, {
								input: "group[course_mnemonic]",
								klass: "new_exhibit_input_long classroom_only hidden"
							}],
							[{
								text: "Course Name (if different from Group Title):",
								klass: "classroom_only hidden"
							}, {
								input: "group[course_name]",
								klass: "new_exhibit_input_long classroom_only hidden"
							}],
							[{
								text: "University:",
								klass: "groups_label classroom_only hidden"
							}, {
								autocomplete: "group[university]",
								klass: "new_exhibit_autocomplete classroom_only hidden",
								url: e
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Next",
								arg0: "invite_members",
								callback: v
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					r = {
						page: "invite_members",
						rows: [
							[{
								text: "Creating New Group",
								klass: "new_exhibit_title"
							}],
							[{
								text: "Step 2: Invite people to your group.",
								klass: "new_exhibit_label"
							}],
							[{
								text: "There are two ways to invite people to join your group in " + c + ": email address or username. If you know the participants' usernames, list them in the blank below, one per line.",
								klass: "invite_users_instructions"
							}],
							[{
								text: "By Username:",
								klass: "invite_users_label"
							}, {
								textarea: "usernames_entry",
								klass: "groups_textarea"
							}],
							[{
								text: "Don't know any usernames? Add email addresses of users you want to invite in the blank below, one per line.",
								klass: "invite_users_instructions"
							}],
							[{
								text: "By Email Address:",
								klass: "invite_users_label"
							}, {
								textarea: "emails_entry",
								klass: "groups_textarea"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Create Group",
								arg0: i,
								callback: y
							}, {
								button: "Previous",
								arg0: "group_properties",
								callback: v
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					a = [n, r],
					s = {
						this_id: "invite_users_dlg",
						pages: a,
						body_style: "invite_users_div",
						row_style: "new_exhibit_row",
						title: "New Group Wizard"
					};
				m = new GeneralDialog(s), v(null, {
					curr_page: "",
					arg0: "group_properties",
					dlg: m
				}), m.initTextAreas({
					onlyClass: "description",
					toolbarGroups: ["fontstyle", "link"],
					linkDlgHandler: new LinkDlgHandler([u], d)
				}), b("group[group_type]", l), m.center()
			};
			w()
		}
	}),
	ForumReplyDlg = Class.create({
		initialize: function(e) {
			this.class_type = "ForumReplyDlg";
			var t = e.topic_id,
				n = e.group_id;
			n && (t = -1);
			var i = e.cluster_id,
				r = e.group_name,
				o = e.cluster_label,
				a = e.cluster_name,
				s = e.thread_id,
				l = e.submit_url,
				c = e.can_delete,
				u = e.populate_exhibit_url,
				d = e.populate_collex_obj_url,
				h = e.populate_topics_url,
				p = e.progress_img,
				f = e.ajax_div,
				g = e.logged_in,
				m = e.redirect,
				v = e.addTopicToLoginRedirect,
				_ = 5,
				b = e.comment_id,
				y = null,
				w = null,
				x = null,
				E = null,
				k = null,
				C = null,
				T = null,
				S = null;
			if (void 0 !== b && (y = e.title, w = e.obj_type, x = e.reply, E = e.nines_obj_list, k = e.exhibit_list, C = e.inet_title, T = e.inet_thumbnail, S = e.inet_url), e.license && (_ = e.license), !g) {
				var O = new SignInDlg;
				O.setInitialMessage("You must be logged in to create a comment.");
				var D = "script=ForumReplyDlg";
				return v && (D += "_" + t), O.setRedirectPageToCurrentWithParam(D), void O.show("sign_in")
			}
			var A = this,
				N = function(e) {
					var t = function(t) {
						var n = [];
						e.setFlash("", !1);
						try {
							t.responseText.length > 0 && (n = t.responseText.evalJSON(!0))
						} catch (i) {
							new MessageBoxDlg("Error", i)
						}
						var r = $$(".discussion_topic_select"),
							o = r[0];
						o.update(""), n = n.sortBy(function(e) {
							return e.text
						}), n.each(function(e) {
							o.appendChild(new Element("option", {
								value: e.value
							}).update(e.text))
						}), $("topic_id").writeAttribute("value", n[0].value)
					};
					serverRequest({
						url: h,
						onSuccess: t
					})
				},
				I = function() {
					var e = $$(".attach_item")[0];
					e.addClassName("hidden"), setTimeout(function() {
						var e = $$(".attach");
						e.each(function(e) {
							e.removeClassName("hidden")
						})
					}, 50)
				},
				j = "",
				F = "";
			this.attachItem = function(e, t) {
				I(), t.arg0 = "mycollection", j = "forum_reply_dlg_btn0", F = t.arg0;
				var n = A.switch_page.bind($(j));
				n(e, t)
			}, this.switch_page = function(e, t) {
				if ("" !== j) {
					$(j).removeClassName("button_tab_selected");
					var n = $$("." + F);
					n.each(function(e) {
						e.addClassName("hidden")
					})
				}
				j = this.id, F = t.arg0, $(this.id).addClassName("button_tab_selected");
				var i = $$("." + t.arg0);
				i.each(function(e) {
					e.removeClassName("hidden")
				})
			}, this.sendWithAjax = function(e, r) {
				var o = r.arg0,
					a = r.dlg;
				a.setFlash("Adding Comment...", !1);
				var l = a.getAllData();
				if (l.thread_id = s, -1 !== t && (l.topic_id = t), n && (l.group_id = n), i && (l.cluster_id = i), l.comment_id = b, l.obj_type = F, l.can_delete = c, f) {
					var u = function() {
						a.cancel()
					};
					serverAction({
						action: {
							actions: o,
							els: f,
							params: l,
							onSuccess: u,
							dlg: a
						}
					})
				} else {
					var d = function() {
						a.cancel(), gotoPage(m)
					};
					serverRequest({
						url: o,
						params: l,
						onSuccess: d,
						dlg: a
					})
				}
			};
			var L = new CreateListOfObjects(d, E, "nines_obj_list", p),
				P = new CreateListOfObjects(u, k, "exhibit_list", p),
				H = new ForumLicenseDisplay({
					populateLicenses: "/exhibits/get_licenses?non_sharing=false",
					currentLicense: _,
					id: "license_list"
				}),
				M = {
					page: "layout",
					rows: [
						[{
							custom: H,
							klass: "forum_reply_license title hidden"
						}, {
							text: "Title",
							klass: "forum_reply_label title hidden"
						}],
						[{
							input: "title",
							value: y,
							klass: "forum_reply_input title hidden"
						}],
						[{
							text: "Group: " + r,
							klass: "group hidden"
						}],
						[{
							text: o + ": " + a,
							klass: "cluster hidden"
						}],
						[{
							text: "Topic:",
							klass: "forum_web_label group hidden"
						}, {
							select: "topic_id",
							klass: "discussion_topic_select group hidden",
							options: [{
								value: -1,
								text: "Loading discussion topics. Please Wait..."
							}]
						}],
						[{
							textarea: "reply",
							klass: "clear_both",
							value: x ? $(x).innerHTML : void 0
						}],
						[{
							link: "Attach an Item...",
							klass: "attach_item nav_link",
							arg0: "",
							callback: this.attachItem
						}],
						[{
							button: "My Collection",
							arg0: "mycollection",
							klass: "button_tab attach hidden",
							callback: this.switch_page
						}, {
							button: "NINES Exhibit",
							klass: "button_tab attach hidden",
							arg0: "exhibit",
							callback: this.switch_page
						}, {
							button: "Web Item",
							klass: "button_tab attach hidden",
							arg0: "weblink",
							callback: this.switch_page
						}],
						[{
							text: "Sort objects by:",
							klass: "forum_reply_label mycollection hidden"
						}, {
							select: "sort_by",
							callback: L.sortby,
							klass: "link_dlg_select mycollection hidden",
							value: "date_collected",
							options: [{
								text: "Date Collected",
								value: "date_collected"
							}, {
								text: "Title",
								value: "title"
							}, {
								text: "Author",
								value: "author"
							}]
						}, {
							text: "and",
							klass: "link_dlg_label_and mycollection hidden"
						}, {
							inputFilter: "filterObjects",
							klass: "mycollection hidden",
							prompt: "type to filter objects",
							callback: L.filter
						}],
						[{
							custom: L,
							klass: "mycollection hidden"
						}, {
							custom: P,
							klass: "exhibit hidden"
						}],
						[{
							text: "Caption:",
							klass: "forum_web_label weblink hidden"
						}, {
							input: "inet_title",
							value: C,
							klass: "forum_web_input weblink hidden"
						}],
						[{
							text: "URL:",
							klass: "forum_web_label weblink hidden"
						}, {
							input: "inet_url",
							value: S,
							klass: "forum_web_input weblink hidden"
						}],
						[{
							text: "Thumbnail for Item:",
							klass: "forum_web_label weblink hidden"
						}, {
							input: "inet_thumbnail",
							value: T,
							klass: "forum_web_input weblink hidden"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Post",
							arg0: l,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				W = null;
			(t || b && y) && (W = "title");
			var R = t ? "New Post" : s ? "Reply" : "Edit Comment",
				z = {
					this_id: "forum_reply_dlg",
					pages: [M],
					body_style: "forum_reply_dlg",
					row_style: "forum_reply_row",
					title: R,
					focus: W
				},
				U = new GeneralDialog(z);
			(t || b && y) && $$(".title").each(function(e) {
				e.removeClassName("hidden")
			}), n && $$(".group").each(function(e) {
				e.removeClassName("hidden")
			}), i && $$(".cluster").each(function(e) {
				e.removeClassName("hidden")
			}), U.initTextAreas({
				toolbarGroups: ["fontstyle", "link"],
				linkDlgHandler: new LinkDlgHandler([d], p)
			}), H.populate(U), L.populate(U, !1, "forum"), P.populate(U, !1, "forum"), U.center(), n && N(U), w && 1 !== w && YAHOO.util.Event.onAvailable("reply_container", function() {
				I();
				var e = ["mycollection", "exhibit", "weblink"],
					t = {
						arg0: e[w - 2]
					};
				j = "forum_reply_dlg_btn" + (w - 2), F = t.arg0;
				var n = A.switch_page.bind($(j));
				n(null, t)
			}, this)
		}
	}),
	editProfileDlg = null,
	EditProfileDialog = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "EditProfileDialog";
			var r = this,
				o = null;
			this.sendWithAjax = function(e, n) {
				o = n.dlg, o.setFlash("Updating User Profile...", !1), editProfileDlg = r, submitForm("layout", t + "_upload")
			}, this.fileUploadError = function(e) {
				o.setFlash(e, !0)
			}, this.fileUploadFinished = function() {
				var n = o.getAllData(),
					i = function() {
						o.cancel()
					};
				serverAction({
					action: {
						actions: t,
						els: e,
						params: n,
						onSuccess: i
					}
				})
			};
			var a = {
					page: "layout",
					rows: [
						[{
							text: "User Name:",
							klass: "edit_facet_label"
						}, {
							text: n.username,
							klass: "new_exhibit_label"
						}],
						[{
							text: "Full Name:",
							klass: "edit_facet_label"
						}, {
							input: "fullname",
							value: n.fullname,
							klass: "edit_facet_input"
						}],
						[{
							text: "Email:",
							klass: "edit_facet_label"
						}, {
							input: "account_email",
							value: n.email,
							klass: "edit_facet_input"
						}],
						[{
							text: "Hide email:",
							klass: "edit_facet_label"
						}, {
							select: "hide_email",
							value: n.hide_email,
							options: [{
								value: "false",
								text: "false"
							}, {
								value: "true",
								text: "true"
							}],
							klass: "edit_facet_input"
						}],
						[{
							text: "Institution:",
							klass: "edit_facet_label"
						}, {
							input: "institution",
							value: n.institution,
							klass: "edit_facet_input"
						}],
						[{
							text: "Link:",
							klass: "edit_facet_label"
						}, {
							input: "link",
							value: n.link,
							klass: "edit_facet_input"
						}],
						[{
							text: "(leave blank if not changing your password)",
							klass: "login_instructions"
						}],
						[{
							text: "Password:",
							klass: "edit_facet_label"
						}, {
							password: "account_password",
							klass: "edit_facet_input"
						}],
						[{
							text: "Re-type password:",
							klass: "edit_facet_label"
						}, {
							password: "account_password2",
							klass: "edit_facet_input"
						}],
						[{
							text: "About me:",
							klass: "edit_facet_label"
						}, {
							textarea: "aboutme",
							value: n.about_me,
							klass: "edit_profile_textarea"
						}],
						[{
							text: "Thumbnail:",
							klass: "edit_facet_label"
						}, {
							image: "image",
							klass: "edit_profile_image",
							size: 35,
							value: i,
							removeButton: "Remove Thumbnail"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				s = {
					this_id: "edit_profile_dlg",
					pages: [a],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Edit Profile",
					focus: "fullname"
				};
			o = new GeneralDialog(s), o.center()
		}
	}),
	CCLicenseDlg = Class.create({
		initialize: function(e, t, n, i, r, o) {
			this.class_type = "CCLicenseDlg";
			var a = Class.create({
					initialize: function(e, t, n) {
						var i = "license_item_selected",
							r = $(n);
						r || (r = new Element("div", {
							id: n
						})), r.addClassName("licensedlg_list"), this.getSelection = function() {
							var e = r.down("." + i),
								t = e ? e.id.substring(e.id.indexOf("_") + 1) : "";
							return {
								field: n,
								value: t
							}
						};
						var o = function(e, r, o) {
								var a = "license_" + e,
									s = new Element("tr", {
										id: a
									});
								e === t && s.addClassName(i);
								var l = new Element("td").update(r),
									c = new Element("td").update(o);
								s.appendChild(l), s.appendChild(c);
								var u = function() {
									$(n).select("." + i).each(function(e) {
										e.removeClassName(i)
									}), $(this.id).addClassName(i)
								};
								return YAHOO.util.Event.addListener(a, "click", u), s
							},
							a = function() {
								var t = new Element("table", {
									cellspacing: "0"
								});
								t.addClassName("input_dlg_list input_dlg_license_list");
								var n = new Element("tbody");
								t.appendChild(n), e.each(function(e) {
									n.appendChild(o(e.id, e.icon, e.text))
								}), r.appendChild(t)
							};
						this.getMarkup = function() {
							return r
						}, a()
					}
				}),
				s = new a(e, t, o),
				l = {
					page: "layout",
					rows: [
						[{
							text: r,
							klass: "input_dlg_license_list_header"
						}],
						[{
							custom: s,
							klass: ""
						}],
						[{
							text: "Licenses provided courtesy of Creative Commons&nbsp;&nbsp;",
							klass: ""
						}, {
							link: "[ Learn more about CC licenses ]",
							klass: "ext_link",
							arg0: "http://creativecommons.org/about/licenses",
							callback: openInNewWindow
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Save",
							callback: n,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				c = {
					this_id: "cc_license_dlg",
					pages: [l],
					body_style: "cc_license_dlg",
					row_style: "forum_reply_row",
					title: i
				},
				u = new GeneralDialog(c);
			u.center()
		}
	}),
	ForumLicenseDisplay = Class.create({
		initialize: function(e) {
			var t = null,
				n = e.populateLicenses,
				i = e.currentLicense,
				r = function() {
					var e = $("forum_dlg_chosen_license_img");
					e.update(t[i - 1].icon), e = $("forum_dlg_chosen_license_abbrev"), e.update(t[i - 1].abbrev)
				},
				o = function(e, t) {
					var n = t.dlg.getAllData();
					i = parseInt(n.license_list2), r(), t.dlg.cancel()
				},
				a = function() {
					new CCLicenseDlg(t, i, o, "Select License", "Share this post under the following license:", "license_list2")
				},
				s = e.id,
				l = $(s);
			l || (l = new Element("div", {
				id: s
			})), l.addClassName("licensedisplay"), l.appendChild(new Element("div", {
				id: "forum_dlg_chosen_license_img"
			})), l.appendChild(new Element("span", {
				id: "forum_dlg_text1"
			}).update("This post will be protected by an")), l.appendChild(new Element("span", {
				id: "forum_dlg_chosen_license_abbrev"
			}).update("(Loading...")), l.appendChild(new Element("span", {
				id: "forum_dlg_text2"
			}).update('license. Click <a id="forum_dlg_changedlg" href="#" onclick="return false;">here</a> to change.')), YAHOO.util.Event.addListener("forum_dlg_changedlg", "click", a), this.getSelection = function() {
				return {
					field: s,
					value: i
				}
			}, this.populate = function(e) {
				e.setFlash("Getting objects...", !1);
				var i = function(n) {
					e.setFlash("", !1);
					try {
						n.responseText.length > 0 && (t = n.responseText.evalJSON(!0), r())
					} catch (i) {
						new MessageBoxDlg("Error", i)
					}
				};
				serverRequest({
					url: n,
					onSuccess: i
				})
			}, this.getMarkup = function() {
				return l
			}
		}
	}),
	createNewExhibitDlg = null,
	CreateNewExhibitWizard = Class.create({
		initialize: function(e) {
			this.class_type = "CreateNewExhibitWizard";
			var t = e.progress_img,
				n = e.url_get_objects,
				i = e.populate_collex_obj_url,
				r = e.group_id,
				o = e.cluster_id,
				a = e.import_url,
				s = e.exhibit_label ? e.exhibit_label : "Exhibit",
				l = this,
				c = new ObjectSelector(t, n, -1, s),
				u = null;
			this.changeView = function(e, t) {
				var n = t.curr_page,
					i = t.arg0,
					r = t.dlg;
				if (r.setFlash("", !1), "choose_title" === n) {
					var o = r.getAllData();
					if (0 === o.exhibit_title.strip().length) return r.setFlash("Please enter a name for this " + s.toLowerCase() + " before continuing.", !0), !1;
					r.setFlash("Verifying title. Please wait...", !1);
					var a = function(e) {
						r.setFlash("", !1), $("exhibit_url").value = e.responseText, r.changePage(i, null)
					};
					return serverRequest({
						url: "/builder/verify_title",
						params: {
							title: o.exhibit_title.strip()
						},
						onSuccess: a
					}), !1
				}
				var l = null;
				switch (i) {
					case "choose_title":
						l = "exhibit_title";
						break;
					case "choose_other_options":
						l = "exhibit_thumbnail";
						break;
					case "choose_palette":
				}
				return r.changePage(i, l), !1
			}, this.fileUploadError = function(e) {
				u.changePage("choose_title", "document"), u.setFlash(e, !0)
			}, this.fileUploadFinished = function(e) {
				u.setFlash("", !1), gotoPage(e)
			}, this.sendWithAjax = function(e, t) {
				createNewExhibitDlg = l;
				var n = t.arg0;
				u = t.dlg, u.setFlash("Verifying " + s.toLowerCase() + " parameters...", !1);
				var i = u.getAllData();
				i.objects = c.getSelectedObjects().join("	"), r && (i.group_id = r), o && (i.cluster_id = o);
				var d = function(e) {
					u.setFlash("Creating " + s + "...", !1);
					var t = $("exhibit_id");
					t.value = e.responseText, submitForm("choose_title", a)
				};
				serverRequest({
					url: n,
					params: i,
					onSuccess: d
				})
			}, this.show = function() {
				var e = '<span class="tooltip"><img src="/assets/help_thumb.sm.gif" alt="help" /><span class="group_help_tooltip">This is the title that will show up in the ' + s.toLowerCase() + " list once you decide to share it with other users. You can edit this later by selecting Edit " + s + " Profile at the top of your " + s.toLowerCase() + " editing page.</span></span>",
					n = {
						page: "choose_title",
						rows: [
							[{
								text: "Creating New " + s,
								klass: "new_exhibit_title"
							}],
							[{
								text: "Step 1: Please choose a title for your new " + s.toLowerCase() + ". " + e,
								klass: "new_exhibit_label"
							}],
							[{
								input: "exhibit_title",
								klass: "new_exhibit_input_long"
							}],
							[{
								text: "Already have a working document?",
								klass: "new_exhibit_title"
							}],
							[{
								text: "Try out the new uploader for Microsoft Word (.docx) files.",
								klass: "new_exhibit_label"
							}],
							[{
								file: "document",
								size: 40
							}, {
								hidden: "exhibit_id"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Next",
								arg0: "choose_palette",
								callback: this.changeView,
								isDefault: !0
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					r = {
						page: "choose_palette",
						rows: [
							[{
								text: "Creating New " + s,
								klass: "new_exhibit_title"
							}],
							[{
								text: "Step 2: Add objects to your " + s.toLowerCase() + ".  (optional)",
								klass: "new_exhibit_label"
							}],
							[{
								text: "Choose resources from your collected objects to add to this new " + s.toLowerCase() + ".",
								klass: "new_exhibit_instructions"
							}],
							[{
								custom: c
							}],
							[{
								text: "Any object you have collected is available for use in your " + s.toLowerCase() + ". You may add or remove objects from this list at any time.",
								klass: "new_exhibit_instructions"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Next",
								arg0: "choose_other_options",
								callback: this.changeView,
								isDefault: !0
							}, {
								button: "Previous",
								arg0: "choose_title",
								callback: this.changeView
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					o = window.location;
				o = "http://" + o.host;
				var a = {
						page: "choose_other_options",
						rows: [
							[{
								text: "Creating New " + s,
								klass: "new_exhibit_title"
							}],
							[{
								text: "Step 3: Additional options",
								klass: "new_exhibit_label"
							}],
							[{
								text: "Choose a url for your " + s.toLowerCase() + ":",
								klass: "new_exhibit_label"
							}],
							[{
								text: o + "/exhibits/&nbsp;",
								klass: "new_exhibit_label"
							}, {
								input: "exhibit_url",
								klass: "new_exhibit_input"
							}],
							[{
								text: "Paste a link to a thumbnail image:",
								klass: "new_exhibit_label"
							}],
							[{
								input: "exhibit_thumbnail",
								klass: "new_exhibit_input_long"
							}],
							[{
								link: "[Choose thumbnail from collected objects]",
								klass: "nav_link",
								callback: this.changeView,
								arg0: "choose_thumbnail"
							}],
							[{
								text: "The thumbnail image will appear next to your " + s.toLowerCase() + " in the exhibit list once you decide to share it with other users. Please use an image that is small, so that the pages doesn't take too long to load. These items are optional and can be entered at any time.",
								klass: "new_exhibit_instructions"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Create " + s,
								arg0: "/builder",
								callback: this.sendWithAjax,
								isDefault: !0
							}, {
								button: "Previous",
								arg0: "choose_palette",
								callback: this.changeView
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					u = "",
					d = function(e) {
						var t = $("exhibit_thumbnail"),
							n = $(e + "_img");
						u = t.value, t.value = n.src
					},
					h = new CreateListOfObjects(i, null, "nines_object", t, d),
					p = function(e, t) {
						h.clearSelection();
						var n = $("exhibit_thumbnail");
						n.value = u, l.changeView(e, t)
					},
					f = {
						page: "choose_thumbnail",
						rows: [
							[{
								text: "Creating New " + s,
								klass: "new_exhibit_title"
							}],
							[{
								text: "Sort objects by:",
								klass: "forum_reply_label"
							}, {
								select: "sort_by",
								callback: h.sortby,
								klass: "link_dlg_select",
								value: "date_collected",
								options: [{
									text: "Date Collected",
									value: "date_collected"
								}, {
									text: "Title",
									value: "title"
								}, {
									text: "Author",
									value: "author"
								}]
							}, {
								text: "and",
								klass: "link_dlg_label_and"
							}, {
								inputFilter: "filterObjects",
								klass: "",
								prompt: "type to filter objects",
								callback: h.filter
							}],
							[{
								custom: h,
								klass: "new_exhibit_label"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Ok",
								arg0: "choose_other_options",
								callback: this.changeView,
								isDefault: !0
							}, {
								button: "Cancel",
								arg0: "choose_other_options",
								callback: p
							}]
						]
					},
					g = [n, r, a, f],
					m = {
						this_id: "new_exhibit_wizard",
						pages: g,
						body_style: "new_exhibit_div",
						row_style: "new_exhibit_row",
						title: "New " + s + " Wizard"
					},
					v = new GeneralDialog(m);
				this.changeView(null, {
					curr_page: "",
					arg0: "choose_title",
					dlg: v
				}), v.center(), c.populate(v), h.populate(v, !1, "thumb")
			}
		}
	});
document.observe("dom:loaded", function() {
	initializeElementEditing()
});
var unhoverlist = $H({}),
	ObjectSelector = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "ObjectSelector", null == i && (i = "Exhibit");
			var r = new CreateListOfObjects(t + "?chosen=false&exhibit_id=" + n, null, "unchosen_objects", e),
				o = new CreateListOfObjects(t + "?chosen=true&exhibit_id=" + n, null, "chosen_objects", e),
				a = null,
				s = [],
				l = function() {
					var e = r.popSelection();
					e && o.add(e)
				},
				c = function() {
					var e = o.popSelection();
					e && r.add(e)
				};
			this.populate = function(e) {
				e.setFlash("Getting objects...", !1), r.populate(e, !1, "new"), o.populate(e, !1, "new"), s.each(function(e) {
					e.el.observe("click", e.action)
				})
			}, this.getMarkup = function() {
				if (null !== a) return a;
				a = new Element("div"), a.addClassName("object_selector");
				var e = new Element("div").update("Available Objects:");
				e.addClassName("select_objects_label select_objects_label_left"), a.appendChild(e);
				var t = new Element("div").update("Objects in " + i + ":");
				t.addClassName("select_objects_label select_objects_label_right"), a.appendChild(t), a.appendChild(r.getMarkup());
				var n = new Element("div");
				n.addClassName("select_objects_buttons");
				var u = new Element("input", {
					type: "button",
					value: "ADD >>"
				});
				n.appendChild(u);
				var d = new Element("input", {
					type: "button",
					value: "<<"
				});
				return n.appendChild(d), s.push({
					el: d,
					action: c
				}), s.push({
					el: u,
					action: l
				}), a.appendChild(n), a.appendChild(o.getMarkup()), a
			}, this.getSelectedObjects = function() {
				return o.getAllObjects()
			}, this.getSelection = function() {
				return ""
			}
		}
	}),
	EditExhibitObjectListDlg = Class.create({
		initialize: function(e, t, n, i, r) {
			this.class_type = "EditExhibitObjectListDlg";
			var o = new ObjectSelector(e, t, i);
			this.sendWithAjax = function(e, t) {
				var n = t.arg0,
					a = t.dlg;
				a.setFlash("Updating Exhibit's Objects...", !1);
				var s = {
						exhibit_id: i,
						objects: o.getSelectedObjects().join("	")
					},
					l = function() {
						a.cancel()
					};
				serverAction({
					action: {
						actions: n,
						els: r,
						params: s,
						onSuccess: l
					}
				})
			};
			var a = {
					page: "choose_objects",
					rows: [
						[{
							text: 'Select object from the list on the left and press the ">>" button to move it to the exhibit.',
							klass: "new_exhibit_instructions"
						}],
						[{
							custom: o
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: n,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				s = {
					this_id: "edit_exhibit_object_list_dlg",
					pages: [a],
					body_style: "edit_palette_dlg",
					row_style: "new_exhibit_row",
					title: "Choose Objects for Exhibit"
				},
				l = new GeneralDialog(s);
			l.center(), o.populate(l)
		}
	}),
	EditFontsDlg = Class.create({
		initialize: function(e, t, n, i, r, o, a) {
			var s = n,
				l = [{
					text: "Arial",
					value: "Arial"
				}, {
					text: "Arial Black",
					value: "Arial Black"
				}, {
					text: "Courier New",
					value: "Courier New"
				}, {
					text: "Lucinda Console",
					value: "Lucinda Console"
				}, {
					text: "Tahoma",
					value: "Tahoma"
				}, {
					text: "Times New Roman",
					value: "Times New Roman"
				}, {
					text: "Trebuchet MS",
					value: "Trebuchet MS"
				}, {
					text: "Verdana",
					value: "Verdana"
				}],
				c = [{
					text: "9",
					value: "9"
				}, {
					text: "10",
					value: "10"
				}, {
					text: "11",
					value: "11"
				}, {
					text: "12",
					value: "12"
				}, {
					text: "13",
					value: "13"
				}, {
					text: "14",
					value: "14"
				}, {
					text: "15",
					value: "15"
				}, {
					text: "16",
					value: "16"
				}, {
					text: "18",
					value: "18"
				}, {
					text: "20",
					value: "20"
				}, {
					text: "22",
					value: "22"
				}, {
					text: "24",
					value: "24"
				}, {
					text: "26",
					value: "26"
				}, {
					text: "28",
					value: "28"
				}, {
					text: "32",
					value: "32"
				}, {
					text: "36",
					value: "36"
				}, {
					text: "40",
					value: "40"
				}, {
					text: "44",
					value: "44"
				}, {
					text: "48",
					value: "48"
				}, {
					text: "54",
					value: "54"
				}],
				u = function(t, n) {
					var i = n.curr_page,
						r = n.dlg;
					r.setFlash("Updating Fonts...", !1), o ? serverAction({
						action: {
							els: o,
							params: r.getAllData(),
							actions: e,
							onSuccess: function() {
								r.cancel()
							}
						}
					}) : submitForm(i, e)
				},
				d = function(e, t) {
					var n = e.split("_"),
						i = "preview_" + n[1];
					$(i).setStyle("size" === n[3] ? {
						fontSize: t + "px"
					} : {
						fontFamily: t
					})
				},
				h = {
					page: "layout",
					rows: [
						[{
							select: i + "[use_styles]",
							value: s.use_styles,
							klass: "not_specified hidden",
							options: [{
								text: "Use these styles in all exhibits",
								value: 1
							}, {
								text: "Allow exhibits to use their own styles",
								value: 0
							}]
						}],
						[{
							text: "Header:",
							klass: "edit_font_label"
						}, {
							select: i + "[header_font_name]",
							value: s.header_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[header_font_size]",
							value: s.header_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "Body Text:",
							klass: "edit_font_label"
						}, {
							select: i + "[text_font_name]",
							value: s.text_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[text_font_size]",
							value: s.text_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "Illustration:",
							klass: "edit_font_label"
						}, {
							select: i + "[illustration_font_name]",
							value: s.illustration_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[illustration_font_size]",
							value: s.illustration_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "First Caption:",
							klass: "edit_font_label"
						}, {
							select: i + "[caption1_font_name]",
							value: s.caption1_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[caption1_font_size]",
							value: s.caption1_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "Second Caption:",
							klass: "edit_font_label"
						}, {
							select: i + "[caption2_font_name]",
							value: s.caption2_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[caption2_font_size]",
							value: s.caption2_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "Footnote Popup:",
							klass: "edit_font_label"
						}, {
							select: i + "[footnote_font_name]",
							value: s.footnote_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[footnote_font_size]",
							value: s.footnote_font_size,
							options: c,
							callback: d
						}],
						[{
							text: "Endnotes:",
							klass: "edit_font_label"
						}, {
							select: i + "[endnotes_font_name]",
							value: s.endnotes_font_name,
							options: l,
							callback: d
						}, {
							select: i + "[endnotes_font_size]",
							value: s.endnotes_font_size,
							options: c,
							callback: d
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Save",
							callback: u,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}, {
							hidden: "id",
							value: t
						}]
					]
				};
			if (a) {
				var p = h.rows.pop();
				h.rows.push([{
					text: "Edit the colors below by using the 6 character RGB code",
					klass: "edit_color_instructions"
				}]), h.rows.push([{
					text: "Header Color:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_header_color]",
					value: s.exhibit_header_color
				}]), h.rows.push([{
					text: "Body Text Color:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_text_color]",
					value: s.exhibit_text_color
				}]), h.rows.push([{
					text: "Caption1 Color:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_caption1_color]",
					value: s.exhibit_caption1_color
				}]), h.rows.push([{
					text: "Caption1 Bkgrd:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_caption1_background]",
					value: s.exhibit_caption1_background
				}]), h.rows.push([{
					text: "Caption2 Color:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_caption2_color]",
					value: s.exhibit_caption2_color
				}]), h.rows.push([{
					text: "Caption2 Bkgrd:",
					klass: "edit_font_label"
				}, {
					input: i + "[exhibit_caption2_background]",
					value: s.exhibit_caption2_background
				}]), h.rows.push(p)
			}
			var f = {
					this_id: "edit_font_dlg",
					pages: [h],
					body_style: "edit_font_div",
					row_style: "new_exhibit_row",
					title: "Edit Exhibit Fonts"
				},
				g = new GeneralDialog(f);
			r && $$(".not_specified").each(function(e) {
				e.removeClassName("hidden")
			}), g.center();
			var m = $("edit_font_dlg"),
				v = m.down(".bd"),
				_ = new Element("div");
			_.addClassName("font_preview"), _.appendChild(new Element("h3", {
				id: "preview_header"
			}).update("Header"));
			var b = new Element("div", {
				style: "float: right;"
			});
			b.appendChild(new Element("div", {
				id: "preview_illustration"
			}).update("Textual Illustration."));
			var y = new Element("div", {
				id: "preview_caption1"
			}).update("Caption 1");
			b.appendChild(y), y.appendChild(new Element("div", {
				id: "preview_caption2"
			}).update("Caption 2")), _.appendChild(b), _.appendChild(new Element("div", {
				id: "preview_text"
			}).update("Paragraph of text.")), _.appendChild(new Element("div", {
				id: "preview_endnotes",
				style: "clear:both;"
			}).update("<span class='endnote_superscript'>1</span>Endnote"));
			var w = new Element("div", {
					style: "text-align: left;"
				}),
				x = new Element("div", {
					style: "position:inherit; visibility: visible; z-index: 2;"
				});
			x.addClassName("yui-panel-container yui-dialog show-scrollbars shadow"), w.appendChild(x);
			var E = new Element("div", {
				style: "visibility: visible;"
			});
			E.addClassName("yui-module yui-overlay yui-panel"), x.appendChild(E);
			var k = new Element("div").update("Footnote");
			k.addClassName("hd"), E.appendChild(k);
			var C = new Element("div");
			C.addClassName("bd"), E.appendChild(C);
			var T = new Element("div");
			C.appendChild(T);
			var S = new Element("div");
			S.addClassName("gd_message_box_row"), T.appendChild(S);
			var O = new Element("span", {
				id: "preview_footnote"
			}).update("Text of footnote.");
			O.addClassName("gd_message_box_label"), S.appendChild(O), _.appendChild(w), v.insert({
				top: _
			}), v.down(".gd_last_row").addClassName("clear_both"), $("preview_header").setStyle({
				fontFamily: s.header_font_name,
				fontSize: s.header_font_size + "px",
				marginTop: "1px",
				marginBottom: "5px"
			}), $("preview_header").addClassName("exhibit_header"), $("preview_illustration").setStyle({
				fontFamily: s.illustration_font_name,
				fontSize: s.illustration_font_size + "px"
			}), $("preview_illustration").addClassName("exhibit_illustration_text"), $("preview_caption1").setStyle({
				fontFamily: s.caption1_font_name,
				fontSize: s.caption1_font_size + "px"
			}), $("preview_caption1").addClassName("exhibit_caption1"), $("preview_caption2").setStyle({
				fontFamily: s.caption2_font_name,
				fontSize: s.caption2_font_size + "px"
			}), $("preview_caption2").addClassName("exhibit_caption2"), $("preview_text").setStyle({
				fontFamily: s.text_font_name,
				fontSize: s.text_font_size + "px"
			}), $("preview_footnote").setStyle({
				fontFamily: s.footnote_font_name,
				fontSize: s.footnote_font_size + "px"
			}), $("preview_endnotes").setStyle({
				fontFamily: s.endnotes_font_name,
				fontSize: s.endnotes_font_size + "px"
			})
		}
	}),
	outline_page_height = 0,
	exhibit_outline = null,
	exhibit_outline_pos = null,
	selectGroup = function(e, t, n) {
		new SelectInputDlg({
			title: "Change Group",
			prompt: "Group",
			id: "group",
			options: t,
			okStr: "Save",
			value: n,
			extraParams: {
				id: e
			},
			actions: ["/builder/change_exhibits_group"],
			target_els: [null]
		})
	},
	selectCluster = function(e, t, n, i) {
		new SelectInputDlg({
			title: "Select " + i,
			prompt: i,
			id: "cluster",
			options: t,
			okStr: "Save",
			value: n,
			extraParams: {
				id: e
			},
			actions: ["/builder/change_exhibits_cluster"],
			target_els: [null]
		})
	},
	CreateSharingList = Class.create({
		list: null,
		initialize: function(e, t, n) {
			var i = this;
			i.list = "<table class='input_dlg_list input_dlg_license_list' cellspacing='0'>";
			var r = 0;
			e.each(function(e) {
				i.list += i.constructItem(e.text, e.icon, r, r === t, n), r++
			}), i.list += "</table>"
		},
		constructItem: function(e, t, n, i, r) {
			var o = "";
			return i && (o = " class='input_dlg_list_item_selected' "), "<tr " + o + "onclick='CreateSharingList.prototype.select(this,\"" + r + "\" );' index='" + n + "' ><td>" + t + "</td><td>" + e + "</td></tr>\n"
		}
	});
CreateSharingList.prototype.select = function(e, t) {
	var n = "input_dlg_list_item_selected";
	$$("." + n).each(function(e) {
		e.removeClassName(n)
	}), $(e).addClassName(n), $(t).value = $(e).getAttribute("index")
}; //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var InplaceObjects = Class.create({
		initialize: function() {
			this.class_type = "InplaceObjects";
			var e = [],
				t = !1,
				n = function(e, t, n) {
					var i = function(e) {
							var t = e.up(".element_block");
							return (null === t || void 0 === t) && (t = e.up(".element_block_hover")), t
						},
						r = function(e, t, n, i, r) {
							var o = function() {
									var e = $(this),
										t = e.readAttribute("hoverClass"),
										n = e.down();
									n.addClassName(t)
								},
								a = function() {
									var e = $(this),
										t = e.readAttribute("hoverClass"),
										n = e.down();
									n.removeClassName(t)
								},
								s = $(e),
								l = s.wrap("a");
							s.writeAttribute("action", n), s.writeAttribute("ajax_action_element_id", t), void 0 !== i && (l.writeAttribute("hoverclass", i), l.observe("mouseover", o), l.observe("mouseout", a)), void 0 !== r && l.observe("click", r)
						},
						o = e.split(","),
						a = $(o[0]),
						s = i(a).id;
					o.length > 1 && (s = s + "," + o[1]), r(o[0], s, t, "richEditorHover", n)
				};
			document.observe("dom:loaded", function() {
				e.each(function(e) {
					n(e.element_id, e.action, e.setupMethod)
				}), t = !0
			}), this.initDiv = function(i, r, o) {
				if (t) n(i, r, o);
				else {
					var a = {
						element_id: i,
						action: r,
						setupMethod: o
					};
					e.push(a)
				}
			}, this.ajaxUpdateFromElement = function(e, t, n) {
				var i = e.readAttribute("action"),
					r = e.readAttribute("ajax_action_element_id"),
					o = i.split(","),
					a = r.split(",");
				serverAction({
					action: {
						actions: o,
						els: a,
						onSuccess: n,
						params: t
					}
				})
			}
		}
	}),
	inplaceObjectManager = new InplaceObjects,
	varFeatureDlg = null,
	featureDlg = function(e, t, n, i) {
		var r = this,
			o = null,
			a = function(e, t) {
				varFeatureDlg = r;
				var n = t.arg0;
				o.setFlash("Verifying feature update...", !1), submitForm("layout", n.url, n.method)
			};
		this.fileUploadError = function(e) {
			o.setFlash(e, !0)
		}, this.fileUploadFinished = function() {
			o.setFlash("Feature updated successfully. Please wait...", !1), reloadPage()
		};
		var s = {
				page: "layout",
				rows: [
					[{
						text: "Object's URI:",
						klass: "admin_dlg_label"
					}, {
						input: "features[object_uri]",
						klass: "new_exhibit_input_long",
						value: n.object_uri
					}],
					[{
						text: "Saved Search Name:",
						klass: "admin_dlg_label"
					}, {
						select: "features[saved_search_name]",
						value: n.saved_search_name,
						klass: "new_exhibit_input_long",
						options: e
					}],
					[{
						text: "Disabled:",
						klass: "admin_dlg_label"
					}, {
						checkbox: "features[disabled]",
						klass: "new_exhibit_input_long",
						value: n.disabled
					}],
					[{
						rowClass: "clear_both"
					}, {
						text: "Thumbnail:",
						klass: ""
					}, {
						image: "image",
						size: "37",
						value: i,
						removeButton: "Remove Thumbnail",
						klass: ""
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						arg0: t,
						callback: a,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			l = {
				this_id: "features_dlg",
				pages: [s],
				body_style: "forum_reply_dlg",
				row_style: "new_exhibit_row",
				title: "Features",
				focus: "features_object_uri"
			};
		o = new GeneralDialog(l), o.center()
	},
	FootnoteAbbrev = Class.create({
		initialize: function(e) {
			var t = e.startingValue,
				n = e.field,
				i = e.populate_all,
				r = e.populate_exhibit_only,
				o = e.progress_img,
				a = null,
				s = function(e, t, i, r) {
					var o = new Element("a", {
						id: n + "_" + e,
						title: t,
						onclick: "return false;",
						href: "#"
					});
					return o.addClassName(r), i && o.addClassName("hidden"), o
				},
				l = function() {
					if (t.length > 0) {
						$(n + "_add").addClassName("hidden"), $(n + "_edit").removeClassName("hidden"), $(n + "_remove").removeClassName("hidden");
						var e = $$("." + a)[0];
						e.removeClassName("hidden"), e.down(".tip").innerHTML = t.stripTags()
					} else $(n + "_add").removeClassName("hidden"), $(n + "_edit").addClassName("hidden"), $(n + "_remove").addClassName("hidden"), $$("." + a)[0].addClassName("hidden")
				},
				c = function(e) {
					t = e, l()
				},
				u = function() {
					return new RteInputDlg({
						title: "Add Footnote",
						okCallback: c,
						value: t,
						populate_urls: [r, i],
						progress_img: o
					}), !1
				},
				d = function() {
					return new RteInputDlg({
						title: "Edit Footnote",
						okCallback: c,
						value: t,
						populate_urls: [r, i],
						progress_img: o
					}), !1
				},
				h = null;
			this.deleteCallback = function(e) {
				h = e
			};
			var p = function() {
				return t = "", l(), h && h(n), !1
			};
			this.getMarkup = function() {
				var e = new Element("div");
				return e.addClassName("footnote_abbrev_div"), e.appendChild(s("add", "Add Footnote", t.length > 0, "footnote_button")), e.appendChild(s("edit", "Edit Footnote", 0 === t.length, "footnote_button")), e.appendChild(s("remove", "Delete Footnote", 0 === t.length, "footnote_delete_button")), e
			}, this.getSelection = function() {
				return {
					field: n,
					value: t
				}
			}, this.delayedSetup = function() {
				YAHOO.util.Event.addListener(n + "_add", "click", u, null), YAHOO.util.Event.addListener(n + "_edit", "click", d, null), YAHOO.util.Event.addListener(n + "_remove", "click", p, null)
			}, this.createEditButton = function(e) {
				return a = e, t.length > 0 ? {
					link: "*<span class='tip'>" + t.stripTags() + "</span>",
					klass: e + " footnote_tip",
					callback: d
				} : {
					link: "*<span class='tip'></span>",
					klass: e + " footnote_tip hidden",
					callback: d
				}
			}
		}
	}),
	FootnotesInRte = Class.create({
		initialize: function() {
			var e = '<a href="#" onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">',
				t = '<a href="#" onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">',
				n = '<A class=superscript onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' href="#">',
				i = '</a><span class="hidden">',
				r = "</A><SPAN class=hidden>",
				o = '<a href="#" onclick="return false; var footnote = $(this).next(); new MessageBoxDlg(&quot;Footnote&quot;, footnote.innerHTML); return false;" class="superscript">',
				a = "</span>",
				s = '<a class="rte_footnote">',
				l = "<span>",
				c = '</span><span class="tip"><span class="footnote_edit_hover">Click this footnote to edit</span>',
				u = "</a>",
				d = "</span>",
				h = function(e) {
					return l + e + c + e.stripTags().truncate(40) + d
				},
				p = function(e) {
					return s + h(e) + u
				},
				f = function(e) {
					for (var t = e.split("<"), n = "", i = 0, r = 0; r < t.length; r++)
						if (t[r].startsWith("span") || t[r].startsWith("SPAN")) i++, n += "<" + t[r];
						else if (t[r].startsWith("/span") || t[r].startsWith("/SPAN")) {
							if (i--, -1 === i) break;
							n += "<" + t[r]
						} else n += "<" + t[r];
					n = n.substr(1);
					for (var o = t[r].substr(6), a = r + 1; a < t.length; a++) o += "<" + t[a];
					return {
						left: n,
						right: o
					}
				};
			this.preprocessFootnotes = function(a) {
				var s = a.split(e);
				1 === s.length && (s = a.split(t)), 1 === s.length && (s = a.split(n)), 1 === s.length && (s = a.split(o)), a = s[0];
				for (var l = 1; l < s.length; l++) {
					var c = s[l].split(i);
					1 === c.length && (c = s[l].split(r));
					var u = f(c[1]),
						d = u.left,
						h = u.right;
					a += p(d) + h
				}
				return a
			}, this.postprocessFootnotes = function(t) {
				var n = t.split(s + l);
				t = n[0];
				for (var r = 1; r < n.length; r++) {
					var o = n[r].split('</span><span class="tip">'),
						c = o[0],
						u = o[1].indexOf("</a>") + 4,
						d = o[1].substr(u);
					t += e + "@" + i + c + a + d
				}
				return t
			}, this.addFootnote = function(e, t) {
				return 0 === t.length && (t = " "), "add" === e ? p(t) : "edit" === e ? h(t) : ""
			}
		}
	}),
	editGroupThumbnailDlg = null,
	EditGroupThumbnailDlg = Class.create({
		initialize: function(e, t, n) {
			this.class_type = "EditGroupThumbnailDlg";
			var i = this,
				r = null,
				o = function(e, n) {
					editGroupThumbnailDlg = i;
					var o = n.arg0;
					r.setFlash("Editing " + t.toLowerCase() + " thumbnail...", !1), submitForm("layout", o)
				};
			this.fileUploadError = function(e) {
				r.setFlash(e, !0)
			}, this.fileUploadFinished = function() {
				r.setFlash(t + " thumbnail updated...", !1), reloadPage()
			};
			var a = function() {
				var i = {
						page: "layout",
						rows: [
							[{
								text: "Choose Thumbnail:"
							}],
							[{
								image: "image",
								size: "47",
								klass: "edit_group_thumbnail"
							}, {
								hidden: "id",
								value: e
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Update Thumbnail",
								arg0: "/" + n + "/edit_thumbnail",
								callback: o
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					a = {
						this_id: "edit_group_thumbnail",
						pages: [i],
						body_style: "new_group_div",
						row_style: "new_exhibit_row",
						title: "Edit " + t + " Thumbnail"
					};
				r = new GeneralDialog(a), r.center()
			};
			a()
		}
	}),
	GroupNewPost = Class.create({
		initialize: function(e, t, n, i, r) {
			new ForumReplyDlg({
				group_id: t,
				group_name: n,
				submit_url: "/forum/post_comment_to_new_thread",
				populate_exhibit_url: "/forum/get_exhibit_list",
				populate_collex_obj_url: "/forum/get_nines_obj_list",
				populate_topics_url: "/forum/get_all_topics",
				progress_img: e,
				logged_in: i,
				addTopicToLoginRedirect: !1,
				redirect: "/groups/" + t,
				license: r
			})
		}
	}),
	ClusterNewPost = Class.create({
		initialize: function(e, t, n, i, r, o, a, s) {
			new ForumReplyDlg({
				group_id: t,
				group_name: n,
				cluster_id: i,
				cluster_name: r,
				cluster_label: o,
				submit_url: "/forum/post_comment_to_new_thread",
				populate_exhibit_url: "/forum/get_exhibit_list",
				populate_collex_obj_url: "/forum/get_nines_obj_list",
				populate_topics_url: "/forum/get_all_topics",
				progress_img: e,
				logged_in: a,
				addTopicToLoginRedirect: !1,
				redirect: "/clusters/" + i,
				license: s
			})
		}
	}),
	GridDlg = Class.create({
		initialize: function(e) {
			this.class_type = "GridDlg";
			var t = e.title,
				n = e.hidden_id,
				i = e.hidden_value,
				r = e.url,
				o = e.fields,
				a = e.data,
				s = e.extraCtrl,
				l = e.extraCtrl2,
				c = function(e) {
					var t = e.element_id,
						n = $(t).up();
					$(t).remove(), n.appendChild(new Element("div", {
						id: t
					}));
					var i = e.fields,
						r = e.data,
						o = e.paginator_id;
					n = $(o).up(), $(o).remove(), n.appendChild(new Element("div", {
						id: o
					}));
					var a = e.highlight,
						s = parseInt("" + (a / 10 + 1)),
						l = [];
					i.each(function(e) {
						l.push({
							key: e,
							sortable: !1,
							resizable: !0
						})
					});
					var c = new YAHOO.util.DataSource(r);
					c.responseType = YAHOO.util.DataSource.TYPE_JSARRAY, c.responseSchema = {
						fields: i
					};
					var u = {};
					r.length > 10 && (u.paginator = new YAHOO.widget.Paginator({
						rowsPerPage: 10,
						containers: o,
						template: "{PreviousPageLink} <strong>{CurrentPageReport}</strong> {NextPageLink}"
					}));
					var d = new YAHOO.widget.DataTable(t, l, c, u);
					return u.paginator && a && u.paginator.setPage(s, !1), a && d.selectRow(a), {
						oDS: c,
						oDT: d
					}
				},
				u = null,
				d = function(e, t) {
					u.setFlash("Updating. Please wait...", !1);
					var n = function() {
							u.cancel()
						},
						i = u.getAllData(),
						r = t.arg0;
					serverAction({
						action: {
							actions: r,
							els: "group_details",
							onSuccess: n,
							params: i
						}
					})
				},
				h = function() {
					var e = {
						page: "layout",
						rows: [
							[{
								text: "paginator",
								id: "membership_pagination",
								klass: "pagination"
							}],
							[{
								text: "grid",
								id: "membership_data_grid"
							}]
						]
					};
					void 0 !== n && e.rows[0].push({
						hidden: n,
						value: i
					}), void 0 !== s && e.rows.push(s), void 0 !== l && e.rows.push(l), e.rows.push([{
						rowClass: "gd_last_row"
					}, {
						button: "Save",
						arg0: r,
						callback: d,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]);
					var h = {
						this_id: "new_group_wizard",
						pages: [e],
						body_style: "edit_group_membership_div",
						row_style: "new_exhibit_row",
						title: t
					};
					u = new GeneralDialog(h), c({
						element_id: "membership_data_grid",
						paginator_id: "membership_pagination",
						fields: o,
						data: a
					}), u.center()
				};
			h()
		}
	}),
	EditMembershipDlg = Class.create({
		initialize: function(e, t, n, i, r) {
			this.class_type = "EditMembershipDlg";
			var o = [{
					Name: i,
					"Administrator?": "owner"
				}],
				a = [{
					text: "No change",
					value: 0
				}];
			t.each(function(e) {
				var t = "editor" === e.role ? ' checked="true"' : "";
				o.push({
					Name: e.name,
					"Administrator?": '<input id="group_' + e.id + '_editor" type="checkbox" value="1" name="group[' + e.id + '[editor]]"' + t + "/>",
					Delete: '<input id="group_' + e.id + '_delete" type="checkbox" value="1" name="group[' + e.id + '[delete]]"/>'
				}), "editor" === e.role && a.push({
					text: e.name,
					value: e.user_id
				})
			});
			var s = [{
					text: "Show Membership List: "
				}, {
					select: "show_membership",
					klass: "gd_select_dlg_input",
					options: [{
						text: "To All",
						value: "Yes"
					}, {
						text: "To Admins",
						value: "No"
					}],
					value: n
				}],
				l = void 0;
			r && a.length > 1 && (l = [{
				text: "Change Owner: "
			}, {
				select: "change_owner",
				klass: "gd_select_dlg_input",
				options: a,
				value: 0
			}]), new GridDlg({
				title: "Edit Membership",
				hidden_id: "id",
				hidden_value: e,
				url: "edit_membership",
				fields: ["Name", "Administrator?", "Delete"],
				data: o,
				extraCtrl: s,
				extraCtrl2: l
			})
		}
	}),
	RespondToRequestDlg = Class.create({
		initialize: function(e, t) {
			this.class_type = "RespondToRequestDlg";
			var n = [];
			t.each(function(e) {
				n.push({
					Name: e.user_name,
					"No Action": '<input id="group_' + e.group_id + '_noaction" type="radio" value="no_action" checked="checked" name="group[' + e.group_id + ']"/>',
					Accept: '<input id="group_' + e.group_id + '_accept" type="radio" value="accept" name="group[' + e.group_id + ']"/>',
					Deny: '<input id="group_' + e.group_id + '_deny" type="radio" value="deny" name="group[' + e.group_id + ']"/>'
				})
			}), new GridDlg({
				title: "Respond",
				hidden_id: "id",
				hidden_value: e,
				url: "pending_requests",
				fields: ["Name", "No Action", "Accept", "Deny"],
				data: n
			})
		}
	}),
	InviteMembersDlg = Class.create({
		initialize: function(e, t) {
			this.class_type = "InviteMembersDlg";
			var n = null,
				i = function(e, t) {
					n.setFlash("Sending email to invitees. Please wait...", !1);
					var i = function() {
							n.cancel()
						},
						r = function(e) {
							var t = "Some or all of your invitees have not been invited. Please check their email address and try again.<br />" + e.responseText;
							new MessageBoxDlg("Members Not Invited", t), n.setFlash("Error: Please try again.", !0)
						},
						o = n.getAllData(),
						a = t.arg0;
					serverAction({
						action: {
							actions: a,
							els: "group_details",
							onSuccess: i,
							onFailure: r,
							params: o
						}
					})
				},
				r = function() {
					var r = {
							page: "layout",
							rows: [
								[{
									text: "There are two ways to invite people to join your group in " + t + ": email address or username. If you know the participants' usernames, list them in the blank below, one per line.",
									klass: "invite_users_instructions"
								}],
								[{
									text: "By Username:",
									klass: "invite_users_label"
								}, {
									textarea: "usernames",
									klass: "groups_textarea"
								}],
								[{
									rowClass: "button_row"
								}, {
									button: "Submit",
									arg0: {
										method: "PUT",
										url: "/groups/" + e
									},
									callback: i
								}],
								[{
									text: "Don't know any usernames? Add email addresses of users you want to invite in the blank below, one per line.",
									klass: "invite_users_instructions"
								}],
								[{
									text: "By Email Address:",
									klass: "invite_users_label"
								}, {
									textarea: "emails",
									klass: "groups_textarea"
								}],
								[{
									rowClass: "gd_last_row"
								}, {
									button: "Submit",
									arg0: {
										method: "PUT",
										url: "/groups/" + e
									},
									callback: i
								}, {
									button: "Cancel",
									callback: GeneralDialog.cancelCallback
								}]
							]
						},
						o = {
							this_id: "invite_users_dlg",
							pages: [r],
							body_style: "invite_users_div",
							row_style: "new_exhibit_row",
							title: "Invite Users to Join",
							focus: "username"
						};
					n = new GeneralDialog(o), n.center()
				};
			r()
		}
	}),
	editDescription = function(e, t, n, i, r) {
		var o = function(t) {
			var i = {};
			i[n + "[description]"] = t, serverAction({
				action: {
					actions: {
						method: "PUT",
						url: "/" + n + "s/" + e
					},
					els: n + "_details",
					params: i
				}
			})
		};
		new RteInputDlg({
			title: "Edit Description",
			okCallback: o,
			value: t,
			populate_urls: [i],
			progress_img: r
		})
	},
	editPermissions = function(e, t, n, i) {
		new SelectInputDlg({
			title: "Change Forum Permissions",
			prompt: "Permissions",
			id: "group[forum_permissions]",
			options: n,
			explanation: i,
			okStr: "Save",
			value: t,
			actions: [{
				method: "PUT",
				url: "/groups/" + e
			}],
			target_els: ["group_discussions"]
		})
	},
	changeWhichExhibitsAreShown = function(e, t, n, i, r) {
		new SelectInputDlg({
			title: "Change Which " + r + "s Are Shown",
			prompt: "Show " + r + "s",
			id: "group[show_exhibits]",
			options: n,
			explanation: i,
			okStr: "Save",
			value: t,
			extraParams: {
				id: e
			},
			actions: [{
				method: "PUT",
				url: "/groups/" + e
			}, "/groups/group_exhibits_list"],
			target_els: ["group_details", "group_exhibits"]
		})
	},
	editVisibility = function(e, t, n, i, r) {
		new SelectInputDlg({
			title: "Change " + r + " Visibility",
			prompt: r + "s are ",
			id: "group[exhibit_visibility]",
			options: n,
			explanation: i,
			okStr: "Save",
			value: t,
			actions: [{
				method: "PUT",
				url: "/groups/" + e
			}],
			target_els: ["group_details"]
		})
	},
	editType = function(e, t, n) {
		new SelectInputDlg({
			title: "Edit Group Type",
			prompt: "Type",
			id: "group[group_type]",
			options: n,
			explanation: ['This group is being used for scholarly collaboration. File this group under the "Community" section.', 'This group is being used to teach. File this group under the "Classroom" section.', "Publication groups work closely with the " + window.gFederationName + " staff to vet their content. If you select this option a notification will be sent to the " + window.gFederationName + " staff, and someone will be in contact with you soon."],
			okStr: "Save",
			value: t,
			actions: {
				method: "PUT",
				url: "/groups/" + e
			},
			target_els: "group_details"
		})
	},
	editGroupTextField = function(e, t, n, i) {
		var r = function(e) {
			var t = e["group[" + i + "]"];
			return 0 === t.length ? "This entry cannot be blank. Please enter a value." : null
		};
		new TextInputDlg({
			title: "Edit " + n,
			prompt: n,
			id: "group[" + i + "]",
			okStr: "Save",
			value: t,
			verifyFxn: r,
			actions: {
				method: "PUT",
				url: "/groups/" + e
			},
			target_els: "group_details"
		})
	},
	editTitle = function(e, t, n) {
		new TextInputDlg({
			title: "Edit Title",
			prompt: "Title",
			id: n + "[name]",
			okStr: "Save",
			value: t,
			actions: {
				method: "PUT",
				url: "/" + n + "s/" + e
			},
			target_els: n + "_details"
		})
	},
	editURL = function(e, t, n, i) {
		new TextInputDlg({
			title: "Edit URL",
			prompt: i,
			id: n + "[visible_url]",
			okStr: "Save",
			value: t,
			inputKlass: "edit_url_input",
			verify: "/" + n + "s/check_url",
			extraParams: {
				id: e
			},
			actions: {
				method: "PUT",
				url: "/" + n + "s/" + e
			},
			target_els: n + "_details"
		})
	},
	moveExhibitToCluster = function(e, t, n, i, r, o, a) {
		new SelectInputDlg({
			title: "Move " + o + " to " + a,
			prompt: o,
			id: "exhibit_id",
			options: i,
			okStr: "Move",
			body_style: "",
			extraParams: {
				dest_cluster: n,
				cluster_id: n,
				group_id: t
			},
			actions: e,
			target_els: r
		})
	},
	changeClusterVisibility = function(e, t, n, i, r) {
		new SelectInputDlg({
			title: "Change " + r + " Visibility",
			prompt: "Visibility",
			id: "cluster[visibility]",
			options: n,
			value: t,
			okStr: "Save",
			actions: e,
			target_els: i
		})
	},
	changeExhibitLabel = function(e, t, n, i, r) {
		new SelectInputDlg({
			title: "Change Exhibit Label",
			prompt: "Label",
			id: "group[exhibits_label]",
			options: n,
			value: t,
			okStr: "Save",
			extraParams: r,
			actions: [e, "/groups/group_exhibits_list"],
			target_els: [i, "group_exhibits"]
		})
	},
	changeClusterLabel = function(e, t, n, i, r) {
		new SelectInputDlg({
			title: "Change Cluster Label",
			prompt: "Label",
			id: "group[clusters_label]",
			options: n,
			value: t,
			okStr: "Save",
			extraParams: r,
			actions: [e, "/groups/group_exhibits_list"],
			target_els: [i, "group_exhibits"]
		})
	},
	moveExhibit = function(e, t, n, i, r) {
		t.unshift({
			text: "(None)",
			value: "0"
		}), new SelectInputDlg({
			title: "Move " + r,
			prompt: "To:",
			id: "dest_cluster",
			value: i,
			options: t,
			okStr: "Save",
			body_style: "",
			extraParams: {
				group_id: n,
				cluster_id: i,
				exhibit_id: e
			},
			actions: ["/clusters/move_exhibit"],
			target_els: ["group_exhibits"]
		})
	},
	request_to_join = function(e, t) {
		serverAction({
			action: {
				actions: "/groups/request_join",
				els: "group_details",
				params: {
					group_id: e,
					user_id: t
				}
			},
			progress: {
				waitMessage: "Request To Join Group...",
				completeMessage: "A request to join this group is pending acceptance by the moderator."
			}
		})
	},
	accept_invitation = function(e) {
		serverAction({
			action: {
				actions: "/groups/accept_invitation",
				els: "group_details",
				params: {
					id: e
				}
			},
			progress: {
				waitMessage: "Updating Group Membership...",
				completeMessage: "You are now a member of this group."
			}
		})
	},
	decline_invitation = function(e) {
		serverAction({
			action: {
				actions: "/groups/decline_invitation",
				els: "group_details",
				params: {
					id: e
				}
			},
			progress: {
				waitMessage: "Updating Group Membership...",
				completeMessage: "You have been removed from this group."
			}
		})
	},
	acceptAsPeerReviewed = function(e, t, n, i, r, o, a, s, l, c, u, d, h) {
		t.unshift({
			text: "(None)",
			value: "0"
		});
		var p = null,
			f = function(t, r) {
				var o = function() {
						p.cancel()
					},
					a = function(e) {
						p.setFlash("Error: " + e.responseText, !0)
					},
					s = p.getAllData();
				if (s.exhibit_id = e, s["exhibit[is_published]"] = "1", "cluster" === s.typ && "0" === s["exhibit[cluster_id]"]) p.setFlash("Please choose a " + i + " from the list.", !0);
				else {
					var l = r.arg0;
					p.setFlash("Accepting " + n + ". Please wait...", !1), serverAction({
						action: {
							actions: l,
							els: "group_exhibits",
							onSuccess: o,
							onFailure: a,
							params: s
						}
					})
				}
			},
			g = {
				page: "layout",
				rows: [
					[{
						rowClass: "accept_peer_review_header"
					}, {
						text: 'You are about to set <a href="' + u + '" target="_blank" class="nav_link">' + r + '</a> by <a class="nav_link" href="#" onclick="showPartialInLightBox(\'' + d + "', 'Profile for " + o + "', '" + h + "'); return false;\">" + o + "</a> as a peer-reviewed object."
					}],
					[{
						text: "This means that the work will be indexed into " + a + ' and stamped with a badge of approval. If you wish to continue, please select "Accept". Otherwise, please select "Cancel."',
						klass: "accept_peer_review_label non_cluster_options"
					}, {
						text: "This means that the work will be indexed into " + a + ' and stamped with a badge of approval. If you wish to continue, please select a method for sharing this work below. Otherwise, please select "Cancel."',
						klass: "accept_peer_review_label hidden cluster_options"
					}],
					[{
						radioList: "typ",
						klass: "accept_peer_review_radio hidden cluster_options",
						value: 0 === s ? "noncluster" : "cluster",
						options: [{
							value: "noncluster",
							text: "I certify this " + n + " has been peer reviewed as a stand-alone object."
						}, {
							value: "cluster",
							text: "I certify that this " + n + " has been peer reviewed as part of a " + i + " of objects."
						}]
					}],
					[{
						text: "Choose a " + i + ":",
						klass: "accept_peer_review_label2 hidden cluster_options"
					}, {
						select: "exhibit[cluster_id]",
						options: t,
						value: s,
						klass: "hidden cluster_options"
					}],
					[{
						text: 'Note: Objects in <span class="accept_peer_review_group_name">' + l + '</span> have a default sharing option of "<span class="accept_peer_review_permissions">' + c + '</span>".',
						klass: "accept_peer_review_label"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Accept",
						arg0: "/groups/accept_as_peer_reviewed",
						callback: f
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			m = {
				this_id: "invite_users_dlg",
				pages: [g],
				body_style: "invite_users_div",
				row_style: "new_exhibit_row",
				title: "Accept As Peer Reviewed",
				focus: "username"
			};
		p = new GeneralDialog(m), t.length > 1 && ($$(".cluster_options").each(function(e) {
			e.removeClassName("hidden")
		}), $$(".non_cluster_options").each(function(e) {
			e.addClassName("hidden")
		})), p.center()
	},
	limitExhibit = function(e, t) {
		serverAction({
			action: {
				actions: "/groups/limit_exhibit",
				els: "group_exhibits",
				params: {
					exhibit_id: e
				}
			},
			progress: {
				waitMessage: "Limiting Exhibit...",
				completeMessage: "This " + t + " can only be viewed by group members."
			}
		})
	},
	unlimitExhibit = function(e, t) {
		serverAction({
			action: {
				actions: "/groups/unlimit_exhibit",
				els: "group_exhibits",
				params: {
					exhibit_id: e
				}
			},
			progress: {
				waitMessage: "Allowing Publishing...",
				completeMessage: "This " + t + " can be viewed by everyone."
			}
		})
	},
	hideAdmins = function(e) {
		serverAction({
			action: {
				actions: e,
				els: "group_details",
				params: {
					"group[show_admins]": "members"
				}
			},
			progress: {
				waitMessage: "Hiding Admins...",
				completeMessage: "The administators are hidden to non-members."
			}
		})
	},
	showAdmins = function(e) {
		serverAction({
			action: {
				actions: e,
				els: "group_details",
				params: {
					"group[show_admins]": "all"
				}
			},
			progress: {
				waitMessage: "Showing Admins...",
				completeMessage: "The administators are visible to non-members."
			}
		})
	},
	confirmDlgWithTextArea = function(e, t, n, i, r, o, a) {
		var s = function(r, o) {
				var s = o.dlg.getAllData();
				a.comment = s.comment, o.dlg.cancel(), serverAction({
					action: {
						actions: e,
						els: t,
						params: a
					},
					progress: {
						waitMessage: n + "...",
						completeMessage: i
					}
				})
			},
			l = {
				page: "layout",
				rows: [
					[{
						text: r,
						klass: "gd_message_box_label"
					}],
					[{
						text: o
					}, {
						textarea: "comment",
						klass: "confirmdlg_comment"
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Ok",
						callback: s,
						isDefault: !0
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			c = {
				this_id: "confirm_comment_dlg",
				pages: [l],
				body_style: "gd_message_box_dlg",
				row_style: "gd_message_box_row",
				title: n
			},
			u = new GeneralDialog(c);
		u.center()
	},
	unpublishExhibit = function(e, t, n, i) {
		confirmDlgWithTextArea(["/groups/unpublish_exhibit"], ["group_exhibits"], "Unpublish " + i, "This " + i + ' has been set to "Private".', "This option unpublishes the " + i + ". A message will be sent to " + t + " at " + n + " with a short message notifying them of your action.", "Add a comment to this email:", {
			exhibit_id: e
		})
	},
	rejectAsPeerReviewed = function(e, t, n, i) {
		confirmDlgWithTextArea(["/groups/reject_as_peer_reviewed"], ["group_exhibits"], "Return " + i + " For Revisions", "The " + i + " has been sent back for revisions.", "This option returns the " + i + " to its original contributor for revision. A message will be sent to " + t + " at " + n + " with a short message notifying them of your request.", "Add a comment to this email:", {
			exhibit_id: e
		})
	},
	newClusterDlg = null,
	CreateNewClusterDlg = Class.create({
		initialize: function(e, t, n, i, r, o, a, s, l) {
			this.class_type = "CreateNewClusterDlg";
			var c = this,
				u = null,
				d = function() {
					u.setFlash("", !1);
					var t = u.getAllData();
					return 0 === t["cluster[name]"].strip().length ? void u.setFlash("Please enter a name for this " + l + " before continuing.", !0) : (newClusterDlg = c, u.setFlash("Verifying " + l + " creation...", !1), u.getAllData(), void submitForm("layout", e))
				};
			this.fileUploadError = function(e) {
				u.setFlash(e, !0)
			}, this.fileUploadFinished = function() {
				u.setFlash(l + " created...", !1);
				var e = function() {
					u.cancel()
				};
				serverAction({
					action: {
						els: o,
						actions: r,
						params: {
							id: t
						},
						onSuccess: e
					}
				})
			};
			var h = function() {
				var r = {
						page: "layout",
						rows: [
							[{
								text: "Creating New " + l + ' in the Group "' + n + '"',
								klass: "new_exhibit_title"
							}, {
								hidden: "cluster[group_id]",
								value: t
							}],
							[{
								text: "Title:",
								klass: "groups_label"
							}, {
								input: "cluster[name]",
								klass: "new_exhibit_input_long"
							}],
							[{
								text: "Description:",
								klass: ""
							}],
							[{
								textarea: "cluster[description]",
								klass: "groups_textarea"
							}],
							[{
								text: "Thumbnail:",
								klass: "groups_label thumbnail hidden"
							}, {
								image: "image",
								size: "37",
								removeButton: "Remove Thumbnail",
								klass: "thumbnail hidden"
							}],
							[{
								rowClass: "new_cluster_radio_title"
							}, {
								text: "This " + l + " should be"
							}],
							[{
								radioList: "cluster[visibility]",
								klass: "new_cluster_radio",
								options: [{
									text: "visible to everyone",
									value: "everyone"
								}, {
									text: "visible to group members only",
									value: "members"
								}, {
									text: "visible to group administrators only",
									value: "administrators"
								}],
								value: "members"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Create " + l,
								arg0: e,
								callback: d
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					},
					o = {
						this_id: "new_cluster_wizard",
						pages: [r],
						body_style: "new_cluster_div",
						row_style: "new_exhibit_row",
						title: "Create New " + l,
						focus: "cluster_name"
					};
				u = new GeneralDialog(o), u.initTextAreas({
					toolbarGroups: ["fontstyle", "link"],
					linkDlgHandler: new LinkDlgHandler([a], s)
				}), i && $$(".thumbnail").each(function(e) {
					e.removeClassName("hidden")
				}), u.center()
			};
			h()
		}
	}),
	setNotificationLevel = function(e, t, n, i, r) {
		var o = null,
			a = function(n, i) {
				var r = function() {
						o.cancel()
					},
					a = o.getAllData();
				a.group_id = e;
				var s = i.arg0;
				o.setFlash("Setting Notifications for " + t + ". Please wait...", !1), serverAction({
					action: {
						actions: s,
						els: "group_details",
						onSuccess: r,
						params: a
					}
				})
			},
			s = {
				page: "layout",
				rows: [
					[{
						text: "Set the email notifications you want to receive when activity occurs in " + t + ":"
					}],
					[{
						checkboxList: "notifications",
						klass: "notifications_checkbox_label",
						selections: n,
						items: [
							["exhibit", "<span class='notifications_item'>" + i + " changes</span>: added or removed from group or " + r + ", sharing level changed"],
							["membership", "<span class='notifications_item'>Membership changes</span>: member invited, member added, member declined, member removed, member becomes admin"],
							["discussion", "<span class='notifications_item'>Discussion changes</span>: new thread or new comment posted in this group"],
							["group", "<span class='notifications_item'>Group changes</span>: changed name, description, add " + r + "s, remove " + r + "s, changed visibility"]
						]
					}],
					[{
						rowClass: "gd_last_row"
					}, {
						button: "Save",
						arg0: "/groups/notifications",
						callback: a
					}, {
						button: "Cancel",
						callback: GeneralDialog.cancelCallback
					}]
				]
			},
			l = {
				this_id: "invite_users_dlg",
				pages: [s],
				body_style: "invite_users_div",
				row_style: "new_exhibit_row",
				title: "Set Notifications",
				focus: "username"
			};
		o = new GeneralDialog(l), o.center()
	};
Event.observe(window, "load", function() {
	setTimeout(function() {
		var e = $$(".progress_timeout");
		e.each(function(e) {
			jQuery(e).removeClass("result_row_img_progress");
			var t = e.readAttribute("data-noimage");
			e.src = t
		})
	}, 8e3)
}); //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var CacheObjects = Class.create({
		initialize: function() {
			var e = new Hash;
			this.get = function(t) {
				return e.get(t)
			}, this.reset = function(t) {
				e.set(t, null)
			}, this.set = function(t, n) {
				e.set(t, n)
			}, this.resetAll = function() {
				e = new Hash
			}
		}
	}),
	ninesObjCache = new CacheObjects,
	CreateListOfObjects = Class.create({
		initialize: function(e, t, n, i, r) {
			var o = "linkdlg_item_selected",
				a = $(n),
				s = null,
				l = null,
				c = this;
			this.getSelection = function() {
				var e = a.down("." + o);
				if (!e) return {
					field: null,
					value: null
				};
				var t = e.id.substring(e.id.indexOf("_") + 1);
				return {
					field: n,
					value: t
				}
			}, this.clearSelection = function() {
				var e = a.down("." + o);
				e && e.removeClassName(o)
			};
			var u, d, h;
			this.useTabs = function(e, t) {
				u = e, h = d = t
			}, this.ninesObjView = function(e, t) {
				var n;
				if (n = "all" === t.arg0 ? u : d, n !== h) {
					c.repopulate(t.dlg, n), h = n;
					var i = t.dlg.getOuterDomElement(),
						r = i.select(".dlg_tab_link"),
						o = i.select(".dlg_tab_link_current");
					r[0].addClassName("dlg_tab_link_current"), r[0].removeClassName("dlg_tab_link"), o[0].addClassName("dlg_tab_link"), o[0].removeClassName("dlg_tab_link_current")
				}
			}, this.resetCacheIfNecessary = function() {
				h !== d && ninesObjCache.reset(d)
			};
			var p = function(e, t, s, l, c) {
					var u = new Element("div", {
						id: e
					});
					u.addClassName("linkdlg_item");
					var d = new Element("div");
					d.addClassName("linkdlg_img_wrapper");
					var h, p;
					t && t.length > 0 && (h = new Element("img", {
						src: i,
						alt: s,
						title: s
					}), h.addClassName("linkdlg_img"), p = new Element("img", {
						id: e + "_img",
						src: t,
						alt: s,
						title: s
					}), p.addClassName("linkdlg_img"), p.addClassName("hidden"));
					var f = new Element("div");
					f.addClassName("linkdlg_text");
					var g = new Element("div").update(l);
					g.addClassName("linkdlg_firstline");
					var m = new Element("div", {
						id: e + "_img"
					}).update(c);
					m.addClassName("linkdlg_secondline");
					var v = new Element("hr");
					v.addClassName("clear_both"), v.addClassName("linkdlg_hr"), f.appendChild(g), f.appendChild(m), t && t.length > 0 && (d.appendChild(h), d.appendChild(p)), u.appendChild(d), u.appendChild(f), u.appendChild(v), a.appendChild(u);
					var _ = function() {
						var e = $(this);
						e.previous().addClassName("hidden");
						var t = parseInt(e.getStyle("height"));
						e.removeClassName("linkdlg_img");
						var n = e.height,
							i = e.width;
						if (0 === n && 0 === i) e.height = t, e.width = t;
						else if (n >= i) e.height = t;
						else {
							e.width = t;
							var r = t * n / i,
								o = parseInt((t - r) / 2);
							e.style.paddingTop = o + "px"
						}
						e.removeClassName("hidden")
					};
					YAHOO.util.Event.addListener(e + "_img", "load", _);
					var b = function() {
						$(n).select("." + o).each(function(e) {
							e.removeClassName(o)
						}), $(this.id).addClassName(o), r && r(this.id)
					};
					YAHOO.util.Event.addListener(e, "click", b)
				},
				f = function(e, n, i) {
					if (a.innerHTML = "", e.each(function(e) {
						p(i + "_" + e.id, e.img, e.title, e.strFirstLine, e.strSecondLine)
					}), l = new Element("div", {
						id: "noObjMsg"
					}).update("<< No objects >>"), l.addClassName("empty_list_text"), a.appendChild(l), 0 !== e.length && l.hide(), t) {
						var r = $(i + "_" + t);
						if (r) r.addClassName(o), YAHOO.util.Event.onAvailable(r.id, function() {
							var e = r.offsetTop,
								t = a.offsetTop,
								n = e - t,
								i = parseInt(r.getStyle("height")) / 2,
								o = parseInt(a.getStyle("height"));
							n + i > o && (a.scrollTop = n + i - o / 2)
						});
						else {
							var s = a.down();
							s && "noObjMsg" !== s.id && s.addClassName(o)
						}
					} else if (n) {
						var c = a.down();
						c && "noObjMsg" !== c.id && c.addClassName(o)
					}
				},
				g = function() {
					var e = $(a).select(".linkdlg_item");
					e.each(function(e) {
						e.remove()
					}), l.parent && l.remove()
				},
				m = e;
			this.repopulate = function(e, t) {
				m = t, g(), this.populate(e, !1, s)
			}, this.populate = function(e, t, n) {
				var i = ninesObjCache.get(m);
				if (s = n, e.setFlash("", !1), i) f(i, t, s);
				else {
					e.setFlash("Getting objects...", !1);
					var r = function(n) {
						e.setFlash("", !1);
						try {
							n.responseText.length > 0 && (i = n.responseText.evalJSON(!0), ninesObjCache.set(m, i), f(i, t, s))
						} catch (r) {
							new MessageBoxDlg("Error", r)
						}
					};
					serverRequest({
						url: m,
						onSuccess: r
					})
				}
			}, this.add = function(e) {
				a.appendChild(e), a.down("#noObjMsg").hide()
			}, this.popSelection = function() {
				var e = a.down("." + o);
				return e && (e.removeClassName(o), e.remove()), 1 === a.childNodes.length && a.down("#noObjMsg").show(), ninesObjCache.resetAll(), e
			}, this.getAllObjects = function() {
				var e = [],
					t = a.select(".linkdlg_item");
				return t.each(function(t) {
					var n = t.readAttribute("id");
					n = n.substring(n.indexOf("_") + 1), e.push(n)
				}), e
			}, this.getMarkup = function() {
				if (!a) {
					a = new Element("div", {
						id: n
					});
					var e = new Element("img", {
						src: i
					});
					e.addClassName("link_dlg_object_progress"), a.appendChild(e);
					var t = new Element("div");
					$(t).setStyle({
						padding: "8px",
						"text-align": "center"
					}), t.innerHTML = "Please wait while your collected objects are being loaded", a.appendChild(t)
				}
				return a.addClassName("linkdlg_list"), a
			};
			var v = "",
				_ = function() {
					var e = $(a).select(".linkdlg_item"),
						t = !1;
					e.each(function(e) {
						var n = e.innerHTML;
						n = n.stripTags(), v.blank() || n.toLowerCase().indexOf(v) >= 0 ? (e.show(), t = !0) : e.hide()
					}), t ? l.hide() : l.show()
				};
			this.filter = function(e) {
				v = e.toLowerCase(), _()
			}, this.sortby = function(t, n) {
				var i = ninesObjCache.get(e);
				"date_collected" !== n && (i = i.sortBy(function(e) {
					return "title" === n ? 0 === e.strFirstLine.length ? "ZZZZZZ" : e.strFirstLine.toUpperCase().gsub(/[^A-Z]/, "") : 0 === e.strSecondLine.length ? "ZZZZZZ" : e.strSecondLine.toUpperCase().gsub(/[^A-Z]/, "")
				})), g(), f(i, !0, s), _()
			}
		}
	}),
	LinkDlgHandler = Class.create({
		initialize: function(e, t) {
			var n = null,
				i = null,
				r = null,
				o = null;
			this.getPopulateUrls = function() {
				return e
			};
			var a = function(e, t) {
					for (var n = function(e, t, n, i) {
						var r = e.substring(t).indexOf(n),
							o = e.substring(t).indexOf(i);
						return r >= 0 && (-1 === o || o > r) ? {
							found: n,
							index: t + r
						} : o >= 0 ? {
							found: i,
							index: t + o
						} : {
							found: ""
						}
					}, i = function(e, t, n, i) {
						var r = e.substring(0, t).lastIndexOf(n),
							o = e.substring(0, t).lastIndexOf(i);
						return r >= 0 && r > o ? {
							found: n,
							index: r
						} : o >= 0 ? {
							found: i,
							index: o
						} : {
							found: ""
						}
					}, r = !1, o = t; !r;) {
						var a = i(e, o, "</span>", "real_link");
						if ("</span>" === a.found) o = e.substring(0, a.index).lastIndexOf("<span");
						else {
							if ("real_link" !== a.found) return null;
							o = e.substring(0, a.index).lastIndexOf("<span"), r = !0
						}
					}
					r = !1;
					for (var s = t; !r;) {
						var l = n(e, s, "</span>", "<span");
						if ("</span>" === l.found) s = l.index + 7, r = !0;
						else {
							if ("<span" !== l.found) return null;
							s = e.substring(l.index).lastIndexOf("</span>")
						}
					}
					return [o, s]
				},
				s = function(a, s) {
					var l = ["NINES Object", "External Link"],
						c = function(e, t) {
							var n = t === l[0] ? ".ld_link_only" : ".ld_nines_only",
								i = t !== l[0] ? ".ld_link_only" : ".ld_nines_only";
							$$(n).each(function(e) {
								e.addClassName("hidden")
							}), $$(i).each(function(e) {
								e.removeClassName("hidden")
							})
						},
						u = function(e) {
							for (var t = e, n = t.indexOf("real_link"); n > 0;) {
								var i = t.substring(0, n).lastIndexOf("<span"),
									r = t.substring(n).indexOf(">"),
									o = t.substring(n).indexOf("</span>");
								if (0 > i || 0 > r || 0 > o) return e;
								t = t.substring(0, i) + t.substring(n + r + 1, n + o) + t.substring(n + o + 7), n = t.indexOf("real_link")
							}
							return t
						},
						d = function() {
							return {
								prologue: o.substring(0, i),
								selection: o.substring(i, r),
								ending: o.substring(r)
							}
						},
						h = function(e, t) {
							var i = d();
							i.selection = u(i.selection), n.updateContents(i.prologue + i.selection + i.ending), t.dlg.cancel()
						},
						p = function(e, t) {
							var i = t.dlg,
								r = i.getAllData(),
								o = d();
							o.selection = u(o.selection), "NINES Object" === r.ld_type ? r.ld_nines_object && (o.selection = '<span title="' + l[0] + ": " + r.ld_nines_object + '" real_link="' + r.ld_nines_object + '" class="nines_linklike">' + o.selection + "</span>", n.updateContents(o.prologue + o.selection + o.ending)) : (o.selection = '<span title="' + l[1] + ": " + r.ld_link_url + '" real_link="' + r.ld_link_url + '" class="ext_linklike">' + o.selection + "</span>", n.updateContents(o.prologue + o.selection + o.ending)), t.dlg.cancel()
						},
						f = new CreateListOfObjects(e[0], 0 === a ? s : null, "ld_nines_object", t);
					2 === e.length && f.useTabs(e[1], e[0]);
					var g = {
						page: "layout",
						rows: [
							[{
								text: "Type of Link:",
								klass: "link_dlg_label"
							}, {
								select: "ld_type",
								callback: c,
								klass: "link_dlg_select",
								value: l[a],
								options: [{
									text: "NINES Object",
									value: "NINES Object"
								}, {
									text: "External Link",
									value: "External Link"
								}]
							}],
							[{
								text: "Sort objects by:",
								klass: "link_dlg_label ld_nines_only hidden"
							}, {
								select: "sort_by",
								callback: f.sortby,
								klass: "link_dlg_select ld_nines_only hidden",
								value: "date_collected",
								options: [{
									text: "Date Collected",
									value: "date_collected"
								}, {
									text: "Title",
									value: "title"
								}, {
									text: "Author",
									value: "author"
								}]
							}, {
								text: "and",
								klass: "link_dlg_label_and ld_nines_only hidden"
							}, {
								inputFilter: "filterObjectsLnk",
								prompt: "type to filter objects",
								callback: f.filter,
								klass: "ld_nines_only hidden"
							}],
							[{
								link: "[Remove Link]",
								callback: h,
								klass: "remove nav_link hidden"
							}],
							[{
								custom: f,
								klass: "link_dlg_label ld_nines_only hidden"
							}, {
								text: "Link URL",
								klass: "link_dlg_label ld_link_only hidden"
							}, {
								input: "ld_link_url",
								value: 1 === a ? s : "",
								klass: "link_dlg_input_long ld_link_only hidden"
							}],
							[{
								rowClass: "gd_last_row"
							}, {
								button: "Save",
								callback: p,
								isDefault: !0
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}]
						]
					};
					2 === e.length && (g.rows[2].push({
						link: "Exhibit Palette",
						klass: "dlg_tab_link_current ld_nines_only hidden",
						callback: f.ninesObjView,
						arg0: "exhibit"
					}), g.rows[2].push({
						link: "All My Objects",
						klass: "dlg_tab_link ld_nines_only hidden",
						callback: f.ninesObjView,
						arg0: "all"
					}));
					var m = {
							this_id: "link_dlg",
							pages: [g],
							body_style: "link_dlg",
							row_style: "link_dlg_row",
							title: "Set Link",
							focus: "link_dlg_sel0"
						},
						v = new GeneralDialog(m);
					f.populate(v, !0, "rte"), s.length > 0 && $$(".remove").each(function(e) {
						e.removeClassName("hidden")
					}), c(null, l[a]), v.center()
				};
			this.show = function(e, t, l, c) {
				n = e, i = l, r = c, o = t;
				var u = function(e) {
						var t = e.indexOf("real_link");
						if (0 > t) return null;
						var n = e.substring(t + 11).indexOf('"');
						return e.substring(t + 11, t + 11 + n)
					},
					d = "",
					h = 0,
					p = a(o, i);
				if (p) {
					i = p[0], r = p[1];
					var f = o.substring(i, r);
					f.indexOf("ext_linklike") > 0 && (h = 1);
					var g = f.indexOf("real_link") + 11,
						m = f.substring(g).indexOf('"');
					d = f.substring(g, g + m)
				} else p = u(o.substring(i, r)), p && (d = p);
				s(h, d)
			}
		}
	}),
	SignInDlg = Class.create({
		initialize: function() {
			this.class_type = "SignInDlg";
			var e = "",
				t = "";
			this.changeView = function(e, t) {
				var n = t.arg0,
					i = t.dlg,
					r = null;
				switch (n) {
					case "sign_in":
						r = "signin_username";
						break;
					case "create_account":
						r = "create_username";
						break;
					case "account_help":
						r = "help_username"
				}
				return i.changePage(n, r), !1
			}, this.sendWithAjax = function(e, n) {
				var i = n.arg0,
					r = n.dlg,
					o = r.getAllData(),
					a = function(e) {
						r.setFlash(e.responseText, !1), "" === t ? reloadPage() : gotoPage(t)
					};
				serverRequest({
					url: i,
					params: o,
					onSuccess: a,
					dlg: r
				})
			}, this.setInitialMessage = function(t) {
				e = t
			}, this.setRedirectPage = function(e) {
				t = e
			}, this.setRedirectPageToCurrentWithParam = function(e) {
				var n = "" + window.location,
					i = "";
				n.indexOf("#") > 0 && (i = n.substring(n.indexOf("#")), n = n.substring(0, n.indexOf("#"))), n += n.indexOf("?") > 0 ? "&" : "?", n += e, t = n + i
			}, this.show = function(t) {
				var n = {
						page: "sign_in",
						rows: [
							[{
								text: "Log in",
								klass: "login_title"
							}],
							[{
								text: "User name:",
								klass: "login_label"
							}],
							[{
								input: "signin_username",
								klass: "login_input"
							}],
							[{
								text: "Password:",
								klass: "login_label"
							}],
							[{
								password: "signin_password",
								klass: "login_input"
							}],
							[{
								button: "Log in",
								arg0: "/login/verify_login",
								callback: this.sendWithAjax,
								isDefault: !0
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}],
							[{
								text: "",
								klass: "login_label"
							}],
							[{
								link: "Create a new account",
								klass: "nav_link",
								arg0: "create_account",
								callback: this.changeView
							}],
							[{
								link: "Forgot user name or password?",
								klass: "nav_link",
								arg0: "account_help",
								callback: this.changeView
							}]
						]
					},
					i = {
						page: "account_help",
						rows: [
							[{
								text: "I forgot my password.",
								klass: "login_title"
							}],
							[{
								text: "Enter your user name and we will email a new password to your email account on file.",
								klass: "login_instructions"
							}],
							[{
								text: "User name:",
								klass: "login_label"
							}],
							[{
								input: "help_username",
								klass: "login_input"
							}],
							[{
								button: "Submit",
								arg0: "/login/reset_password",
								callback: this.sendWithAjax
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}],
							[{
								text: "",
								klass: "login_label"
							}],
							[{
								text: "",
								klass: "login_label"
							}],
							[{
								text: "I forgot my user name.",
								klass: "login_title"
							}],
							[{
								text: "Enter your email address and we will email you your user name.",
								klass: "login_instructions"
							}],
							[{
								text: "E-mail address:",
								klass: "login_label"
							}],
							[{
								input: "help_email",
								klass: "login_input"
							}],
							[{
								button: "Submit",
								arg0: "/login/recover_username",
								callback: this.sendWithAjax
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}],
							[{
								text: "",
								klass: "login_label"
							}],
							[{
								link: "Create a new account",
								klass: "nav_link",
								arg0: "create_account",
								callback: this.changeView
							}],
							[{
								link: "Log in",
								klass: "nav_link",
								arg0: "sign_in",
								callback: this.changeView
							}]
						]
					},
					r = {
						page: "create_account",
						rows: [
							[{
								text: "Create a New Account",
								klass: "login_title"
							}],
							[{
								text: "User name:",
								klass: "login_label"
							}],
							[{
								input: "create_username",
								klass: "login_input"
							}],
							[{
								text: "E-mail address:",
								klass: "login_label"
							}],
							[{
								input: "create_email",
								klass: "login_input"
							}],
							[{
								text: "Password:",
								klass: "login_label"
							}],
							[{
								password: "create_password",
								klass: "login_input"
							}],
							[{
								text: "Re-type password:",
								klass: "login_label"
							}],
							[{
								password: "create_password2",
								klass: "login_input"
							}],
							[{
								button: "Sign up",
								arg0: "/login/submit_signup",
								callback: this.sendWithAjax,
								isDefault: !0
							}, {
								button: "Cancel",
								callback: GeneralDialog.cancelCallback
							}],
							[{
								link: "Log in",
								klass: "nav_link",
								arg0: "sign_in",
								callback: this.changeView
							}]
						]
					},
					o = [n, i, r],
					a = {
						this_id: "login_dlg",
						pages: o,
						flash_notice: e,
						body_style: "login_div",
						row_style: "login_row"
					},
					s = new GeneralDialog(a);
				this.changeView(null, {
					curr_page: "",
					arg0: t,
					dlg: s
				}), s.center()
			}
		}
	}),
	RedirectIfLoggedIn = Class.create({
		initialize: function(e, t, n) {
			if (this.class_type = "RedirectIfLoggedIn", n) gotoPage(e);
			else {
				var i = new SignInDlg;
				i.setInitialMessage(t), i.setRedirectPage(e), i.show("sign_in")
			}
		}
	}); //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
jQuery(document).ready(function(e) {
	"use strict";
	var t = e("body");
	t.on("click", ".more_link", function() {
		var t = e(this),
			n = t.attr("data-div"),
			i = t.attr("data-less");
		i && 0 !== i.length || (i = "less", t.attr("data-less", i));
		var r = t.attr("data-more");
		r && 0 !== r.length || (r = t.text(), t.attr("data-more", r));
		var o = e("#" + n);
		o.length > 0 && (t.text() === i ? (o.hide(), t.text(r)) : (o.show(), t.text(i)))
	})
}); //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var nospam = function() {
	var e = $$("a.nospam");
	e.each(function(e) {
		var t = e.href,
			n = t.split("/"),
			i = n[n.length - 1].split("%20");
		if (3 === i.length) {
			var r = i[0] + "@" + i[1] + "." + i[2];
			e.href = "mailto:" + r, "$$$$" === e.innerHTML && (e.innerHTML = r)
		}
	})
};
document.observe("dom:loaded", function() {
	setTimeout(function() {
		nospam()
	}, 100)
}), //     Copyright 2014 Applied Research in Patacriticism and the University of Virginia
	jQuery(document).ready(function(e) {
		"use strict";
		var t = e("body");
		t.on("change", ".post-style .sort select", function() {
			var t = window.collex.getUrlVars(),
				n = e(this),
				i = this.id,
				r = n.val();
			r && r.length > 0 ? t[i] = r : delete t[i];
			var o = n.closest(".post-style"),
				a = o.attr("data-controller"),
				s = "/results",
				l = window.collex.makeQueryString(t);
			window.location = "/" + a + s + "?" + l
		}), t.on("click", ".post-style .select-facet", function() {
			var t = window.collex.getUrlVars(),
				n = e(this),
				i = n.attr("data-key"),
				r = n.attr("data-value");
			t[i] = r;
			var o = n.closest(".post-style"),
				a = o.attr("data-controller"),
				s = "/results",
				l = window.collex.makeQueryString(t);
			window.location = "/" + a + s + "?" + l
		})
	}), //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
	function() {
		var e = function() {
				YAHOO.widget.SimpleEditor.prototype.getNumSibs = function(e) {
					for (var t = 0, n = e; n.previousSibling;) n = n.previousSibling, (3 != n.nodeType || 0 != n.wholeText.trim().length) && 8 != n.nodeType && t++;
					return t
				}, YAHOO.widget.SimpleEditor.prototype.getXPathPosition = function(e) {
					for (var t = this.getNumSibs(e), n = [], i = e;
						 "BODY" !== i.parentNode.tagName;) i.parentNode && n.push(this.getNumSibs(i.parentNode)), i = i.parentNode;
					for (var r = [], o = n.length - 1; o >= 0; o--) r.push(n[o]);
					return r.push(t), r
				}, YAHOO.widget.SimpleEditor.prototype.checkStringForMatchingTags = function(e) {
					for (var t = 0, n = 0; n < e.length - 1; n++)
						if ("<" === e[n] && ("/" === e[n + 1] ? t-- : t++), 0 > t) return !1;
					return 0 === t
				}, YAHOO.widget.SimpleEditor.prototype.splitHtmlIntoArray = function(e) {
					var t = e.split("<");
					t = t.map(function(e) {
						return "<" + e
					}), "<" === t[0] ? t.shift() : t[0] = t[0].substring(1);
					for (var n = [], i = 0; i < t.length; i++)
						if (t[i].indexOf(">") > 0) {
							var r = t[i].split(">");
							n.push(r[0] + ">"), n.push(r[1])
						} else n.push(t[i]);
					return n
				}, YAHOO.widget.SimpleEditor.prototype.excludeOuterTagsFromSelection = function(e, t, n) {
					for (;
						"<" === e[t];) t = t + e.substring(t).indexOf(">") + 1;
					for (;
						">" === e[n - 1];) n = e.substring(0, n - 1).lastIndexOf("<");
					return {
						aOffset: t,
						fOffset: n
					}
				}, YAHOO.widget.SimpleEditor.prototype.canInsertTagsAroundSelection = function(e, t, n) {
					var i = e.substring(t, n),
						r = this.checkStringForMatchingTags(i);
					if (!r) {
						var o = this.excludeOuterTagsFromSelection(e, t, n);
						t = o.aOffset, n = o.fOffset, i = e.substring(t, n), r = this.checkStringForMatchingTags(i)
					}
					return r ? {
						aOffset: t,
						fOffset: n,
						selection: i,
						errorMsg: null
					} : {
						errorMsg: "Please try to select something different and attempt the operation again. [Problem: You cannot create a link when the selection is over different tags.]"
					}
				}, YAHOO.widget.SimpleEditor.prototype.guessSelectionEnd = function(e, t, n) {
					var i = (n + "").length,
						r = e.substring(t - i, t);
					return r === n ? t - i : (r = e.substring(t, t + i), r === n ? t + i : -1)
				}, YAHOO.widget.SimpleEditor.prototype.correctOffsetForSubstitutedText = function(e, t) {
					if (void 0 === e) return 0;
					var n = "" + e;
					return n = n.substr(0, t), n = n.escapeHTML(n), n.length
				}, YAHOO.widget.SimpleEditor.prototype.getRawSelectionPosition = function(e) {
					if (this.browser.opera) return null;
					var t = null,
						n = this._getSelection();
					if (this.browser.webkit) n + "" == "" && (n = null);
					else if (this.browser.ie) {
						var i = n.createRange(),
							r = i.htmlText;
						t = this.getEditorHTML();
						var o = t.indexOf(r);
						if (-1 !== o) return {
							startPos: o,
							endPos: o + r.length,
							selection: r,
							errorMsg: null
						};
						n.rangeCount = 2
					} else n && void 0 !== n || (n = null), e && "" === n.toString() && (n = null); if (null === n) return {
						errorMsg: "Nothing is selected."
					};
					if (1 !== n.rangeCount) return {
						errorMsg: "You cannot create a link when more than one area is selected."
					};
					var a = n.anchorNode,
						s = this.correctOffsetForSubstitutedText(a.data, n.anchorOffset),
						l = n.focusNode,
						c = this.correctOffsetForSubstitutedText(l.data, n.focusOffset),
						u = n.toString();
					if ("BODY" === a.tagName && "BODY" === l.tagName) {
						if (l.textContent === u) {
							var d = this.getEditorHTML();
							return {
								startPos: 0,
								endPos: d.length,
								selection: d,
								errorMsg: null
							}
						}
						return {
							errorMsg: "We're sorry. We can't figure out what you've selected. Try selecting a more than one character."
						}
					}
					var h = "BODY" === a.tagName ? null : this.getXPathPosition(a),
						p = "BODY" === l.tagName ? null : this.getXPathPosition(l);
					t = this.getEditorHTML().gsub("&nbsp;", " ");
					var f = this.splitHtmlIntoArray(t),
						g = -1,
						m = -1,
						v = [-1],
						_ = 0,
						b = !1;
					if (f.each(function(e) {
						if ("" !== e) {
							if (b) return e.endsWith("-->") && (b = !1), void(_ += e.length);
							if (e.startsWith("<!--") && 0 == e.endsWith("-->")) return b = !0, void(_ += e.length);
							"<br>" === e || "<hr>" === e || e.startsWith("<meta") || e.startsWith("<!--") && e.endsWith("-->") ? v[v.length - 1] ++ : "</" === e.substring(0, 2) ? v.pop() : "<" === e.substring(0, 1) && "/>" === e.substring(e.length - 3) ? v[v.length - 1] ++ : "<" === e.substring(0, 1) ? (v[v.length - 1] ++, v.push(-1)) : e.trim().length > 0 && v[v.length - 1] ++;
							var t = v.join(",");
							if (h && h.join(",") === t && (g = _ + s), p && p.join(",") === t && (m = _ + c), g > -1 || m > -1) throw $break;
							_ += e.length
						}
					}), -1 === g && (g = this.guessSelectionEnd(t, m, u)), -1 === m && (m = this.guessSelectionEnd(t, g, u)), g > m) {
						var y = g;
						g = m, m = y
					}
					var w = this.canInsertTagsAroundSelection(t, g, m);
					return w.errorMsg ? {
						errorMsg: w.errorMsg
					} : {
						startPos: w.aOffset,
						endPos: w.fOffset,
						selection: w.selection,
						errorMsg: null
					}
				}, YAHOO.widget.SimpleEditor.prototype.filter_safari = function(e) {
					if (this.browser.webkit) {
						e = e.replace(/<span class="Apple-tab-span" style="white-space:pre">([^>])<\/span>/gi, "&nbsp;&nbsp;&nbsp;&nbsp;"), e = e.replace(/Apple-style-span/gi, ""), e = e.replace(/style="line-height: normal;"/gi, ""), e = e.replace(/yui-wk-div/gi, ""), e = e.replace(/yui-wk-p/gi, ""), e = e.replace(/<li><\/li>/gi, ""), e = e.replace(/<li> <\/li>/gi, ""), e = e.replace(/<li>\s+<\/li>/gi, "");
						var t = e.startsWith("<div"),
							n = !1,
							i = "<DROPCAPDIV>",
							r = "</DROPCAPDIV>";
						if (t) {
							var o = e.lastIndexOf("</div>"); - 1 !== o && (e = i + e.substring(4, o) + r + e.substring(o), n = !0)
						} else e = e.replace('<div class=" ">', "");
						this.get("ptags") ? (e = e.replace(/<div([^>]*)>/g, "<p$1>"), e = e.replace(/<\/div>/gi, "</p>")) : (e = e.replace(/<div([^>]*)>([ tnr]*)<\/div>/gi, "<br>"), e = e.replace(/<\/div>/gi, "")), n && (e = e.replace(i, "<div"), e = e.replace(r, "</div>"))
					}
					return e
				}
			},
			t = function() {
				void 0 === YAHOO.widget.SimpleEditor ? setTimeout(t, 100) : e()
			};
		t()
	}();
var RichTextEditor = Class.create({
	initialize: function(e) {
		this.class_type = "RichTextEditor";
		var t = this,
			n = e.id,
			i = e.toolbarGroups,
			r = e.linkDlgHandler,
			o = e.footnote,
			a = void 0,
			s = void 0,
			l = void 0,
			c = void 0;
		o && (a = o.callback, s = e.populate_all, l = e.populate_exhibit_only, c = o.progress_img);
		var u = e.bodyStyle ? e.bodyStyle : "",
			d = {
				group: "fontstyle",
				label: "Font Name and Size",
				buttons: [{
					type: "select",
					label: "Arial",
					value: "fontname",
					disabled: !0,
					menu: [{
						text: "Arial",
						checked: !0
					}, {
						text: "Arial Black"
					}, {
						text: "Comic Sans MS"
					}, {
						text: "Courier New"
					}, {
						text: "Lucida Console"
					}, {
						text: "Tahoma"
					}, {
						text: "Times New Roman"
					}, {
						text: "Trebuchet MS"
					}, {
						text: "Verdana"
					}]
				}, {
					type: "spin",
					label: "13",
					value: "fontsize",
					range: [9, 75],
					disabled: !0
				}]
			},
			h = {
				group: "textstyle",
				label: "Font Style",
				buttons: [{
					type: "push",
					label: "Bold CTRL + SHIFT + B",
					value: "bold"
				}, {
					type: "push",
					label: "Italic CTRL + SHIFT + I",
					value: "italic"
				}, {
					type: "push",
					label: "Underline CTRL + SHIFT + U",
					value: "underline"
				}, {
					type: "push",
					label: "Strike Through",
					value: "strikethrough"
				}]
			},
			p = {
				group: "textstyle",
				label: "Font Style",
				buttons: [{
					type: "push",
					label: "Bold CTRL + SHIFT + B",
					value: "bold"
				}, {
					type: "push",
					label: "Italic CTRL + SHIFT + I",
					value: "italic"
				}, {
					type: "push",
					label: "Underline CTRL + SHIFT + U",
					value: "underline"
				}, {
					type: "push",
					label: "Strike Through",
					value: "strikethrough"
				}, {
					type: "push",
					label: "First Letter",
					value: "firstletter"
				}]
			},
			f = {
				group: "alignment",
				label: "Alignment",
				buttons: [{
					type: "push",
					label: "Align Left CTRL + SHIFT + [",
					value: "justifyleft"
				}, {
					type: "push",
					label: "Align Center CTRL + SHIFT + |",
					value: "justifycenter"
				}, {
					type: "push",
					label: "Align Right CTRL + SHIFT + ]",
					value: "justifyright"
				}, {
					type: "push",
					label: "Justify",
					value: "justifyfull"
				}]
			},
			g = {
				group: "indentlist",
				label: "Lists",
				buttons: [{
					type: "push",
					label: "Create an Unordered List",
					value: "insertunorderedlist"
				}, {
					type: "push",
					label: "Create an Ordered List",
					value: "insertorderedlist"
				}]
			},
			m = {
				group: "insertitem",
				label: "Insert Item",
				buttons: [{
					type: "push",
					label: "HTML Link CTRL + SHIFT + L",
					value: "createlink",
					disabled: !0
				}]
			},
			v = {
				group: "insertitem",
				label: "Insert Item",
				buttons: [{
					type: "push",
					label: "HTML Link CTRL + SHIFT + L",
					value: "createlink",
					disabled: !0
				}, {
					type: "push",
					label: "Insert Footnote",
					value: "createfootnote"
				}]
			},
			_ = {
				type: "separator"
			},
			b = function() {
				var e = t.editor;
				e.on("toolbarLoaded", function() {
					this.toolbar.on("firstletterClick", function() {
						var e = this.getEditorHTML(),
							n = !e.include("drop_cap");
						if (n)
							if (e.startsWith("<div")) {
								var i = e.substring(0, e.indexOf(">")),
									r = i.indexOf("class=");
								e = -1 === r ? '<div class="drop_cap" ' + e.substring(4) + "</div>" : e.substring(0, r + 7) + "drop_cap " + e.substring(r + 7)
							} else e = "<div class='drop_cap'>" + e + "</div>";
						else e = e.gsub("drop_cap", "");
						t.updateContents(e)
					}, this, !0)
				})
			},
			y = function() {
				if (void 0 !== o && null !== o) {
					var e = t.editor;
					e.on("toolbarLoaded", function() {
						e.toolbar.on("createfootnoteClick", function() {
							var n = null,
								i = function(i) {
									var r = a("add", i),
										o = e.getEditorHTML().gsub("&nbsp;", " ");
									o = o.substr(0, n) + r + o.substr(n), t.updateContents(o)
								},
								r = e.getRawSelectionPosition(!1);
							return r ? r.errorMsg ? (new MessageBoxDlg("Error", r.errorMsg), !1) : (n = r.endPos, new RteInputDlg({
								title: "Add Footnote",
								okCallback: i,
								value: "",
								populate_urls: [l, s],
								progress_img: c
							}), !0) : (new MessageBoxDlg("Error", "IE has not been implemented yet."), !1)
						}, this, !0)
					}, this, !0), e.on("editorContentLoaded", function() {
						t.initializeFootnoteEvents()
					}, this, !0)
				}
			};
		this.updateContents = function(e) {
			t.editor.setEditorHTML(e), t.initializeFootnoteEvents()
		}, this.initializeFootnoteEvents = function() {
			var e = $(n + "_editor"),
				t = e.contentDocument;
			(void 0 === t || null === t) && (t = e.contentWindow.document);
			var i = [],
				r = function(e) {
					$A(e.childNodes).each(function(e) {
						"A" === e.nodeName && e.className.indexOf("rte_footnote") >= 0 && i.push(e), e.childNodes.length > 0 && r(e)
					})
				};
			$A(t.childNodes).each(function(e) {
				r(e)
			});
			var o = null,
				u = function() {
					o && (o.remove(), o = null)
				},
				d = function(e) {
					for (var t = 0; null !== e;) t += e.offsetLeft, e = e.offsetParent;
					return t
				},
				h = function(e) {
					for (var t = 0; null !== e;) t += e.offsetTop, e = e.offsetParent;
					return t
				},
				p = function(t) {
					var n = t.target;
					void 0 === n && (n = this), $A(n.childNodes).each(function(t) {
						if (t.className.indexOf("tip") >= 0) {
							var i = $("gd_modal_dlg_parent"),
								r = d(n) + d(e.offsetParent) + 20,
								a = h(n) + h(e.offsetParent) + 20;
							o = new Element("div", {
								style: "z-index:500; position: absolute; top:" + a + "px; left:" + r + "px; width:20em; border:1px solid #914C29; background-color: #F7ECDB; color:#000; text-align: left; font-weight: normal; padding: .3em;"
							}).update(t.innerHTML), i.appendChild(o)
						}
					})
				},
				f = function(e) {
					var t = e.target;
					void 0 === t && (t = this), u();
					var n = function(e) {
							var n = a("edit", e);
							t.innerHTML = n
						},
						i = function(e, n) {
							n.dlg.cancel(), t.parentNode.removeChild(t)
						},
						r = t.childNodes[0];
					new RteInputDlg({
						title: "Edit Footnote",
						okCallback: n,
						value: r.innerHTML,
						populate_urls: [l, s],
						progress_img: c,
						extraButton: {
							label: "Delete Footnote",
							callback: i
						}
					})
				};
			i.each(function(e) {
				YAHOO.util.Event.addListener(e, "mouseover", p, null), YAHOO.util.Event.addListener(e, "mouseout", u, null), YAHOO.util.Event.addListener(e, "click", f, null)
			})
		};
		var w = function() {
			if (void 0 !== r && null !== r) {
				var e = t.editor;
				e.on("editorKeyDown", function(n) {
					var i = function(e) {
							return e = e.gsub("<br>", "").gsub("<br/>", "").gsub("<br />", ""), e = e.gsub(/<a(.*?)href="(.*?)"(.*?)>(.*?)<\/a>/, "#{2}#{4}"), e = e.gsub(/<span (.*?)class="ext_linklike" real_link="(.*?)"(.*?)>(.*?)<\/span>/, "#{2}#{4}"), e = e.gsub(/<span (.*?)class="nines_linklike" real_link="(.*?)"(.*?)>(.*?)<\/span>/, "#{2}#{4}\b"), e = e.gsub(/<span (.*?)real_link="(.*?)" class="ext_linklike"(.*?)>(.*?)<\/span>/, "#{2}#{4}"), e = e.gsub(/<span (.*?)real_link="(.*?)" class="nines_linklike"(.*?)>(.*?)<\/span>/, "#{2}#{4}\b"), e = e.stripTags().stripScripts().gsub("&nbsp;", "").escapeHTML(), e = e.gsub("", "<br/>"), e = e.gsub(/\x03(.*?)\x04(.*?)\x05/, '<span class="ext_linklike" real_link="#{1}" title="External Link: #{1}">#{2}</span>'), e = e.gsub(/\x06(.*?)\x07(.*?)\x08/, '<span class="nines_linklike" real_link="#{1}" title="NINES Link: #{1}">#{2}</span>'), e + " "
						},
						r = n.ev.ctrlKey,
						o = n.ev.metaKey,
						a = n.ev.keyCode;
					if (86 === a && (r || o)) {
						var s = e.getRawSelectionPosition(!1),
							l = e.getEditorHTML();
						if (void 0 === s.errorMsg) {
							var c = l.substring(0, s.startPos),
								u = l.substring(s.endPos);
							setTimeout(function() {
								var n = e.getEditorHTML(),
									r = i(n.substring(s.startPos, n.length - u.length));
								t.updateContents(c + r + u)
							}, 10)
						} else setTimeout(function() {
							for (var n = e.getEditorHTML(), r = null, o = 0; o < l.length && l[o] === n[o]; o++) "<" === l[o] && (r = o), ">" === l[o] && (r = null);
							null !== r && (o = r);
							for (var a = l.length - 1, s = n.length - 1;;) {
								if (0 > a || 0 > s) break;
								if (l[a] !== n[s]) break;
								a--, s--
							}
							for (var c = s; c > 0 && ">" !== n[c];) {
								if ("<" === n[c]) {
									for (; s < n.length && ">" !== n[s];) s++;
									break
								}
								c--
							}
							s++;
							var u = n.substring(0, o),
								d = i(n.substring(o, s)),
								h = n.substring(s);
							t.updateContents(u + d + h)
						}, 10)
					}
					return !0
				}, this, !0), e.on("toolbarLoaded", function() {
					e.toolbar.on("createlinkClick", function() {
						var n = e.getRawSelectionPosition(!0);
						return n ? n.errorMsg ? (new MessageBoxDlg("Error", n.errorMsg), !1) : (r.show(t, e.getEditorHTML(), n.startPos, n.endPos), !1) : (new MessageBoxDlg("Error", "IE has not been implemented yet."), !1)
					}, this, !0)
				}, this, !0)
			}
		};
		this.attachToDialog = function(e) {
			e.showEvent.subscribe(this.editor.show, this.editor, !0), e.hideEvent.subscribe(this.editor.hide, this.editor, !0)
		}, this.save = function() {
			var e = this.editor._getDoc().body;
			void 0 !== e && (this.editor.cleanHTML(), this.editor.saveHTML())
		};
		var x = {
				buttonType: "advanced",
				draggable: !1,
				buttons: []
			},
			E = !1,
			k = !0;
		i.each(function(e) {
			switch (k || x.buttons.push(_), k = !1, e) {
				case "font":
					x.buttons.push(d);
					break;
				case "fontstyle":
					x.buttons.push(h);
					break;
				case "dropcap":
					E = !0, x.buttons.push(p);
					break;
				case "alignment":
					x.buttons.push(f);
					break;
				case "list":
					x.buttons.push(g);
					break;
				case "link":
					x.buttons.push(m);
					break;
				case "link&footnote":
					x.buttons.push(v)
			}
		});
		var C = null !== e.width ? e.width : 702,
			T = " a.rte_footnote { background: url(/assets/rte_footnote.jpg) top right no-repeat; padding-right: 9px; cursor: pointer !important; } a.rte_footnote span { display: none; }",
			S = " a:link { color: #A60000 !important; text-decoration: none !important; } a:visited { color: #A60000 !important; text-decoration: none !important; } a:hover { color: #A60000 !important; text-decoration: none !important; } .nines_linklike { color: #A60000; background: url(../assets/nines/nines_link.jpg) center right no-repeat; padding-right: 13px; } .ext_linklike { color: #A60000; background: url(../assets/external_link.jpg) center right no-repeat; padding-right: 13px; }",
			O = ' .drop_cap:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} .drop_cap p:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} ';
		this.editor = new YAHOO.widget.SimpleEditor(n, {
			width: C + "px",
			height: "200px",
			css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + " " + u + T + S + O,
			toolbar: x,
			animate: !0
		}), E && b(), this.editor.render(), w(), y()
	}
});
jQuery(document).ready(function() {
	"use strict";
	window.collex.getArchive = function(e) {
		function t(e, n) {
			for (var i = 0; i < e.length; i++) {
				var r = e[i];
				if (r.handle === n) return r;
				if (r.children) {
					var o = t(r.children, n);
					if (o) return o
				}
			}
			return null
		}
		return t(window.collex.facetNames.archives, e)
	}, window.collex.getSite = function(e) {
		var t = window.collex.getArchive(e);
		return t ? window.pss.createHtmlTag("a", {
			"class": "nines_link",
			target: "_blank",
			href: t.site_url
		}, t.name) : e
	}, window.collex.getArchiveNode = function(e) {
		function t(e, n) {
			for (var i = 0; i < e.length; i++) {
				var r = e[i];
				if (r.id === n) return r;
				if (r.children) {
					var o = t(r.children, n);
					if (o) return o
				}
			}
			return null
		}
		return e = parseInt(e, 10), t(window.collex.facetNames.archives, e)
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(t, n) {
		function i(e) {
			for (var t = [], i = 0; i < e.length; i++) {
				var r = e[i];
				t.push({
					label: r[0] + " (" + r[1] + ")",
					value: r[0]
				})
			}
			n(t)
		}

		function r() {
			n([])
		}
		var o = this.element,
			a = o.attr("data-autocomplete-url") + ".json",
			s = o.attr("data-autocomplete-field"),
			l = e("meta[name=csrf-param]")[0].content,
			c = e("meta[name=csrf-token]")[0].content;
		t.other = window.collex.removeSortAndPageFromQueryObject(), t.field = s ? e(s).val() : "q", t.term = window.collex.sanitizeString(t.term), t[l] = c;
		for (var u = ["q", "t", "aut", "ed", "pub"], d = !1, h = 0; !d && h < u.length; h++) t.field === u[h] && (d = !0);
		d && t.term.length > 2 && -1 === t.term.indexOf(" ") && e.post(a, t).done(i).fail(r)
	}
	e("body");
	window.collex.initAutoComplete = function(n) {
		var i = e(n);
		i.autocomplete({
			source: t,
			minLength: 2,
			delay: 500
		})
	}, e(".jq-autocomplete").each(function(e, t) {
		window.collex.initAutoComplete(t)
	})
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e, t, n) {
		var i = window.pss.createHtmlTag("a", {
			"class": "modify_link query-editable",
			href: "#",
			"data-original": n,
			"data-type": t
		}, n);
		e.html(i)
	}
	var n = e("body");
	n.on("blur", ".query-editing", function() {
		var i = e(this),
			r = i.attr("data-type"),
			o = i.attr("data-original"),
			a = i.val(),
			s = i.attr("data-processing");
		s || o === a || n.trigger("ModifySearch", {
			key: r,
			original: o,
			newValue: a
		});
		var l = i.closest("td");
		t(l, r, a)
	}), n.on("keydown", ".query-editing", function(e) {
		var t = e.which;
		return 13 === t || 10 === t || 27 === t ? !1 : void 0
	}), n.on("keyup", ".query-editing", function(i) {
		var r = e(this),
			o = r.closest("td"),
			a = i.which,
			s = r.attr("data-original"),
			l = r.val(),
			c = r.attr("data-type");
		return 13 === a || 10 === a ? (r.attr("data-processing", "true"), n.trigger("ModifySearch", {
			key: c,
			original: s,
			newValue: l
		}), !1) : 27 === a ? (r.attr("data-processing", "true"), t(o, c, s), !1) : void 0
	}), n.on("click", ".query-editable", function() {
		var t = e(this),
			n = t.closest("td"),
			i = t.attr("data-type"),
			r = t.text();
		return n.html("<input type='text' data-original='" + r + "' data-type='" + i + "' value='" + r + "' class='query-editing' />"), n.find(".query-editing").focus(), !1
	})
}), //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
	jQuery(document).ready(function(e) {
		"use strict";
		var t = e("body");
		t.on("click", ".resource-tree-node button", function() {
			var t = e(this),
				n = t.closest(".resource-tree-node"),
				i = n.find('button[data-action="open"]'),
				r = t.attr("data-action"),
				o = n.attr("data-id");
			"toggle" === r && (r = i.is(":visible") ? "open" : "close");
			var a = window.collex.getArchiveNode(o);
			a && (a.toggle = r);
			var s = e(".facet-archive");
			s.find("tr").show(), s.find("button").show(), window.collex.setResourceToggle(s, window.collex.facetNames.archives), serverNotify("/search/remember_resource_toggle", {
				dir: r,
				id: o
			})
		})
	});
var ResultRowDlg = Class.create({
		initialize: function(e, t, n, i) {
			this.class_type = "ResultRowDlg";
			var r = null,
				o = "",
				a = i;
			a.uri = t;
			var s = function() {
					var t = function(t) {
						r.setFlash("", !1);
						try {
							o = t.responseText
						} catch (n) {
							genericAjaxFail(r, n, e)
						}
						var i = $$(".result_row_details"),
							a = i[0];
						a.update(o);
						var s = a.select(".search_result_data .hidden");
						s.each(function(e) {
							e.removeClassName("hidden")
						})
					};
					serverRequest({
						url: e,
						params: a,
						onSuccess: t
					})
				},
				l = {
					page: "layout",
					rows: [
						[{
							text: '<img src="' + n + '" alt="Please wait..." />',
							klass: "result_row_details"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback,
							isDefault: !0
						}]
					]
				},
				c = {
					this_id: "result_row_dlg",
					pages: [l],
					body_style: "result_row_dlg",
					row_style: "result_row_row",
					title: "Object Details"
				};
			r = new GeneralDialog(c), r.center(), s()
		}
	}),
	bulk_checked = !1,
	StartDiscussionWithObject = Class.create({
		initialize: function(e, t, n, i, r, o, a, s) {
			this.class_type = "StartDiscussionWithObject";
			var l = null;
			if (!o) {
				var c = new SignInDlg;
				return c.setInitialMessage("Please log in to start a discussion"), c.setRedirectPageToCurrentWithParam("script=StartDiscussionWithObject"), void c.show("sign_in")
			}
			var u = function() {
				var t = function(e) {
					var t = [];
					l.setFlash("", !1);
					try {
						e.responseText.length > 0 && (t = e.responseText.evalJSON(!0))
					} catch (n) {
						new MessageBoxDlg("Error", n)
					}
					var i = $$(".discussion_topic_select"),
						r = i[0];
					r.update(""), t = t.sortBy(function(e) {
						return e.text
					}), t.each(function(e) {
						r.appendChild(new Element("option", {
							value: e.value
						}).update(e.text))
					}), $("topic_id").writeAttribute("value", t[0].value)
				};
				serverRequest({
					url: e,
					onSuccess: t
				})
			};
			this.sendWithAjax = function(e, t) {
				var i = t.arg0,
					o = t.dlg;
				o.setFlash("Updating Discussion Topics...", !1);
				var a = o.getAllData();
				a.inet_thumbnail = "", a.thread_id = "", a.nines_exhibit = "", a.nines_object = n, a.inet_url = "", a.inet_title = "", a.disc_type = "NINES Object";
				var s = function(e) {
					jQuery(r).hide(), o.cancel(), gotoPage(e.responseText)
				};
				serverRequest({
					url: i,
					params: a,
					onSuccess: s
				})
			};
			var d = new ForumLicenseDisplay({
					populateLicenses: "/exhibits/get_licenses?non_sharing=false",
					currentLicense: 5,
					id: "license_list"
				}),
				h = {
					page: "start_discussion",
					rows: [
						[{
							text: "Starting a discussion of: " + i,
							klass: "new_exhibit_label"
						}],
						[{
							custom: d,
							klass: "forum_reply_license title"
						}, {
							text: "Select the topic you want this discussion to appear under:",
							klass: "new_exhibit_label"
						}],
						[{
							select: "topic_id",
							klass: "discussion_topic_select",
							options: [{
								value: -1,
								text: "Loading discussion topics. Please Wait..."
							}]
						}],
						[{
							text: "Title",
							klass: "forum_reply_label title "
						}],
						[{
							input: "title",
							klass: "forum_reply_input title"
						}],
						[{
							textarea: "description"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				p = {
					this_id: "start_discussion_with_object_dlg",
					pages: [h],
					body_style: "forum_reply_dlg",
					row_style: "new_exhibit_row",
					title: "Choose Discussion Topic",
					focus: "start_discussion_with_object_dlg_sel0"
				};
			l = new GeneralDialog(p), l.initTextAreas({
				toolbarGroups: ["fontstyle", "link"],
				linkDlgHandler: new LinkDlgHandler([a], s)
			}), d.populate(l), l.center(), u(l)
		}
	}); //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
jQuery(document).ready(function(e) {
	"use strict";
	window.collex.showString = function(t) {
		new TextInputDlg({
			title: "Copy and Paste link into E-mail or IM",
			prompt: "Link:",
			id: "show_save_name",
			value: t,
			inputKlass: "saved_search_copy_el",
			body_style: "saved_search_copy_body",
			noOk: !0
		}), e("#show_save_name").select()
	}, window.collex.showHiddenSavedSearches = function(t, n) {
		var i = e("." + t),
			r = e("." + n),
			o = "[show all]" === i.text();
		o ? (i.text("[hide some]"), r.removeClass("hidden"), i.closest(".empty_list_text").find(".hiding-text").hide()) : (i.text("[show all]"), r.addClass("hidden"), i.closest(".empty_list_text").find(".hiding-text").show())
	}, window.collex.doSaveSearch = function() {
		function e(e) {
			var t = e.responseJSON;
			window.collex.savedSearches.push({
				name: t.name,
				url: t.url
			}), window.collex.drawSavedSearch(), window.collex.drawSavedSearchList()
		}
		new TextInputDlg({
			title: "Save Search",
			prompt: "Name:",
			id: "saved_search_name",
			okStr: "Save",
			actions: "/search/save_search",
			target_els: "bit-bucket",
			pleaseWaitMsg: "Storing the current search...",
			extraParams: {
				query: encodeURIComponent(window.location.search.substr(1))
			},
			onSuccess: e
		})
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t() {
		var e = {
				page: "spinner_layout",
				rows: [
					[{
						text: " ",
						klass: "gd_transparent_progress_spinner"
					}],
					[{
						rowClass: "gd_progress_label_row"
					}, {
						text: "Searching...",
						klass: "transparent_progress_label"
					}]
				]
			},
			t = {
				this_id: "gd_progress_spinner_dlg",
				pages: [e],
				body_style: "gd_progress_spinner_div",
				row_style: "gd_progress_spinner_row"
			};
		m = new GeneralDialog(t), m.center()
	}

	function n(e) {
		e.query = window.collex.getUrlVars();
		for (var t in e.query) e.query.hasOwnProperty(t) && (e.query[t] && 0 !== e.query[t].length || delete e.query[t]);
		g.trigger("RedrawSearchResults", e), setTimeout(function() {
			m && (m.cancel(), m = null)
		}, 200)
	}

	function i(e) {
		setTimeout(function() {
			m && (m.cancel(), m = null)
		}, 200), window.console.error(e)
	}

	function r() {
		var r = window.collex.getUrlVars();
		e.ajax({
			url: "/search.json",
			data: r,
			success: n,
			error: i
		}), m && (m.cancel(), m = null, setTimeout(function() {
			t()
		}, 200))
	}

	function o(t, n) {
		var i = window.collex.getUrlVars();
		return void 0 === i[t] ? i[t] = n : "string" == typeof i[t] ? i[t] = [i[t], n] : -1 === e.inArray(n, i[t]) && i[t].push(n), i
	}

	function a(t, n) {
		var i = window.collex.getUrlVars();
		if (void 0 === i[t]) return i;
		if ("string" == typeof i[t]) i[t] === n && delete i[t];
		else {
			var r = e.inArray(n, i[t]); - 1 !== r && i[t].splice(r, 1)
		}
		return i
	}

	function s(t, n, i) {
		var r = window.collex.getUrlVars();
		if (void 0 === r[t]) return r;
		if ("string" == typeof r[t]) r[t] === n && (r[t] = i);
		else {
			var o = e.inArray(n, r[t]); - 1 !== o && (r[t][o] = i)
		}
		return r
	}

	function l() {
		var e = window.collex.getUrlVars(),
			t = {};
		return e.srt && (t.srt = e.srt), e.dir && (t.dir = e.dir), e.f && (t.f = e.f), t
	}

	function c(e, t) {
		var n = window.collex.getUrlVars();
		return n[e] = t, n
	}

	function u(e, t, n) {
		var i;
		return i = "remove" === n ? a(e, t) : "add" === n ? o(e, t) : c(e, t), "page" !== e && delete i.page, "/search?" + window.collex.makeQueryString(i)
	}

	function d(e) {
		var n = "/search" + window.location.search;
		if (e !== n) {
			t(), window.collex.resetNameFacet();
			var i = document.title;
			History.pushState(null, i, e)
		}
	}

	function h(e) {
		var t = e.closest("tr"),
			n = t.find(".query_type_select").val(),
			i = t.find(".query_term input").val();
		i = window.collex.sanitizeString(i);
		var r = t.find(".new-query_and-not select").val();
		"NOT" === r && i && "-" !== i[0] && (i = "-" + i);
		var o = u(n, i, "add");
		d(o)
	}

	function p() {
		var t = window.collex.getUrlVars(),
			n = e(".sort select[name='dir']");
		t.srt && t.srt.length > 0 ? (e(".sort select[name='srt']").val(t.srt), t.dir && t.dir.length > 0 && n.val(t.dir)) : n.hide()
	}

	function f() {
		window.collex && ("search" === window.collex.pageName ? (p(), t(), setTimeout(r, 10)) : window.collex.hits && window.collex.hits.length > 0 && setTimeout(function() {
			g.trigger("DrawHits", {
				hits: window.collex.hits,
				collected: window.collex.collected
			}), window.collex.drawSavedSearchList()
		}, 10))
	}
	var g = e("body"),
		m = null;
	window.collex.getUrlVars = function() {
		var e = {},
			t = "" + window.location.search;
		if ("" === t) return e;
		t = t.substr(1);
		for (var n = t.split("&"), i = 0; i < n.length; i++) {
			var r;
			r = n[i].split("="), 1 === r.length && r.push("");
			var o = decodeURIComponent(r[1]);
			void 0 !== e[r[0]] ? "string" == typeof e[r[0]] ? e[r[0]] = [e[r[0]], o] : e[r[0]].push(o) : e[r[0]] = o
		}
		return e
	}, window.collex.makeQueryString = function(e) {
		var t = [];
		for (var n in e)
			if (e.hasOwnProperty(n)) {
				var i = e[n];
				if ("string" == typeof i) t.push(n + "=" + i);
				else
					for (var r = 0; r < i.length; r++) t.push(n + "=" + i[r])
			}
		return t.join("&")
	}, History.Adapter.bind(window, "statechange", function() {
		History.getState(), r()
	}), window.collex.removeSortFromQueryObject = function() {
		var e = window.collex.getUrlVars();
		return delete e.srt, delete e.dir, e
	}, window.collex.removeSortAndPageFromQueryObject = function() {
		var e = window.collex.removeSortFromQueryObject();
		return delete e.page, e
	}, g.on("click", ".new_search", function() {
		var e = l();
		d("/search?" + window.collex.makeQueryString(e))
	}), g.on("click", ".ajax-style .select-facet", function() {
		var t = e(this),
			n = t.attr("data-key"),
			i = t.attr("data-value"),
			r = t.attr("data-action"),
			o = u(n, i, r);
		d(o)
	}), g.on("change", ".ajax-style .sort select", function() {
		var t, n = e(this),
			i = n.attr("name"),
			r = n.val();
		if ("srt" === i)
			if ("rel" === r) {
				e(".sort select[name='dir']").hide();
				var o = window.collex.removeSortFromQueryObject();
				t = "/search?" + window.collex.makeQueryString(o)
			} else e(".sort select[name='dir']").show();
		t || (t = u(i, r, "replace")), d(t)
	}), window.collex.sanitizeString = function(t) {
		for (t = t.replace(/[^0-9A-Za-z'"\u00C0-\u017F]/g, " ");
			 "'" === t.substr(0, 1);) t = t.substr(1);
		return t = t.replace(/ '/g, " "), t = t.replace(/\s+/g, " "), e.trim(t)
	}, g.on("click", ".query_add", function() {
		h(e(this))
	}), g.on("change", ".query_and-not select", function() {
		var t = e(this),
			n = t.val(),
			i = t.attr("data-key"),
			r = t.attr("data-val"),
			o = r;
		"AND" === n && "-" === o[0] && (o = o.substr(1)), "NOT" === n && "-" !== o[0] && (o = "-" + o);
		var a = s(i, r, o);
		d("/search?" + window.collex.makeQueryString(a))
	}), g.on("keydown", ".query.search-form .new-search-term input", function(e) {
		var t = e.which;
		return 13 === t || 10 === t ? !1 : void 0
	}), g.on("keyup", ".query.search-form .new-search-term input", function(t) {
		var n = t.which;
		return 13 === n || 10 === n ? (h(e(this)), !1) : void 0
	}), g.on("change", ".search_all_federations", function() {
		if (this.checked) {
			for (var t = [], n = e(".limit_to_federation input"), i = 0; i < n.length; i++) t.push(n[i].name);
			var r = u("f", t, "replace");
			d(r)
		}
	}), g.on("change", ".limit_to_federation input", function() {
		var t = e(".limit_to_federation input"),
			n = !0,
			i = [];
		t.each(function(e, t) {
			t.checked && (n = !1, i.push(t.name))
		});
		var r = window.collex.getUrlVars();
		n ? delete r.f : r.f = i, delete r.page, d("/search?" + window.collex.makeQueryString(r))
	}), g.bind("SetSearch", function(e, t) {
		for (var n in t) t.hasOwnProperty(n) && (t[n] = window.collex.sanitizeString(t[n]));
		var i = l();
		jQuery.extend(t, i), d("/search?" + window.collex.makeQueryString(t))
	}), g.bind("ModifySearch", function(e, t) {
		var n = s(t.key, t.original, window.collex.sanitizeString(t.newValue));
		d("/search?" + window.collex.makeQueryString(n))
	}), f()
}), //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
	jQuery(document).ready(function(e) {
		"use strict";
		var t = e("body");
		t.on("click", ".expandSearchNameFacet", function() {
			var t = e("#search_name_facet_min"),
				n = e("#search_name_facet_max");
			t.addClass("hidden"), n.removeClass("hidden");
			var i = e("#search_name_never_requested");
			if (i) {
				var r = function(e) {
					new MessageBoxDlg("Error in retrieving names", "There was an error getting the list of names from the server. The problem was: " + e.responseText)
				};
				serverAction({
					action: {
						els: "search_name_facet_max",
						actions: "/search/list_name_facet_all",
						params: {
							query: window.collex.removeSortAndPageFromQueryObject()
						},
						onFailure: r
					}
				})
			}
		}), t.on("click", ".minimizeSearchNameFacet", function() {
			var t = e("#search_name_facet_min"),
				n = e("#search_name_facet_max");
			n.addClass("hidden"), t.removeClass("hidden")
		}), t.on("click", ".showAllSearchNameFacet", function() {
			new ShowDivInLightbox({
				title: "Name Browser",
				id: "full_name_facet_list",
				klass: "name_facet_in_lightbox"
			})
		}), window.collex.resetNameFacet = function() {
			var t = e("#search_name_facet_max"),
				n = window.pss.createHtmlTag("div", {
					id: "search_name_never_requested"
				}, window.pss.createHtmlTag("img", {
					alt: "Please wait...",
					src: "/assets/ajax_loader.gif"
				}) + "<br><br>Searching for names. Please wait a moment...");
			t.html(n);
			var i = e("#search_name_facet_min"),
				r = e("#search_name_facet_max");
			r.addClass("hidden"), i.removeClass("hidden")
		}
	}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e, t, n, i, r) {
		if (r || (r = e), i) {
			var o = window.collex.create_facet_button("[X]", e, "remove", n);
			return window.pss.createHtmlTag("tr", {
				"class": "limit_to_selected"
			}, window.pss.createHtmlTag("td", {
				"class": "limit_to_lvl1"
			}, r + "&nbsp;&nbsp;" + o) + window.pss.createHtmlTag("td", {
				"class": "num_objects"
			}, window.collex.number_with_delimiter(t)))
		}
		var a = window.collex.create_facet_button(r, e, "add", n);
		return window.pss.createHtmlTag("tr", {}, window.pss.createHtmlTag("td", {
			"class": "limit_to_lvl1"
		}, a) + window.pss.createHtmlTag("td", {
			"class": "num_objects"
		}, window.collex.number_with_delimiter(t)))
	}

	function n(n, i, r, o, a) {
		var s = "";
		"string" == typeof o && (o = [o]);
		for (var l in i)
			if (i.hasOwnProperty(l)) {
				var c = e.inArray(l, o),
					u = l;
				a && (u = a[l]), s += t(l, i[l], r, -1 !== c, u)
			}
		var d = e("." + n),
			h = window.pss.createHtmlTag("tr", {}, d.find("tr:first-of-type").html());
		d.html(h + s)
	}

	function i(e, t, n, i, r) {
		var o = window.pss.createHtmlTag("button", {
				"class": "nav_link  limit_to_arrow",
				"data-action": "open"
			}, window.pss.createHtmlTag("img", {
				alt: "Arrow Open",
				src: window.collex.images.arrow_open
			})),
			a = window.pss.createHtmlTag("button", {
				"class": "nav_link  limit_to_arrow",
				"data-action": "close"
			}, window.pss.createHtmlTag("img", {
				alt: "Arrow Close",
				src: window.collex.images.arrow_close
			})),
			s = window.pss.createHtmlTag("button", {
				"class": "nav_link limit_to_category",
				"data-action": "toggle"
			}, n),
			l = window.pss.createHtmlTag("td", {
				"class": "resource-tree-node limit_to_lvl" + t,
				"data-id": e
			}, o + a + s),
			c = window.pss.createHtmlTag("td", {
				"class": "num_objects"
			}, window.collex.number_with_delimiter(i)),
			u = "resource_node " + r;
		return window.pss.createHtmlTag("tr", {
			id: "resource_" + e,
			"class": u
		}, l + c)
	}

	function r(e, t, n, i, r, o, a) {
		var s, l = o;
		a ? (l += " limit_to_selected", s = window.pss.createHtmlTag("td", {
			"class": "limit_to_lvl" + t
		}, n + "&nbsp;&nbsp;" + window.collex.create_facet_button("[X]", r, "remove", "a"))) : s = window.pss.createHtmlTag("td", {
			"class": "limit_to_lvl" + t
		}, window.collex.create_facet_button(n, r, "replace", "a"));
		var c = window.pss.createHtmlTag("td", {
			"class": "num_objects"
		}, window.collex.number_with_delimiter(i));
		return window.pss.createHtmlTag("tr", {
			id: "resource_" + e,
			"class": l
		}, s + c)
	}

	function o(e, t, n, a, s) {
		for (var l = "", c = 0, u = 0; u < e.length; u++) {
			var d = e[u];
			if (d.children) {
				var h = o(d.children, t, n + 1, "child_of_" + d.id, s);
				if (c += h.total, h.total > 0) {
					var p = i(d.id, n, d.name, window.collex.number_with_delimiter(h.total), a);
					l += p + h.html
				}
			} else t[d.handle] && (l += r(d.id, n, d.name, t[d.handle], d.handle, a, d.handle === s), c += parseInt(t[d.handle], 10))
		}
		return {
			html: l,
			total: c
		}
	}

	function a(e, t) {
		for (var n = e.find(".resource_node.child_of_" + t), i = 0; i < n.length; i++) {
			var r = n[i],
				o = r.id.split("_")[1];
			e.find(".child_of_" + o).hide(), a(e, o)
		}
	}

	function s(t, n) {
		var i = o(window.collex.facetNames.archives, t, 1, "", n).html,
			r = e(".facet-archive"),
			a = window.pss.createHtmlTag("tr", {}, r.find("tr:first-of-type").html());
		r.html(a + i), window.collex.setResourceToggle(r, window.collex.facetNames.archives)
	}
	window.collex.create_facet_button = function(e, t, n, i) {
		return window.pss.createHtmlTag("button", {
			"class": "select-facet nav_link",
			"data-action": n,
			"data-key": i,
			"data-value": t
		}, e)
	}, window.collex.number_with_delimiter = function(e) {
		var t = ",",
			n = ".",
			i = ("" + e).split(".");
		return i[0] = i[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + t), i.join(n)
	}, window.collex.setResourceToggle = function(e, t) {
		for (var n = 0; n < t.length; n++) {
			var i = t[n];
			i.children && ("open" === i.toggle ? e.find("#resource_" + i.id + ' button[data-action="open"]').hide() : (e.find("#resource_" + i.id + ' button[data-action="close"]').hide(), e.find(".child_of_" + i.id).hide(), a(e, i.id)), window.collex.setResourceToggle(e, i.children))
		}
	}, window.collex.createFacets = function(e) {
		n("facet-genre", e.facets.genre, "g", e.query.g), n("facet-discipline", e.facets.discipline, "discipline", e.query.discipline), n("facet-format", e.facets.doc_type, "doc_type", e.query.doc_type), n("facet-access", e.facets.access, "o", e.query.o, window.collex.facetNames.access), s(e.facets.archive, e.query.a)
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e) {
		var t = e.thumbnail,
			n = t ? e.image : void 0;
		if (!t) {
			var i = window.collex.getArchive(e.archive);
			i && (t = i.thumbnail)
		}
		t || (t = window.collex.images.federationThumbnail);
		var r = "progress_" + b++,
			o = e.title ? e.title : "Image",
			a = window.pss.createHtmlTag("img", {
				src: t,
				alt: o,
				"class": "result_row_img hidden",
				onload: 'finishedLoadingImage("' + r + '", this, 100, 100);'
			}),
			s = window.pss.createHtmlTag("img", {
				id: r,
				"class": "progress_timeout result_row_img_progress",
				src: window.collex.images.spinner,
				alt: "loading...",
				"data-noimage": window.collex.images.spinnerTimeout
			});
		if (n) {
			o.length > 60 && (o = o.substr(0, 59) + "...");
			var l = 'showInLightbox({ title: "' + o + '", img: "' + n + '", spinner: "' + window.collex.images.spinner + '", size: 500 }); return false;';
			a = window.pss.createHtmlTag("a", {
				"class": "nines_pic_link",
				onclick: l,
				href: "#"
			}, a)
		}
		return s + a
	}

	function n(e, n) {
		var i = "",
			r = window.collex.currentUserId && window.collex.currentUserId > 0;
		r && (i = window.pss.createHtmlTag("input", {
			type: "checkbox",
			id: "bulk_collect_" + e,
			name: "bulk_collect[" + e + "]",
			value: n.uri
		}));
		var o = t(n),
			a = "";
		"true" === n.freeculture && (a += window.pss.createHtmlTag("span", {
			"class": "tooltip free_culture"
		}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + window.pss.createHtmlTag("span", {
			"class": "result_row_tooltip"
		}, "Free Culture resource"))), "true" === n.has_full_text && (a += window.pss.createHtmlTag("span", {
			"class": "tooltip full_text"
		}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + window.pss.createHtmlTag("span", {
			"class": "result_row_tooltip"
		}, "Full text provided for this document"))), "true" === n.source_xml && (a += window.pss.createHtmlTag("span", {
			"class": "tooltip has_xml_source"
		}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + window.pss.createHtmlTag("span", {
			"class": "result_row_tooltip"
		}, "XML source available for this document")));
		var s = window.pss.createHtmlTag("div", {
				"class": "result_row_icons"
			}, a),
			l = window.pss.createHtmlTag("div", {
				"class": "search_result_image"
			}, o + s);
		return window.pss.createHtmlTag("div", {
			"class": "search_result_left"
		}, i + l)
	}

	function i(e, t) {
		var n = t ? "" : window.pss.createHtmlTag("button", {
				"class": "collect"
			}, "Collect"),
			i = t ? window.pss.createHtmlTag("button", {
				"class": "uncollect"
			}, "Uncollect") : "",
			r = window.pss.createHtmlTag("button", {
				"class": "discuss"
			}, "Discuss"),
			o = t ? window.pss.createHtmlTag("button", {
				"class": "exhibit"
			}, "Exhibit") : "",
			a = window.collex.hasTypewright && e.typewright ? window.pss.createHtmlTag("button", {
				"class": "edit log-in-first-link",
				"data-login-prompt": "Please log in to begin editing"
			}, "Edit") : "";
		return window.pss.createHtmlTag("div", {
			"class": "search_result_buttons"
		}, n + i + r + o + a)
	}

	function r(e) {
		var t = encodeURIComponent(e.url),
			n = e.title ? encodeURIComponent(e.title) : "",
			i = e.role_AUT ? encodeURIComponent(e.role_AUT) : "",
			r = e.date_label ? encodeURIComponent(e.date_label) : "",
			o = e.role_PBL ? encodeURIComponent(e.role_PBL) : "",
			a = ["ctx_ver=Z39.88-2004", "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook", "rft_id=" + t, "rfr_id=info%3Asid%2Focoins.info%3Agenerator", "rft.genre=book", "rft.btitle=" + n, "rft.title=" + n, "rft.aulast=" + i, "rft.aufirst=", "rft.au=" + i, "rft.date=" + r, "rft.pub=" + o];
		return a.join("&amp;")
	}

	function o(e, t) {
		if (e || (e = "No title"), e.length < 200) return window.pss.createHtmlTag("a", {
			"class": "nines_link doc-title",
			href: t,
			target: "_blank",
			title: " "
		}, e);
		y++;
		var n = e.substr(0, 199),
			i = e.substr(199),
			r = "title_more_" + y,
			o = n + window.pss.createHtmlTag("span", {
				id: r,
				style: "display:none;"
			}, i);
		return window.pss.createHtmlTag("a", {
			"class": "nines_link doc-title",
			title: e,
			target: "_blank",
			href: t
		}, o) + window.pss.createHtmlTag("a", {
			href: "#",
			onclick: "return false;",
			"class": "nav_link more_link",
			"data-div": r,
			"data-less": "[show less]",
			title: " "
		}, "...[show full title]")
	}

	function a(e) {
		var t = "";
		window.collex.isAdmin && (t = window.pss.createHtmlTag("a", {
			"class": "uri_link",
			href: "#"
		}, "uri") + window.pss.createHtmlTag("span", {
			style: "display:none;"
		}, e.uri + "&nbsp;"));
		var n = o(e.title, e.url),
			i = window.pss.createHtmlTag("div", {
				"class": "search_result_header"
			}, t + n);
		return window.pss.createHtmlTag("span", {
			"class": "Z3988",
			title: r(e)
		}, i)
	}

	function s(e) {
		return window.pss.createHtmlTag("div", {
			"class": e,
			style: "display:none;"
		}, window.pss.createHtmlTag("span", {
			"class": "label"
		}, "") + window.pss.createHtmlTag("span", {
			"class": "value"
		}, ""))
	}

	function l(e, t, n) {
		e.find(".label").html(t), e.find(".value").html(n)
	}

	function c(e, t, n, i, r) {
		if (!n) return "";
		var o = "row";
		switch (i && (o += " hidden", w = !0), r && (o += " " + r), e) {
			case "separate_lines":
				for (var a = window.pss.createHtmlTag("div", {
					"class": o
				}, window.pss.createHtmlTag("span", {
					"class": "label"
				}, t) + window.pss.createHtmlTag("span", {
					"class": "value"
				}, n[0])), s = 1; s < n.length; s++) a += window.pss.createHtmlTag("div", {
					"class": o
				}, window.pss.createHtmlTag("span", {
					"class": "label"
				}, "") + window.pss.createHtmlTag("span", {
					"class": "value"
				}, n[s]));
				return a;
			case "single_item":
				return window.pss.createHtmlTag("div", {
					"class": o
				}, window.pss.createHtmlTag("span", {
					"class": "label"
				}, t) + window.pss.createHtmlTag("span", {
					"class": "value"
				}, n));
			case "multiple_item":
				return window.pss.createHtmlTag("div", {
					"class": o
				}, window.pss.createHtmlTag("span", {
					"class": "label"
				}, t) + window.pss.createHtmlTag("span", {
					"class": "value"
				}, n.join("; ")));
			case "one_col":
				return window.pss.createHtmlTag("div", {
					"class": o
				}, window.pss.createHtmlTag("span", {
					"class": "one-col"
				}, n))
		}
	}

	function u(e) {
		return e && 0 !== e.length ? window.pss.createHtmlTag("div", {
			"class": "search_result_full_text_label"
		}, "Excerpt from Full Text:") + window.pss.createHtmlTag("span", {
			"class": "snippet"
		}, e) : ""
	}

	function d(e, t, n, i) {
		var r, o = "";
		if (n)
			for (r = 0; r < n.length; r++) {
				0 !== r && (o += " | "), o += window.pss.createHtmlTag("a", {
					"class": "tag_link my_tag",
					title: "view all objects tagged &quot;" + n[r] + "&quot;",
					href: "/tags/results?tag=" + n[r] + "&amp;view=tag"
				}, n[r]);
				var a = "doRemoveTag('" + e + "', 'search_result_" + t + "', '" + n[r] + "'); return false;";
				o += window.pss.createHtmlTag("a", {
					"class": "modify_link remove_tag",
					title: "delete tag &quot;" + n[r] + "&quot;",
					onclick: a,
					href: "#"
				}, "X")
			}
		if (i && i.length > 0)
			for (n && n.length > 0 && (o += " | "), r = 0; r < i.length; r++) o += window.pss.createHtmlTag("a", {
				"class": "tag_link other_tag",
				title: "view all objects tagged &quot;" + i[r] + "&quot;",
				href: "/tags/results?tag=" + i[r] + "&amp;view=tag"
			}, i[r]);
		return o
	}

	function h(e, t, n, i) {
		var r, o = "doAddTag('/tag/tag_name_autocomplete', '" + e + "', " + t + ", 'search_result_" + t + "', event); return false;",
			a = window.collex.currentUserId && window.collex.currentUserId > 0;
		return r = a ? window.pss.createHtmlTag("button", {
			"class": "modify_link",
			id: "add_tag_" + t,
			onclick: o
		}, "[add&nbsp;tag]") : window.pss.createHtmlTag("span", {
			"class": "tags_instructions"
		}, "[" + window.pss.createHtmlTag("a", {
			"class": "nav_link",
			href: "#",
			onclick: "var dlg = new SignInDlg(); dlg.show('sign_in'); return false;"
		}, "LOG IN") + " to add tags]"), d(e, t, n, i) + r
	}

	function p(e, t, n) {
		var i, r = "doAnnotation('" + t + "', " + e + ", 'search_result_" + e + "', 'annotation_" + e + "', '/forum/get_nines_obj_list', '" + window.collex.images.spinner + "'); return false;",
			o = "<br>" + window.pss.createHtmlTag("span", {
				id: "annotation_" + e,
				"class": "annotation"
			}, n);
		return i = n && n.length > 0 ? "Edit Private Annotation" : "Add Private Annotation", window.pss.createHtmlTag("button", {
			"class": "modify_link",
			onclick: r
		}, i) + o
	}

	function f(e) {
		var t = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
			n = e.split("T");
		n = n[0].split("-");
		var i = parseInt(n[2], 10),
			r = parseInt(n[1], 10) - 1,
			o = n[0];
		return t[r] + " " + i + ", " + o
	}

	function g(e) {
		var t = e.title + "&nbsp;" + window.pss.createHtmlTag("a", {
			"class": "nav_link",
			href: e.view_path
		}, "[view]");
		return e.edit_path && e.edit_path.length > 0 && (t += "&nbsp;" + window.pss.createHtmlTag("a", {
			"class": "nav_link",
			href: e.edit_path
		}, "[edit]")), t
	}

	function m(e) {
		if (!e) return null;
		try {
			e = JSON.parse(e)
		} catch (t) {
			return window.console.error(t.message), null
		}
		for (var n = [], i = 0; i < e.length; i++) n.push(_(e[i]));
		return n
	}

	function v(e, t, n) {
		w = !1;
		var i = "";
		if (i += c("one_col", "", e.alternative, !1), i += c("separate_lines", "Source:", e.source, !1), i += c("multiple_item", "By:", e.role_AUT, !1), i += c("multiple_item", "Artist:", e.role_ART, !1), i += n ? c("single_item", "Collected&nbsp;on:", f(n), !1, "collected-on") : s("row collected-on"), null !== t) {
			var r = h(e.uri, t, e.my_tags, e.tags);
			i += c("single_item", "Tags:", r, !1, "tag-list")
		}
		var o = window.collex.getSite(e.archive);
		i += c("single_item", "Site:", o, !1), i += c("multiple_item", "Genre:", e.genre, !0), i += c("multiple_item", "Discipline:", e.discipline, !0), i += c("multiple_item", "Subject:", e.subject, !0), i += c("single_item", "Exhibit&nbsp;type:", e.exhibit_type, !1), i += c("single_item", "License:", e.license, !1), i += c("multiple_item", "Editor:", e.role_EDT, !0), i += c("multiple_item", "Publisher:", e.role_PBL, !0), i += c("multiple_item", "Owner:", e.role_OWN, !0), i += c("multiple_item", "Translator:", e.role_TRL, !0), i += c("multiple_item", "Date:", e.date_label, !0), i += c("multiple_item", "Provenance:", e.provenance, !0), i += c("multiple_item", "Architect:", e.role_ARC, !0), i += c("multiple_item", "Binder:", e.role_BND, !0), i += c("multiple_item", "Book Designer:", e.role_BKD, !0), i += c("multiple_item", "Book Producer:", e.role_BKP, !0), i += c("multiple_item", "Broadcaster:", e.role_BRD, !0), i += c("multiple_item", "Calligrapher:", e.role_CLL, !0), i += c("multiple_item", "Cartographer:", e.role_CTG, !0), i += c("multiple_item", "Collector:", e.role_COL, !0), i += c("multiple_item", "Colorist:", e.role_CLR, !0), i += c("multiple_item", "Commentator:", e.role_CWT, !0), i += c("multiple_item", "Compiler:", e.role_COM, !0), i += c("multiple_item", "Compositor:", e.role_CMT, !0), i += c("multiple_item", "Cinematographer:", e.role_CNG, !0), i += c("multiple_item", "Conductor:", e.role_CND, !0), i += c("multiple_item", "Creator:", e.role_CRE, !0), i += c("multiple_item", "Director:", e.role_DRT, !0), i += c("multiple_item", "Dubious Author:", e.role_DUB, !0), i += c("multiple_item", "Facsimilist:", e.role_FAC, !0), i += c("multiple_item", "Former Owner:", e.role_FMO, !0), i += c("multiple_item", "Illuminator:", e.role_ILU, !0), i += c("multiple_item", "Illustrator:", e.role_ILL, !0), i += c("multiple_item", "Interviewer:", e.role_IVR, !0), i += c("multiple_item", "Interviewee:", e.role_IVE, !0), i += c("multiple_item", "Lithographer:", e.role_LTG, !0), i += c("multiple_item", "Owner:", e.role_OWN, !0), i += c("multiple_item", "Performer:", e.role_PRF, !0), i += c("multiple_item", "Printer:", e.role_PRT, !0), i += c("multiple_item", "Printer of plates:", e.role_POP, !0), i += c("multiple_item", "Printmaker:", e.role_PRM, !0), i += c("multiple_item", "Producer:", e.role_PRO, !0), i += c("multiple_item", "Production Company:", e.role_PRN, !0), i += c("multiple_item", "Repository:", e.role_RPS, !0), i += c("multiple_item", "Rubricator:", e.role_RBR, !0), i += c("multiple_item", "Scribe:", e.role_SCR, !0), i += c("multiple_item", "Sculptor:", e.role_SCL, !0), i += c("multiple_item", "Translator:", e.role_TRL, !0), i += c("multiple_item", "Type Designer:", e.role_TYD, !0), i += c("multiple_item", "Typographer:", e.role_TYG, !0), i += c("multiple_item", "Wood Engraver:", e.role_WDE, !0), i += c("multiple_item", "Wood Cutter:", e.role_WDC, !0), i += c("separate_lines", "Has Part:", m(e.hasPart), !0), i += c("separate_lines", "Is Part Of:", m(e.isPartOf), !0);
		var a;
		if (e.exhibits) {
			a = [];
			for (var l = 0; l < e.exhibits.length; l++) a.push(g(e.exhibits[l]))
		}
		i += a ? c("multiple_item", "Exhibits:", a, !0, "exhibits-row") : s("row exhibits-row"), w && null !== t && (i += window.pss.createHtmlTag("button", {
			id: "more-search_result_" + t,
			"class": "nav_link more",
			onclick: 'removeHidden("more-search_result_' + t + '", "search_result_' + t + '");return false;'
		}, "[more...]"));
		var d = p(t, e.uri, e.annotation),
			v = {
				"class": "row annotation-row"
			};
		return n || (v.style = "display:none;"), i += window.pss.createHtmlTag("div", v, d), i += u(e.text), window.pss.createHtmlTag("div", {
			"class": "search_result_data_container",
			"data-uri": e.uri
		}, i)
	}

	function _(e) {
		var t = a(e),
			n = v(e, null);
		return window.pss.createHtmlTag("div", {
			"class": "search-result-sub"
		}, t + n)
	}
	var b = 0,
		y = 0,
		w = !1;
	window.collex.createMediaBlock = function(e, t, r, o) {
		var s = n(t, e),
			l = i(e, r),
			c = a(e),
			u = v(e, t, o),
			d = window.pss.createHtmlTag("div", {
				"class": "search_result_right"
			}, c + u),
			h = window.pss.createHtmlTag("div", {
				"class": "clear_both"
			}, "") + window.pss.createHtmlTag("hr", {
				"class": "search_results_hr"
			}),
			p = "search-result";
		return r && (p += " result_row_collected"), h += window.pss.createHtmlTag("div", {
			id: "search_result_" + t,
			"class": p,
			"data-index": t,
			"data-uri": e.uri
		}, s + l + d)
	}, window.collex.setCollected = function(t, n, r) {
		var o = e("#search_result_" + t);
		if (o.length) {
			o.addClass("result_row_collected");
			var a = {};
			r && (a.typewright = !0);
			var s = i(a, !0);
			o.find(".search_result_buttons").html(s);
			var c = o.find(".collected-on");
			l(c, "Collected&nbsp;on:", f(n)), o.find(".collected-on").show(), o.find(".annotation-row").show()
		}
	}, window.collex.setUncollected = function(t, n) {
		var r = e("#search_result_" + t);
		if (r.length) {
			r.removeClass("result_row_collected");
			var o = {};
			n && (o.typewright = !0);
			var a = i(o, !1);
			r.find(".search_result_buttons").html(a), r.find(".collected-on").hide();
			var s = r.find(".annotation-row");
			s.find("button").text("Add Private Annotation"), s.find(".annotation").text(""), s.hide()
		}
	}, window.collex.redrawTags = function(t, n, i) {
		var r = e("#search_result_" + t);
		if (r.length) {
			var o = r.find(".tag-list .value"),
				a = r.attr("data-uri"),
				s = h(a, t, n, i);
			o.html(s)
		}
	}, window.collex.redrawAnnotation = function(t, n) {
		var i = e("#search_result_" + t);
		if (i.length) {
			var r = i.find(".annotation-row"),
				o = i.closest(".search_result_data_container"),
				a = o.attr("data-uri"),
				s = p(t, a, n);
			r.html(s)
		}
	}, window.collex.redrawExhibits = function(t, n) {
		var i = e("#search_result_" + t);
		if (i.length) {
			var r = i.find(".exhibits-row"),
				o = [];
			if (n) {
				for (var a = 0; a < n.length; a++) o.push(g(n[a]));
				r.find(".value").html(o.join("<br>")), r.find(".label").html("Exhibits:"), r.show()
			} else r.hide()
		}
	}, window.collex.createResultRows = function(t) {
		for (var n = "", i = 0; i < t.hits.length; i++) {
			var r = void 0 !== t.collected[t.hits[i].uri];
			n += window.collex.createMediaBlock(t.hits[i], i, r, t.collected[t.hits[i].uri])
		}
		e(".search-results").html(n)
	}
}), jQuery(document).ready(function(e) {
	"use strict";
	window.collex.createPagination = function(t, n, i) {
		var r = "";
		n = parseInt(n, 10), i = parseInt(i, 10), t = parseInt(t, 10);
		var o = Math.ceil(n / i),
			a = e(".pagination");
		if (1 === o) return void a.html(r);
		var s, l;
		11 > o ? (s = 1, l = o) : (s = t - 5, l = t + 5, 1 > s && (s = 1, l = s + 10), l > o && (l = o, s = l - 10)), s > 1 && (r += window.collex.create_facet_button("first", "1", "replace", "page"), r += "&nbsp;&nbsp;"), t > 1 && (r += window.collex.create_facet_button("<<", t - 1, "replace", "page"), r += "&nbsp;&nbsp;");
		for (var c = s; l >= c; c++) r += c === t ? window.pss.createHtmlTag("span", {
			"class": "current_serp"
		}, c) : window.collex.create_facet_button(c, c, "replace", "page"), r += "&nbsp;&nbsp;";
		o > l && (r += "...&nbsp;&nbsp;", o > 12 && (r += window.collex.create_facet_button(o, o, "replace", "page")), r += "&nbsp;&nbsp;"), o > t && (r += window.collex.create_facet_button(">>", t + 1, "replace", "page"), r += "&nbsp;&nbsp;"), o > l && (r += window.collex.create_facet_button("last", o, "replace", "page"), r += "&nbsp;&nbsp;"), a.html(r)
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e) {
		var t = {
			a: "Archive",
			discipline: "Discipline",
			g: "Genre",
			q: "Search Term",
			doc_type: "Format",
			t: "Title",
			aut: "Author",
			ed: "Editor",
			pub: "Publisher",
			art: "Artist",
			own: "Owner",
			y: "Year",
			lang: "Language"
		};
		return t[e] ? t[e] : e
	}

	function n(e, t) {
		var n = window.pss.createHtmlTag("option", {}, "AND"),
			i = {};
		t && t.length > 0 && "-" === t[0] && (i.selected = "selected");
		var r = window.pss.createHtmlTag("option", i, "NOT");
		return i = {}, e && (i["data-key"] = e), t && (i["data-val"] = t), window.pss.createHtmlTag("select", i, n + r)
	}

	function i(e, t) {
		return window.pss.createHtmlTag("button", {
			"class": "trash select-facet",
			"data-key": e,
			"data-value": t,
			"data-action": "remove"
		}, '<img alt="Remove Term" src="/assets/lvl2_trash.gif">')
	}

	function r() {
		var e = [
			["Search Term", "q"],
			["Title", "t"]
		];
		window.collex.hasFuzzySearch ? (e.push(["Language", "lang"]), e.push(["Year (YYYY)", "y"])) : (e.push(["Author", "aut"]), e.push(["Editor", "ed"]), e.push(["Publisher", "pub"]), e.push(["Artist", "art"]), e.push(["Owner", "own"]), e.push(["Year (YYYY)", "y"]));
		for (var t = "", i = 0; i < e.length; i++) t += window.pss.createHtmlTag("option", {
			value: e[i][1]
		}, e[i][0]);
		var r = window.pss.createHtmlTag("select", {
				"class": "query_type_select"
			}, t),
			o = window.pss.createHtmlTag("input", {
				"class": "add-autocomplete",
				type: "text",
				placeholder: "click here to add new search term",
				"data-autocomplete-url": "/search/auto_complete_for_q",
				"data-autocomplete-field": ".query_type_select",
				autocomplete: "off"
			}) + window.pss.createHtmlTag("div", {
				"class": "auto_complete",
				id: "search_phrase_auto_complete",
				style: "display: none;"
			}, ""),
			a = window.pss.createHtmlTag("button", {
				"class": "query_add"
			}, "Add");
		return window.pss.createHtmlTag("tr", {
			"class": "new-search-term"
		}, window.pss.createHtmlTag("td", {
			"class": "query_type"
		}, r) + window.pss.createHtmlTag("td", {
			"class": "query_term"
		}, o) + window.pss.createHtmlTag("td", {
			"class": "new-query_and-not"
		}, n()) + window.pss.createHtmlTag("td", {
			"class": "query_remove"
		}, a))
	}
	window.collex.createSearchForm = function(o) {
		var a = e(".search-form"),
			s = "",
			l = !0;
		for (var c in o)
			if (o.hasOwnProperty(c) && "page" !== c && "srt" !== c && "dir" !== c && "f" !== c)
				for (var u = "string" == typeof o[c] ? [o[c]] : o[c], d = 0; d < u.length; d++) {
					var h = u[d],
						p = c;
					if ("a" === c) {
						var f = window.collex.getArchive(h);
						f && (h = f.name)
					} else if ("o" === c) switch (h) {
						case "typewright":
							p = "TypeWright", h = "Only resources that can be edited.";
							break;
						case "freeculture":
							p = "Free Culture", h = "Only resources that are freely available in their full form.";
							break;
						case "fulltext":
							p = "Full Text", h = "Only resources that contain full text."
					}
					l = !1;
					var g = h;
					g && "-" === g[0] && (g = g.substr(1)), ("q" === c || "t" === c || "aut" === c || "ed" === c || "pub" === c || "art" === c || "own" === c || "y" === c) && (g = window.pss.createHtmlTag("a", {
						"class": "modify_link query-editable",
						href: "#",
						"data-type": c
					}, g)), s += window.pss.createHtmlTag("tr", {}, window.pss.createHtmlTag("td", {
						"class": "query_type"
					}, t(p)) + window.pss.createHtmlTag("td", {
						"class": "query_term"
					}, g) + window.pss.createHtmlTag("td", {
						"class": "query_and-not"
					}, n(c, h)) + window.pss.createHtmlTag("td", {
						"class": "query_remove"
					}, i(c, h)))
				}
		s += r(), a.html(s), a.find(".add-autocomplete").each(function(e, t) {
			window.collex.initAutoComplete(t)
		}), l ? e("#saved_search_name_span").html("") : window.collex.drawSavedSearch(l), window.collex.drawSavedSearchList()
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t() {
		var e = window.location.search;
		e = e.replace(/%20/g, " "), "?" === e.substr(0, 1) && (e = e.substr(1));
		for (var t = 0; t < window.collex.savedSearches.length; t++) {
			var n = window.collex.savedSearches[t];
			if (n.url === e) return n
		}
		return null
	}

	function n(e) {
		return window.location.origin + "/search?" + e
	}

	function i(e) {
		var t = window.pss.createHtmlTag("img", {
			alt: "Permalink",
			src: "/assets/link.jpg",
			title: "Click here to get a permanent link for this saved search."
		});
		return window.pss.createHtmlTag("a", {
			"class": "nav_link",
			href: "#",
			onclick: "window.collex.showString(&quot;" + n(e) + "&quot;); return false;"
		}, t)
	}
	window.collex.drawSavedSearch = function() {
		var n = e("#saved_search_name_span"),
			r = window.collex.currentUserId && window.collex.currentUserId > 0;
		if (r) {
			var o = t();
			n.html(o ? " : " + o.name + " " + i(o.url) : window.pss.createHtmlTag("a", {
				"class": "modify_link",
				href: "#",
				onclick: "window.collex.doSaveSearch(); return false;"
			}, "[save search]"))
		} else {
			var a = window.pss.createHtmlTag("a", {
				"class": "nav_link",
				href: "#",
				onclick: "var dlg = new SignInDlg(); dlg.show('sign_in'); return false;"
			}, "LOG IN");
			n.html(window.pss.createHtmlTag("span", {
				"class": "save_search_instruction"
			}, "(" + a + " to save this search)"))
		}
	}, window.collex.drawSavedSearchList = function() {
		var t = e(".saved-search-list");
		if (0 !== t.length) {
			var r = 10,
				o = Math.min(r, window.collex.savedSearches.length),
				a = "";
			o !== window.collex.savedSearches.length && (a += window.pss.createHtmlTag("div", {
				"class": "empty_list_text"
			}, window.pss.createHtmlTag("span", {
				"class": "hiding-text"
			}, "Showing the " + o + " most recent of your " + window.collex.savedSearches.length + " saved searches. ") + window.pss.createHtmlTag("a", {
				"class": "nav_link saved_search_show_all",
				onclick: "window.collex.showHiddenSavedSearches('saved_search_show_all', 'saved_search_hidden_item' );"
			}, "[show all]")));
			var s = "";
			if (0 === window.collex.savedSearches.length) s += window.pss.createHtmlTag("tr", {}, window.pss.createHtmlTag("td", {
				"class": "query_term"
			}, "No searches saved"));
			else
				for (var l = 0; l < window.collex.savedSearches.length; l++) {
					var c = window.collex.savedSearches[l],
						u = window.pss.createHtmlTag("td", {
							"class": "query_term"
						}, window.pss.createHtmlTag("a", {
							"class": "nav_link",
							href: n(c.url)
						}, c.name)),
						d = "serverAction({confirm: { title: 'Saved Search', message: 'Are you sure you want to remove this saved search?' }, action: { actions: this.href }, progress: { waitMessage: 'Please Wait...' }}); return false;",
						h = c.id ? c.id : c.name,
						p = window.pss.createHtmlTag("td", {
							"class": "query_remove"
						}, window.pss.createHtmlTag("a", {
							"class": "modify_link",
							href: "/search/remove_saved_search?id=" + h,
							post: !0,
							onclick: d
						}, "[remove]")),
						f = {};
					l >= o && (f["class"] = "saved_search_hidden_item hidden");
					var g = window.pss.createHtmlTag("td", {
						"class": "saved_search_link"
					}, i(c.url));
					s += window.pss.createHtmlTag("tr", f, u + p + g)
				}
			a += window.pss.createHtmlTag("table", {
				"class": "query"
			}, s), t.html(a)
		}
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(t) {
		e("#search_result_count").text("Search Results (" + window.collex.number_with_delimiter(t) + ")")
	}

	function n(t, n) {
		var i = e(".limit_to_federation .num_objects");
		i.each(function(n, i) {
			i = e(i);
			var r = i.attr("data-federation");
			i.text(t[r] ? window.collex.number_with_delimiter(t[r]) : "")
		});
		var r = e(".limit_to_federation input");
		n || (n = [window.collex.defaultFederation]);
		for (var o = {}, a = 0; a < n.length; a++) o[n[a]] = !0;
		r.each(function(t, n) {
			var i = n.name;
			e(n).prop("checked", o[i])
		})
	}

	function i(e) {
		for (var t in e)
			if (e.hasOwnProperty(t) && "srt" !== t && "dir" !== t && "f" !== t) return !1;
		return !0
	}

	function r(t) {
		i(t.query) ? (e(".has-results").hide(), e(".add_constraint_form").show()) : (e(".add_constraint_form").hide(), e(".has-results").show(), 0 === t.hits.length ? (e(".not-empty").hide(), e(".no_results_msg").show()) : (e(".not-empty").show(), e(".no_results_msg").hide()))
	}

	function o(t) {
		var n = e(".search_error_message");
		n.text(t), t && t.length > 0 ? n.show() : n.hide()
	}

	function a() {
		e("#expand_all").show(), e("#collapse_all").hide()
	}

	function s() {
		l = setTimeout(function() {
			var t = e(".progress_timeout");
			t.each(function(t, n) {
				n.src = e(n).attr("data-noimage")
			}), l = null
		}, 8e3)
	}
	var l, c = e("body");
	c.bind("RedrawSearchResults", function(e, i) {
		if (!(i && i.hits && i.facets && i.query)) return void window.console.log("error redrawing search results", i);
		l && (clearTimeout(l), l = null), r(i), o(i.message), window.collex.createResultRows(i), window.collex.createSearchForm(i.query), window.collex.createFacets(i);
		var c = i.query.page ? i.query.page : 1;
		window.collex.createPagination(c, i.total_hits, i.page_size), t(i.total_hits), n(i.facets.federation, i.query.f), a(), s()
	}), c.bind("DrawHits", function(e, t) {
		window.collex.createResultRows(t), s()
	})
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(t, n) {
		t.preventDefault();
		var i = e(n),
			r = i.closest(".search-result"),
			o = r.attr("data-index"),
			a = r.attr("data-uri"),
			s = window.collex.currentUserId && window.collex.currentUserId > 0,
			l = r.find(".doc-title").text(),
			c = r.find("button.edit").length > 0;
		return {
			uri: a,
			index: o,
			isLoggedIn: s,
			title: l,
			hasEdit: c
		}
	}
	var n = e("body");
	n.on("click", ".search_result_buttons .collect", function(e) {
		var n = t(e, this);
		doCollect("/results/result_row", n.uri, n.index, "search_result_" + n.index, n.isLoggedIn, n.hasEdit)
	}), n.on("click", ".search_result_buttons .uncollect", function(e) {
		var n = t(e, this);
		doRemoveCollect("/results/result_row", n.uri, n.index, n.hasEdit)
	}), n.on("click", ".search_result_buttons .discuss", function(e) {
		var n = t(e, this);
		new StartDiscussionWithObject("/forum/get_all_topics", "/forum/post_object_to_new_thread", n.uri, n.title, "#search_result_" + n.index + " .discuss", n.isLoggedIn, "/forum/get_nines_obj_list", window.collex.spinner)
	}), n.on("click", ".search_result_buttons .exhibit", function(e) {
		var n = t(e, this);
		doAddToExhibit("result_row", n.uri, n.index, "search_result_" + n.index, window.collex.myCollexUrl)
	}), n.on("click", ".search_result_buttons .edit", function(e) {
		var n = t(e, this),
			i = "/typewright/documents/0?uri=" + n.uri;
		doEditDocument(n.isLoggedIn, i)
	}), n.on("click", ".search-result .uri_link", function() {
		return jQuery(this).next().toggle(), !1
	})
}), //    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
	jQuery(document).ready(function(e) {
		"use strict";
		var t = e("body"),
			n = e("#add-search-constraint");
		n.on("submit", function() {
			var i = e(".add_constraint_form").is(":visible");
			if (!i) return !1;
			var r = n.find('input[type="submit"]'),
				o = r.val();
			r.each(function(e, t) {
				t.disabled = !0, t.value = "......", t.addClassName("submitting")
			});
			var a = function() {
					r.each(function(e, t) {
						t.disabled = !1, t.value = o, t.removeClassName("submitting")
					})
				},
				s = function(e) {
					new MessageBoxDlg("Error", e), a()
				},
				l = n.find('input[type="text"],select[class="search_language"]'),
				c = {},
				u = !1;
			if (l.each(function(t, n) {
				e(n).val().length > 0 && (u = !0, c[n.name] = e(n).val())
			}), !u) return s("Please enter some text before searching."), !1;
			var d = c.y;
			if (d && d.length > 0)
				if (d = d.trim().replace(/-/, " TO ").replace(/to/i, "TO").replace(/\s+/, " "), d = d.trim(), d.length > 0) {
					var h = /^\d{4}(\s+TO\s+\d{4})?$/;
					if (!h.match(d)) return s("The year must be 4 digits or a valid year span (e.g. 1700 TO 1900)."), !1;
					c.y = d
				} else delete c.y;
			return t.trigger("SetSearch", c), setTimeout(function() {
				l.val(""), a()
			}, 2e3), !1
		})
	}); //     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
var SidebarTagCloud = Class.create({
		initialize: function() {
			this.instructions = {
				tag: "tag",
				annotation: "annotation"
			}, this.initSidebarFilterHandler()
		},
		initSidebarFilterHandler: function() {
			this.sidebarTouched = !1, Event.observe("sidebar_search", "keyup", this.onSidebarFilter.bindAsEventListener(this))
		},
		onSidebarFilter: function() {
			this.sidebarTouched = !0, this.updateTagCloud()
		},
		updateTagCloud: function() {
			var e = $("tagcloud");
			if (e) {
				var t = this.sidebarTouched ? $("sidebar_search").value.toLowerCase() : "",
					n = e.select("a"),
					i = 0,
					r = [];
				n.each(function(e) {
					e.hasClassName("dont_filter") === !1 ? t.blank() || e.innerHTML.toLowerCase().indexOf(t) >= 0 ? (e.show(), r[i++] = e) : e.hide() : "[show fewer tags]" === e.innerHTML ? t.blank() ? e.show() : e.hide() : "[show entire tag cloud]" === e.innerHTML && (t.blank() || e.hide())
				});
				var o = $("more_tags");
				o && o.show()
			}
		}
	}),
	StartDiscussionWithExhibit = Class.create({
		initialize: function(e, t, n, i, r, o, a, s, l, c) {
			this.class_type = "StartDiscussionWithExhibit";
			var u = null;
			if (!o) {
				var d = new SignInDlg;
				return d.setInitialMessage("Please log in to start a discussion"), d.setRedirectPageToCurrentWithParam("script=StartDiscussionWithExhibit"), void d.show("sign_in")
			}
			var h = function() {
				var t = function(e) {
					var t = [];
					u.setFlash("", !1);
					try {
						e.responseText.length > 0 && (t = e.responseText.evalJSON(!0))
					} catch (n) {
						new MessageBoxDlg("Error", n)
					}
					var i = $$(".discussion_topic_select"),
						r = i[0];
					r.update(""), t = t.sortBy(function(e) {
						return e.text
					}), t.each(function(e) {
						r.appendChild(new Element("option", {
							value: e.value
						}).update(e.text))
					}), $("topic_id").writeAttribute("value", t[0].value)
				};
				serverRequest({
					url: e,
					onSuccess: t
				})
			};
			this.sendWithAjax = function(e, t) {
				var i = t.arg0,
					o = t.dlg;
				o.setFlash("Updating Discussion Topics...", !1);
				var a = o.getAllData();
				a.inet_thumbnail = "", a.thread_id = "", a.group_id = l, a.cluster_id = c, a.nines_exhibit = n, a.nines_object = "", a.inet_url = "", a.inet_title = "", a.disc_type = "NINES Exhibit";
				var s = function(e) {
					$(r).hide(), o.cancel(), gotoPage(e.responseText)
				};
				serverRequest({
					url: i,
					params: a,
					onSuccess: s
				})
			};
			var p = new ForumLicenseDisplay({
					populateLicenses: "/exhibits/get_licenses?non_sharing=false",
					currentLicense: 5,
					id: "license_list"
				}),
				f = {
					page: "start_discussion",
					rows: [
						[{
							text: "Starting a discussion of: " + i,
							klass: "new_exhibit_label"
						}],
						[{
							custom: p,
							klass: "forum_reply_license title"
						}, {
							text: "Select the topic you want this discussion to appear under:",
							klass: "new_exhibit_label"
						}],
						[{
							select: "topic_id",
							klass: "discussion_topic_select",
							options: [{
								value: -1,
								text: "Loading topics. Please Wait..."
							}]
						}],
						[{
							text: "Title",
							klass: "forum_reply_label title "
						}],
						[{
							input: "title",
							klass: "forum_reply_input title"
						}],
						[{
							textarea: "description"
						}],
						[{
							rowClass: "gd_last_row"
						}, {
							button: "Ok",
							arg0: t,
							callback: this.sendWithAjax,
							isDefault: !0
						}, {
							button: "Cancel",
							callback: GeneralDialog.cancelCallback
						}]
					]
				},
				g = {
					this_id: "start_discussion_with_object_dlg",
					pages: [f],
					body_style: "forum_reply_dlg",
					row_style: "new_exhibit_row",
					title: "Start Discussion",
					focus: "start_discussion_with_object_dlg_sel0"
				};
			u = new GeneralDialog(g), u.initTextAreas({
				toolbarGroups: ["fontstyle", "link"],
				linkDlgHandler: new LinkDlgHandler([a], s)
			}), p.populate(u), u.center(), h(u)
		}
	}),
	tagZoom = {
		zoom_level: 1,
		startY: 0,
		offsetY: 0,
		dragElement: null,
		oldZIndex: 0,
		curr_pos: 0,
		doZoom: function(e) {
			var t = function(e) {
				for (var t = $$("#tagcloud span"), n = 0; n < t.length; n++) {
					for (var i = 0; 10 >= i; i++) t[n].removeClassName("cloud" + i);
					var r = t[n].readAttribute("zoom").split(","),
						o = "cloud" + r[e - 1];
					t[n].addClassName(o)
				}
			};
			switch (e) {
				case "+":
					tagZoom.zoom_level < 10 && tagZoom.zoom_level++;
					break;
				case "-":
					tagZoom.zoom_level > 1 && tagZoom.zoom_level--;
					break;
				case "1":
					tagZoom.zoom_level = 1;
					break;
				case "2":
					tagZoom.zoom_level = 2;
					break;
				case "3":
					tagZoom.zoom_level = 3;
					break;
				case "4":
					tagZoom.zoom_level = 4;
					break;
				case "5":
					tagZoom.zoom_level = 5;
					break;
				case "6":
					tagZoom.zoom_level = 6;
					break;
				case "7":
					tagZoom.zoom_level = 7;
					break;
				case "8":
					tagZoom.zoom_level = 8;
					break;
				case "9":
					tagZoom.zoom_level = 9;
					break;
				case "10":
					tagZoom.zoom_level = 10
			}
			t(tagZoom.zoom_level);
			var n = $("tag_zoom_thumb");
			n.style.top = "" + (306 - 9 * tagZoom.zoom_level) + "px", null === tagZoom.dragElement && serverNotify("/tag/set_zoom", {
				level: tagZoom.zoom_level
			})
		},
		zoomThumbMouseDown: function(e) {
			var t = function(e) {
					var t = parseInt(e);
					return null === t || isNaN(t) ? 0 : t
				},
				n = function(e) {
					for (; e;) {
						if ("tag_zoom_thumb" === e.id) return e;
						e = e.parentNode
					}
					return null
				},
				i = function(e) {
					null === e && (e = window.event);
					var t = tagZoom.offsetY + e.clientY - tagZoom.startY;
					224 > t && (t = 224), t > 297 && (t = 297), tagZoom.dragElement.style.top = t + "px", tagZoom.curr_pos = Math.round((297 - t) / 8) + 1, tagZoom.doZoom("" + tagZoom.curr_pos)
				};
			null === e && (e = window.event);
			var r = null !== e.target ? e.target : e.srcElement;
			return r = n(r), (1 === e.button && null !== window.event || 0 === e.button) && null !== r ? (tagZoom.startY = e.clientY, tagZoom.offsetY = t(r.style.top), tagZoom.oldZIndex = r.style.zIndex, r.style.zIndex = 1e4, tagZoom.dragElement = r, document.onmousemove = i, document.body.focus(), document.onselectstart = function() {
				return !1
			}, r.ondragstart = function() {
				return !1
			}, !1) : !0
		},
		zoomThumbMouseUp: function() {
			null !== tagZoom.dragElement && (tagZoom.dragElement.style.zIndex = tagZoom.oldZIndex, document.onmousemove = null, document.onselectstart = null, tagZoom.dragElement.ondragstart = null, tagZoom.dragElement = null, tagZoom.doZoom("" + tagZoom.curr_pos))
		}
	};
YUI().use("node", "io-base", function(e) {
	function t(t) {
		var n = "#" + t.getAttribute("data-target"),
			i = t.hasClass("contracter");
		if (i) {
			t.removeClass("contracter");
			var r = e.one(n);
			r.addClass("hidden")
		} else {
			t.addClass("contracter");
			var r = e.one(n);
			r.removeClass("hidden")
		}
		var o = t.getAttribute("data-notice-url");
		o && (o += o.indexOf("?") ? "&" : "?", o += "expanded=" + !i, e.io(o))
	}
	e.delegate("click", function(e) {
		t(e.target)
	}, "body", ".expander")
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e) {
		var t = this;
		t.html(e)
	}
	e(".log-in-first-link").on("click", function() {
		var t = window.collex && window.collex.currentUserId && window.collex.currentUserId > 0;
		if (!t) {
			var n = e(this),
				i = n.attr("data-login-prompt"),
				r = new SignInDlg(i);
			r.setInitialMessage("Please log in to begin editing"), r.setRedirectPage = this.href, r.show("sign_in")
		}
	});
	for (var n = e(".lazy-load"), i = 0; i < n.length; i++) {
		var r = e(n[i]),
			o = r.attr("data-action");
		e.ajax(o, {
			context: r,
			success: t
		})
	}
}), jQuery(document).ready(function(e) {
	"use strict";

	function t(e) {
		var t = String(e);
		return t.replace(/\"/g, "&quot;")
	}

	function n(e, n, i) {
		var r = "nav_link tw_change_line";
		return i && (r += " tw_deleted_line"), '<a href="#" class="' + r + '" data-amount="' + n + '">' + t(e) + "</a>"
	}

	function i() {
		var t = e(".tw_undo_button"),
			n = e(".tw_redo_button"),
			i = e(".tw_correct"),
			r = e(".tw_delete_line");
		TW.line.canRedo(TW.currLine) ? (t.addClass("hidden"), n.removeClass("hidden")) : TW.line.canUndo(TW.currLine) ? (t.removeClass("hidden"), n.addClass("hidden")) : (t.addClass("hidden"), n.addClass("hidden")), TW.line.isInRange(TW.currLine) === !1 ? (i && i.addClass("hidden"), r && r.addClass("hidden")) : (i && i.removeClass("hidden"), i && i.removeClass("disabled"), r && r.removeClass("hidden"))
	}

	function r(t, n, i) {
		t.token = TW.token, e.ajax({
			url: TW.updateUrl,
			type: "PUT",
			data: t,
			async: !1,
			beforeSend: function(e) {
				e.setRequestHeader("X-CSRF-Token", jQuery('meta[name="csrf-token"]').attr("content"))
			},
			dataType: "json",
			success: n,
			error: i
		})
	}

	function o(e) {
		void 0 !== e.edit_line && TW.line.setEditTime(e.edit_line, e.edit_time, e.exact_time), l(e)
	}

	function a(e, t, n, i) {
		var r = '<a href="#" class="nav_link" onclick="showPartialInLightBox(\'/my_collex/show_profile?user=' + t + "', 'Profile for " + e + "', ''); return false;\">" + e + "</a>",
			o = Math.round(n % 60);
		n /= 60;
		var a = Math.round(n % 60);
		n /= 60;
		var s = Math.round(n % 24);
		n /= 24;
		var l = Math.round(n);
		return r += " (" + l + " " + s + ":" + a + ":" + o + ")", i && (r += " (page: " + i + ")"), r
	}

	function s() {
		var t = "";
		if (TW.line.numUndisplayedChanges() > 0) {
			var n = 1 === TW.line.numUndisplayedChanges() ? "There has been 1 change" : "There have been " + TW.line.numUndisplayedChanges() + " changes";
			t = '<div><button class="tw_icon tw_icon_edit_history_new tw_apply_new_data"></button><span class="tw_stale_data_note">' + n + " to this page. Click the button to update.</span></div>"
		}
		var i = "";
		if (N.page.length > 0) {
			i += "<h3>The following people are currently editing this page:</h3>";
			for (var r = 0; r < N.page.length; r++) {
				var o = N.page[r];
				i += a(o.username, o.federation_user_id, o.idle_time) + "<br>"
			}
		}
		if (N.doc.length > 0) {
			i += "<h3>The following people are currently editing other pages in this document:</h3>";
			for (var s = 0; s < N.doc.length; s++) {
				var l = N.doc[s];
				i += a(l.username, l.federation_user_id, l.idle_time, l.page) + "<br>"
			}
		}
		0 === N.page.length && 0 === N.doc.length && (i += "No one else is currently editing this document.");
		var c = e(".tw_live_status");
		if (TW.line.numUndisplayedChanges() > 0 || N.page.length > 0 || N.doc.length > 0) {
			var u = c.find(".tw_body");
			u.html(t + "<br>" + i), c.show(), y()
		} else c.hide()
	}

	function l(t) {
		if (t.lines.length > 0) {
			TW.line.liveUpdate(t.lines);
			var n = e(".tw_notification");
			n.find(".tw_notification_text").html("This page has been edited by someone else."), n.fadeIn("slow"), setTimeout(function() {
				n.fadeOut("slow")
			}, 3e3)
		}
		N = t.editors, s()
	}

	function c(t, n, i) {
		var r = e(".tw_live_status"),
			o = r.find(".tw_body");
		o.html(i.message), r.show()
	}

	function u() {
		if (TW.line.isDirty(TW.currLine)) {
			var e = TW.line.serialize(TW.currLine);
			e.page = TW.page, r({
				params: JSON.stringify(e)
			}, o, c), TW.line.setClean(TW.currLine)
		}
	}

	function d(e) {
		r({
			ping: !0,
			document_id: TW.doc_id,
			page: TW.page,
			load_time: e
		}, l, c)
	}

	function h() {
		r({
			unload: !0
		})
	}

	function p(e, t) {
		return "<span class='tw_icon " + e + " tw_history_tooltip_wrapper'>&nbsp;<span class='tw_tooltip hidden'>" + t + "</span></span>"
	}

	function f(e) {
		var t = TW.line.getAllHistory(e);
		if (t) {
			var n = TW.line.lineIsStale(e),
				i = n ? "tw_icon_edit_history_new" : "tw_icon_edit_history";
			return p(i, "<h4 class='header'>History:</h4><hr />" + t)
		}
		return ""
	}

	function g(e) {
		switch (TW.line.getChangeType(e)) {
			case "change":
				return p("tw_icon_edit", "Originally: " + TW.line.getStartingText(e));
			case "delete":
				return p("tw_icon_delete", "Line has been deleted.");
			case "correct":
				return p("tw_icon_checkmark", "Line is correct.")
		}
		return ""
	}

	function m() {
		var t = e("#tw_text_1 .tw_change_icon");
		t.html(g(TW.currLine)), i()
	}

	function v() {
		m();
		var n = e("#tw_text_1 .tw_history_icon"),
			i = e("#tw_text_1 .tw_line_num");
		n.html(f(TW.currLine)), i.html(t(TW.line.getLineNum(TW.currLine)));
		var r = TW.line.getCurrentText(TW.currLine).replace(/\"/g, "&quot;"),
			o = TW.line.isJustDeleted(TW.currLine),
			a = TW.line.lineIsStale(TW.currLine),
			s = TW.line.isDeleted(TW.currLine),
			l = TW.line.isEof(TW.currLine),
			c = [];
		c.push('id="tw_input_focus"'), c.push('type="text"'), (o || a || l) && c.push('readonly="readonly"'), s || a ? (c.push('value=""'), c.push('placeholder="' + r + '"'), c.push('class="tw_deleted_line_text"')) : c.push('value="' + r + '"'), o && c.push('class="tw_deleted_line"');
		var u = e("#tw_editing_line");
		u.html("<input " + c.join(" ") + " />"), e("#tw_input_focus").focus()
	}

	function _() {
		v(), u()
	}

	function b() {
		var t = e("#tw_input_focus");
		t && TW.line.doRegisterLineChange(TW.currLine, t.val()) && m()
	}

	function y() {
		if (void 0 !== window.TW.currLine) {
			var i = e("#tw_text_0 .tw_history_icon"),
				r = e("#tw_text_0 .tw_change_icon"),
				o = e("#tw_text_0 .tw_line_num"),
				a = e("#tw_text_0 .tw_text");
			TW.currLine > 0 ? (i.html(f(TW.currLine - 1)), r.html(g(TW.currLine - 1)), o.html(t(TW.line.getLineNum(TW.currLine - 1))), a.html(n(TW.line.getCurrentText(TW.currLine - 1), -1, TW.line.isDeleted(TW.currLine - 1)))) : (i.html(""), r.html(""), o.html(""), a.html("-- top of page --")), v(), i = e("#tw_text_2 .tw_history_icon"), r = e("#tw_text_2 .tw_change_icon"), o = e("#tw_text_2 .tw_line_num"), a = e("#tw_text_2 .tw_text"), TW.line.isLast(TW.currLine) ? (i.html(""), r.html(""), o.html(""), a.html(TW.line.isEof(TW.currLine) === !0 ? "" : "-- bottom of page --")) : (i.html(f(TW.currLine + 1)), r.html(g(TW.currLine + 1)), o.html(t(TW.line.getLineNum(TW.currLine + 1))), a.html(n(TW.line.getCurrentText(TW.currLine + 1), 1, TW.line.isDeleted(TW.currLine + 1)))), S.update(TW.currLine), O && (O.destroy(), O = void 0)
		}
	}

	function w(e) {
		TW.line.isInRange(e) ? void 0 !== window.TW.currLine && x(e) : e >= TW.lines.length && void 0 !== window.TW.currLine && TW.line.isEof(TW.currLine) === !1 && x(TW.lines.length)
	}

	function x(e) {
		TW.line.hasChanged(TW.currLine) && u(), TW.currLine = e, y()
	}

	function E(e) {
		w(TW.currLine + e)
	}

	function k(e, t, n) {
		if (e.setSelectionRange) e.focus(), e.setSelectionRange(t, t + n);
		else if (e.createTextRange) {
			var i = e.createTextRange();
			i.collapse(!0), i.moveEnd("character", t + n), i.moveStart("character", t), i.select()
		}
	}

	function C() {
		TW.line.doInsert(TW.currLine), y(), u()
	}

	function T() {
		TW.line.isEof(TW.currLine) !== !0 && (TW.line.doInsert(TW.currLine + 1), TW.currLine += 1, y(), u())
	}
	var S, O, D = e("body"),
		A = !1,
		N = {
			doc: [],
			page: []
		},
		I = 8,
		j = 13,
		F = 33,
		L = 34,
		P = 35,
		H = 36,
		M = 38,
		$ = 40,
		W = 46,
		R = 73,
		z = 89;
	if (D.on("click", ".tw_correct", function() {
		A === !1 && (TW.line.hasChanged(TW.currLine) ? E(1) : (TW.line.doConfirm(TW.currLine), _()))
	}), D.bind("changeLine:highlight", function(t, n) {
		var i = n.lineNum,
			r = n.text;
		w(i);
		var o = TW.line.getStartingText(i).indexOf(r);
		if (o >= 0) {
			var a = e("#tw_input_focus");
			k(a[0], o, r.length)
		}
	}), D.on("click", ".tw_change_line", function() {
		var t = e(this).attr("data-amount");
		E(parseInt(t, 10))
	}), D.on("mousewheel", ".tw_editing, #tw_input_focus, #tw_img_full, #tw_pointer_doc", function(e) {
		var t = e.originalEvent.wheelDelta / 120;
		E(-t), e.preventDefault(), e.stopPropagation()
	}), D.on("DOMMouseScroll", ".tw_editing, #tw_input_focus, #tw_img_full, #tw_pointer_doc", function(e) {
		var t = e.originalEvent.detail;
		E(t), e.preventDefault(), e.stopPropagation()
	}), D.on("click", "#tw_img_thumb", function(e) {
		var t = S.convertThumbToOrig(e.clientX, e.clientY),
			n = TW.line.findLine(t.x, t.y);
		w(n)
	}), e(window).unload(function() {
		void 0 !== TW.updateUrl && (void 0 !== TW.currLine && TW.line.hasChanged(TW.currLine) && u(), h())
	}), D.on("click", ".tw_delete_line", function() {
		TW.line.doDelete(TW.currLine), _()
	}), D.on("keydown", "#tw_input_focus", function(e) {
		A = !0;
		var t = e.which;
		switch (t) {
			case j:
			case F:
			case L:
			case M:
			case $:
			case P:
			case H:
				return !1
		}
	}), D.on("keyup", "#tw_input_focus", function(t) {
		var n = t.which;
		switch (n) {
			case I:
				t.ctrlKey ? (TW.line.doDelete(TW.currLine), _()) : b();
				break;
			case W:
				t.ctrlKey ? (TW.line.doDelete(TW.currLine), _()) : b();
				break;
			case j:
				t.ctrlKey ? (TW.line.doConfirm(TW.currLine), _()) : A && E(1);
				break;
			case F:
				E(-3);
				break;
			case L:
				E(3);
				break;
			case M:
				E(-1);
				break;
			case $:
				E(1);
				break;
			case P:
				var i = e("#tw_input_focus");
				k(i[0], i.val().length, 0);
				break;
			case H:
				var r = e("#tw_input_focus");
				k(r[0], 0, 0);
				break;
			default:
				var o = !1;
				n === R ? t.ctrlKey && t.shiftKey === !1 ? (T(), o = !0) : t.ctrlKey && t.shiftKey && (C(), o = !0) : n === z && t.ctrlKey && (TW.line.canRedo(TW.currLine) ? (TW.line.doRedo(TW.currLine), _()) : TW.line.canUndo(TW.currLine) && (TW.line.doUndo(TW.currLine), _()), o = !0), o === !1 && b()
		}
		A = !1
	}), D.on("click", ".tw_undo_button", function() {
		TW.line.doUndo(TW.currLine), _()
	}), D.on("click", ".tw_redo_button", function() {
		TW.line.doRedo(TW.currLine), _()
	}), D.on("click", ".tw_insert_above_button", function() {
		C()
	}), D.on("click", ".tw_insert_below_button", function() {
		T()
	}), YUI().use("node", "event-delegate", "resize", function(e) {
		e.on("resize", function() {
			y()
		}, window), D.on("click", ".tw_resize_box", function() {
			return O ? (O.destroy(), O = void 0) : (O = new e.Resize({
				node: "#tw_pointer_doc"
			}), O.plug(e.Plugin.ResizeConstrained, {
				constrain: "#tw_img_full",
				minHeight: 16,
				minWidth: 50
			}), O.on("resize:end", function(e) {
				var t = S.getBox(TW.currLine);
				t && (TW.line.setRect(TW.currLine, t), e.preventDefault(), e.stopPropagation())
			})), !1
		})
	}), D.on("click", ".tw_apply_new_data", function() {
		TW.line.integrateRemoteChanges(), s()
	}), void 0 !== TW.updateUrl) {
		var U = 3e4;
		setInterval(d, U)
	}
	D.on("click", ".tw_dismiss", function() {
		return e(".tw_notification").fadeOut("slow"), !1
	}), setTimeout(function() {
		void 0 !== TW.updateUrl && (S = TW.createImageCursor(), void 0 !== window.TW.currLine && w(window.TW.currLine), d(window.TW.loadTime), e("#tw_input_focus").focus(), setTimeout(function() {
			e("#tw_input_focus").focus()
		}, 1e3))
	}, 1)
}), jQuery(document).ready(function() {
	"use strict";

	function e(e) {
		var t = e.attr("data-url"),
			n = function() {
				serverAction({
					action: {
						actions: {
							method: "PUT",
							url: t
						}
					}
				})
			};
		new ConfirmDlg("Delete Edits", "This will delete any edits made on this page. Are you sure?", "Ok", "Cancel", n)
	}
	jQuery("#tw_delete_edits").on("click", function() {
		e(jQuery(this))
	})
}), jQuery(document).ready(function() {
	"use strict";

	function e(e) {
		var t = e.attr("data-url"),
			n = e.attr("data-title");
		showPartialInLightBox(t, n, "/assets/ajax_loader.gif")
	}
	jQuery(".show-in-lightbox").on("click", function() {
		e(jQuery(this))
	})
});
var DIFF_DELETE = -1,
	DIFF_INSERT = 1,
	DIFF_EQUAL = 0;
Diff_match_patch.Diff, Diff_match_patch.prototype.diff_main = function(e, t, n, i) {
	"undefined" == typeof i && (i = this.Diff_Timeout <= 0 ? Number.MAX_VALUE : (new Date).getTime() + 1e3 * this.Diff_Timeout);
	var r = i;
	if (null == e || null == t) throw new Error("Null input. (diff_main)");
	if (e == t) return e ? [
		[DIFF_EQUAL, e]
	] : [];
	"undefined" == typeof n && (n = !0);
	var o = n,
		a = this.diff_commonPrefix(e, t),
		s = e.substring(0, a);
	e = e.substring(a), t = t.substring(a), a = this.diff_commonSuffix(e, t);
	var l = e.substring(e.length - a);
	e = e.substring(0, e.length - a), t = t.substring(0, t.length - a);
	var c = this.diff_compute_(e, t, o, r);
	return s && c.unshift([DIFF_EQUAL, s]), l && c.push([DIFF_EQUAL, l]), this.diff_cleanupMerge(c), c
}, Diff_match_patch.prototype.diff_compute_ = function(e, t, n, i) {
	var r;
	if (!e) return [
		[DIFF_INSERT, t]
	];
	if (!t) return [
		[DIFF_DELETE, e]
	];
	var o = e.length > t.length ? e : t,
		a = e.length > t.length ? t : e,
		s = o.indexOf(a);
	if (-1 != s) return r = [
		[DIFF_INSERT, o.substring(0, s)],
		[DIFF_EQUAL, a],
		[DIFF_INSERT, o.substring(s + a.length)]
	], e.length > t.length && (r[0][0] = r[2][0] = DIFF_DELETE), r;
	if (1 == a.length) return [
		[DIFF_DELETE, e],
		[DIFF_INSERT, t]
	];
	o = a = null;
	var l = this.diff_halfMatch_(e, t);
	if (l) {
		var c = l[0],
			u = l[1],
			d = l[2],
			h = l[3],
			p = l[4],
			f = this.diff_main(c, d, n, i),
			g = this.diff_main(u, h, n, i);
		return f.concat([
			[DIFF_EQUAL, p]
		], g)
	}
	return n && e.length > 100 && t.length > 100 ? this.diff_lineMode_(e, t, i) : this.diff_bisect_(e, t, i)
}, Diff_match_patch.prototype.diff_lineMode_ = function(e, t, n) {
	var i = this.diff_linesToChars_(e, t);
	e = i[0], t = i[1];
	var r = i[2],
		o = this.diff_bisect_(e, t, n);
	this.diff_charsToLines_(o, r), this.diff_cleanupSemantic(o), o.push([DIFF_EQUAL, ""]);
	for (var a = 0, s = 0, l = 0, c = "", u = ""; a < o.length;) {
		switch (o[a][0]) {
			case DIFF_INSERT:
				l++, u += o[a][1];
				break;
			case DIFF_DELETE:
				s++, c += o[a][1];
				break;
			case DIFF_EQUAL:
				if (s >= 1 && l >= 1) {
					var i = this.diff_main(c, u, !1, n);
					o.splice(a - s - l, s + l), a = a - s - l;
					for (var d = i.length - 1; d >= 0; d--) o.splice(a, 0, i[d]);
					a += i.length
				}
				l = 0, s = 0, c = "", u = ""
		}
		a++
	}
	return o.pop(), o
}, Diff_match_patch.prototype.diff_bisect_ = function(e, t, n) {
	for (var i = e.length, r = t.length, o = Math.ceil((i + r) / 2), a = o, s = 2 * o, l = new Array(s), c = new Array(s), u = 0; s > u; u++) l[u] = -1, c[u] = -1;
	l[a + 1] = 0, c[a + 1] = 0;
	for (var d = i - r, h = d % 2 != 0, p = 0, f = 0, g = 0, m = 0, v = 0; o > v && !((new Date).getTime() > n); v++) {
		for (var _ = -v + p; v - f >= _; _ += 2) {
			var b, y = a + _;
			b = _ == -v || _ != v && l[y - 1] < l[y + 1] ? l[y + 1] : l[y - 1] + 1;
			for (var w = b - _; i > b && r > w && e.charAt(b) == t.charAt(w);) b++, w++;
			if (l[y] = b, b > i) f += 2;
			else if (w > r) p += 2;
			else if (h) {
				var x = a + d - _;
				if (x >= 0 && s > x && -1 != c[x]) {
					var E = i - c[x];
					if (b >= E) return this.diff_bisectSplit_(e, t, b, w, n)
				}
			}
		}
		for (var k = -v + g; v - m >= k; k += 2) {
			var E, x = a + k;
			E = k == -v || k != v && c[x - 1] < c[x + 1] ? c[x + 1] : c[x - 1] + 1;
			for (var C = E - k; i > E && r > C && e.charAt(i - E - 1) == t.charAt(r - C - 1);) E++, C++;
			if (c[x] = E, E > i) m += 2;
			else if (C > r) g += 2;
			else if (!h) {
				var y = a + d - k;
				if (y >= 0 && s > y && -1 != l[y]) {
					var b = l[y],
						w = a + b - y;
					if (E = i - E, b >= E) return this.diff_bisectSplit_(e, t, b, w, n)
				}
			}
		}
	}
	return [
		[DIFF_DELETE, e],
		[DIFF_INSERT, t]
	]
}, Diff_match_patch.prototype.diff_bisectSplit_ = function(e, t, n, i, r) {
	var o = e.substring(0, n),
		a = t.substring(0, i),
		s = e.substring(n),
		l = t.substring(i),
		c = this.diff_main(o, a, !1, r),
		u = this.diff_main(s, l, !1, r);
	return c.concat(u)
}, Diff_match_patch.prototype.diff_linesToChars_ = function(e, t) {
	function n(e) {
		for (var t = "", n = 0, o = -1, a = i.length; o < e.length - 1;) {
			o = e.indexOf("\n", n), -1 == o && (o = e.length - 1);
			var s = e.substring(n, o + 1);
			n = o + 1, (r.hasOwnProperty ? r.hasOwnProperty(s) : void 0 !== r[s]) ? t += String.fromCharCode(r[s]) : (t += String.fromCharCode(a), r[s] = a, i[a++] = s)
		}
		return t
	}
	var i = [],
		r = {};
	i[0] = "";
	var o = n(e),
		a = n(t);
	return [o, a, i]
}, Diff_match_patch.prototype.diff_charsToLines_ = function(e, t) {
	for (var n = 0; n < e.length; n++) {
		for (var i = e[n][1], r = [], o = 0; o < i.length; o++) r[o] = t[i.charCodeAt(o)];
		e[n][1] = r.join("")
	}
}, Diff_match_patch.prototype.diff_commonPrefix = function(e, t) {
	if (!e || !t || e.charAt(0) != t.charAt(0)) return 0;
	for (var n = 0, i = Math.min(e.length, t.length), r = i, o = 0; r > n;) e.substring(o, r) == t.substring(o, r) ? (n = r, o = n) : i = r, r = Math.floor((i - n) / 2 + n);
	return r
}, Diff_match_patch.prototype.diff_commonSuffix = function(e, t) {
	if (!e || !t || e.charAt(e.length - 1) != t.charAt(t.length - 1)) return 0;
	for (var n = 0, i = Math.min(e.length, t.length), r = i, o = 0; r > n;) e.substring(e.length - r, e.length - o) == t.substring(t.length - r, t.length - o) ? (n = r, o = n) : i = r, r = Math.floor((i - n) / 2 + n);
	return r
}, Diff_match_patch.prototype.diff_commonOverlap_ = function(e, t) {
	var n = e.length,
		i = t.length;
	if (0 == n || 0 == i) return 0;
	n > i ? e = e.substring(n - i) : i > n && (t = t.substring(0, n));
	var r = Math.min(n, i);
	if (e == t) return r;
	for (var o = 0, a = 1;;) {
		var s = e.substring(r - a),
			l = t.indexOf(s);
		if (-1 == l) return o;
		a += l, (0 == l || e.substring(r - a) == t.substring(0, a)) && (o = a, a++)
	}
}, Diff_match_patch.prototype.diff_halfMatch_ = function(e, t) {
	function n(e, t, n) {
		for (var i, r, o, s, l = e.substring(n, n + Math.floor(e.length / 4)), c = -1, u = ""; - 1 != (c = t.indexOf(l, c + 1));) {
			var d = a.diff_commonPrefix(e.substring(n), t.substring(c)),
				h = a.diff_commonSuffix(e.substring(0, n), t.substring(0, c));
			u.length < h + d && (u = t.substring(c - h, c) + t.substring(c, c + d), i = e.substring(0, n - h), r = e.substring(n + d), o = t.substring(0, c - h), s = t.substring(c + d))
		}
		return 2 * u.length >= e.length ? [i, r, o, s, u] : null
	}
	if (this.Diff_Timeout <= 0) return null;
	var i = e.length > t.length ? e : t,
		r = e.length > t.length ? t : e;
	if (i.length < 4 || 2 * r.length < i.length) return null;
	var o, a = this,
		s = n(i, r, Math.ceil(i.length / 4)),
		l = n(i, r, Math.ceil(i.length / 2));
	if (!s && !l) return null;
	o = l ? s && s[4].length > l[4].length ? s : l : s;
	var c, u, d, h;
	e.length > t.length ? (c = o[0], u = o[1], d = o[2], h = o[3]) : (d = o[0], h = o[1], c = o[2], u = o[3]);
	var p = o[4];
	return [c, u, d, h, p]
}, Diff_match_patch.prototype.diff_cleanupSemantic = function(e) {
	for (var t = !1, n = [], i = 0, r = null, o = 0, a = 0, s = 0, l = 0, c = 0; o < e.length;) e[o][0] == DIFF_EQUAL ? (n[i++] = o, a = l, s = c, l = 0, c = 0, r = e[o][1]) : (e[o][0] == DIFF_INSERT ? l += e[o][1].length : c += e[o][1].length, null !== r && r.length <= Math.max(a, s) && r.length <= Math.max(l, c) && (e.splice(n[i - 1], 0, [DIFF_DELETE, r]), e[n[i - 1] + 1][0] = DIFF_INSERT, i--, i--, o = i > 0 ? n[i - 1] : -1, a = 0, s = 0, l = 0, c = 0, r = null, t = !0)), o++;
	for (t && this.diff_cleanupMerge(e), this.diff_cleanupSemanticLossless(e), o = 1; o < e.length;) {
		if (e[o - 1][0] == DIFF_DELETE && e[o][0] == DIFF_INSERT) {
			var u = e[o - 1][1],
				d = e[o][1],
				h = this.diff_commonOverlap_(u, d);
			h && (e.splice(o, 0, [DIFF_EQUAL, d.substring(0, h)]), e[o - 1][1] = u.substring(0, u.length - h), e[o + 1][1] = d.substring(h), o++), o++
		}
		o++
	}
}, Diff_match_patch.prototype.diff_cleanupSemanticLossless = function(e) {
	function t(e, t) {
		if (!e || !t) return 5;
		var s = 0;
		return (e.charAt(e.length - 1).match(n) || t.charAt(0).match(n)) && (s++, (e.charAt(e.length - 1).match(i) || t.charAt(0).match(i)) && (s++, (e.charAt(e.length - 1).match(r) || t.charAt(0).match(r)) && (s++, (e.match(o) || t.match(a)) && s++))), s
	}
	for (var n = /[^a-zA-Z0-9]/, i = /\s/, r = /[\r\n]/, o = /\n\r?\n$/, a = /^\r?\n\r?\n/, s = 1; s < e.length - 1;) {
		if (e[s - 1][0] == DIFF_EQUAL && e[s + 1][0] == DIFF_EQUAL) {
			var l = e[s - 1][1],
				c = e[s][1],
				u = e[s + 1][1],
				d = this.diff_commonSuffix(l, c);
			if (d) {
				var h = c.substring(c.length - d);
				l = l.substring(0, l.length - d), c = h + c.substring(0, c.length - d), u = h + u
			}
			for (var p = l, f = c, g = u, m = t(l, c) + t(c, u); c.charAt(0) === u.charAt(0);) {
				l += c.charAt(0), c = c.substring(1) + u.charAt(0), u = u.substring(1);
				var v = t(l, c) + t(c, u);
				v >= m && (m = v, p = l, f = c, g = u)
			}
			e[s - 1][1] != p && (p ? e[s - 1][1] = p : (e.splice(s - 1, 1), s--), e[s][1] = f, g ? e[s + 1][1] = g : (e.splice(s + 1, 1), s--))
		}
		s++
	}
}, Diff_match_patch.prototype.diff_cleanupEfficiency = function(e) {
	for (var t = !1, n = [], i = 0, r = "", o = 0, a = !1, s = !1, l = !1, c = !1; o < e.length;) e[o][0] == DIFF_EQUAL ? (e[o][1].length < this.Diff_EditCost && (l || c) ? (n[i++] = o, a = l, s = c, r = e[o][1]) : (i = 0, r = ""), l = c = !1) : (e[o][0] == DIFF_DELETE ? c = !0 : l = !0, r && (a && s && l && c || r.length < this.Diff_EditCost / 2 && a + s + l + c == 3) && (e.splice(n[i - 1], 0, [DIFF_DELETE, r]), e[n[i - 1] + 1][0] = DIFF_INSERT, i--, r = "", a && s ? (l = c = !0, i = 0) : (i--, o = i > 0 ? n[i - 1] : -1, l = c = !1), t = !0)), o++;
	t && this.diff_cleanupMerge(e)
}, Diff_match_patch.prototype.diff_cleanupMerge = function(e) {
	e.push([DIFF_EQUAL, ""]);
	for (var t, n = 0, i = 0, r = 0, o = "", a = ""; n < e.length;) switch (e[n][0]) {
		case DIFF_INSERT:
			r++, a += e[n][1], n++;
			break;
		case DIFF_DELETE:
			i++, o += e[n][1], n++;
			break;
		case DIFF_EQUAL:
			i + r > 1 ? (0 !== i && 0 !== r && (t = this.diff_commonPrefix(a, o), 0 !== t && (n - i - r > 0 && e[n - i - r - 1][0] == DIFF_EQUAL ? e[n - i - r - 1][1] += a.substring(0, t) : (e.splice(0, 0, [DIFF_EQUAL, a.substring(0, t)]), n++), a = a.substring(t), o = o.substring(t)), t = this.diff_commonSuffix(a, o), 0 !== t && (e[n][1] = a.substring(a.length - t) + e[n][1], a = a.substring(0, a.length - t), o = o.substring(0, o.length - t))), 0 === i ? e.splice(n - i - r, i + r, [DIFF_INSERT, a]) : 0 === r ? e.splice(n - i - r, i + r, [DIFF_DELETE, o]) : e.splice(n - i - r, i + r, [DIFF_DELETE, o], [DIFF_INSERT, a]), n = n - i - r + (i ? 1 : 0) + (r ? 1 : 0) + 1) : 0 !== n && e[n - 1][0] == DIFF_EQUAL ? (e[n - 1][1] += e[n][1], e.splice(n, 1)) : n++, r = 0, i = 0, o = "", a = ""
	}
	"" === e[e.length - 1][1] && e.pop();
	var s = !1;
	for (n = 1; n < e.length - 1;) e[n - 1][0] == DIFF_EQUAL && e[n + 1][0] == DIFF_EQUAL && (e[n][1].substring(e[n][1].length - e[n - 1][1].length) == e[n - 1][1] ? (e[n][1] = e[n - 1][1] + e[n][1].substring(0, e[n][1].length - e[n - 1][1].length), e[n + 1][1] = e[n - 1][1] + e[n + 1][1], e.splice(n - 1, 1), s = !0) : e[n][1].substring(0, e[n + 1][1].length) == e[n + 1][1] && (e[n - 1][1] += e[n + 1][1], e[n][1] = e[n][1].substring(e[n + 1][1].length) + e[n + 1][1], e.splice(n + 1, 1), s = !0)), n++;
	s && this.diff_cleanupMerge(e)
}, Diff_match_patch.prototype.diff_xIndex = function(e, t) {
	var n, i = 0,
		r = 0,
		o = 0,
		a = 0;
	for (n = 0; n < e.length && (e[n][0] !== DIFF_INSERT && (i += e[n][1].length), e[n][0] !== DIFF_DELETE && (r += e[n][1].length), !(i > t)); n++) o = i, a = r;
	return e.length != n && e[n][0] === DIFF_DELETE ? a : a + (t - o)
}, Diff_match_patch.prototype.diff_prettyHtml = function(e) {
	for (var t = [], n = 0, i = /&/g, r = /</g, o = />/g, a = /\n/g, s = 0; s < e.length; s++) {
		var l = e[s][0],
			c = e[s][1],
			u = c.replace(i, "&amp;").replace(r, "&lt;").replace(o, "&gt;").replace(a, "&para;<br>");
		switch (l) {
			case DIFF_INSERT:
				t[s] = '<ins style="background:#e6ffe6;">' + u + "</ins>";
				break;
			case DIFF_DELETE:
				t[s] = '<del style="background:#ffe6e6;">' + u + "</del>";
				break;
			case DIFF_EQUAL:
				t[s] = "<span>" + u + "</span>"
		}
		l !== DIFF_DELETE && (n += c.length)
	}
	return t.join("")
}, Diff_match_patch.prototype.diff_text1 = function(e) {
	for (var t = [], n = 0; n < e.length; n++) e[n][0] !== DIFF_INSERT && (t[n] = e[n][1]);
	return t.join("")
}, Diff_match_patch.prototype.diff_text2 = function(e) {
	for (var t = [], n = 0; n < e.length; n++) e[n][0] !== DIFF_DELETE && (t[n] = e[n][1]);
	return t.join("")
}, Diff_match_patch.prototype.diff_levenshtein = function(e) {
	for (var t = 0, n = 0, i = 0, r = 0; r < e.length; r++) {
		var o = e[r][0],
			a = e[r][1];
		switch (o) {
			case DIFF_INSERT:
				n += a.length;
				break;
			case DIFF_DELETE:
				i += a.length;
				break;
			case DIFF_EQUAL:
				t += Math.max(n, i), n = 0, i = 0
		}
	}
	return t += Math.max(n, i)
}, Diff_match_patch.prototype.diff_toDelta = function(e) {
	for (var t = [], n = 0; n < e.length; n++) switch (e[n][0]) {
		case DIFF_INSERT:
			t[n] = "+" + encodeURI(e[n][1]);
			break;
		case DIFF_DELETE:
			t[n] = "-" + e[n][1].length;
			break;
		case DIFF_EQUAL:
			t[n] = "=" + e[n][1].length
	}
	return t.join("	").replace(/%20/g, " ")
}, Diff_match_patch.prototype.diff_fromDelta = function(e, t) {
	for (var n = [], i = 0, r = 0, o = t.split(/\t/g), a = 0; a < o.length; a++) {
		var s = o[a].substring(1);
		switch (o[a].charAt(0)) {
			case "+":
				try {
					n[i++] = [DIFF_INSERT, decodeURI(s)]
				} catch (l) {
					throw new Error("Illegal escape in diff_fromDelta: " + s)
				}
				break;
			case "-":
			case "=":
				var c = parseInt(s, 10);
				if (isNaN(c) || 0 > c) throw new Error("Invalid number in diff_fromDelta: " + s);
				var u = e.substring(r, r += c);
				n[i++] = "=" == o[a].charAt(0) ? [DIFF_EQUAL, u] : [DIFF_DELETE, u];
				break;
			default:
				if (o[a]) throw new Error("Invalid diff operation in diff_fromDelta: " + o[a])
		}
	}
	if (r != e.length) throw new Error("Delta length (" + r + ") does not equal source text length (" + e.length + ").");
	return n
}, Diff_match_patch.prototype.match_main = function(e, t, n) {
	if (null == e || null == t || null == n) throw new Error("Null input. (match_main)");
	return n = Math.max(0, Math.min(n, e.length)), e == t ? 0 : e.length ? e.substring(n, n + t.length) == t ? n : this.match_bitap_(e, t, n) : -1
}, Diff_match_patch.prototype.match_bitap_ = function(e, t, n) {
	function i(e, i) {
		var r = e / t.length,
			a = Math.abs(n - i);
		return o.Match_Distance ? r + a / o.Match_Distance : a ? 1 : r
	}
	if (t.length > this.Match_MaxBits) throw new Error("Pattern too long for this browser.");
	var r = this.match_alphabet_(t),
		o = this,
		a = this.Match_Threshold,
		s = e.indexOf(t, n); - 1 != s && (a = Math.min(i(0, s), a), s = e.lastIndexOf(t, n + t.length), -1 != s && (a = Math.min(i(0, s), a)));
	var l = 1 << t.length - 1;
	s = -1;
	for (var c, u, d, h = t.length + e.length, p = 0; p < t.length; p++) {
		for (c = 0, u = h; u > c;) i(p, n + u) <= a ? c = u : h = u, u = Math.floor((h - c) / 2 + c);
		h = u;
		var f = Math.max(1, n - u + 1),
			g = Math.min(n + u, e.length) + t.length,
			m = Array(g + 2);
		m[g + 1] = (1 << p) - 1;
		for (var v = g; v >= f; v--) {
			var _ = r[e.charAt(v - 1)];
			if (m[v] = 0 === p ? (m[v + 1] << 1 | 1) & _ : (m[v + 1] << 1 | 1) & _ | ((d[v + 1] | d[v]) << 1 | 1) | d[v + 1], m[v] & l) {
				var b = i(p, v - 1);
				if (a >= b) {
					if (a = b, s = v - 1, !(s > n)) break;
					f = Math.max(1, 2 * n - s)
				}
			}
		}
		if (i(p + 1, n) > a) break;
		d = m
	}
	return s
}, Diff_match_patch.prototype.match_alphabet_ = function(e) {
	for (var t = {}, n = 0; n < e.length; n++) t[e.charAt(n)] = 0;
	for (var n = 0; n < e.length; n++) t[e.charAt(n)] |= 1 << e.length - n - 1;
	return t
}, Diff_match_patch.prototype.patch_addContext_ = function(e, t) {
	if (0 != t.length) {
		for (var n = t.substring(e.start2, e.start2 + e.length1), i = 0; t.indexOf(n) != t.lastIndexOf(n) && n.length < this.Match_MaxBits - this.Patch_Margin - this.Patch_Margin;) i += this.Patch_Margin, n = t.substring(e.start2 - i, e.start2 + e.length1 + i);
		i += this.Patch_Margin;
		var r = t.substring(e.start2 - i, e.start2);
		r && e.diffs.unshift([DIFF_EQUAL, r]);
		var o = t.substring(e.start2 + e.length1, e.start2 + e.length1 + i);
		o && e.diffs.push([DIFF_EQUAL, o]), e.start1 -= r.length, e.start2 -= r.length, e.length1 += r.length + o.length, e.length2 += r.length + o.length
	}
}, Diff_match_patch.prototype.patch_make = function(e, t, n) {
	var i, r;
	if ("string" == typeof e && "string" == typeof t && "undefined" == typeof n) i = e, r = this.diff_main(i, t, !0), r.length > 2 && (this.diff_cleanupSemantic(r), this.diff_cleanupEfficiency(r));
	else if (e && "object" == typeof e && "undefined" == typeof t && "undefined" == typeof n) r = e, i = this.diff_text1(r);
	else if ("string" == typeof e && t && "object" == typeof t && "undefined" == typeof n) i = e, r = t;
	else {
		if ("string" != typeof e || "string" != typeof t || !n || "object" != typeof n) throw new Error("Unknown call format to patch_make.");
		i = e, r = n
	} if (0 === r.length) return [];
	for (var o = [], a = new patch_obj, s = 0, l = 0, c = 0, u = i, d = i, h = 0; h < r.length; h++) {
		var p = r[h][0],
			f = r[h][1];
		switch (s || p === DIFF_EQUAL || (a.start1 = l, a.start2 = c), p) {
			case DIFF_INSERT:
				a.diffs[s++] = r[h], a.length2 += f.length, d = d.substring(0, c) + f + d.substring(c);
				break;
			case DIFF_DELETE:
				a.length1 += f.length, a.diffs[s++] = r[h], d = d.substring(0, c) + d.substring(c + f.length);
				break;
			case DIFF_EQUAL:
				f.length <= 2 * this.Patch_Margin && s && r.length != h + 1 ? (a.diffs[s++] = r[h], a.length1 += f.length, a.length2 += f.length) : f.length >= 2 * this.Patch_Margin && s && (this.patch_addContext_(a, u), o.push(a), a = new patch_obj, s = 0, u = d, l = c)
		}
		p !== DIFF_INSERT && (l += f.length), p !== DIFF_DELETE && (c += f.length)
	}
	return s && (this.patch_addContext_(a, u), o.push(a)), o
}, Diff_match_patch.prototype.patch_deepCopy = function(e) {
	for (var t = [], n = 0; n < e.length; n++) {
		var i = e[n],
			r = new patch_obj;
		r.diffs = [];
		for (var o = 0; o < i.diffs.length; o++) r.diffs[o] = i.diffs[o].slice();
		r.start1 = i.start1, r.start2 = i.start2, r.length1 = i.length1, r.length2 = i.length2, t[n] = r
	}
	return t
}, Diff_match_patch.prototype.patch_apply = function(e, t) {
	if (0 == e.length) return [t, []];
	e = this.patch_deepCopy(e);
	var n = this.patch_addPadding(e);
	t = n + t + n, this.patch_splitMax(e);
	for (var i = 0, r = [], o = 0; o < e.length; o++) {
		var a, s = e[o].start2 + i,
			l = this.diff_text1(e[o].diffs),
			c = -1;
		if (l.length > this.Match_MaxBits ? (a = this.match_main(t, l.substring(0, this.Match_MaxBits), s), -1 != a && (c = this.match_main(t, l.substring(l.length - this.Match_MaxBits), s + l.length - this.Match_MaxBits), (-1 == c || a >= c) && (a = -1))) : a = this.match_main(t, l, s), -1 == a) r[o] = !1, i -= e[o].length2 - e[o].length1;
		else {
			r[o] = !0, i = a - s;
			var u;
			if (u = -1 == c ? t.substring(a, a + l.length) : t.substring(a, c + this.Match_MaxBits), l == u) t = t.substring(0, a) + this.diff_text2(e[o].diffs) + t.substring(a + l.length);
			else {
				var d = this.diff_main(l, u, !1);
				if (l.length > this.Match_MaxBits && this.diff_levenshtein(d) / l.length > this.Patch_DeleteThreshold) r[o] = !1;
				else {
					this.diff_cleanupSemanticLossless(d);
					for (var h, p = 0, f = 0; f < e[o].diffs.length; f++) {
						var g = e[o].diffs[f];
						g[0] !== DIFF_EQUAL && (h = this.diff_xIndex(d, p)), g[0] === DIFF_INSERT ? t = t.substring(0, a + h) + g[1] + t.substring(a + h) : g[0] === DIFF_DELETE && (t = t.substring(0, a + h) + t.substring(a + this.diff_xIndex(d, p + g[1].length))), g[0] !== DIFF_DELETE && (p += g[1].length)
					}
				}
			}
		}
	}
	return t = t.substring(n.length, t.length - n.length), [t, r]
}, Diff_match_patch.prototype.patch_addPadding = function(e) {
	for (var t = this.Patch_Margin, n = "", i = 1; t >= i; i++) n += String.fromCharCode(i);
	for (var i = 0; i < e.length; i++) e[i].start1 += t, e[i].start2 += t;
	var r = e[0],
		o = r.diffs;
	if (0 == o.length || o[0][0] != DIFF_EQUAL) o.unshift([DIFF_EQUAL, n]), r.start1 -= t, r.start2 -= t, r.length1 += t, r.length2 += t;
	else if (t > o[0][1].length) {
		var a = t - o[0][1].length;
		o[0][1] = n.substring(o[0][1].length) + o[0][1], r.start1 -= a, r.start2 -= a, r.length1 += a, r.length2 += a
	}
	if (r = e[e.length - 1], o = r.diffs, 0 == o.length || o[o.length - 1][0] != DIFF_EQUAL) o.push([DIFF_EQUAL, n]), r.length1 += t, r.length2 += t;
	else if (t > o[o.length - 1][1].length) {
		var a = t - o[o.length - 1][1].length;
		o[o.length - 1][1] += n.substring(0, a), r.length1 += a, r.length2 += a
	}
	return n
}, Diff_match_patch.prototype.patch_splitMax = function(e) {
	for (var t = this.Match_MaxBits, n = 0; n < e.length; n++)
		if (e[n].length1 > t) {
			var i = e[n];
			e.splice(n--, 1);
			for (var r = i.start1, o = i.start2, a = ""; 0 !== i.diffs.length;) {
				var s = new patch_obj,
					l = !0;
				for (s.start1 = r - a.length, s.start2 = o - a.length, "" !== a && (s.length1 = s.length2 = a.length, s.diffs.push([DIFF_EQUAL, a])); 0 !== i.diffs.length && s.length1 < t - this.Patch_Margin;) {
					var c = i.diffs[0][0],
						u = i.diffs[0][1];
					c === DIFF_INSERT ? (s.length2 += u.length, o += u.length, s.diffs.push(i.diffs.shift()), l = !1) : c === DIFF_DELETE && 1 == s.diffs.length && s.diffs[0][0] == DIFF_EQUAL && u.length > 2 * t ? (s.length1 += u.length, r += u.length, l = !1, s.diffs.push([c, u]), i.diffs.shift()) : (u = u.substring(0, t - s.length1 - this.Patch_Margin), s.length1 += u.length, r += u.length, c === DIFF_EQUAL ? (s.length2 += u.length, o += u.length) : l = !1, s.diffs.push([c, u]), u == i.diffs[0][1] ? i.diffs.shift() : i.diffs[0][1] = i.diffs[0][1].substring(u.length))
				}
				a = this.diff_text2(s.diffs), a = a.substring(a.length - this.Patch_Margin);
				var d = this.diff_text1(i.diffs).substring(0, this.Patch_Margin);
				"" !== d && (s.length1 += d.length, s.length2 += d.length, 0 !== s.diffs.length && s.diffs[s.diffs.length - 1][0] === DIFF_EQUAL ? s.diffs[s.diffs.length - 1][1] += d : s.diffs.push([DIFF_EQUAL, d])), l || e.splice(++n, 0, s)
			}
		}
}, Diff_match_patch.prototype.patch_toText = function(e) {
	for (var t = [], n = 0; n < e.length; n++) t[n] = e[n];
	return t.join("")
}, Diff_match_patch.prototype.patch_fromText = function(e) {
	var t = [];
	if (!e) return t;
	for (var n = e.split("\n"), i = 0, r = /^@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@$/; i < n.length;) {
		var o = n[i].match(r);
		if (!o) throw new Error("Invalid patch string: " + n[i]);
		var a = new patch_obj;
		for (t.push(a), a.start1 = parseInt(o[1], 10), "" === o[2] ? (a.start1--, a.length1 = 1) : "0" == o[2] ? a.length1 = 0 : (a.start1--, a.length1 = parseInt(o[2], 10)), a.start2 = parseInt(o[3], 10), "" === o[4] ? (a.start2--, a.length2 = 1) : "0" == o[4] ? a.length2 = 0 : (a.start2--, a.length2 = parseInt(o[4], 10)), i++; i < n.length;) {
			var s = n[i].charAt(0);
			try {
				var l = decodeURI(n[i].substring(1))
			} catch (c) {
				throw new Error("Illegal escape in patch_fromText: " + l)
			}
			if ("-" == s) a.diffs.push([DIFF_DELETE, l]);
			else if ("+" == s) a.diffs.push([DIFF_INSERT, l]);
			else if (" " == s) a.diffs.push([DIFF_EQUAL, l]);
			else {
				if ("@" == s) break;
				if ("" !== s) throw new Error('Invalid patch mode "' + s + '" in: ' + l)
			}
			i++
		}
	}
	return t
}, patch_obj.prototype.toString = function() {
	var e, t;
	e = 0 === this.length1 ? this.start1 + ",0" : 1 == this.length1 ? this.start1 + 1 : this.start1 + 1 + "," + this.length1, t = 0 === this.length2 ? this.start2 + ",0" : 1 == this.length2 ? this.start2 + 1 : this.start2 + 1 + "," + this.length2;
	for (var n, i = ["@@ -" + e + " +" + t + " @@\n"], r = 0; r < this.diffs.length; r++) {
		switch (this.diffs[r][0]) {
			case DIFF_INSERT:
				n = "+";
				break;
			case DIFF_DELETE:
				n = "-";
				break;
			case DIFF_EQUAL:
				n = " "
		}
		i[r + 1] = n + encodeURI(this.diffs[r][1]) + "\n"
	}
	return i.join("").replace(/%20/g, " ")
}, window.Diff_match_patch = Diff_match_patch, window.patch_obj = patch_obj, window.DIFF_DELETE = DIFF_DELETE, window.DIFF_INSERT = DIFF_INSERT, window.DIFF_EQUAL = DIFF_EQUAL, jQuery(document).ready(function() {
	"use strict";
	jQuery(".tw_edit_page_nav_button .tw-complete-btn").on("click", function() {
		jQuery.ajax({
			url: "/typewright/documents/" + TW.doc_id + "/complete",
			type: "POST",
			beforeSend: function(e) {
				e.setRequestHeader("X-CSRF-Token", jQuery('meta[name="csrf-token"]').attr("content"))
			},
			success: function() {
				jQuery(".tw-complete-msg").show(), jQuery(".tw-complete-btn").hide()
			},
			error: function() {
				alert("Unable to set document status to complete")
			}
		})
	})
});
var tw_featureDlg = function(e, t) {
	var n = null,
		i = function(e, t) {
			var i = t.arg0;
			n.setFlash("Verifying feature...", !1);
			var r = function() {
					n.cancel()
				},
				o = function(e) {
					n.setFlash(e.responseText, !0)
				};
			serverAction({
				action: {
					actions: i,
					els: "tw_features",
					params: n.getAllData(),
					onSuccess: r,
					onFailure: o
				}
			})
		},
		r = {
			page: "layout",
			rows: [
				[{
					text: "Object's URI:",
					klass: "admin_dlg_label"
				}, {
					input: "features[uri]",
					klass: "new_exhibit_input_long",
					value: t.uri
				}],
				[{
					text: "Primary:",
					klass: "admin_dlg_label"
				}, {
					checkbox: "features[primary]",
					klass: "new_exhibit_input_long",
					value: t.primary
				}],
				[{
					text: "Disabled:",
					klass: "admin_dlg_label"
				}, {
					checkbox: "features[disabled]",
					klass: "new_exhibit_input_long",
					value: t.disabled
				}],
				[{
					rowClass: "gd_last_row"
				}, {
					button: "Ok",
					arg0: e,
					callback: i,
					isDefault: !0
				}, {
					button: "Cancel",
					callback: GeneralDialog.cancelCallback
				}]
			]
		},
		o = {
			this_id: "features_dlg",
			pages: [r],
			body_style: "forum_reply_dlg",
			row_style: "new_exhibit_row",
			title: "Features",
			focus: "features_object_uri"
		};
	n = new GeneralDialog(o), n.center()
};
jQuery(document).ready(function() {
	"use strict";

	function e(e) {
		var t = e.getAllData(),
			n = t.find.toLowerCase();
		e.setFlash("Finding " + n, !1);
		for (var r = !1, o = 0; !TW.line.isLast(o);) {
			var a = TW.line.getCurrentText(o);
			if (a && a.toLowerCase().indexOf(n) >= 0) {
				i.trigger("changeLine:highlight", {
					lineNum: o,
					text: t.find
				}), r = !0;
				break
			}
			o++
		}
		return r ? e.cancel() : e.setFlash("Text not found on page", !0), !1
	}

	function t() {
		var t = {
			layout: [
				[{
					type: "label",
					klass: "tw_dlg_find_label",
					text: "Find:"
				}, {
					type: "input",
					klass: "tw_dlg_find",
					name: "find",
					focus: !0
				}]
			]
		};
		dialogMaker.dialog({
			config: {
				id: "tw_find_dlg",
				action: "",
				div: "",
				align: ".tw_find_button",
				lineClass: "tw_dlg_find_line"
			},
			header: {
				title: "Find Text on Page"
			},
			body: t,
			footer: {
				buttons: [{
					label: "ok",
					action: e,
					def: !0
				}, {
					label: "cancel",
					action: "cancel"
				}]
			}
		})
	}

	function n(e) {
		e.keyCode === r && e.shiftKey && e.ctrlKey && t()
	}
	var i = jQuery("body"),
		r = 72;
	jQuery(".tw_find_button").on("click", function() {
		t()
	}), i.on("keyup", n)
}), TW.createImageCursor = function() {
	"use strict";

	function e() {
		var e = jQuery("#tw_img_thumb"),
			t = e.offset(),
			n = {
				width: e.width(),
				height: e.height()
			},
			i = n.width / TW.imgWidth,
			r = n.height / TW.imgHeight;
		return {
			origWidth: TW.imgWidth,
			ofsXThumb: t.left,
			ofsYThumb: t.top,
			xFactorThumb: i,
			yFactorThumb: r
		}
	}

	function t(e, t, n, i, r, o, a, s) {
		var l = jQuery(e),
			c = t + o,
			u = n + a - s;
		0 > i && (i = 100), 0 > r && (r = 20), l.css({
			left: c + "px",
			top: u + "px",
			width: i + "px",
			height: r + "px",
			display: "block"
		}), l.attr("data-orig-left", c), l.attr("data-orig-top", u), l.attr("data-orig-width", i), l.attr("data-orig-height", r)
	}

	function n(e, t) {
		var n = jQuery("#tw_pointer_thumb"),
			i = TW.line.getRect(t),
			r = i.l * e.xFactorThumb + e.ofsXThumb,
			o = i.t * e.yFactorThumb + e.ofsYThumb,
			a = i.r - i.l;
		0 > a && (a = 100), a *= e.xFactorThumb;
		var s = i.b - i.t;
		0 > s && (s = 20), s *= e.yFactorThumb, n.css({
			left: r + "px",
			top: o + "px",
			width: a + "px",
			height: s + "px"
		})
	}

	function i(e, t) {
		var n, i = [];
		for (n = 0; t > n; n++) {
			var r = String(e);
			i.push(r), e++
		}
		return i
	}

	function r(e, t) {
		var n, r = jQuery(e[0]).css("backgroundImage"),
			o = r.lastIndexOf("-"),
			a = r.lastIndexOf(".png"),
			s = r.substring(0, o + 1),
			l = r.substring(a),
			c = i(t, e.length);
		for (n = 0; n < e.length; n++) jQuery(e[n]).css("backgroundImage", s + c[n] + l)
	}

	function o(e, t) {
		var n = {};
		n.imgs = jQuery("#tw_img_full div"), n.numImages = n.imgs.length, n.middleImage = Math.floor(n.numImages / 2);
		var i = jQuery(n.imgs[0]);
		n.sectorSize = i.height();
		var r = i.offset();
		n.ofsX = r.left, n.ofsY = r.top, n.displaySize = {
			width: i.width(),
			height: n.sectorSize * n.numImages
		}, n.ratio = n.displaySize.width / e.origWidth;
		var o = TW.line.getRect(t);
		n.left = o.l * n.ratio, n.top = o.t * n.ratio, n.width = (o.r - o.l) * n.ratio, n.height = (o.b - o.t) * n.ratio;
		var a = n.top + n.height / 2;
		n.sector = a / n.sectorSize, n.sector = Math.round(n.sector);
		var s = TW.imgHeight * n.ratio / n.sectorSize;
		return s = Math.round(s), n.sector > 0 && (n.sector = n.sector - n.middleImage), n.sector = Math.min(n.sector, s), n.scrollY = n.sector * n.sectorSize, n
	}

	function a(e, n) {
		var i = o(e, n);
		r(i.imgs, i.sector), t("#tw_pointer_doc", i.left, i.top, i.width, i.height, i.ofsX, i.ofsY, i.scrollY)
	}
	var s = {
		convertThumbToOrig: function(t, n) {
			var i = e();
			return {
				x: (t - i.ofsXThumb) / i.xFactorThumb,
				y: (n - i.ofsYThumb) / i.yFactorThumb
			}
		},
		update: function(t) {
			var i = e();
			n(i, t), a(i, t)
		},
		getBox: function(t) {
			var n = jQuery("#tw_pointer_doc"),
				i = n.css("left").replace("px", ""),
				r = n.css("top").replace("px", ""),
				a = n.css("width").replace("px", ""),
				s = n.css("height").replace("px", ""),
				l = n.attr("data-orig-left"),
				c = n.attr("data-orig-top"),
				u = n.attr("data-orig-width"),
				d = n.attr("data-orig-height");
			if (i === l && r === c && a === u && s === d) return null;
			var h = o(e(), t),
				p = {
					l: (parseInt(i, 10) - h.ofsX) / h.ratio,
					t: (parseInt(r, 10) - h.ofsY + h.scrollY) / h.ratio,
					r: (parseInt(a, 10) + parseInt(i, 10) - h.ofsX) / h.ratio,
					b: (parseInt(s, 10) + parseInt(r, 10) - h.ofsY + h.scrollY) / h.ratio
				},
				f = TW.imgHeight - p.b;
			return 0 > f && (p.b = Math.min(p.b, TW.imgHeight), n.css("height", (p.b - p.t) * h.ratio + "px")), p.t = Math.max(p.t, 0), p
		}
	};
	return s
}, jQuery(document).ready(function(e) {
	"use strict";

	function t(e) {
		for (var t = !1, n = 0; n < TW.lines.length && !t; n++)
			if (TW.lines[n].num === e) return n;
		return -1
	}

	function n(e) {
		for (var t = !1, n = 0; n < TW.lines.length && !t; n++) {
			if (TW.lines[n].num === e) return n;
			if (TW.lines[n].num > e) return n
		}
		return TW.lines.length
	}
	TW.line = {
		findLine: function(e, t) {
			for (var n = 0; n < TW.lines.length; n++) {
				var i = TW.lines[n].l <= e,
					r = e <= TW.lines[n].r,
					o = TW.lines[n].t <= t,
					a = t <= TW.lines[n].b;
				if (i && r && o && a) return n
			}
			return -1
		},
		doInsert: function(e) {
			var t = e > 0 ? TW.lines[e - 1].num : 0,
				n = e < TW.lines.length ? TW.lines[e].num : t + 1,
				i = e > 0 ? parseInt(TW.lines[e - 1].b) + 1 : 1,
				r = 1e3,
				o = e < TW.lines.length ? parseInt(TW.lines[e].t) : i + 30,
				a = 1;
			if (o - i > 30) {
				var s = i + (o - i) / 2;
				i = s - 15, o = s + 15
			}
			var l = t + (n - t) / 2;
			TW.lines.splice(e, 0, {
				src: "gale",
				l: a,
				t: i,
				r: r,
				b: o,
				words: [
					[]
				],
				text: [""],
				num: l,
				change: {
					type: "insert",
					text: "",
					words: []
				},
				box_size: "changed",
				dirty: !0
			})
		},
		allStaleLines: [],
		staleLines: {},
		isEof: function(e) {
			return e === TW.lines.length
		},
		isLast: function(e) {
			return e === TW.lines.length - 1
		},
		isInRange: function(e) {
			return e >= 0 && e < TW.lines.length
		},
		canUndo: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : void 0 !== TW.lines[e].change
		},
		canRedo: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : void 0 !== TW.lines[e].undo
		},
		hasChanged: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : TW.lines[e].change && "change" === TW.lines[e].change.type || "changed" === TW.lines[e].box_size
		},
		getLastAction: function(e) {
			return TW.line.isInRange(e) === !1 ? null : TW.lines[e].actions ? TW.lines[e].actions[TW.lines[e].actions.length - 1] : null
		},
		getChangeType: function(e) {
			return TW.line.isInRange(e) === !1 ? null : TW.lines[e].change ? TW.lines[e].change.type : "delete" === TW.line.getLastAction(e) ? "delete" : null
		},
		isJustDeleted: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : TW.lines[e].change && "delete" === TW.lines[e].change.type
		},
		isDeleted: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : TW.line.isJustDeleted(e) ? !0 : "delete" === TW.line.getLastAction(e)
		},
		getLineNum: function(e) {
			return TW.line.isInRange(e) === !1 ? "" : TW.lines[e].num
		},
		getStartingText: function(e) {
			return TW.lines[e].text[TW.lines[e].text.length - 1]
		},
		getRect: function(e) {
			return TW.line.isInRange(e) === !1 ? {
				l: 0,
				r: 0,
				t: 0,
				b: 0
			} : {
				l: TW.lines[e].l,
				r: TW.lines[e].r,
				t: TW.lines[e].t,
				b: TW.lines[e].b
			}
		},
		isDirty: function(e) {
			return TW.line.isInRange(e) === !1 ? !1 : TW.lines[e].dirty === !0
		},
		numUndisplayedChanges: function() {
			return TW.line.allStaleLines.length
		},
		getCurrentText: function(e) {
			var t;
			return TW.line.isEof(e) === !0 ? "-- bottom of page --" : TW.line.isInRange(e) === !1 ? "" : (t = TW.lines[e].change && "change" === TW.lines[e].change.type ? TW.lines[e].change.text : TW.line.isDeleted(e) ? TW.lines[e].text[0] : TW.lines[e].text[TW.lines[e].text.length - 1], (null === t || void 0 === t) && (t = ""), t)
		},
		getAllHistory: function(e) {
			function t(e, t, n, i, r) {
				i || (i = "");
				var o;
				switch (e) {
					case "delete":
						o = "-- Deleted --";
						break;
					case "correct":
						o = "-- Declared Correct --";
						break;
					case "change":
						o = t;
						break;
					case "insert":
						o = "Inserted";
						break;
					case "original":
						o = t;
						break;
					case "":
						o = t;
						break;
					default:
						o = e
				}
				return "<tr class='" + r + "'><td><span></span>" + o + "</td><td>" + n + "</td><td>" + i + "</td></tr>"
			}
			if (TW.line.isInRange(e) === !1) return null;
			var n, i = TW.lines[e],
				r = [];
			if (i.actions)
				for (n = 0; n < i.text.length; n++) {
					var o = i.exact_times && i.exact_times[n] ? i.exact_times[n] : 0;
					r.push({
						action: i.actions[n],
						text: i.text[n],
						author: i.authors[n],
						date: i.dates[n],
						time: o,
						klass: ""
					})
				}
			if (TW.line.staleLines[e])
				for (n = 0; n < TW.line.staleLines[e].length; n++) {
					var a = TW.line.staleLines[e][n];
					r.push({
						action: a.action,
						text: a.text,
						author: a.author,
						date: a.date,
						time: a.exact_time,
						klass: "tw_stale"
					})
				}
			if (i.change && r.push({
				action: i.change.type,
				text: i.change.text,
				author: "You",
				date: i.change.date,
				time: i.change.exact_time,
				klass: "tw_local_change"
			}), r.length > 0) {
				var s = "<table><tr><td class='tw_header'>Correction:</td><td td class='tw_header'>Editor:</td><td td class='tw_header'>Date:</td></tr>";
				for (r.sort(function(e, t) {
					return e.time - t.time
				}), n = 0; n < r.length; n++) s += t(r[n].action, r[n].text, r[n].author, r[n].date, r[n].klass);
				return s += "</table>"
			}
			return null
		},
		lineIsStale: function(e) {
			return TW.line.staleLines[e] && TW.line.staleLines[e].length > 0
		},
		setClean: function(e) {
			TW.lines[e].dirty = !1
		},
		doRegisterLineChange: function(e, t) {
			if (0 == TW.line.isInRange(e)) return !1;
			var n = TW.lines[e],
				i = n.text.length - 1,
				r = n.text[i];
			if (r !== t && (null !== r || "" !== t)) {
				n.dirty = !0;
				var o = n.words[n.words.length - 1];
				return n.change = {
					type: "change",
					text: t,
					words: TW.reparseWords(t, o, {
						l: n.l,
						r: n.r,
						t: n.t,
						b: n.b
					})
				}, !0
			}
			return n.change && "change" === n.change.type ? (n.dirty = !0, delete n.change, !0) : !1
		},
		setEditTime: function(e, n, i) {
			var r = t(e);
			r >= 0 && TW.lines[r].change ? (TW.lines[r].change.date = n, TW.lines[r].change.exact_time = i) : console.log("Can't set edit time: ", e, r, n)
		},
		doUndo: function(e) {
			TW.lines[e].dirty = !0, TW.lines[e].undo = TW.lines[e].change, delete TW.lines[e].change
		},
		doRedo: function(e) {
			TW.lines[e].dirty = !0, TW.lines[e].change = TW.lines[e].undo, delete TW.lines[e].undo
		},
		doConfirm: function(e) {
			TW.lines[e].dirty = !0, TW.lines[e].change = {
				type: "correct"
			}
		},
		doDelete: function(e) {
			TW.lines[e].dirty = !0, TW.lines[e].change = {
				type: "delete"
			}
		},
		setRect: function(e, t) {
			TW.lines[e].dirty = !0, TW.lines[e].l = Math.round(t.l), TW.lines[e].r = Math.round(t.r), TW.lines[e].t = Math.round(t.t), TW.lines[e].b = Math.round(t.b), TW.lines[e].box_size = "changed"
		},
		liveUpdate: function(n) {
			e.merge(TW.line.allStaleLines, n);
			for (var i = 0; i < n.length; i++) {
				var r = n[i];
				r.line = parseFloat(r.line);
				var o = t(r.line);
				if (o >= 0) {
					var a = TW.line.staleLines[o];
					void 0 === a && (a = []), a.push(r), TW.line.staleLines[o] = a;
					var s = TW.lines[o];
					void 0 === s.actions && (s.actions = ["original"], s.authors = ["Original"], s.dates = [""], s.exact_times = [""])
				}
			}
		},
		integrateRemoteChanges: function() {
			for (var e = 0; e < TW.line.allStaleLines.length; e++) {
				var i = TW.line.allStaleLines[e],
					r = t(i.line),
					o = r >= 0 ? TW.lines[r] : null;
				switch (o && o.change && (o.actions.push(o.change.type), o.authors.push("You"), o.dates.push(o.change.date), o.exact_times.push(o.change.exact_time), o.text.push(o.change.text), o.words.push(o.change.words), o.change = void 0), i.action) {
					case "change":
						o && (o.actions.push(i.action), o.authors.push(i.author), o.dates.push(i.date), o.exact_times.push(i.exact_time), o.text.push(i.text), o.words.push(i.words), o.l = i.l, o.r = i.r, o.t = i.t, o.b = i.b);
						break;
					case "insert":
						r = n(i.line), TW.lines.splice(r, 0, {
							src: "gale",
							l: i.l,
							t: i.t,
							r: i.r,
							b: i.b,
							words: [
								[]
							],
							text: [""],
							actions: [""],
							authors: [""],
							dates: [""],
							exact_times: [""],
							num: i.line
						});
						break;
					case "delete":
						o && (o.actions.push(i.action), o.authors.push(i.author), o.dates.push(i.date), o.exact_times.push(i.exact_time), o.text.push(""), o.words.push([]))
				}
			}
			TW.line.allStaleLines = [], TW.line.staleLines = {}
		},
		serialize: function(e) {
			var t = {};
			return TW.lines[e].change ? (t.status = TW.lines[e].change.type, "change" === t.status ? (t.words = TW.lines[e].words, t.words.push(TW.lines[e].change.words)) : "insert" === t.status && (t.words = [], t.words.push(TW.lines[e].change.words)), "changed" === TW.lines[e].box_size && (t.box = {
				l: TW.lines[e].l,
				r: TW.lines[e].r,
				t: TW.lines[e].t,
				b: TW.lines[e].b
			})) : "changed" === TW.lines[e].box_size ? (t.status = "change", t.words = TW.lines[e].words, t.box = {
				l: TW.lines[e].l,
				r: TW.lines[e].r,
				t: TW.lines[e].t,
				b: TW.lines[e].b
			}) : t.status = "undo", t.line = this.getLineNum(e), t.src = TW.lines[e].src, t
		}
	}
}), jQuery(document).ready(function() {
	"use strict";
	var e = function() {
			jQuery("#dim-overlay").show(), jQuery("#wait-spinner").show(), jQuery("#wait-popup").show()
		},
		t = function() {
			jQuery("#dim-overlay").hide(), jQuery("#wait-popup").hide()
		};
	jQuery(".tw-retrieve-link").on("click", function() {
		e();
		var n = new Date,
			i = Math.round(n.getTime() / 1e3),
			r = jQuery(this).attr("href"),
			o = r.indexOf("&token");
		o > -1 && (r = r.substring(0, o)), jQuery(this).attr("href", r + "&token=" + i);
		var a = 300,
			s = setInterval(function() {
				var e = jQuery.cookie("fileDownloadToken");
				a -= 1, (e == i || 0 >= a) && (t(), clearInterval(s))
			}, 500)
	}), jQuery("#content_container.admin .nav_link").on("click", function() {
		e()
	}), jQuery("form.filter").on("submit", function() {
		e()
	}), jQuery(".tw_overview .nav_link").on("click", function() {
		var e = "",
			t = jQuery("#tw_filter").val();
		t.length > 0 && (t = "&filter=" + t), e = jQuery(this).hasClass("tw_asc") ? "desc" : jQuery(this).hasClass("tw_desc") ? "asc" : "asc", jQuery(".tw_overview .nav_link").removeClass("tw_asc"), jQuery(".tw_overview .nav_link").removeClass("tw_desc"), jQuery(this).addClass("tw_" + e);
		var n = "uri",
			i = jQuery(this).attr("id");
		i = i.substring(0, i.length - "-sort".length), n = i.substring(i.indexOf("tw-doc") > -1 ? "tw-doc-".length : "tw-user-".length);
		var r = "/typewright/overviews?sort=" + n + "&order=" + e + t;
		"users" === jQuery("#curr_view").text() && (r = "/typewright/overviews?view=users&sort=" + n + "&order=" + e + t), window.location = r
	}), jQuery("#tw_clear_filter").on("click", function() {
		e(), jQuery("#tw_doc_status_filter").val("all"), jQuery("#tw_filter").val(""), jQuery("#tw_doc_filter_controls form").submit()
	}), jQuery(".tw_change_doc_status").on("click", function() {
		jQuery(this).parent(".tw_status_display").hide(), jQuery(this).parent().parent().find(".tw_status_change").show(), jQuery(".tw_change_doc_status").attr("disabled", "disabled")
	});
	var n = function(e) {
		jQuery(e).parent().hide(), jQuery(e).parent().parent().find(".tw_status_display").show(), jQuery(".tw_change_doc_status").removeAttr("disabled")
	};
	jQuery(".tw_cancel_status").on("click", function() {
		n(this)
	}), jQuery(".tw_save_status").on("click", function() {
		var i = this,
			r = jQuery(this).attr("id").substring("tw_save_status_".length),
			o = jQuery(this).parent().find("select").val(),
			a = "No";
		"complete" === o && (a = "Confirmed complete"), e(), jQuery.ajax({
			url: "/typewright/documents/" + r + "/status",
			type: "POST",
			data: {
				new_status: o
			},
			beforeSend: function(e) {
				e.setRequestHeader("X-CSRF-Token", jQuery('meta[name="csrf-token"]').attr("content"))
			},
			success: function() {
				n(i), jQuery(i).parent().parent().find(".tw_status_txt").text(a), t()
			},
			error: function(e) {
				t(), alert("Unable to change document status:\n	" + e.responseText)
			}
		})
	})
}), TW.reparseWords = function(e, t, n) {
	"use strict";

	function i(e, t) {
		var n = new Diff_match_patch;
		n.Diff_Timeout = 1, n.Diff_EditCost = 4;
		var i = n.diff_linesToChars_(e.replace(/ /g, "\n"), t.replace(/ /g, "\n"));
		e = i[0], t = i[1];
		var r = i[2],
			o = n.diff_main(e, t);
		n.diff_charsToLines_(o, r);
		var a = function(e) {
				for (var t = [], n = 0, i = 0, r = 0; r < e.length; r++) {
					var o = e[r][0],
						a = e[r][1],
						s = a.split("\n");
					"" === s[s.length - 1] && s.pop();
					var l;
					switch (o) {
						case 0:
							for (l = 0; l < s.length; l++) t.push({
								action: "NO_CHANGE",
								oldIndex: n++,
								newIndex: i++,
								text: s[l]
							});
							break;
						case -1:
							if (r < e.length - 1 && 1 === e[r + 1][0]) {
								r++;
								var c = e[r][1].split("\n");
								"" === c[c.length - 1] && c.pop();
								var u = s.length === c.length ? c.length : Math.min(s.length, c.length) - 1;
								for (l = 0; u > l; l++) t.push({
									action: "CHANGED",
									oldIndex: n++,
									newIndex: i++,
									text: c[l]
								});
								if (s.length > c.length) {
									var d = [];
									for (l = u; l < s.length; l++) d.push(n++);
									t.push({
										action: "COMBINED",
										oldIndexArr: d,
										newIndex: i++,
										text: c[c.length - 1]
									})
								} else if (s.length < c.length) {
									var h = [];
									for (l = u; l < c.length; l++) h.push({
										newIndex: i++,
										text: c[l]
									});
									t.push({
										action: "SPLIT",
										oldIndex: n++,
										newIndexArr: h
									})
								}
							} else
								for (l = 0; l < s.length; l++) t.push({
									action: "DELETED",
									oldIndex: n++
								});
							break;
						case 1:
							for (l = 0; l < s.length; l++) t.push({
								action: "INSERTED",
								oldIndex: n,
								newIndex: i++,
								text: s[l]
							})
					}
				}
				return t
			},
			s = a(o);
		return s
	}
	var r = function(e, t) {
			return {
				l: Math.min(e.l, t.l),
				t: Math.min(e.t, t.t),
				b: Math.max(e.b, t.b),
				r: Math.max(e.r, t.r)
			}
		},
		o = function(e) {
			for (var t = e.split(" "), n = [], i = 0; i < t.length; i++) t[i].length > 0 && n.push(t[i]);
			return n
		},
		a = function(e, t, n) {
			var i = r(e, t);
			return i.line = e.line, i.word = n, i
		},
		s = function(e) {
			return {
				l: e.l,
				t: e.t,
				r: e.r,
				b: e.b,
				word: e.word,
				line: e.line
			}
		},
		l = function(e) {
			for (var t = [], n = 0; n < e.length; n++) t.push(s(e[n]));
			return t
		},
		c = function(e) {
			for (var t = "", n = 0; n < e.length; n++) 0 !== n && (t += " "), t += e[n].word;
			return t
		},
		u = function(e) {
			for (var n, i = [], r = [], o = [], a = [], s = 0; s < e.length; s++) {
				i.push("NO_CHANGE" !== e[s].action ? e[s].action : "");
				var l = "",
					c = "",
					u = "";
				switch (e[s].action) {
					case "NO_CHANGE":
						l = "o:" + e[s].oldIndex + " n:" + e[s].newIndex, c = t[e[s].oldIndex].word, u = e[s].text;
						break;
					case "CHANGED":
						l = "o:" + e[s].oldIndex + " n:" + e[s].newIndex, c = t[e[s].oldIndex].word, u = e[s].text;
						break;
					case "COMBINED":
						for (l = "o:" + e[s].oldIndexArr.join("/") + " n:" + e[s].newIndex, n = 0; n < e[s].oldIndexArr.length; n++) c += t[e[s].oldIndexArr[n]].word + " ";
						u = e[s].text;
						break;
					case "SPLIT":
						for (l = "o:" + e[s].oldIndex + " n:", c = t[e[s].oldIndex].word, n = 0; n < e[s].newIndexArr.length; n++) l += e[s].newIndexArr[n].newIndex + " ", u += e[s].newIndexArr[n].text + " ";
						break;
					case "DELETED":
						l = "o:" + e[s].oldIndex, c = t[e[s].oldIndex].word;
						break;
					case "INSERTED":
						l = "o:" + e[s].oldIndex + " n:" + e[s].newIndex, c = e[s].oldIndex < t.length ? t[e[s].oldIndex].word : "", u = e[s].text
				}
				r.push(l), o.push(c), a.push(u)
			}
			var d = "<table><tr>";
			for (s = 0; s < i.length; s++) d += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + i[s] + "</td>";
			for (d += "</tr></tr>", s = 0; s < r.length; s++) d += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + r[s] + "</td>";
			for (d += "</tr></tr>", s = 0; s < o.length; s++) d += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + o[s] + "</td>";
			for (d += "</tr></tr>", s = 0; s < a.length; s++) d += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + a[s] + "</td>";
			d += "</tr></table>", document.getElementById("debugging_table").innerHTML = d
		},
		d = function(e, t) {
			t = l(t);
			for (var i = [], r = 0; r < e.length; r++) switch (e[r].action) {
				case "NO_CHANGE":
					i.push(t[e[r].oldIndex]);
					break;
				case "CHANGED":
					t[e[r].oldIndex].word = e[r].text, i.push(t[e[r].oldIndex]);
					break;
				case "COMBINED":
					i.push(a(t[e[r].oldIndexArr[0]], t[e[r].oldIndexArr[e[r].oldIndexArr.length - 1]], e[r].text));
					break;
				case "SPLIT":
					for (var o = e[r].newIndexArr.length - 1, c = 0; c < e[r].newIndexArr.length; c++) o += e[r].newIndexArr[c].text.length;
					var u = parseInt(t[e[r].oldIndex].r, 10) - parseInt(t[e[r].oldIndex].l, 10),
						d = u / o,
						h = parseInt(t[e[r].oldIndex].l, 10);
					for (c = 0; c < e[r].newIndexArr.length; c++) {
						var p = Math.round(e[r].newIndexArr[c].text.length * d);
						i.push({
							l: h,
							r: h + p,
							t: t[e[r].oldIndex].t,
							b: t[e[r].oldIndex].b,
							word: e[r].newIndexArr[c].text
						}), h += Math.round(p + d)
					}
					break;
				case "DELETED":
					break;
				case "INSERTED":
					if (e[r].oldIndex < t.length) {
						var f = s(t[e[r].oldIndex]);
						e[r].oldIndex > 0 && (f.r = f.l, f.l = t[e[r].oldIndex - 1].r), f.word = e[r].text, i.push(f)
					} else i.push({
						l: n.l,
						r: n.r,
						t: n.t,
						b: n.b,
						word: e[r].text
					})
			}
			return i
		},
		h = o(e),
		p = i(c(t), h.join(" "));
	return TW.showDebugItems && u(p), d(p, t)
}, jQuery(document).ready(function() {
	"use strict";

	function e(e) {
		var t = e.attr("data-url");
		showPartialInLightBox(t, "Report an Issue on This Page", "/assets/ajax_loader.gif")
	}
	jQuery("#tw_report_page").on("click", function() {
		e(jQuery(this))
	})
}), jQuery(document).ready(function() {
	"use strict";

	function e(e) {
		var t = e.attr("data-url"),
			n = e.val();
		window.location = t + n
	}
	jQuery("body").on("change", "#tw_page", function() {
		e(jQuery(this))
	})
});
var dialogMaker = {};
YUI().use("overlay", "node", "io-base", "querystring-stringify-simple", "event-delegate", "event-key", function(e) {
	function t(t, n, i, r) {
		var o = function(n, r) {
				t.cancel(), void 0 !== r.responseText && e.one("#" + i).set("innerHTML", r.responseText)
			},
			a = function(e, n) {
				500 === n.status ? t.setFlash("Internal Error: please contact site administrator", !0) : t.setFlash(n.responseText, !0)
			};
		e.io(n, {
			method: "POST",
			data: r,
			on: {
				success: o,
				failure: a
			}
		})
	}

	function n(t, n) {
		var i = document.createElement(t);
		if (n)
			for (var r = 0; r < n.length; r++) n[r][1] && e.one(i).setAttribute(n[r][0], n[r][1]);
		return i
	}

	function i(e) {
		return void 0 === e ? void 0 : e.replace(/\[/g, "_").replace(/\]/g, "")
	}
	var r = function(t) {
		var i = e.one("meta[name=csrf-param]")._node.content,
			r = e.one("meta[name=csrf-token]")._node.content;
		t.appendChild(n("input", [
			["id", i],
			["type", "hidden"],
			["name", i],
			["value", r]
		]))
	};
	dialogMaker.dialog = function(o) {
		var a = this;
		dialogMaker.handleFormSubmit = function() {
			try {
				dialogMaker.defaultAction(a)
			} catch (e) {}
			return !1
		};
		var s = n("form", [
			["id", o.config.id],
			["action", o.config.action],
			["method", "POST"],
			["onsubmit", "return dialogMaker.handleFormSubmit();"]
		]);
		r(s);
		var l = n("div");
		l.innerHTML = o.header.title;
		var c = n("div", [
			["name", "dlgFlash"],
			["id", "dlgFlash"]
		]);
		c.className = "hidden", s.appendChild(c);
		for (var u = null, d = 0; d < o.body.layout.length; d++) {
			var h = n("div");
			h.className = o.config.lineClass;
			for (var p = 0; p < o.body.layout[d].length; p++) {
				var f = o.body.layout[d][p];
				switch (f.type) {
					case "label":
						var g = n("span", [
							["name", f.name],
							["id", i(f.name)]
						]);
						g.className = f.klass, g.innerHTML = f.text, h.appendChild(g);
						break;
					case "input":
						var m = n("input", [
							["name", f.name],
							["id", i(f.name)]
						]);
						m.className = f.klass, h.appendChild(m), f.focus && (u = m);
						break;
					case "select":
						var v = n("select", [
							["name", f.name],
							["id", i(f.name)]
						]);
						v.className = f.klass;
						for (var _ = 0; _ < f.options.length; _++) {
							var b;
							f.options[_] instanceof Array ? (b = n("option", [
								["value", f.options[_][0]]
							]), b.innerHTML = f.options[_][1]) : (b = n("option"), b.innerHTML = f.options[_]), v.appendChild(b)
						}
						h.appendChild(v), f.focus && (u = v)
				}
			}
			s.appendChild(h)
		}
		var y = n("div");
		for (y.className = "yui3-dlg-footer", d = 0; d < o.footer.buttons.length; d++) {
			var w = void 0 === o.config.div && "submit" === o.footer.buttons[d].action ? "submit" : "button",
				x = e.one(n("input", [
					["type", w],
					["value", o.footer.buttons[d].label],
					["data-index", "" + d]
				]));
			if (y.appendChild(x._node), "cancel" === o.footer.buttons[d].action ? x.on("click", function() {
				return a.cancel(), !1
			}) : "submit" === o.footer.buttons[d].action ? void 0 !== o.config.div && x.on("click", function() {
				a.setFlash("Saving score...", !1);
				var e = a.getAllData();
				if (o.config.onsubmit) {
					var n = o.config.onsubmit(e);
					if (n) return void a.setFlash(n, !0)
				}
				t(a, o.config.action, o.config.div, e)
			}) : x.on("click", function(e) {
				var t = e.target._node.getAttribute("data-index");
				return o.footer.buttons[parseInt(t)].action(a), !1
			}), o.footer.buttons[d].def) {
				dialogMaker.defaultAction = o.footer.buttons[d].action;
				var E = 13;
				e.delegate("key", function(e) {
					e.halt(), dialogMaker.defaultAction(a)
				}, "body", "#" + o.config.id, "down:" + E, e)
			}
		}
		s.appendChild(y);
		var k = new e.Overlay({
			visible: !1,
			zIndex: 10,
			headerContent: l,
			bodyContent: s
		});
		k.render(), k.show(), k.set("align", {
			node: o.config.align,
			points: [e.WidgetPositionAlign.TL, e.WidgetPositionAlign.BL]
		}), u && u.focus(), this.cancel = function() {
			k.hide();
			var t = e.one("#" + o.config.id),
				n = t.ancestor(".yui3-overlay");
			n.remove()
		}, this.setFlash = function(t, n) {
			var i = e.one("#dlgFlash");
			0 === t.length ? i.addClass("hidden") : (i.addClass(n === !1 ? "dlg_flash_ok" : "dlg_flash_error"), i.set("innerHTML", t), i.removeClass("hidden"))
		}, this.getAllData = function() {
			var t = {},
				n = e.all("#" + o.config.id + " input");
			n.each(function(e) {
				"checkbox" === e._node.type ? t[e._node.name] = e._node.checked : "radio" === e._node.type ? e._node.checked && (t[e._node.name] = e._node.value) : "button" !== e._node.type && (t[e._node.name] = e._node.value)
			});
			var i = e.all("#" + o.config.id + " select");
			return i.each(function(e) {
				var n = e._node.options[e._node.selectedIndex];
				t[e._node.name] = n.value ? n.value : n.text
			}), t
		}
	}
}),
/**
 * History.js jQuery Adapter
 * @author Benjamin Arthur Lupton <contact@balupton.com>
 * @copyright 2010-2011 Benjamin Arthur Lupton <contact@balupton.com>
 * @license New BSD License <http://creativecommons.org/licenses/BSD/>
 */
	function(e, t) {
		"use strict";
		var n = e.History = e.History || {},
			i = e.jQuery;
		if ("undefined" != typeof n.Adapter) throw new Error("History.js Adapter has already been loaded...");
		n.Adapter = {
			bind: function(e, t, n) {
				i(e).bind(t, n)
			},
			trigger: function(e, t, n) {
				i(e).trigger(t, n)
			},
			extractEventData: function(e, n, i) {
				var r = n && n.originalEvent && n.originalEvent[e] || i && i[e] || t;
				return r
			},
			onDomLoad: function(e) {
				i(e)
			}
		}, "undefined" != typeof n.init && n.init()
	}(window),
/**
 * History.js Core
 * @author Benjamin Arthur Lupton <contact@balupton.com>
 * @copyright 2010-2011 Benjamin Arthur Lupton <contact@balupton.com>
 * @license New BSD License <http://creativecommons.org/licenses/BSD/>
 */
	function(e, t) {
		"use strict";
		var n = e.console || t,
			i = e.document,
			r = e.navigator,
			o = e.sessionStorage || !1,
			a = e.setTimeout,
			s = e.clearTimeout,
			l = e.setInterval,
			c = e.clearInterval,
			u = e.JSON,
			d = e.alert,
			h = e.History = e.History || {},
			p = e.history;
		if (u.stringify = u.stringify || u.encode, u.parse = u.parse || u.decode, "undefined" != typeof h.init) throw new Error("History.js Core has already been loaded...");
		h.init = function() {
			return "undefined" == typeof h.Adapter ? !1 : ("undefined" != typeof h.initCore && h.initCore(), "undefined" != typeof h.initHtml4 && h.initHtml4(), !0)
		}, h.initCore = function() {
			if ("undefined" != typeof h.initCore.initialized) return !1;
			if (h.initCore.initialized = !0, h.options = h.options || {}, h.options.hashChangeInterval = h.options.hashChangeInterval || 100, h.options.safariPollInterval = h.options.safariPollInterval || 500, h.options.doubleCheckInterval = h.options.doubleCheckInterval || 500, h.options.storeInterval = h.options.storeInterval || 1e3, h.options.busyDelay = h.options.busyDelay || 250, h.options.debug = h.options.debug || !1, h.options.initialTitle = h.options.initialTitle || i.title, h.intervalList = [], h.clearAllIntervals = function() {
				var e, t = h.intervalList;
				if ("undefined" != typeof t && null !== t) {
					for (e = 0; e < t.length; e++) c(t[e]);
					h.intervalList = null
				}
			}, h.debug = function() {
				h.options.debug && h.log.apply(h, arguments)
			}, h.log = function() {
				var e, t, r, o, a, s = !("undefined" == typeof n || "undefined" == typeof n.log || "undefined" == typeof n.log.apply),
					l = i.getElementById("log");
				for (s ? (o = Array.prototype.slice.call(arguments), e = o.shift(), "undefined" != typeof n.debug ? n.debug.apply(n, [e, o]) : n.log.apply(n, [e, o])) : e = "\n" + arguments[0] + "\n", t = 1, r = arguments.length; r > t; ++t) {
					if (a = arguments[t], "object" == typeof a && "undefined" != typeof u) try {
						a = u.stringify(a)
					} catch (c) {}
					e += "\n" + a + "\n"
				}
				return l ? (l.value += e + "\n-----\n", l.scrollTop = l.scrollHeight - l.clientHeight) : s || d(e), !0
			}, h.getInternetExplorerMajorVersion = function() {
				var e = h.getInternetExplorerMajorVersion.cached = "undefined" != typeof h.getInternetExplorerMajorVersion.cached ? h.getInternetExplorerMajorVersion.cached : function() {
					for (var e = 3, t = i.createElement("div"), n = t.getElementsByTagName("i");
						 (t.innerHTML = "<!--[if gt IE " + ++e + "]><i></i><![endif]-->") && n[0];);
					return e > 4 ? e : !1
				}();
				return e
			}, h.isInternetExplorer = function() {
				var e = h.isInternetExplorer.cached = "undefined" != typeof h.isInternetExplorer.cached ? h.isInternetExplorer.cached : Boolean(h.getInternetExplorerMajorVersion());
				return e
			}, h.emulated = {
				pushState: !Boolean(e.history && e.history.pushState && e.history.replaceState && !(/ Mobile\/([1-7][a-z]|(8([abcde]|f(1[0-8]))))/i.test(r.userAgent) || /AppleWebKit\/5([0-2]|3[0-2])/i.test(r.userAgent))),
				hashChange: Boolean(!("onhashchange" in e || "onhashchange" in i) || h.isInternetExplorer() && h.getInternetExplorerMajorVersion() < 8)
			}, h.enabled = !h.emulated.pushState, h.bugs = {
				setHash: Boolean(!h.emulated.pushState && "Apple Computer, Inc." === r.vendor && /AppleWebKit\/5([0-2]|3[0-3])/.test(r.userAgent)),
				safariPoll: Boolean(!h.emulated.pushState && "Apple Computer, Inc." === r.vendor && /AppleWebKit\/5([0-2]|3[0-3])/.test(r.userAgent)),
				ieDoubleCheck: Boolean(h.isInternetExplorer() && h.getInternetExplorerMajorVersion() < 8),
				hashEscape: Boolean(h.isInternetExplorer() && h.getInternetExplorerMajorVersion() < 7)
			}, h.isEmptyObject = function(e) {
				for (var t in e) return !1;
				return !0
			}, h.cloneObject = function(e) {
				var t, n;
				return e ? (t = u.stringify(e), n = u.parse(t)) : n = {}, n
			}, h.getRootUrl = function() {
				var e = i.location.protocol + "//" + (i.location.hostname || i.location.host);
				return i.location.port && (e += ":" + i.location.port), e += "/"
			}, h.getBaseHref = function() {
				var e = i.getElementsByTagName("base"),
					t = null,
					n = "";
				return 1 === e.length && (t = e[0], n = t.href.replace(/[^\/]+$/, "")), n = n.replace(/\/+$/, ""), n && (n += "/"), n
			}, h.getBaseUrl = function() {
				var e = h.getBaseHref() || h.getBasePageUrl() || h.getRootUrl();
				return e
			}, h.getPageUrl = function() {
				var e, t = h.getState(!1, !1),
					n = (t || {}).url || i.location.href;
				return e = n.replace(/\/+$/, "").replace(/[^\/]+$/, function(e) {
					return /\./.test(e) ? e : e + "/"
				})
			}, h.getBasePageUrl = function() {
				var e = i.location.href.replace(/[#\?].*/, "").replace(/[^\/]+$/, function(e) {
					return /[^\/]$/.test(e) ? "" : e
				}).replace(/\/+$/, "") + "/";
				return e
			}, h.getFullUrl = function(e, t) {
				var n = e,
					i = e.substring(0, 1);
				return t = "undefined" == typeof t ? !0 : t, /[a-z]+\:\/\//.test(e) || (n = "/" === i ? h.getRootUrl() + e.replace(/^\/+/, "") : "#" === i ? h.getPageUrl().replace(/#.*/, "") + e : "?" === i ? h.getPageUrl().replace(/[\?#].*/, "") + e : t ? h.getBaseUrl() + e.replace(/^(\.\/)+/, "") : h.getBasePageUrl() + e.replace(/^(\.\/)+/, "")), n.replace(/\#$/, "")
			}, h.getShortUrl = function(e) {
				var t = e,
					n = h.getBaseUrl(),
					i = h.getRootUrl();
				return h.emulated.pushState && (t = t.replace(n, "")), t = t.replace(i, "/"), h.isTraditionalAnchor(t) && (t = "./" + t), t = t.replace(/^(\.\/)+/g, "./").replace(/\#$/, "")
			}, h.store = {}, h.idToState = h.idToState || {}, h.stateToId = h.stateToId || {}, h.urlToId = h.urlToId || {}, h.storedStates = h.storedStates || [], h.savedStates = h.savedStates || [], h.normalizeStore = function() {
				h.store.idToState = h.store.idToState || {}, h.store.urlToId = h.store.urlToId || {}, h.store.stateToId = h.store.stateToId || {}
			}, h.getState = function(e, t) {
				"undefined" == typeof e && (e = !0), "undefined" == typeof t && (t = !0);
				var n = h.getLastSavedState();
				return !n && t && (n = h.createStateObject()), e && (n = h.cloneObject(n), n.url = n.cleanUrl || n.url), n
			}, h.getIdByState = function(e) {
				var t, n = h.extractId(e.url);
				if (!n)
					if (t = h.getStateString(e), "undefined" != typeof h.stateToId[t]) n = h.stateToId[t];
					else if ("undefined" != typeof h.store.stateToId[t]) n = h.store.stateToId[t];
					else {
						for (;;)
							if (n = (new Date).getTime() + String(Math.random()).replace(/\D/g, ""), "undefined" == typeof h.idToState[n] && "undefined" == typeof h.store.idToState[n]) break;
						h.stateToId[t] = n, h.idToState[n] = e
					}
				return n
			}, h.normalizeState = function(e) {
				var t, n;
				return e && "object" == typeof e || (e = {}), "undefined" != typeof e.normalized ? e : (e.data && "object" == typeof e.data || (e.data = {}), t = {}, t.normalized = !0, t.title = e.title || "", t.url = h.getFullUrl(h.unescapeString(e.url || i.location.href)), t.hash = h.getShortUrl(t.url), t.data = h.cloneObject(e.data), t.id = h.getIdByState(t), t.cleanUrl = t.url.replace(/\??\&_suid.*/, ""), t.url = t.cleanUrl, n = !h.isEmptyObject(t.data), (t.title || n) && (t.hash = h.getShortUrl(t.url).replace(/\??\&_suid.*/, ""), /\?/.test(t.hash) || (t.hash += "?"), t.hash += "&_suid=" + t.id), t.hashedUrl = h.getFullUrl(t.hash), (h.emulated.pushState || h.bugs.safariPoll) && h.hasUrlDuplicate(t) && (t.url = t.hashedUrl), t)
			}, h.createStateObject = function(e, t, n) {
				var i = {
					data: e,
					title: t,
					url: n
				};
				return i = h.normalizeState(i)
			}, h.getStateById = function(e) {
				e = String(e);
				var n = h.idToState[e] || h.store.idToState[e] || t;
				return n
			}, h.getStateString = function(e) {
				var t, n, i;
				return t = h.normalizeState(e), n = {
					data: t.data,
					title: e.title,
					url: e.url
				}, i = u.stringify(n)
			}, h.getStateId = function(e) {
				var t, n;
				return t = h.normalizeState(e), n = t.id
			}, h.getHashByState = function(e) {
				var t, n;
				return t = h.normalizeState(e), n = t.hash
			}, h.extractId = function(e) {
				var t, n, i;
				return n = /(.*)\&_suid=([0-9]+)$/.exec(e), i = n ? n[1] || e : e, t = n ? String(n[2] || "") : "", t || !1
			}, h.isTraditionalAnchor = function(e) {
				var t = !/[\/\?\.]/.test(e);
				return t
			}, h.extractState = function(e, t) {
				var n, i, r = null;
				return t = t || !1, n = h.extractId(e), n && (r = h.getStateById(n)), r || (i = h.getFullUrl(e), n = h.getIdByUrl(i) || !1, n && (r = h.getStateById(n)), r || !t || h.isTraditionalAnchor(e) || (r = h.createStateObject(null, null, i))), r
			}, h.getIdByUrl = function(e) {
				var n = h.urlToId[e] || h.store.urlToId[e] || t;
				return n
			}, h.getLastSavedState = function() {
				return h.savedStates[h.savedStates.length - 1] || t
			}, h.getLastStoredState = function() {
				return h.storedStates[h.storedStates.length - 1] || t
			}, h.hasUrlDuplicate = function(e) {
				var t, n = !1;
				return t = h.extractState(e.url), n = t && t.id !== e.id
			}, h.storeState = function(e) {
				return h.urlToId[e.url] = e.id, h.storedStates.push(h.cloneObject(e)), e
			}, h.isLastSavedState = function(e) {
				var t, n, i, r = !1;
				return h.savedStates.length && (t = e.id, n = h.getLastSavedState(), i = n.id, r = t === i), r
			}, h.saveState = function(e) {
				return h.isLastSavedState(e) ? !1 : (h.savedStates.push(h.cloneObject(e)), !0)
			}, h.getStateByIndex = function(e) {
				var t = null;
				return t = "undefined" == typeof e ? h.savedStates[h.savedStates.length - 1] : 0 > e ? h.savedStates[h.savedStates.length + e] : h.savedStates[e]
			}, h.getHash = function() {
				var e = h.unescapeHash(i.location.hash);
				return e
			}, h.unescapeString = function(t) {
				for (var n, i = t;;) {
					if (n = e.unescape(i), n === i) break;
					i = n
				}
				return i
			}, h.unescapeHash = function(e) {
				var t = h.normalizeHash(e);
				return t = h.unescapeString(t)
			}, h.normalizeHash = function(e) {
				var t = e.replace(/[^#]*#/, "").replace(/#.*/, "");
				return t
			}, h.setHash = function(e, t) {
				var n, r, o;
				return t !== !1 && h.busy() ? (h.pushQueue({
					scope: h,
					callback: h.setHash,
					args: arguments,
					queue: t
				}), !1) : (n = h.escapeHash(e), h.busy(!0), r = h.extractState(e, !0), r && !h.emulated.pushState ? h.pushState(r.data, r.title, r.url, !1) : i.location.hash !== n && (h.bugs.setHash ? (o = h.getPageUrl(), h.pushState(null, null, o + "#" + n, !1)) : i.location.hash = n), h)
			}, h.escapeHash = function(t) {
				var n = h.normalizeHash(t);
				return n = e.escape(n), h.bugs.hashEscape || (n = n.replace(/\%21/g, "!").replace(/\%26/g, "&").replace(/\%3D/g, "=").replace(/\%3F/g, "?")), n
			}, h.getHashByUrl = function(e) {
				var t = String(e).replace(/([^#]*)#?([^#]*)#?(.*)/, "$2");
				return t = h.unescapeHash(t)
			}, h.setTitle = function(e) {
				var t, n = e.title;
				n || (t = h.getStateByIndex(0), t && t.url === e.url && (n = t.title || h.options.initialTitle));
				try {
					i.getElementsByTagName("title")[0].innerHTML = n.replace("<", "&lt;").replace(">", "&gt;").replace(" & ", " &amp; ")
				} catch (r) {}
				return i.title = n, h
			}, h.queues = [], h.busy = function(e) {
				if ("undefined" != typeof e ? h.busy.flag = e : "undefined" == typeof h.busy.flag && (h.busy.flag = !1), !h.busy.flag) {
					s(h.busy.timeout);
					var t = function() {
						var e, n, i;
						if (!h.busy.flag)
							for (e = h.queues.length - 1; e >= 0; --e) n = h.queues[e], 0 !== n.length && (i = n.shift(), h.fireQueueItem(i), h.busy.timeout = a(t, h.options.busyDelay))
					};
					h.busy.timeout = a(t, h.options.busyDelay)
				}
				return h.busy.flag
			}, h.busy.flag = !1, h.fireQueueItem = function(e) {
				return e.callback.apply(e.scope || h, e.args || [])
			}, h.pushQueue = function(e) {
				return h.queues[e.queue || 0] = h.queues[e.queue || 0] || [], h.queues[e.queue || 0].push(e), h
			}, h.queue = function(e, t) {
				return "function" == typeof e && (e = {
					callback: e
				}), "undefined" != typeof t && (e.queue = t), h.busy() ? h.pushQueue(e) : h.fireQueueItem(e), h
			}, h.clearQueue = function() {
				return h.busy.flag = !1, h.queues = [], h
			}, h.stateChanged = !1, h.doubleChecker = !1, h.doubleCheckComplete = function() {
				return h.stateChanged = !0, h.doubleCheckClear(), h
			}, h.doubleCheckClear = function() {
				return h.doubleChecker && (s(h.doubleChecker), h.doubleChecker = !1), h
			}, h.doubleCheck = function(e) {
				return h.stateChanged = !1, h.doubleCheckClear(), h.bugs.ieDoubleCheck && (h.doubleChecker = a(function() {
					return h.doubleCheckClear(), h.stateChanged || e(), !0
				}, h.options.doubleCheckInterval)), h
			}, h.safariStatePoll = function() {
				var t, n = h.extractState(i.location.href);
				if (!h.isLastSavedState(n)) return t = n, t || (t = h.createStateObject()), h.Adapter.trigger(e, "popstate"), h
			}, h.back = function(e) {
				return e !== !1 && h.busy() ? (h.pushQueue({
					scope: h,
					callback: h.back,
					args: arguments,
					queue: e
				}), !1) : (h.busy(!0), h.doubleCheck(function() {
					h.back(!1)
				}), p.go(-1), !0)
			}, h.forward = function(e) {
				return e !== !1 && h.busy() ? (h.pushQueue({
					scope: h,
					callback: h.forward,
					args: arguments,
					queue: e
				}), !1) : (h.busy(!0), h.doubleCheck(function() {
					h.forward(!1)
				}), p.go(1), !0)
			}, h.go = function(e, t) {
				var n;
				if (e > 0)
					for (n = 1; e >= n; ++n) h.forward(t);
				else {
					if (!(0 > e)) throw new Error("History.go: History.go requires a positive or negative integer passed.");
					for (n = -1; n >= e; --n) h.back(t)
				}
				return h
			}, h.emulated.pushState) {
				var f = function() {};
				h.pushState = h.pushState || f, h.replaceState = h.replaceState || f
			} else h.onPopState = function(t, n) {
				var r, o, a = !1,
					s = !1;
				return h.doubleCheckComplete(), (r = h.getHash()) ? (o = h.extractState(r || i.location.href, !0), o ? h.replaceState(o.data, o.title, o.url, !1) : (h.Adapter.trigger(e, "anchorchange"), h.busy(!1)), h.expectedStateId = !1, !1) : (a = h.Adapter.extractEventData("state", t, n) || !1, s = a ? h.getStateById(a) : h.expectedStateId ? h.getStateById(h.expectedStateId) : h.extractState(i.location.href), s || (s = h.createStateObject(null, null, i.location.href)), h.expectedStateId = !1, h.isLastSavedState(s) ? (h.busy(!1), !1) : (h.storeState(s), h.saveState(s), h.setTitle(s), h.Adapter.trigger(e, "statechange"), h.busy(!1), !0))
			}, h.Adapter.bind(e, "popstate", h.onPopState), h.pushState = function(t, n, i, r) {
				if (h.getHashByUrl(i) && h.emulated.pushState) throw new Error("History.js does not support states with fragment-identifiers (hashes/anchors).");
				if (r !== !1 && h.busy()) return h.pushQueue({
					scope: h,
					callback: h.pushState,
					args: arguments,
					queue: r
				}), !1;
				h.busy(!0);
				var o = h.createStateObject(t, n, i);
				return h.isLastSavedState(o) ? h.busy(!1) : (h.storeState(o), h.expectedStateId = o.id, p.pushState(o.id, o.title, o.url), h.Adapter.trigger(e, "popstate")), !0
			}, h.replaceState = function(t, n, i, r) {
				if (h.getHashByUrl(i) && h.emulated.pushState) throw new Error("History.js does not support states with fragement-identifiers (hashes/anchors).");
				if (r !== !1 && h.busy()) return h.pushQueue({
					scope: h,
					callback: h.replaceState,
					args: arguments,
					queue: r
				}), !1;
				h.busy(!0);
				var o = h.createStateObject(t, n, i);
				return h.isLastSavedState(o) ? h.busy(!1) : (h.storeState(o), h.expectedStateId = o.id, p.replaceState(o.id, o.title, o.url), h.Adapter.trigger(e, "popstate")), !0
			}; if (o) {
				try {
					h.store = u.parse(o.getItem("History.store")) || {}
				} catch (g) {
					h.store = {}
				}
				h.normalizeStore()
			} else h.store = {}, h.normalizeStore();
			h.Adapter.bind(e, "beforeunload", h.clearAllIntervals), h.Adapter.bind(e, "unload", h.clearAllIntervals), h.saveState(h.storeState(h.extractState(i.location.href, !0))), o && (h.onUnload = function() {
				var e, t;
				try {
					e = u.parse(o.getItem("History.store")) || {}
				} catch (n) {
					e = {}
				}
				e.idToState = e.idToState || {}, e.urlToId = e.urlToId || {}, e.stateToId = e.stateToId || {};
				for (t in h.idToState) h.idToState.hasOwnProperty(t) && (e.idToState[t] = h.idToState[t]);
				for (t in h.urlToId) h.urlToId.hasOwnProperty(t) && (e.urlToId[t] = h.urlToId[t]);
				for (t in h.stateToId) h.stateToId.hasOwnProperty(t) && (e.stateToId[t] = h.stateToId[t]);
				h.store = e, h.normalizeStore(), o.setItem("History.store", u.stringify(e))
			}, h.intervalList.push(l(h.onUnload, h.options.storeInterval)), h.Adapter.bind(e, "beforeunload", h.onUnload), h.Adapter.bind(e, "unload", h.onUnload)), h.emulated.pushState || (h.bugs.safariPoll && h.intervalList.push(l(h.safariStatePoll, h.options.safariPollInterval)), ("Apple Computer, Inc." === r.vendor || "Mozilla" === (r.appCodeName || "")) && (h.Adapter.bind(e, "hashchange", function() {
				h.Adapter.trigger(e, "popstate")
			}), h.getHash() && h.Adapter.onDomLoad(function() {
				h.Adapter.trigger(e, "hashchange")
			})))
		}, h.init()
	}(window);