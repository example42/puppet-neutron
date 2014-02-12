#
# = Class: neutron
#
# This class installs and manages neutron
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class neutron (

  $conf_hash                 = undef,
  $generic_service_hash      = undef,

  $package_name              = $neutron::params::package_name,
  $package_ensure            = 'present',

  $service_name              = $neutron::params::service_name,
  $service_ensure            = 'running',
  $service_enable            = true,

  $config_file_path          = $neutron::params::config_file_path,
  $config_file_replace       = $neutron::params::config_file_replace,
  $config_file_require       = 'Package[neutron]',
  $config_file_notify        = 'class_default',
  $config_file_source        = undef,
  $config_file_template      = undef,
  $config_file_content       = undef,
  $config_file_options_hash  = undef,
  $config_file_owner         = $neutron::params::config_file_owner,
  $config_file_group         = $neutron::params::config_file_group,
  $config_file_mode          = $neutron::params::config_file_mode,

  $config_dir_path           = $neutron::params::config_dir_path,
  $config_dir_source         = undef,
  $config_dir_purge          = false,
  $config_dir_recurse        = true,

  $dependency_class          = undef,
  $my_class                  = undef,

  $monitor_class             = undef,
  $monitor_options_hash      = { } ,

  $firewall_class            = undef,
  $firewall_options_hash     = { } ,

  $scope_hash_filter         = '(uptime.*|timestamp)',

  $tcp_port                  = undef,
  $udp_port                  = undef,

  ) inherits neutron::params {


  # Class variables validation and management

  validate_bool($service_enable)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  $manage_config_file_content = default_content($config_file_content, $config_file_template)

  $manage_config_file_notify  = $config_file_notify ? {
    'class_default' => 'Service[neutron]',
    ''              => undef,
    default         => $config_file_notify,
  }

  if $package_ensure == 'absent' {
    $manage_service_enable = undef
    $manage_service_ensure = stopped
    $config_dir_ensure = absent
    $config_file_ensure = absent
  } else {
    $manage_service_enable = $service_enable ? {
      ''      => undef,
      'undef' => undef,
      default => $service_enable,
    }
    $manage_service_ensure = $service_ensure ? {
      ''      => undef,
      'undef' => undef,
      default => $service_ensure,
    }
    $config_dir_ensure = directory
    $config_file_ensure = present
  }


  # Resources managed

  if $neutron::package_name {
    package { 'neutron':
      ensure   => $neutron::package_ensure,
      name     => $neutron::package_name,
    }
  }

  if $neutron::config_file_path {
    file { 'neutron.conf':
      ensure  => $neutron::config_file_ensure,
      path    => $neutron::config_file_path,
      mode    => $neutron::config_file_mode,
      owner   => $neutron::config_file_owner,
      group   => $neutron::config_file_group,
      source  => $neutron::config_file_source,
      content => $neutron::manage_config_file_content,
      notify  => $neutron::manage_config_file_notify,
      require => $neutron::config_file_require,
    }
  }

  if $neutron::config_dir_source {
    file { 'neutron.dir':
      ensure  => $neutron::config_dir_ensure,
      path    => $neutron::config_dir_path,
      source  => $neutron::config_dir_source,
      recurse => $neutron::config_dir_recurse,
      purge   => $neutron::config_dir_purge,
      force   => $neutron::config_dir_purge,
      notify  => $neutron::manage_config_file_notify,
      require => $neutron::config_file_require,
    }
  }

  if $neutron::service_name {
    service { 'neutron':
      ensure     => $neutron::manage_service_ensure,
      name       => $neutron::service_name,
      enable     => $neutron::manage_service_enable,
    }
  }


  # Extra classes
  if $conf_hash {
    create_resources('neutron::conf', $conf_hash)
  }

  if $generic_service_hash {
    create_resources('neutron::generic_service', $generic_service_hash)
  }


  if $neutron::dependency_class {
    include $neutron::dependency_class
  }

  if $neutron::my_class {
    include $neutron::my_class
  }

  if $neutron::monitor_class {
    class { $neutron::monitor_class:
      options_hash => $neutron::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $neutron::firewall_class {
    class { $neutron::firewall_class:
      options_hash => $neutron::firewall_options_hash,
      scope_hash   => {},
    }
  }

}

