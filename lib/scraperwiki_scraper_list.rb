require './lib/hosted_code_list'

class ScraperwikiScraperList < HostedCodeList
  attr_reader :all, :own, :contributor
  
  def initialize(username)
    @username = username
    @own = []
    @contributor = []
    @all = []
    get_data()
  end
  
  def get_data
    data = call_api("https://api.scraperwiki.com/api/1.0/scraper/getuserinfo?format=jsondict&username=#{@username}")
    
    own = data[0]["coderoles"]["owner"]
    own.delete_if { |x| x =~ /.emailer$/}
    
    own.each do |repo|
      link = "https://scraperwiki.com/scrapers/#{repo}"
      repo_data = call_api("https://api.scraperwiki.com/api/1.0/scraper/getinfo?format=jsondict&name=#{repo}&version=-1")
      repo_hash = {"sw_name" => repo, "name" => repo_data[0]["title"], "html_url" => link, "language" => capitalize_language(repo_data[0]["language"]), "description" => repo_data[0]["description"], "homepage" => ""}
      @own << repo_hash
      @all << repo_hash
    end
    
    contribs = data[0]["coderoles"]["editor"]
    contribs.each do |repo|
      link = "https://scraperwiki.com/scrapers/#{repo}"
      repo_data = call_api("https://api.scraperwiki.com/api/1.0/scraper/getinfo?format=jsondict&name=#{repo}&version=-1")
      repo_hash = {"sw_name" => repo, "name" => repo_data[0]["title"], "html_url" => link, "language" => capitalize_language(repo_data[0]["language"]), "description" => repo_data[0]["description"], "homepage" => ""}
      @contributor << repo_hash
      @all << repo_hash
    end
  end
end