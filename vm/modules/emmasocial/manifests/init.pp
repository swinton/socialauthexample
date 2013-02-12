class emmasocial() {
    $bashrc_auto_activate_virtualenv = "\\n# auto-activate virtualenv\\nsource .virtualenvs/emmasocial/bin/activate\\n"

    file {"/home/vagrant/.virtualenvs":
        ensure => directory,
        owner => "vagrant",
        group => "vagrant",
    }

    exec {"heroku-toolbelt":
        command => "wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh",
        creates => "/usr/bin/heroku",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
    }

    exec {"virtualenv":
        command => "virtualenv -p /usr/local/bin/python2.7 --distribute --no-site-packages emmasocial",
        path => "/usr/local/bin",
        cwd => "/home/vagrant/.virtualenvs",
        creates => "/home/vagrant/.virtualenvs/emmasocial/bin/activate",
        user => "vagrant",
        require => File["/home/vagrant/.virtualenvs"],
    }

    exec {"auto-activate virtualenv":
        command => "echo '$bashrc_auto_activate_virtualenv' | cat >> .bashrc",
        path => "/bin",
        cwd => "/home/vagrant",
        unless => "grep -q 'auto-activate virtualenv' .bashrc",
        user => "vagrant",
        require => Exec["virtualenv"],
    }

    exec {"pip install requirements":
        command => "pip install -r requirements.txt",
        path => "/home/vagrant/.virtualenvs/emmasocial/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        cwd => "/home/vagrant/emmasocial",
        user => "vagrant",
        require => Exec["virtualenv"],
    }

    exec {"easy_install ipython":
        command => "easy_install http://archive.ipython.org/release/0.12.1/ipython-0.12.1-py2.7.egg",
        path => "/home/vagrant/.virtualenvs/emmasocial/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        user => "vagrant",
        require => Exec["virtualenv"],
    }

    exec {"mysql create database":
        command => "mysql -u root -e \"create database if not exists emmasocial default character set = 'utf8'\"",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        user => "vagrant",
        require => Exec["pip install requirements"],
    }

    exec {"syncdb":
        command => "manage.py syncdb --noinput",
        path => "/home/vagrant/emmasocial/src:/home/vagrant/.virtualenvs/emmasocial/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        user => "vagrant",
        require => Exec["mysql create database"],
    }

    exec {"migrate":
        command => "manage.py migrate emmasocial",
        path => "/home/vagrant/emmasocial/src:/home/vagrant/.virtualenvs/emmasocial/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin",
        user => "vagrant",
        require => Exec["syncdb"],
    }
}