# sc-mesosphere

This is a kitchen sink cookbook built around the various Mesos-related cookbooks. The name is a bit of a misnomer since this does not install Mesosphere's DCOS, but uses some of the Mesos OS packages from Mesosphere.

There are two roles, mesosphere-master and mesosphere-slave. For testing purposes, all nodes are also slaves. Masters have Exhibitor, Zookeeper, mesos-master, mesos-slave, and Marathon installed. Slaves have Exhibitor, Zookeeper, mesos-slave, and Marathon installed. Therefore, all nodes can use their local Zookeeper address. This is not best practice! Seriously! You should have separate Exhibitor/Zookeeper and Mesos Master clusters & a load balanced address set up in front of them.

Requirements:

 - Hostname set to public IP in /etc/hosts
Running `hostname::default` with

```
default['set_fqdn'] = node['fqdn']
default['hostname_cookbook']['hostsfile_ip'] = node['ipaddress']
```

will do that.

 - A shared network directory for the Exhibitor config mounted locally (i.e. NFS mount) - set `default['exhibitor']['cli']['fsconfigdir']` to that directory

 - Customize config.json.erb with your upstream DNS servers (either internal or public) - need to paramaterize this

 - For mesos-dns to work, slaves must have the host running mesos-dns as their DNS server, or the mesos-dns host must be set as a conditional forwarder for the "mesos" DNS domain

Zookeeper versions are specified in both the LWRP and attributes file for downstream use

You can preload Docker containers to the slave by setting them seperately in `default['sc-mesosphere']['docker_preloads']`

Excerpt from my environment JSON (note that Marathon listens on port 8081, not 8080, as Exhibitor listens on 8080)

```
"exhibitor": {
  "cli": {
    "fsconfigdir": "/media/data/.config/exhibitor"
  }
},
"marathon": {
  "flags": {
    "zk": "zk://127.0.0.1:2181/marathon",
    "http_port": "8081",
    "master": "zk://127.0.0.1:2181/mesos"
  }
},
"mesos": {
  "version": "0.26.0",
  "master": {
    "flags": {
      "cluster": "production",
      "zk": "zk://127.0.0.1:2181/mesos",
      "quorum": "2"
    }
  },
  "slave": {
    "flags": {
      "master": "zk://127.0.0.1:2181/mesos",
      "containerizers": "docker,mesos"
    }
  }
},
"sc-mesosphere": {
  "docker_preloads": [
    "mesosphere/marathon-lb"
  ]
}
```

Roles:

`mesosphere-master.json`
```
{
  "name": "mesosphere-master",
  "run_list": [
    "role[base-cookbook-here::set-up-hostname-and-network-share]",
    "recipe[sc-mesosphere::zookeeper]",
    "recipe[sc-mesosphere::master]",
    "recipe[sc-mesosphere::slave]",
    "recipe[sc-mesosphere::marathon]"
  ]
}
```

`mesosphere-slave.json`
```
{
  "name": "mesosphere-slave",
  "run_list": [
    "role[base-cookbook-here::set-up-hostname-and-network-share]",
    "recipe[sc-mesosphere::slave]",
    "recipe[marathon::install]"
  ]
}
```
