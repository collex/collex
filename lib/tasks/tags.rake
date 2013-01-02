namespace :tags do

  desc "Covert a genre to a tag (genre=genre_name username=name)"
  task :create_tag_from_genre => :environment do
    genre = ENV['genre']
    tag_name = ENV['genre']
    if tag_name.nil? || genre.nil?
      $stderr.puts "Usage:  rake tags:create_tag_from_genre genre=genre_name username=name"
      return
    end

    username = ENV['username']
    user = User.find_by_username(username) if not username.nil?
    if username.nil? || user.nil?
      $stderr.puts "User '#{username}' not found."
      return
    end

    tag_info = {'name' => tag_name}

    start_time = Time.now()

    # find all objects with genre:genre
    solr = Catalog.factory_create(false)
    constraints = []
    constraints << FacetConstraint.new( :fieldx => 'genre', :value => genre, :inverted => false)
    constraints << FederationConstraint.new(:fieldx => 'federation', :value => Setup.default_federation(), :inverted => false)
    #constraints << FederationConstraint.new(:fieldx => 'federation', :value => 'NINES', :inverted => false)
    start = 0
    max = 1000
    results = solr.search(constraints, start, max, nil, nil)
    # Loop across all URIs
    total_tagged = 0
    total_left = results['total_hits'].to_i
    while total_left > 0
      if results['hits']
        total_left -= results['hits'].count
        start += results['hits'].count
        results['hits'].each do |hit|
          if hit['uri']
            hit['uri'].gsub!(/"/,'')     # Why are there quotes in the URI?!?
            Tag.add(user, hit['uri'], tag_info)
            total_tagged += 1
          end
        end
        if total_left > 0
          results = solr.search(constraints, start, max, nil, nil)
        end
      else
        break
      end
    end
    puts "Total objects tagged with '#{tag_name}': #{total_tagged}"

    finish_line(start_time)
  end

  desc "Covert orphaned genres to a tags"
  task :convert_orphaned_genres_to_tags => :environment do
    genres = [
        #'Architecture',
        #'Artifacts',
        #'Book History',
        'Education',
        'Family Life',
        'Folklore',
        #'History',   # Historiography ?
        'Humor',
        'Leisure',
        #'Letters',
        #'Periodical',
        'Politics',
        #'Science'
    ]

    username=ENV['username']
    if username.nil?
      $stderr.puts "Usage rake tags:convert_orphaned_genres_to_tags username=user"
      return
    end

    start_time = Time.now()

    genres.each do |genre|
      Rake::Task["tags:create_tag_from_genre"].reenable
      ENV['genre'] = "#{genre}"
      Rake::Task["tags:create_tag_from_genre"].invoke
    end

    finish_line(start_time)

  end

end