require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'yaml'

require './lib/github_repo_list'
require './lib/scraperwiki_scraper_list'

before do
  @config = YAML.load(File.read('config/config.yml'))
end

get "/styles/style.css" do
  response.headers['Cache-Control'] = 'public, max-age=86400'
  sass :style
end

get "/" do
  #cache for 2 hours
  response.headers['Cache-Control'] = 'public, max-age=7200'
  
  @section_links = []
  
  @config["code_hosts"].each do |host|
    case host["host"]
      when "github"
        @repos = GithubRepoList.new(host["username"])
      when "scraperwiki"
        @scrapers = ScraperwikiScraperList.new(host["username"])
    end
    host["sections"].each do |section|
      @section_links << {"link" => "#{host["host"]}_#{section["type"]}", "text" => section["text"]}
    end
  end
  
  haml :index
end
