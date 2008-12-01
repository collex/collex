<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>N I N E S</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 

	<!-- site wide styles -->
  <link href="/stylesheets/globals.css" media="all" rel="stylesheet" type="text/css" />
  <link href="/stylesheets/core.css" media="all" rel="stylesheet" type="text/css" />

	<!-- section styles -->
  <link href="/stylesheets/news.css" media="all" rel="stylesheet" type="text/css" />
	
<!--[if IE]>
	  	<link href="/stylesheets/ie.css" media="all" rel="stylesheet" type="text/css" />
<![endif]-->
	
	<!-- site wide scripts -->
	<script src="/javascripts/prototype.js" type="text/javascript"></script>
	<script src="/javascripts/effects.js" type="text/javascript"></script>
	<script src="/javascripts/dragdrop.js" type="text/javascript"></script>
	<script src="/javascripts/controls.js" type="text/javascript"></script>
	<script src="/javascripts/application.js" type="text/javascript"></script>
		
<!-- section scripts -->
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
							<div>
    <a href="/login">sign in</a>	</div>

					</div>
	<div id="content">
		<table class="tabs" cellspacing='0px' >
				<tr>
					<td class="tab-spacer-left">&nbsp;</td>
					<td class='link_tab'><a href="/">Home</a></td>
					<td class='link_tab'><a href="/my9s">My&nbsp;9s</a></td>
					<td class='link_tab'><a href="/search">Search</a></td>
					<td class='link_tab'><a href="/tags">Tags</a></td>
					<td class='link_tab'><a href="/exhibit_list">Exhibits</a></td>
					<td class='curr_tab'>News</td>
					<td class='link_tab'><a href="/tab_about">About</a></td>
					<td class="tab-spacer-right">&nbsp;</td>
				</tr>
		</table>

		<div class="tab-content-outline">
		<div class="tab-content-outline2">
		<div class="tab-content">

				<?php if (have_posts()) : ?>

			  <?php $post = $posts[0]; // Hack. Set $post so that the_date() works. ?>
			  <?php /* If this is a category archive */ if (is_category()) { ?>
				<h2 class="pagetitle">Archive for the &#8216;<?php single_cat_title(); ?>&#8217; Category</h2>
			  <?php /* If this is a tag archive */ } elseif( is_tag() ) { ?>
				<h2 class="pagetitle">Posts Tagged &#8216;<?php single_tag_title(); ?>&#8217;</h2>
			  <?php /* If this is a daily archive */ } elseif (is_day()) { ?>
				<h2 class="pagetitle">Archive for <?php the_time('F jS, Y'); ?></h2>
			  <?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
				<h2 class="pagetitle">Archive for <?php the_time('F, Y'); ?></h2>
			  <?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
				<h2 class="pagetitle">Archive for <?php the_time('Y'); ?></h2>
			  <?php /* If this is an author archive */ } elseif (is_author()) { ?>
				<h2 class="pagetitle">Author Archive</h2>
			  <?php /* If this is a paged archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
				<h2 class="pagetitle">Blog Archives</h2>
			  <?php } ?>


				<div class="navigation">
					<div class="alignleft"><?php next_posts_link('&laquo; Older Entries') ?></div>
					<div class="alignright"><?php previous_posts_link('Newer Entries &raquo;') ?></div>
				</div>

				<?php while (have_posts()) : the_post(); ?>
				<div class="post">
						<h3 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h3>

						<div class="entry">
							<?php the_content() ?>
						</div>

						<p><small> Posted in <?php the_category(', ') ?> at <?php the_time('F jS, Y') ?> by <?php the_author() ?></small></p>
					</div>

				<?php endwhile; ?>

				<div class="navigation">
					<div class="alignleft"><?php next_posts_link('&laquo; Older Entries') ?></div>
					<div class="alignright"><?php previous_posts_link('Newer Entries &raquo;') ?></div>
				</div>

			<?php else : ?>

				<h2 class="center">Not Found</h2>
				<?php include (TEMPLATEPATH . '/searchform.php'); ?>

			<?php endif; ?>

			</div> 
			</div> 
			</div>
			<br />
	      </div>
    </div>
	</div>
	<!-- <script type="text/javascript" src="/javascripts/boxover.js"></script> -->
<!--	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
	</script>
	<script type="text/javascript">
	_uacct = "UA-1813036-1";
	urchinTracker();
	</script> -->
  </body>

</html>
                
