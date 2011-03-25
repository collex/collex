
module NinesMapping

  GENRE_MAPPING = {
      # the values on the right must be lowercased without a trailing period
      'Bibliography' => ['bibliography'],
      'Book History' => ['specimens', 'publishers\' cloth bindings (binding)', 'facsimiles', 'gilt edges (binding)', 'binders\' tickets (binding)', 'gold blocked bindings (binding)', 'pictorial cloth bindings (binding)', 'blind tooled bindings (binding)', 'gift books', 'bevelled edge boards (binding)', 'blocked bindings (binding)', 'publishers\' advertisements', 'imprints', 'book prices (publishing)', 'flap bindings (binding)', 'amateur books (publishing)', 'leaf books', 'printing', 'bookbinding', 'rare books', 'miniature books', 'booksellers and bookselling', 'original printed wrappers', 'books and reading', 'books', 'book collecting'],
      'Collection' => ['catalogs','exhibitions','collections', 'excerpts, arranged' 'registers', 'autograph albums', 'catalogs and collections', 'gift books', 'bio-bibliography', 'digests', 'texts', 'account books', 'selections'],
      'Drama' => ['drama', 'theater', 'actors'],
      'Education' => ['textbooks', 'education', 'outlines, syllabi, etc', 'readers', 'conversation and phrase books', 'examinations, questions, etc', 'faculty papers', 'alphabet rhymes','readers (primary)'],
      'Ephemera' => ['ephemera','broadsides', 'clippings', 'posters', 'scrapbooks', 'autographs', 'miscellanea', 'autograph albums','timetables', 'war posters', 'cloth printings', 'pamphlets', 'playbills','games', 'keepsakes', 'souvenir programs', 'chapbooks', 'postcards'],
      'Family Life' => ['juvenile literature','cookbooks', 'juvenile fiction', 'children\'s stories','juvenile', 'juvenile poetry', 'family papers', 'picture books for children','home economics', 'nursery rhymes'],
      'Fiction' => ['fiction', 'mystery fiction', 'mystery and detective fiction','juvenile fiction', 'historial fiction', 'historical fiction, american', 'sea stories', 'american fiction', 'short stories, american', 'fairy tales'],
      'Folklore' => ['folklore', 'legends', 'fables'],
      'History' => ['genealogy', 'genealogies','speeches in congress','sources', 'personal narratives, confederate','personal narratives, english','personal narratives, american', 'registers', 'directories', 'congresses', 'historical fiction, american', 'historical geography','pedigrees', 'historical fiction', 'war posters', 'proclamations', 'sources', 'chronology', 'minutes', 'history, comic, satirical, etc', 'proclamations', 'commerce', 'antiquities', 'missions', 'economic conditions', 'history, military', 'world war, 1914\-1918','world history','civilization', 'charters', 'leisure', 'archaeology', 'conduct of life', 'social conditions'],
      'Humor' => ['parodies','Parodies, imitiations, etc', 'imitations', 'humor', 'political cartoons', 'comedies', 'farces', 'satires'],
      'Law' => ['trials, litigation, etc', 'regulations', 'cases', 'patents', 'rules and practice', 'judicial records', 'real property'],
      'Letters' => ['letters', 'letters (correspondence)', 'correspondence', 'diaries', 'love letters'],
      'Life Writing' => ['biography', 'biographies', 'autobiographies','personal narratives', 'interviews', 'anecdotes', 'personal narratives, american', 'personal narratives, confederate','personal narratives, english', 'anecdotes', 'personal narratives, british', 'diaries', 'bio-bibliography', 'meditations'],  
      'Manuscript' => ['manuscripts for publication','manuscripts', 'manuscript', 'maps, manuscript', 'notebooks'],
      'Music' => ['songs and music', 'excerpts, arranged', 'excerpts', 'musical settings', 'vocal scores with piano', 'librettos', 'piano scores', 'songs with piano','hymns', 'scores', 'music', 'parts', 'studies and exercises', 'song sheets', 'operas', 'opera', 'musicals', 'overtures'],
      'Nonfiction' => ['outdoor books', 'forests and forestry', 'botany', 'fires and fire prevention','human anatomy', 'anatomy', 'arithmetic', 'natural history', 'medecine', 'medicine', 'science', 'astronomy'],
      'Poetry' => ['poems', 'poetry', 'juvenile poetry', 'english poetry'],
      'Politics' => ['speeches in congress', 'treaties', 'treaties, etc', 'treaties','charters', 'political cartoons', 'political science', 'rules and practice', 'foreign relations', 'taxation', 'tariff', 'military law', 'Laws, statutes, etc.', 'campaign literature', 'monarchy','communism'],
      'Periodical' => ['periodicals','newspapers'],
      'Photograph' => ['photographs', 'photography','portrait photographs', 'card photographs','wet collodion negatives', 'tintypes', 'photograph albums', 'photomontages', 'photo montages', 'glass negatives'],
      'Reference Works' => ['dictionaries', 'registers', 'handbooks, manuals, etc', 'directories', 'glossaries, vocabularies, etc', 'pedigrees', 'genealogies', 'genealogy', 'timetables', 'indexes', 'tables', 'bio-bibliography', 'abstracts', 'classification', 'weights and measures', 'glossaries'],
      'Religion' => ['religion','sermons', 'hymns', 'theology','hymnals','catechisms', 'prayers and devotions', 'prayers','pastoral letters and charges', 'Bible', 'bible','christianity', 'novenas','devotional calendars'],
	  'Science' => ['science', 'astronomy', 'medicine', 'health' ],
      'Translation' => ['translations into english', 'conversation and phrase books', 'translations'],
      'Travel' => ['maps', 'voyages and travels', 'guidebooks', 'gazetteers', 'maps, manuscript', 'maps, topographic', 'maps, pictorial','cityscapes', 'maps, outline and base', 'viewbooks', 'festivals', 'festivals, etc', 'nautical charts', 'surveys', 'explorers'],
      'Visual Art' => ['pictorial works', 'portraits','caricatures and cartoons', 'illustrations', 'lithographs', 'designs and plans', 'group portraits', 'painting', 'paintings','portrait prints','engravings', 'engraving', 'political cartoons', 'graphic design drawings', 'ink drawings', 'art', 'albumen prints','watercolors', 'architectural drawings', 'decoration and ornament', 'illustrated books', 'painters', 'decorative arts', 'sculpture'],
    }

    GEOGRAPHIC_MAPPING = {
      # the values on the right must be lowercased without a trailing period
      'History' => ['history', 'history, local', 'resources', 'social life and customs'],
      'Politics'=> ['politics and government'],
      'Travel' => ['description and travel', 'discovery and exploration', 'public lands', 'roads', 'boundaries', 'california', 'texas', 'colorado', 'mexico', 'france', 'england','great britain', 'ireland', 'scotland','united states', 'america','spain', 'west', 'europe', 'italy','london'],
      'Religion' => ['church history'],
    }

    FORMAT_MAPPING = {
      'Criticism' => ['THESIS-DIS','IVY-THESIS'],
      'Ephemera' => ['BROADSIDE', 'POSTER'],
      'Manuscript' => ['MANUSCRIPT'],
      'Music' => ['MUSIC-DC', 'MUSI-SCORE'],
      'Periodical' => ['BOUND-JRNL', 'IVY-JRNL', 'NEWSPAPER', 'CUR-PER', 'BD-JRN-NC'],
      'Travel' => ['MAP'],
    }
    
   SUBJECT_GENRE_FIELDS = [ 
      ['600','v'],
      ['610','k'],
      ['610','v'],
      ['610','x'],
      ['611','v'],
      ['630','a'],
      ['630','k'],
      ['630','x'],
      ['650','v'],
      ['650','a'],
      ['651','v'],
      ['651','x'],
      ['655','a'],
      ['710','k'],
    ]
  
  GEOGRAPHIC_GENRE_FIELDS = [
      ['650','c'],
      ['650','z'],
      ['651','a'],
      ['651','x'],
      ['651','z'],
      ['655','z'],
    ]
    
  # concatenate the fields together in the order they are given
#  BANCROFT_URL = [
#    "http://pathfinder.berkeley.edu/WebZ/Authorize?sessionid=0:bad=html/authofail.html:next=NEXTCMD%22/WebZ/CheckIndexCombined:next=html/results.html:format=B:numrecs=20:entitytoprecno=1:entitycurrecno=1:tempjds=TRUE:entitycounter=1:entitydbgroup=Glad:entityCurrentPage=SearchRecentAcq:dbname=Glad:entitycountAvail=0:entitycountDisplay=0:entitycountWhere=0:entityCurrentSearchScreen=html/search.html:entityactive=1:indexA=cl%3D:termA=",
#    ['950','a'],['950','b'],
#    ":next=html/Cannedresultsframe.html:bad=error/badsearchframe.html"
#  ]
#
#  URL_FORMULA = BANCROFT_URL

  AUTHOR_MARC_CODES = [ ['100','a'], ['110','a'], ['111','a'], ['130','a'] ]       

  FORMAT_FACET = [ ['999','t'] ]
  
  SCAN_LIST = SUBJECT_GENRE_FIELDS + GEOGRAPHIC_GENRE_FIELDS + FORMAT_FACET
  
end