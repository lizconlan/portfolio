require './lib/hosted_code_list'

class GithubRepoList < HostedCodeList
  attr_reader :all, :own, :forks, :watched, :contributor, :organisations
  
  def initialize(username)
    @username = username
    get_data()
  end
  
  private
    def get_data
      @all = call_api("https://api.github.com/users/#{@username}/repos?type=public")
      
      @contributor = []
      
      @own = @all.dup
      @own.delete_if {|x| x["fork"] == true}
      @own.delete_if {|x| x["owner"]["login"] != @username}
      
      @forks = @all.dup
      @forks.delete_if {|x| x["fork"] == false}
      
      @watched = call_api("https://api.github.com/users/#{@username}/watched")
      
      #ignore your own stuff that you "watch"
      @watched.delete_if {|x| x["owner"]["login"] == @username}
      
      @watched.each do |repo|
        process_repo_contribs(repo)
      end
      
      #being a watcher and a contributor isn't massively useful, remove the duplicates from @watched
      contrib_project_names = @contributor.collect {|x| x["name"]}
      @watched.delete_if {|x| contrib_project_names.include?(x["name"])}
      
      #include stuff from organisations
      @organisations = call_api("https://api.github.com/users/#{@username}/orgs")
      @organisations.each do |org|
        org_repos = call_api("https://api.github.com/orgs/#{org["login"]}/repos")
        org_repos.each do |repo|
          process_repo_contribs(repo)
        end
      end
    end
    
    def process_repo_contribs(repo)
      #fall back to API v2 as v3 doesn't seem to work (without auth?)
      contribs = call_api("https://github.com/api/v2/json/repos/show/#{repo["owner"]["login"]}/#{repo["name"]}/contributors")
      contribs["contributors"].each do |user|
        if user["login"] == @username
          @all << repo
          @contributor << repo
          break
        end
      end
    end
end