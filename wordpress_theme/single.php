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


				<?php if (have_posts()) : while (have_posts()) : the_post(); ?>

					<div class="navigation">
						<div class="alignleft"><?php previous_post_link('&laquo; %link') ?></div>
						<div class="alignright"><?php next_post_link('%link &raquo;') ?></div>
					</div>

					<div class="post" id="post-<?php the_ID(); ?>">
						<h2><?php the_title(); ?></h2>

						<div class="entry">
							<?php the_content('<p class="serif">Read the rest of this entry &raquo;</p>'); ?>

							<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>
							<?php the_tags( '<p>Tags: ', ', ', '</p>'); ?>

							<p class="postmetadata alt">
								<small>
									This entry was posted
									<?php /* This is commented, because it requires a little adjusting sometimes.
										You'll need to download this plugin, and follow the instructions:
										http://binarybonsai.com/archives/2004/08/17/time-since-plugin/ */
										/* $entry_datetime = abs(strtotime($post->post_date) - (60*120)); echo time_since($entry_datetime); echo ' ago'; */ ?>
									on <?php the_time('l, F jS, Y') ?> at <?php the_time() ?>
									and is filed under <?php the_category(', ') ?>.
								</small>
							</p>

						</div>
					</div>

				<?php endwhile; else: ?>

					<p>Sorry, no posts matched your criteria.</p>

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
                
