require 'ftools'

namespace :collex do
  
  desc "Update the installed NINES Wordpress theme"
  task :update_nines_theme do
    copy_dir( "#{RAILS_ROOT}/wordpress_theme", "#{RAILS_ROOT}/public/wp/wp-content/themes/nines" )
  end
  
  desc "Install the NINES Wordpress theme"
  task :install_nines_theme do    
    # install php files
    Dir.mkdir("#{RAILS_ROOT}/public/wp/wp-content/themes/nines")
    copy_dir( "#{RAILS_ROOT}/wordpress_theme", "#{RAILS_ROOT}/public/wp/wp-content/themes/nines" );        
  end
    
  def copy_dir( start_dir, dest_dir )
     puts "Copying the contents of #{start_dir} to #{dest_dir}..."
     Dir.new(start_dir).each { |file|
       unless file =~ /\A\./
         start_file = "#{start_dir}/#{file}"
         dest_file = "#{dest_dir}/#{file}"  
         File.copy("#{start_dir}/#{file}", "#{dest_dir}/#{file}")
       end     
     }    
  end
end

