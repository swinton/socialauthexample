class mysql() {

    package {'mysql-server':
        ensure => present,
    }

    package {'mysql-client':
        ensure => present,
    }

    package {'libmysqlclient-dev':
        ensure => present,
    }

    service {'mysql':
        ensure => running,
        enable => true,
        require => Package['mysql-server'],
    }

    # Allow access to MySQL from host...

    # Backup my.cnf
    file {'/etc/mysql/my.original.cnf':
        ensure => present,
        source => '/etc/mysql/my.cnf',
        require => Package['mysql-server'],
    }

    # Edit my.cnf, updated bind-address to 0.0.0.0
    exec {'modify-bind-address':
        command => 'sed "s/\\(bind-address.*\\)127.0.0.1/\\10.0.0.0/g" /etc/mysql/my.original.cnf > /etc/mysql/my.cnf',
        path => '/bin',
        require => File['/etc/mysql/my.original.cnf'],
        notify => Service['mysql'],
    }

    # Grant all on *.* to root, restart mysql service
    exec {"mysql-grant-all":
        command => "mysql -u root -e \"grant all on *.* to root@'%.%.%.%'; flush privileges\" mysql",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        user => "vagrant",
        require => Service["mysql"],
    }
}