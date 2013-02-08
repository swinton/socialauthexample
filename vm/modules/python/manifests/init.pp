class python() {
    file {"/home/vagrant/Build":
        ensure => directory,
        owner => "vagrant",
        group => "vagrant",
    }

    file {"/home/vagrant/Packages":
        ensure => directory,
        require => File['/home/vagrant/Build'],
        owner => "vagrant",
        group => "vagrant",
    }

    exec {"wget python27":
        command => "/usr/bin/wget http://python.org/ftp/python/2.7/Python-2.7.tgz -O /home/vagrant/Packages/Python-2.7.tgz",
        require => File['/home/vagrant/Packages'],
        creates => "/home/vagrant/Packages/Python-2.7.tgz",
    }

    exec {"tar xzf python27":
        command => "/bin/tar xzf /home/vagrant/Packages/Python-2.7.tgz -C /home/vagrant/Build",
        require => Exec['wget python27'],
        creates => "/home/vagrant/Build/Python-2.7",
    }

    exec {"configure python27":
        command => "/home/vagrant/Build/Python-2.7/configure",
        cwd => "/home/vagrant/Build/Python-2.7",
        creates => "/home/vagrant/Build/Python-2.7/Makefile",
        require => Exec['tar xzf python27'],
    }

    exec {"make python27":
        command => "/usr/bin/make",
        cwd => "/home/vagrant/Build/Python-2.7",
        creates => "/home/vagrant/Build/Python-2.7/python",
        require => Exec['configure python27'],
    }

    exec {"make altinstall":
        command => "/usr/bin/make altinstall",
        cwd => "/home/vagrant/Build/Python-2.7",
        creates => "/usr/local/bin/python2.7",
        require => Exec['make python27'],
    }

    exec {"install pip":
        command => "/usr/bin/apt-get install -y python-pip",
        creates => "/usr/bin/pip",
    }

    exec {"pip install virtualenv":
        command => "/usr/bin/pip install virtualenv",
        creates => "/usr/local/bin/virtualenv",
        require => Exec['install pip'],
    }

    exec {"pip install virtualenvwrapper":
        command => "/usr/bin/pip install virtualenv",
        creates => "/usr/local/bin/virtualenvwrapper.sh",
        require => Exec['install pip'],
    }
}