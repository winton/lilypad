require File.expand_path("#{File.dirname __FILE__}/../lilypad") unless defined?(::Lilypad)

Capistrano::Configuration.instance(:must_exist).load do

  after "deploy", "hoptoad:notify"
  after "deploy:long", "hoptoad:notify"
  after "deploy:migrations", "hoptoad:notify"

  namespace :hoptoad do
    desc "Notify Hoptoad of the deployment"
    task :notify, :except => { :no_release => true } do
      ENV['RACK_ENV'] = fetch(:rails_env, "production")
      Lilypad.deploy(
        :environment => ENV['RACK_ENV'],
        :repository => repository,
        :revision => current_revision,
        :username => ENV['USER'] || ENV['USERNAME']
      )
    end
  end
end