# Gem for applications to automatically post to Campfire after an deploy.

require 'broach'
require 'etc'

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

    # Campfire room
    def room
      self.config["room"]
    end

    # Campfire account
    def account
      self.config["account"]
    end

    # Campfire token
    def token
      self.config["token"]
    end

    # `brew install cowsay && cowsay "capfire"`
    #  _________
    #< capfire >
    # ---------
    #        \   ^__^
    #         \  (oo)\_______
    #            (__)\       )\/\
    #                ||----w |
    #                ||     ||
    def cowsay?
      config["cowsay"] && self.bin_installed?("cowsay")
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

    def default_idiot_message
      "LATFH: #deployer# wanted to deploy #application#, but forgot to push first."
    end

    # Message to post on deploying without pushing
    def idiot_message(application)
      message = self.config["idiot_message"]
      message = default_idiot_message unless message
      message.gsub!(/#deployer#/, self.deployer)
      message.gsub!(/#application#/, application)
      message
    end

    # Message to post to campfire on deploy
    def deploy_message(args,compare_url, application)
      message = self.config["message"]
      message.gsub!(/#deployer#/, deployer)
      message.gsub!(/#application#/, application)
      message.gsub!(/#args#/, args)
      message.gsub!(/#compare_url#/, compare_url)
      message
    end

    # Quick and irty way to check for installed bins
    # Ideally this should also check if it's in the users
    # path etc. Skipping for now.
    def bin_installed?(bin_name)
      !`which #{bin_name}`.empty?
    end

    # Initializes a broach campfire room
    def broach_room
      Broach.settings = {
        'account' => self.account,
        'token' => self.token,
        'use_ssl' => true
      }
      Broach::Room.find_by_name(self.room)
    end

    # Posts to campfire
    def speak(message)
      self.broach_room.speak(message)
    end

  end

end
