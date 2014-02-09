##  Parameter Class for Tomcat Module
#
class tomcat::params {
  $jenkins_version        = pick($::jenkins_version, '1.400')
  $jenkins_war_file       = pick($::jenkins_war_file, "jenkins-${jenkins_version}.war")
  $tomcat_version         = pick($::tomcat_version, '7.0.25')
  $tomcat_installer       = pick($::tomcat_installer, "apache-tomcat-${tomcat_version}.tar.gz")
  $architecture_real      = pick($::architecture_real, 'i586')
  $jdk_installer          = pick($::jdk_installer, "jdk-6u21-linux-${architecture_real}-rpm.bin")
  $war_source             = pick($::war_source, 'puppet:///files/tomcat')
  $tomcat_stage_dir       = pick($::tomcat_stage_dir, '/opt/tomcat/active')
  $tomcat_target_dir      = pick($::tomcat_target_dir, '/opt/tomcat/active')
  $catalina_home          = pick($::catalina_home, '/opt/tomcat/active')
  $tomcat_current_version = pick($::tomcat_current_version, "apache-tomcat-${tomcat_version}")
  $tomcat_tarball         = pick($::tomcat_tarball, "apache-tomcat-${tomcat_version}.tar.gz")
}

