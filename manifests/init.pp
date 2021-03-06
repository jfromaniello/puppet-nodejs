class nodejs ( $version, $logoutput = 'on_failure' ) {

  if ! defined(Package['curl']) {
    package { 'curl':
      ensure => present,
    }
  }


  case $operatingsystem {
    centos, redhat: {
      $libssl_dev_pkgname = 'openssl-devel'
      exec { 'yum Group Install':
        unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
        command => '/usr/bin/yum -y groupinstall "Development tools"',
        before => Exec['nave']
      }
    }
    debian, ubuntu: {
      $libssl_dev_pkgname = 'libssl-dev'
      package { 'build-essential':
        ensure => present,
        before => Exec['nave']
      }
    }
    default: { fail("Unrecognized operating system for webserver") }
  }

  package { 'libssl-dev':
    name   => $libssl_dev_pkgname,
    ensure => present,
  }

  file { '/usr/local/bin/nave':
    source => "puppet:///modules/nodejs/nave.sh",
    mode   => 'ugo=rx'
  }

  # use nave, yo
  exec { 'nave' :
    command     => "nave usemain $version",
    path        => [ "/usr/local/bin", "/bin" , "/usr/bin" ],
    require     => [ Package[ 'curl' ], Package[ 'libssl-dev' ], File['/usr/local/bin/nave'] ],
    environment => [ 'HOME=""', 'PREFIX=/usr/local/lib/node', 'NAVE_JOBS=1' ],
    logoutput   => $logoutput,
    timeout     => 0,
    unless      => "test \"v$version\" = \"\$(node -v)\""
  }

}
