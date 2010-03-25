# Defines deploy:notify_hoptoad which will send information about the deploy to Hoptoad.

Capistrano::Configuration.instance(:must_exist).load do

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
      config = YAML::load(File.open(File.join(ENV['HOME'],'.campfire')))
      Broach.settings = { 'account' => config["campfire"]["account"], 'token' => config["campfire"]["token"] }
      Broach.speak(campfire_room,
                   "I (#{deployer}) deployed #{application} " +
                   "with `cap #{ARGV.join(' ')}` (#{compare_url})"
                   )
    end
  end
end
