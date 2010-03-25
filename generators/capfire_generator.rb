require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")

class CapfireGenerator < Rails::Generator::Base
  def add_options!(opt)
    puts "Adding options"
    opt.on('-a', '--account=account', String, "Your account") {|v| options[:campfire_account] = v}
    opt.on('-k', '--token=token', String, "Your token key") {|v| options[:campfire_token] = v}
    opt.on('-r', '--chatroom=room', String, "The chatroom") {|v| options[:chat_room] = v}
  end

  def manifest
    if campfire_file_exists?
      puts "You already have a ~/.campfire file, please remove this to use the generator"
      exit
    end
    if !options[:campfire_token] && !options[:chat_room] && !options[:campfire_account]
      puts options.inspect
      puts "Token and chat room are required"
      exit
    end

    record do |m|
      if ['config/deploy.rb', 'Capfile'].all? { |file| File.exists?(file) }
        m.append_to 'config/deploy.rb', capistrano_hook
      end

      conf = <<-CONF
campfire:
  account: #{options[:campfire_account]}
  token: #{options[:campfire_token]}
  room: #{options[:chat_room]}
CONF
puts options.inspect
      File.open(File.join(ENV['HOME'],'.campfire'), 'w') do |out|
        out.write(conf)
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
