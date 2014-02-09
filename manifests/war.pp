define tomcat::war(
  $war_source        = 'http://master/tomcat',
  $tomcat_stage_dir  = '/opt/staging/tomcat',
  $tomcat_target_dir = '/opt/tomcat/active',
  $filename
) {

  staging::file { "${tomcat_stage_dir}/war/${filename}":
    source  => "${war_source}/${filename}",
  }

  exec { "extract_${name}":
    command     => "unzip ${tomcat_stage_dir}/war/${filename} -d ${tomcat_target_dir}/apps/${filename}",
    path        => '/bin:/usr/bin',
    refresh     => "rm -Rf ${tomcat_target_dir}/apps/${filename} && unzip ${tomcat_stage_dir}/war/${filename} -d ${tomcat_target_dir}/apps/${filename}",
    require     => [File["${tomcat_target_dir}/apps"], Package['unzip']],
    subscribe   => [
      Staging::File["${tomcat_stage_dir}/war/${filename}"],
      File[$tomcat_stage_dir],
      File["${tomcat_target_dir}/webapps/${name}"],
    ], 
    refreshonly => true,
    notify      => Service['tomcat'],
  }

  file { "${tomcat_target_dir}/apps/${filename}":
    ensure => directory,
  }

  file { "${tomcat_target_dir}/webapps/${name}":
    ensure  => symlink,
    target  => "${tomcat_target_dir}/apps/${filename}",
    require => File["${tomcat_target_dir}/apps/${filename}"],
    notify  => Service['tomcat'],
  }
}

