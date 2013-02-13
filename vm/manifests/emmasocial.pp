# Quick and dirty setup

exec {'apt-update' :
        command => '/usr/bin/apt-get update',
} -> Package <| |>

exec {'apt-get install build-essential' :
        command => '/usr/bin/apt-get install -y build-essential bzip2 libbz2-dev libsqlite3-dev tcl tcl-dev tk tk-dev python-tk python3-tk',
} -> Package <| |>

class {'mysql' :
}

class {'redis':
    version => '2.6.5',
}

class {'python' :
}

class {'emmasocial' :
} <- Class['python']