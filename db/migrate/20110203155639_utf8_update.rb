# encoding: UTF-8
class Utf8Update < ActiveRecord::Migration
  def self.up
    
    # define configuration that will be used in the update
    db_config = ActiveRecord::Base.connection.instance_values["config"]
    db_name = db_config[:database]
    db_user = db_config[:username]
    db_pass = db_config[:password]
    db_host = db_config[:host].blank? ? "localhost" : db_config[:host]

    if db_pass.nil? || db_pass.empty?
       pass_str = nil
    else
       pass_str = "-p#{db_pass}"
    end
    charset = 'utf8'
    
    # some temp files
    orig_dump = 'orig_dump.sql'
    utf8_dump = 'utf8_dump.sql'
    fixed_dump = 'final_dump.sql'
    
    puts "Dumping database to #{orig_dump}... "
    system "mysqldump -u#{db_user} #{pass_str} -h #{db_host} #{db_name} > #{orig_dump}"
    
    puts "Convert to UTF8... "
    system "cat #{orig_dump} | sed -e 's/DEFAULT CHARSET=latin1/DEFAULT CHARSET=utf8/g' | sed -e 's/CHARACTER SET latin1//g' >  #{utf8_dump}"
    
    puts "Correcting contents of UTF8 dump file..."
    file = File.open(utf8_dump, "r")
    content = file.read
    file.close

    new_text = content.gsub("â€™", '’')
    new_text = new_text.gsub("â€”", '—')
    new_text = new_text.gsub("â€œ", '“')
    new_text = new_text.gsub("â€•", '―')
    new_text = new_text.gsub("â€“", '–')
    new_text = new_text.gsub("â€˜", '‘')
    new_text = new_text.gsub("â€¦", '…')
    new_text = new_text.gsub("â†’", '→')
    new_text = new_text.gsub("â€¡", '‡')
    new_text = new_text.gsub("â€ ", '†')
    new_text = new_text.gsub("â€", '”')
    new_text = new_text.gsub("â€¢", '•')
    new_text = new_text.gsub("Ã ", 'à')
    new_text = new_text.gsub("Ã¡", 'á')
    new_text = new_text.gsub("Ã¢", 'â')
    new_text = new_text.gsub("Ã¤", 'ä')
    new_text = new_text.gsub("Ã", 'Á')
    new_text = new_text.gsub("Ã¦", 'æ')
    new_text = new_text.gsub("Ã†", 'Æ')
    new_text = new_text.gsub("ÃŸ", 'ß')
    new_text = new_text.gsub("Ã§", 'ç')
    new_text = new_text.gsub("Ã‰", 'É')
    new_text = new_text.gsub("Ãˆ", 'È')
    new_text = new_text.gsub("Ã«", 'ë')
    new_text = new_text.gsub("Ã¨", 'è')
    new_text = new_text.gsub("Ã©", 'é')
    new_text = new_text.gsub("Ãª", 'ê')
    new_text = new_text.gsub("ÃŒ", 'Ì')
    new_text = new_text.gsub("Ã­", 'í')
    new_text = new_text.gsub("Ã¯", 'ï')
    new_text = new_text.gsub("Ã¬", 'ì')
    new_text = new_text.gsub("Ã³", 'ó')
    new_text = new_text.gsub("Ã¶", 'ö')
    new_text = new_text.gsub("Ã²", 'ò')
    new_text = new_text.gsub("Ãµ", 'õ')
    new_text = new_text.gsub("Ãº", 'ú')
    new_text = new_text.gsub("Ã¹", 'ù')
    new_text = new_text.gsub("Ã¼", 'ü')
    new_text = new_text.gsub("Ã±", 'ñ')

    new_text = new_text.gsub("Â", '')
    new_text = new_text.gsub("Â¬", '')

    file = File.new(fixed_dump, "w")
    file.write(new_text)
    file.close
    
    puts "Recreate database... "
    system "mysql -u#{db_user} #{pass_str} -h #{db_host} -e \"drop database #{db_name}\""  
    system "mysql -u#{db_user} #{pass_str} -h #{db_host} -e \"create database #{db_name} default character set utf8\""   
    system "mysql -u#{db_user} #{pass_str} -h #{db_host} #{db_name} < #{fixed_dump}"
    
    puts "Clean up..."
    system "rm #{orig_dump}"
    system "rm #{utf8_dump}"
    system "rm #{fixed_dump}"
    
  end

  def self.down
     puts "No rollback for converstion to UTF8"
  end
end
