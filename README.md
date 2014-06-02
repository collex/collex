# Collex Main Website

This is the user-facing website for collex. You will need this if you are 
setting up your own instance of Collex. After downloading this, you will have 
to customize it for your own look and feel. You can then either arrange
to have your own documents added to the ARC Federation, or you can create a 
completely stand alone version of this site. If you do the former, then this is
the only project in the collex tool chain that you need to set up yourself. 
It is recommended that you also use the collex_wordpress_theme project, though. 
If you are setting up a stand-alone site, you will need all the projects.

# Collex architecture

Collex is a complex project made up of a number of subprojects that all have to
be in place for it to work. Most users will probably just need to set up the 
main Collex piece and point it at the existing Catalog. If that is all you want
to do, then you don't need to understand the following architecture and you 
don't need to download the "solr" or "catalog" projects.

When Collex is deployed, it is branded with the name of a particular 
"Federation", like NINES or 18thConnect. The website that the end user goes to 
will look like that federation, but the code behind it is the "collex" 
project here.

When a search is done from "collex", the request is made to the "catalog" 
project, which is a web service that exposes all the documents that have been 
stored.

The "catalog" webservice processes the request and forms the correct call to 
the "solr" webservice.

The "arc-inbox" is a simple website that allows users to upload new .rdf 
content that will be added to the catalog / solr index.

The documents are added to the solr index by converting RDF documents using 
the project "rdf-indexer".

The About section of "collex" and the News section of "collex" are two separate
WordPress installations. The recommended theme to use is in the 
"collex_wordpress_theme" project.

The "typewright" project can be attached to a "collex" instance if you wish by 
setting it up in the site.yml file of "collex". The "typewright" project is a 
webservice that keeps the information about all the typewright-enabled
documents. The actual web presence of typewright is in the "collex" project 
under subfolders named typewright.

# Local Install

1. Download this project to your local development area.
2. Copy config/database.example.yml to config/database.yml.
3. Copy config/site.example.yml to config/site.yml.
4. Modify those two files to suit your server and your needs. There are comments in them. **DO NOT CHECK THEM IN!**
5. The first time you run, you will have to run `bundle install`.
6. Next, you must configure the database, and bootstrap some necessary data into the system. This is done with the by running the following:

        rake db:setup
        rake bootstrap:globals url={catalog url}

# Deployment

Collex is deployed using capistrano, and can be deployed to either
a staging server (edge) or a production server. The configuration for each
host is found in config/site.yml at the bottom of the file. Fill
in the necessary data for each site. To complete this section, you
must have a user created on the target host which will run the catalog.
That user must have full read/write permissions on the install directory.
Additionally you must generate an ssh key-pair on your development machine and
install it on the target host. Add an entry in your ~/.ssh/config file for
each host. Example:

    Host edge-collex
       Hostname 128.128.128.128
       User collex
       Port 22
       IdentityFile ~/.ssh/edge-collex


1. First time deployment has a few extra setup steps
  1. Copy Capfile.example to Capfile
  2. Copy config/deploy.rb.example to config/deploy.rb
  3. Modify config/deploy.rb to suit your needs.
  4. Setup common structures on the host, run the capistrano setup comman for the
	   desired host and federation.
	   Example: `cap edge_nines_setup` or `cap prod_18th_setup`
	5. Login to the host and navigate to the install directory.
	6. From there, cd into shared/config.
	7. Fill in the template database.yml and site.yml
	8. Startup mysql and create the database for the federation. For example: 'nines_production'
2. After this setup, each subsequent deployment is accomplished by running `cap menu`
	 It will present you with a menu to pick a destination of edge or production
	 for each of the availble federations. After you make the selection, deployment will begin.

# License

> Copyright 2011 Applied Research in Patacriticism and the University of Virginia

> Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

> Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
