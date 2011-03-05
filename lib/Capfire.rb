# Gem for applications to automatically post to Campfire after an deploy.

class Capfire
  # To see how it actually works take a gander at the generator
  # or in the capistrano.rb
  class << self
    def config_file_exists?
      File.exists?(File.join(ENV['HOME'],'.campfire'))
    end

    def valid_config?
      config = self.config
      config["message"] && config["room"] && config ["token"] && config["account"]
    end

    def config
      YAML::load(File.open(File.join(ENV['HOME'],'.campfire')))["campfire"]
    end

    def room
      self.config["room"]
    end

    def account
      self.config["account"]
    end

    def token
      self.config["token"]
    end

    def cowsay?
      config["cowsay"]
    end

    # Who is deploying
    def deployer
      Etc.getlogin
    end

    # Link to github's excellent Compare View
    def github_compare_url(repo_url, first_commit, last_commit)
      repo_url.gsub!(/git@/, 'http://')
      repo_url.gsub!(/\.com:/,'.com/')
      repo_url.gsub!(/\.git/, '')
      "#{repo_url}/compare/#{first_commit}...#{last_commit}"
    end

    # Message to post to campfire
    def message(args,compare_url, application)
      message = self.config["message"]
      message.gsub!(/#deployer#/, deployer)
      message.gsub!(/#application#/, application)
      message.gsub!(/#args#/, args)
      message.gsub!(/#compare_url#/, compare_url)
      message
    end
  end
end

