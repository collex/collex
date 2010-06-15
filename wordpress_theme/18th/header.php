<?php
/**
 * @package WordPress
 * @subpackage 18thConnect_Theme
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title>18thConnect - News</title>

	<link rel='stylesheet' type='text/css' href='http://yui.yahooapis.com/combo?2.7.0/build/reset-fonts-grids/reset-fonts-grids.css&2.7.0/build/base/base.css&2.7.0/build/button/assets/skins/sam/button.css&2.7.0/build/container/assets/skins/sam/container.css&2.7.0/build/assets/skins/sam/skin.css' />
	<link href="/stylesheets/about-min.css" media="all" rel="stylesheet" type="text/css" />
	<!-- section styles -->

<!--[if lt IE 7]>
	<link href="/stylesheets/iehacks.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->
<!--[if IE 7]>
	<link href="/stylesheets/ie7hacks.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->

	<script src="/javascripts/prototype-min.js" type="text/javascript"></script>
	<script src='http://yui.yahooapis.com/combo?2.7.0/build/yahoo-dom-event/yahoo-dom-event.js&2.7.0/build/json/json.js&2.7.0/build/element/element.js&2.7.0/build/button/button.js&2.7.0/build/container/container.js&2.7.0/build/dragdrop/dragdrop.js' type='text/javascript' ></script>
	<script src="/javascripts/about-min.js" type="text/javascript"></script>

<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
<link rel="alternate" type="application/atom+xml" title="<?php bloginfo('name'); ?> Atom Feed" href="<?php bloginfo('atom_url'); ?>" />
<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />

<style type="text/css" media="screen">

<?php
// Checks to see whether it needs a sidebar or not
if ( !empty($withcomments) && !is_single() ) {
?>
	#page { background: url("<?php bloginfo('stylesheet_directory'); ?>/images/kubrickbg-<?php bloginfo('text_direction'); ?>.jpg") repeat-y top; border: none; }
<?php } else { // No sidebar ?>
	#page { background: url("<?php bloginfo('stylesheet_directory'); ?>/images/kubrickbgwide.jpg") repeat-y top; border: none; }
<?php } ?>

</style>

<?php if ( is_singular() ) wp_enqueue_script( 'comment-reply' ); ?>

<?php wp_head(); ?>
</head>

<body class="yui-skin-sam">
	<div id="main_container">
		<div id="header_container">
			<a href="/" id="header_left">&nbsp;</a>
			<div id="header_right"></div>
		</div>
		<a id="my_collex_tab" href="/my_collex" class="my_collex_link">.....</a>

		<div id='nav_container'>
			<a href="/" class="tab_link">HOME</a>
			<a href="/news/" class="tab_link_current">News</a>
			<a href="/classroom" class="tab_link_long">Classroom</a>
			<a href="/communities" class="tab_link_long">Community</a>
			<a href="/publications" class="tab_link_long">Publications</a>
			<a href="/search" class="tab_link">Search</a>
		</div>

    	<div id="subnav_container">
        	<div id="login_container">
				<script type="text/javascript">
				document.observe('dom:loaded', function() {
					new Ajax.Updater({ success: 'login_container', failure: 'bit_bucket' }, '/login/login_controls');
					new Ajax.Updater({ success: 'my_collex_tab', failure: 'bit_bucket' }, '/my_collex/get_tab_name');
					});
				</script>
            </div>
            <div id="subnav_links_container">
				<a href="/18th_about/what_is.html" class="nav_link">What is 18thConnect?</a> | <a href="/18th_about/peerReview.html" class="nav_link">Peer Review</a>
            </div>
           	<div class="clear_both"></div>
		</div>
		<div id="content_container">
			<div class="inner_content_container yui-t2">
<hr />
<div id="nines-page">
