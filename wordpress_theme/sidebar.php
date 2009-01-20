<?php
/**
 * @package WordPress
 * @subpackage Default_Theme
 */
?>
	<div id="sidebar">
		<ul>
			<?php 	/* Widgetized sidebar, if you have the plugin installed. */
				if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar() ) : ?>
			<li>
				<div class="news_link"><a href="<?php bloginfo('url'); ?>">Return to News</a></div>
				<?php get_search_form(); ?>
			</li>

			<!-- Author information is disabled per default. Uncomment and fill in your details if you want to use it.
			<li><h2>Author</h2>
			<p>A little something about you, the author. Nothing lengthy, just an overview.</p>
			</li>
			-->

			<?php if ( is_404() || is_category() || is_day() || is_month() ||
						is_year() || is_search() || is_paged() ) {
			?> <li>

			<?php /* If this is a 404 page */ if (is_404()) { ?>
			<?php /* If this is a category archive */ } elseif (is_category()) { ?>
			<p>You are currently browsing the archives for the <?php single_cat_title(''); ?> category.</p>

			<?php /* If this is a yearly archive */ } elseif (is_day()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for the day <?php the_time('l, F jS, Y'); ?>.</p>

			<?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for <?php the_time('F, Y'); ?>.</p>

			<?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for the year <?php the_time('Y'); ?>.</p>

			<?php /* If this is a monthly archive */ } elseif (is_search()) { ?>
			<p>You have searched the <a href="<?php echo bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for <strong>'<?php the_search_query(); ?>'</strong>. If you are unable to find anything in these search results, you can try one of these links.</p>

			<?php /* If this is a monthly archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
			<p>You are currently browsing the <a href="<?php echo bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives.</p>

			<?php } ?>

			</li> <?php }?>

			<table><tr>
			<td><a href="http://localhost/wp/?feed=rss2"><img src="/images/RSS_icon.jpg" alt="rss" width="40" /></a></td>
			<td>Want to learn more about NINES?</td>
			</tr></table>
			<div class="rss_feed_link"><a href="http://localhost/wp/?feed=rss2">Subscribe to our RSS feed here</a></div>

			<li><div class="rounded_left"><div class="rounded_middle"><div class="rounded_right"><h3 class="rounded_h1">Archives</h3></div></div></div>
				<ul>
				<?php wp_get_archives('type=monthly'); ?>
				</ul>
			</li>

			<?php wp_list_categories('show_count=1&title_li=<div class="rounded_left"><div class="rounded_middle"><div class="rounded_right"><h3 class="rounded_h1">Categories</h3></div></div></div>'); ?>

			<?php /* If this is the frontpage */ if ( is_home() || is_page() ) { ?>
				<?php wp_list_bookmarks('title_li=Blogroll&title_before=<div class="rounded_left"><div class="rounded_middle"><div class="rounded_right"><h3 class="rounded_h1">&title_after=</h3></div></div></div>'); ?>

			<li><div class="rounded_left"><div class="rounded_middle"><div class="rounded_right"><h3 class="rounded_h1">Contact</h3></div></div></div>
				<div class="questions">Questions? Contact NINES at inquiries(at)nines(dot)org.</div>
			</li>

				<li><div class="rounded_left"><div class="rounded_middle"><div class="rounded_right"><h3 class="rounded_h1">Administration</h3></div></div></div>
				<ul>
					<?php wp_register(); ?>
					<li><?php wp_loginout(); ?></li>
				</ul>
				</li>
			<?php } ?>

			<?php endif; ?>
		</ul>
	</div>

