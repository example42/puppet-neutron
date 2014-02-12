# Class: neutron::params
#
# Defines all the variables used in the module.
#
class neutron::params {

  $package_name = $::osfamily ? {
    'Redhat' => 'openstack-neutron',
    default  => 'neutron-server',
  }

  $service_name = $::osfamily ? {
    'Redhat' => 'openstack-neutron-server',
    default  => 'neutron-server',
  }

  $config_file_path = $::osfamily ? {
    default => '/etc/neutron/neutron.conf',
  }

  $config_file_mode = $::osfamily ? {
    default => '0644',
  }

  $config_file_owner = $::osfamily ? {
    default => 'root',
  }

  $config_file_group = $::osfamily ? {
    default => 'neutron',
  }

  $config_dir_path = $::osfamily ? {
    default => '/etc/neutron',
  }

  case $::osfamily {
    'Debian','RedHat','Amazon': { }
    default: {
      fail("${::operatingsystem} not supported. Review params.pp for extending support.")
    }
  }
}
