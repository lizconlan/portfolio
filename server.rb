require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

require 'lib/repo_list'

get "/" do
  #cache for an hour
  response.headers['Cache-Control'] = 'public, max-age=3600'
  @repos = RepoList.new("lizconlan")
  haml :index
end