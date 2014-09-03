jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	function setup(e, self) {
		e.preventDefault();
		var el = $(self);
		var parent = el.closest(".search-result");
		var index = parent.attr("data-index");
		var uri = parent.attr("data-uri");
		var isLoggedIn = window.collex.currentUserId && window.collex.currentUserId > 0;
		var title = parent.find('.doc-title').text();
		return { uri: uri, index: index, isLoggedIn: isLoggedIn, title: title };
	}

	body.on("click", ".search_result_buttons .collect", function (e) {
		var params = setup(e, this);
		doCollect('/results/result_row', params.uri, params.index, 'search_result_'+params.index, params.isLoggedIn);
	});

	body.on("click", ".search_result_buttons .uncollect", function (e) {
		var params = setup(e, this);
		doRemoveCollect('/results/result_row', params.uri, params.index, 'search_result_'+params.index);
	});

	body.on("click", ".search_result_buttons .discuss", function (e) {
		var params = setup(e, this);
		new StartDiscussionWithObject('/forum/get_all_topics', '/forum/post_object_to_new_thread', params.uri, params.title, '#search_result_'+params.index+' .discuss', params.isLoggedIn, '/forum/get_nines_obj_list', window.collex.spinner);
	});

	body.on("click", ".search_result_buttons .exhibit", function (e) {
		var params = setup(e, this);
		doAddToExhibit('result_row', params.uri, params.index, 'search_result_'+params.index, window.collex.myCollexUrl);
	});

	body.on("click", ".search_result_buttons .edit", function (e) {
		var params = setup(e, this);
		var tw_url = "/typewright/documents/0?uri="+params.uri;
		doEditDocument( params.isLoggedIn, tw_url );
	});

	body.on("click", ".search-result .uri_link", function (e) {
		jQuery(this).next().toggle();
		return false;

	});

});

