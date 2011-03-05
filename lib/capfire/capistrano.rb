# Capistrano task for posting to Campfire.
#
# There are two ways to use Capfire, either run the generator (see the README)
# or add 'require "capfire/capistrano"' to your deploy.rb.

require 'broach'
require 'capfire'

Capistrano::Configuration.instance(:must_exist).load do
  # Don't bother users who have capfire installed but don't have a ~/.campfire file

  if Capfire.config_file_exists?
    if Capfire.valid_config?
      before "deploy:update_code", "capfire:check_for_push"
      after "deploy:update_code", "capfire:post_to_campfire"
    else
      logger.info "Not all required keys found in your .campfire file. Please regenerate."
    end
  else
    logger.info "Couldn't find a .campfire in your home directory."
  end

  namespace :capfire do

    desc "Check if local version was pushed to github"
    task :check_for_push do
      deployed_version = current_revision[0,7] rescue "0000000"
      local_version = `git rev-parse HEAD`[0,7]
      if deployed_version == local_version
        `say -v "Cellos" fail` if Capfire.bin_installed?("say")
        Capfire.speak(Capfire.idiot_message(application)) unless dry_run
        logger.important "\nDidn't you forget something? A hint: `git push`."
        exit
      end
    end

    desc <<-DESC
This will post to the campfire room as specified in your ~/.campfire. \
The message posted will contain a link to Github's excellent compare view, \
the commiters name, the project name and the arguments supplied to cap.
  DESC
    task :post_to_campfire do
      begin
        source_repo_url = repository
        deployed_version = previous_revision[0,7] rescue "000000"
        local_version = `git rev-parse HEAD`[0,7]

        compare_url = Capfire.github_compare_url source_repo_url, deployed_version, local_version
        message = Capfire.deploy_message(ARGV.join(' '), compare_url, application)
        message = `cowsay "#{message}"` if Capfire.cowsay?

        if dry_run
          logger.info "Capfire would have posted:\n#{message}"
        else
          Capfire.speak message
        end
        logger.info "Posting to Campfire"
      rescue => e
        # Making sure we don't make capistrano fail.
        # Cause nothing sucks donkeyballs like not being able to deploy
        logger.important e.message
      end
    end
  end
end
