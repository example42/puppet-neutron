# = Class: neutron::example42
#
# Example42 puppi additions. To add them set:
#   my_class => 'neutron::example42'
#
class neutron::example42 {

  puppi::info::module { 'neutron':
    packagename => $neutron::package_name,
    servicename => $neutron::service_name,
    processname => 'neutron',
    configfile  => $neutron::config_file_path,
    configdir   => $neutron::config_dir_path,
    pidfile     => '/var/run/neutron.pid',
    datadir     => '',
    logdir      => '/var/log/neutron',
    protocol    => 'tcp',
    port        => '5000',
    description => 'What Puppet knows about neutron' ,
    # run         => 'neutron -V###',
  }

  puppi::log { 'neutron':
    description => 'Logs of neutron',
    log         => [ '/var/log/neutron/neutron.log' , '/var/log/neutron/neutron-manage.log' ],
  }

}
