require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")

class CapfireGenerator < Rails::Generator::Base
  def add_options!(opt)
    opt.on('-a', '--account=account', String, "Your account") {|v| options[:campfire_account] = v}
    opt.on('-k', '--token=token', String, "Your token key") {|v| options[:campfire_token] = v}
    opt.on('-r', '--chatroom=room', String, "The chatroom") {|v| options[:chat_room] = v}
  end

  def manifest
    if !campfire_file_exists? && !options[:campfire_token] && !options[:chat_room] && !options[:campfire_account]
      puts "Token (-k), account (-a) and chatroom (-r) are required on first run."
      exit
    end

    record do |m|
      if ['config/deploy.rb', 'Capfile'].all? { |file| File.exists?(file) }
        m.append_to 'config/deploy.rb', capistrano_hook
      else
        puts "No config/deploy discovered, so I've done nothing."
      end

      conf = <<-CONF
campfire:
  account: #{options[:campfire_account]}
  token: #{options[:campfire_token]}
  ssl: false
  room: #{options[:chat_room]}
  message: "I (#deployer#) deployed #application# with `cap #args#` (#compare_url#)"
  cowsay: true
  cow: random
CONF
      unless campfire_file_exists?
        File.open(File.join(ENV['HOME'],'.campfire'), 'w') do |out|
          out.write(conf)
        end
      end
    end
  end


  def campfire_file_exists?
    File.exists?(File.join(ENV['HOME'],'.campfire'))
  end

  def capistrano_hook
    IO.read(source_path('capistrano_hook.rb'))
  end
end
