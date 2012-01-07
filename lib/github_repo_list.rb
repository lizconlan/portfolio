require './lib/hosted_code_list'

class GithubRepoList < HostedCodeList
  attr_reader :all, :own, :forks, :watched, :contributor, :organisations
  
  def initialize(username)
    @username = username
    @token = ENV['gh_token'] || YAML::load(File.read("config/oauth.yml"))[:access_token]
    get_data()
  end
  
  private
    def get_data
      @all = call_api("https://api.github.com/users/#{@username}/repos?type=public?access_token=#{@token}")
      
      @contributor = []
      
      @own = @all.dup
      @own.delete_if {|x| x["fork"] == true}
      
      @forks = @all.dup
      @forks.delete_if {|x| x["fork"] == false}
      
      @contributor = call_api("https://api.github.com/users/#{@username}/repos?type=member&access_token=#{@token}")
      
      #include stuff from organisations
      @organisations = call_api("https://api.github.com/users/#{@username}/orgs?access_token=#{@token}")
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