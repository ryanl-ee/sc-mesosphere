docker_service 'default' do
  action [:create, :start]
end

include_recipe "sc-mesosphere::zookeeper"
include_recipe "mesos::slave"
include_recipe "haproxy::default"

directory '/usr/local/mesos-dns/'

remote_file '/usr/local/mesos-dns/mesos-dns' do
  source 'https://github.com/mesosphere/mesos-dns/releases/download/v0.5.1/mesos-dns-v0.5.1-linux-amd64'
  mode '0755'
end

directory '/etc/mesos-dns'

template '/etc/mesos-dns/config.json' do
  source 'config.json.erb'
end

sudo 'marathon' do
  user 'marathon'
  nopasswd true
end

docker_preloads = node['sc-mesosphere']['docker_preloads']

docker_preloads.each do |container|
  docker_image "#{container}" do
    action :pull
  end
end

docker_image 'wernight/plex-media-server' do
  tag 'autoupdate'
  action :pull
end
