set :stage, :local
  role :app, %w{admin.lissa.dev}
  server 'admin.lissa.dev', user: 'vagrant'
  set :deploy_to, '/home/vagrant/lissa_kickstart'