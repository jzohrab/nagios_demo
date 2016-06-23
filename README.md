# Nagios demo

This project provides a simple demonstration of Nagios with a Nagios server and
a monitored host using Vagrant.

## Usage

`vagrant up`

The first provision will likely take up to 10 minutes as the base box
is downloaded and Nagios components are compiled from source.

When that is complete, the Nagios server is accessible from your
localhost at http://localhost:8080/ or http://192.168.33.10

* Username: nagiosadmin
* Password: nagios

When you check the server, you will find that there is currently a
failing check (see the "Tactical Overview" link in the server
sidebar).  This was left on purpose to demonstrate a failing check.

If you're new to Nagios, look through the links under the "Current Status" sidebar:

* Tactical Overview: a summary of current state
* Hosts: monitored hosts
* Services: monitored services
* Host/Service Groups: logical groups (none used in this demo)
* Problems: current problems

### Configuration

Nagios checks are defined in server folder
`/usr/local/nagios/etc/servers`, as set in `provision_server.sh`.

The Vagrantfile line `srv.vm.synced_folder` sets the local folder
`server`, which is created during `vagrant up`, to be synced to the VM
server's `/usr/local/nagios/etc` directory.  This means that can edit
the server's configuration files by editing the files in local
directory `./server/servers`.

You can also edit files directly on the VM if you prefer, using
`vagrant ssh server` and `sudo vi
/usr/local/nagios/etc/servers/<config_file_name>`.

If you create or edit a configuration, you'll need to reload the
configurations on the server:

    vagrant ssh server -c "sudo service nagios reload"

### Shutting down

Since provisioning the box from scratch takes a while, you may prefer
to `vagrant suspend` the box when you're done using it.  You can then
`vagrant resume` the box.

To destroy the box completely, use `vagrant destroy`.

## Further resources

* [The official docs](http://go.nagios.com/nagioscore/docs)
* [A short
  guide](http://users.telenet.be/mydotcom/howto/nagios/index.html):
  covers the basics, and important topics like configuration file
  management.
* [A short video](https://www.youtube.com/watch?v=hjzHI0mQXIE)