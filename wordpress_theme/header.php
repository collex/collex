<?php
/**
 * @package WordPress
 * @subpackage Default_Theme
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title>N I N E S</title>

	<!-- site wide styles -->
  <link href="/stylesheets/globals.css" media="all" rel="stylesheet" type="text/css" />
  <link href="/stylesheets/core.css" media="all" rel="stylesheet" type="text/css" />

	<!-- section styles -->
  <link href="/stylesheets/news.css" media="all" rel="stylesheet" type="text/css" />

	
<!--[if IE]>
	  	<link href="/stylesheets/ie.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->

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
<body>

<div id="mainContent">

	<div id="container">
		<div id="header-left">
			<img src="" alt="" />
		</div>
		<div id="header-center">
			<span class="emph1"><a href="/">&nbsp;</a></span><br /><i>&nbsp;</i><br />
		</div>
		<div id="header-right">
		</div>

	<div id="nines-content">
		<table class="tabs" cellspacing='0px' >
			<tr>
				<td class="tab-spacer-left">&nbsp;</td>
				<td class='link_tab'><a href="/" class="nav_link">Home</a></td>
				<td class='link_tab'><a href="/my9s" class="nav_link">My&nbsp;9s</a></td>
				<td class='link_tab'><a href="/search" class="nav_link">Search</a></td>
				<td class='link_tab'><a href="/tags" class="nav_link">Tags</a></td>
				<td class='link_tab'><a href="/exhibit_list" class="nav_link">Exhibits</a></td>
				<td class='curr_tab'>News</td>
				<td class='link_tab'><a href="/tab_about" class="nav_link">About</a></td>
				<td class="tab-spacer-right">&nbsp;</td>
			</tr>
		</table>

		<div class="tab-content-outline">
		<div class="tab-content-outline2">

		<div class="tab-content">
<div id="nines-page">
<hr />
