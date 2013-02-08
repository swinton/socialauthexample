class emmasocial() {
    file {"/home/vagrant/.virtualenvs":
        ensure => directory,
        owner => "vagrant",
        group => "vagrant",
    }

    exec{"virtualenv":
        command => "virtualenv -p /usr/local/bin/python2.7 --distribute --no-site-packages emmasocial",
        path => "/usr/local/bin",
        cwd => "/home/vagrant/.virtualenvs",
        creates => "/home/vagrant/.virtualenvs/emmasocial/bin/activate",
        user => "vagrant",
        require => File["/home/vagrant/.virtualenvs"],
    }

    exec{"pip install requirements":
        command => "pip install -r requirements.txt",
        path => "/home/vagrant/.virtualenvs/emmasocial/bin",
        cwd => "/home/vagrant/emmasocial",
        user => "vagrant",
        require => Exec["virtualenv"],
    }

    # TODO:
    # Auto-activate virtualenv (cat > .bashrc)
    # Install mysql-python
    # Run syncdb
    # ...
}