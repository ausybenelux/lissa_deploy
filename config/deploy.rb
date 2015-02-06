# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'lissa_kickstart'
set :repo_url, 'git@github.com:ONEAgency/lissa_kickstart.git'
set :branch, '8.0.x'
set :deploy_to, '/home/web/lissa_kickstart'
set :use_sudo, true
set :pty, true
set :deploy_via, :copy
set :docroot, '/var/www/admin-server/docroot'
set :chef_cache_dir, '/var/chef/cache'
set :db_name, 'lissa_kickstart'
set :db_user, 'root'
set :db_password, 'root'
set :keep_db_backups, 5

# Default value for :log_level is :debug
set :log_level, :trace

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }


desc "Backup the database"
namespace :db do
    task :backup do
        on roles(:app) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            execute :mkdir, "-p #{backup_path}"
            basename = 'database'

            filename = "#{basename}_#{fetch(:stage)}_#{fetch(:db_name)}_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.bz2"
            debug "We will backup to file: #{backup_path}/#{filename}"

            db_host = fetch(:db_host)
            hostcmd = db_host.nil? ? '' : "-h #{db_host}"
            execute :mysqldump, "-u #{fetch(:db_user)} --password='#{fetch(:db_password)}' --databases #{fetch(:db_name)} #{hostcmd} | bzip2 -9 > #{backup_path}/#{filename}"

            purge_old_backups "#{basename}", "#{backup_path}"
        end
    end

    def purge_old_backups(basename,backup_path)
        max_keep = fetch(:keep_db_backups, 5).to_i
        backup_files = capture("ls -t #{backup_path}/#{basename}*").split.reverse
        if max_keep >= backup_files.length
          info "No old database backups to clean up"
        else
          info "Keeping #{max_keep} of #{backup_files.length} database backups"
          delete_backups = (backup_files - backup_files.last(max_keep)).join(" ")
          execute :rm, "-rf #{delete_backups}"
        end
    end
end

namespace :deploy do
  task :build do
    on roles(:app) do
      within release_path do
        docroot = fetch(:docroot)
        execute "cd #{release_path} && sudo phing -Ddocroot=#{docroot}"
      end
    end
  end

  task :update do
    on roles(:app) do
      within release_path do
        docroot = fetch(:docroot)
        execute "cd #{release_path} && sudo phing update -Ddocroot=#{docroot}"
      end
    end
  end

  task :update_env_config do
    on roles(:app) do
      within release_path do
        chef_cache_dir = fetch(:chef_cache_dir)
        # Copy environment specific configuration provisioned by Chef.
        execute "cp #{chef_cache_dir}/lissa_kickstart/build.properties #{release_path}"
        execute "cp #{chef_cache_dir}/lissa_kickstart/settings.local.php #{release_path}"
      end
    end
  end

  before :update, 'deploy:update_env_config'
  before :build, 'deploy:update_env_config'
  after :updated, 'deploy:update'
  before :updating, 'db:backup'
end