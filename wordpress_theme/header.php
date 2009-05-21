<?php
/**
 * @package WordPress
 * @subpackage NINES_Theme
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title>N I N E S - News</title>

	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/reset-fonts-grids/reset-fonts-grids.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/base/base-min.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/menu/assets/skins/sam/menu.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/button/assets/skins/sam/button.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/container/assets/skins/sam/container.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/editor/assets/skins/sam/editor.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/resize/assets/skins/sam/resize.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.7.0/build/assets/skins/sam/skin.css">
	<link href="/stylesheets/main.css" media="all" rel="stylesheet" type="text/css" />
	<link href="/stylesheets/nav.css" media="all" rel="stylesheet" type="text/css" />
	<link href="/stylesheets/lvl2.css" media="all" rel="stylesheet" type="text/css" />
	<link href="/stylesheets/js_dialog.css" media="all" rel="stylesheet" type="text/css" />
	<!-- section styles -->

<!--[if lt IE 7]>
	<link href="/stylesheets/iehacks.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->
<!--[if IE 7]>
	<link href="/stylesheets/ie7hacks.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->

	<script src="/javascripts/prototype.js" type="text/javascript"></script>
	<script src="/javascripts/application.js" type="text/javascript"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/yahoo-dom-event/yahoo-dom-event.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/json/json.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/element/element.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/button/button.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/container/container.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/connection/connection.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/menu/menu.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/editor/editor.js"></script>	
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/dragdrop/dragdrop.js"></script>
	<script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/resize/resize.js"></script>
	<script src="/javascripts/general_dialog.js" type="text/javascript"></script>
	<script src="/javascripts/login.js" type="text/javascript"></script>
	<script src="/javascripts/nospam.js" type="text/javascript"></script>

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
			<a href="/"><div id="header_left"></div></a>
			<div id="header_right"></div>
		</div>
		<a href="/my9s" class="mynines_link">My 9s</a>

		<div id='nav_container'>
			<a href="/" class="tab_link">HOME</a>
			<a href="/news/" class="tab_link_current">News</a>
			<a href="/forum" class="tab_link">Forum</a>
			<a href="/exhibit_list" class="tab_link">Exhibits</a>
			<a href="/tags" class="tab_link">Tags</a>
			<a href="/search" class="tab_link">Search</a>
		</div>

    	<div id="subnav_container">
        	<div id="login_container">
				<script language="JavaScript">
				document.observe('dom:loaded', function() {
					new Ajax.Updater('login_container', '/login/login_controls');
					});
				</script>
            </div>
            <div id="subnav_links_container">
            	<a href="/about">What is NINES?</a>  |  <a href="/scholarship/index.html">Scholarship</a>  |  <a href="/software/index.html">Software</a>  |  <a href="/community/index.html">Community</a> 
            </div>
           	<div class="clear_both"></div>
		</div>
		<div id="content_container">
			<div class="inner_content_container yui-t2">
<hr />
<div id="nines-page">
