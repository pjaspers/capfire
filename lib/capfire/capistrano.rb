# Defines deploy:notify_campfire

require 'broach'

Capistrano::Configuration.instance(:must_exist).load do

  # Don't bother users who have capfire installed but don't have a ~/.campfire file
  if File.exists?(File.join(ENV['HOME'],'.campfire'))
    after "deploy:update_code", "deploy:notify_campfire"
  end

  namespace :deploy do
    desc "Posting a message to Campfire"
    task :notify_campfire do
      source_repo_url = repository
      deployer = Etc.getlogin
      deploying = `git rev-parse HEAD`[0,7]
      begin
        deployed = previous_revision[0,7]
      rescue
        deployed = "000000"
      end
      puts "Posting to Campfire"
      # Getting the github url
      github_url = repository.gsub(/git@/, 'http://').gsub(/\.com:/,'.com/').gsub(/\.git/, '')
      compare_url = "#{github_url}/compare/#{deployed}...#{deploying}"

      # Reading the config file and drill in on the campfire section of course.
      config = YAML::load(File.open(File.join(ENV['HOME'],'.campfire')))["campfire"]

      # Ugly but it does the job.
      message = config["message"].gsub(/#deployer#/, deployer).gsub(/#application#/, application).gsub(/#args#/, ARGV.join(' ')).gsub(/#compare_url#/,compare_url)
      
      message = `cowsay "#{message}"` if config["cowsay"]
      
      # Posting the message.
      Broach.settings = {
        'account' => config["account"],
        'token' => config["token"],
        'use_ssl' => (config["ssl"] ||= false)
      }
      room = Broach::Room.find_by_name(config["room"])
      room.paste(message)
    end
  end
end
