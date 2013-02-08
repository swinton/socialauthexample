class mysql() {

    package {'mysql-server':
            ensure => present,
        }

    package {'mysql-client':
            ensure => present,
        }

    service {'mysql':
            ensure => running,
            enable => true,
            require => Package['mysql-server'],
        }
}