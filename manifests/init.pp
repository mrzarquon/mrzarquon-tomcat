class tomcat(
  $tomcat_version         = '7.0.25',
  $war_source             = 'http://master/tomcat/',
  $tomcat_stage_dir       = '/opt/tomcat/active',
  $tomcat_target_dir      = '/opt/tomcat/active',
) {
  
  $tomcat_tarball         = "apache-tomcat-${tomcat_version}.tar.gz"
  $tomcat_current_version = "apache-tomcat-${tomcat_version}"

  # This class makes use of the staging::file defined type in order to take
  # advantage of a centrally defined file staging directory. Specifically,
  # $staging::path. In Puppet at the time of writing, however, parse order is
  # important when it comes to defining and using variables. For this class to
  # work as expected, Class['staging'] needs to be parsed *before* this class
  # is. Because of how important this parse order is to expected behavior, a
  # warning will be issued on both the server and agent if this class is parsed
  # before Class['staging'] has been declared.
  #
  # Good: (assume Class['profile::staging'] declares Class['staging'])
  #
  #  include profile::staging
  #  include 7zip
  #
  # Bad:
  #
  #  include 7zip
  #  include profile::staging
  #
  if ! defined(Class['staging']) {
    $message_array = [
      "Parse order error: Class['${name}'] uses Class['staging'] in a ",
      "parse-order dependent fashion. As such, Class['staging'] should be ",
      "defined BEFORE Class['${name}']. Without resolution, unexpected ",
      "behavior could result from the current configuration.",
    ]
    warning("${message_array}")
    notify { "Class['${name}'] warning": message => "${message_array}"; }
  }

  staging::deploy { $tomcat_tarball:
    source  => "${war_source}/${tomcat_tarball}",
    target  => "/opt/tomcat",
    creates => "/opt/tomcat/${tomcat_current_version}",
    require => File["/opt/tomcat"],
  }

  #
  # Tomcat Setup and Dependencies
  #
  package { "java-1.7.0-openjdk.${::hardwaremodel}":
    ensure => installed,
  }

  file { '/opt/tomcat/active':
    ensure  => symlink,
    target  => "/opt/tomcat/${tomcat_current_version}",
    require => Staging::Extract[$tomcat_tarball],
  }

  file { '/opt/tomcat':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0644,
  }

  file { '/etc/init.d/tomcat':
    mode    => '0755',
    source  => 'puppet:///modules/tomcat/tomcat-init-script',
    require => File['/opt/tomcat/active'],
  }

  file { "/usr/bin/stop_tomcat":
    ensure => present,
    mode   => '0755',
    source => 'puppet:///modules/tomcat/stop_tomcat.sh',
  }

  service { 'tomcat':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => '/usr/bin/stop_tomcat && sleep 3 && /etc/init.d/tomcat start',
    subscribe => [
                   File['/opt/tomcat/active'],
                   Package["java-1.7.0-openjdk.${::hardwaremodel}"]
                 ],
    require   => [
                   File['/usr/bin/stop_tomcat'],
                   File['/etc/init.d/tomcat'],
                 ],
  }

  #
  # War Defined Type dependencies
  #
  package { 'unzip':
    ensure => installed,
  }
  file { "${tomcat_stage_dir}/war":
    ensure => directory,
  }

  file { "${tomcat_target_dir}/apps":
    ensure       => directory,
    #purge        => true,
    #force        => true,
    #recurse      => true,
    #recurselimit => 1,
    backup       => false,
  }
}

