<?php
/**
 * @package WordPress
 * @subpackage 18thConnect_Theme
 */

get_header(); ?>

<?php get_sidebar(); ?>

<div id="bd">
<div id="yui-main">
<div class="yui-b">
<div class="yui-g">
	<!--<div id="wp-content" class="narrowcolumn">-->

		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<div class="post" id="post-<?php the_ID(); ?>">
		<h2><?php the_title(); ?></h2>
			<div class="entry">
				<?php the_content('<p class="serif">Read the rest of this page &raquo;</p>'); ?>

				<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>

			</div>
		</div>
		<?php endwhile; endif; ?>
	<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>
	</div>
</div>
</div>
</div>
<?php get_footer(); ?>