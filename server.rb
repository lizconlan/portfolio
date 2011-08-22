require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

require 'lib/repo_list'

before do
  @username = "lizconlan"
end

get "/styles/style.css" do
  sass :style
end

get "/" do
  #cache for 2 hours
  response.headers['Cache-Control'] = 'public, max-age=7200'
  @repos = RepoList.new(@username)
  haml :index
end
