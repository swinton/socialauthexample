# Quick and dirty setup

exec {'apt-update' :
        command => '/usr/bin/apt-get update',
} -> Package <| |>

exec {'apt-get install build-essential' :
        command => '/usr/bin/apt-get install -y build-essential',
} -> Package <| |>

class {'mysql' :
}

class {'redis' :
}

class {'python' :
}

class {'emmasocial' :
} <- Class['python']