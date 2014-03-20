class scs (
    $serverid = '',
    $mysqld_options = {},
) {
    file {
        '/usr/bin/scs-runtime-hook-start' :
            ensure => file,
            source => 'puppet:///modules/scs/scs-runtime-hook-start',
            owner => root,
            group => root,
            mode => 0755,
            ;
    }

    exec {
        'apt-source:percona:key' :
            command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C4CBDCDCD2EFD2A',
            ;
        'apt-source:percona' :
            command => '/bin/echo "deb http://repo.percona.com/apt precise main" >> /etc/apt/sources.list',
            unless => '/bin/grep "deb http://repo.percona.com/apt precise main" /etc/apt/sources.list',
            require => [
                Exec['apt-source:percona:key'],
            ],
            ;
        'apt-update' :
            command => '/usr/bin/apt-get update',
            require => [
                Exec['apt-source:percona'],
            ],
            ;
    }

    file {
        "/etc/mysqld" :
            ensure => directory,
            ;
        "/etc/mysqld/mysqld.ini" :
            ensure => file,
            content => template('scs/mysqld/mysqld.ini.erb'),
            require => [
                Package['percona-server-server-5.6'],
            ],
            ;
        "/etc/supervisor.d/mysqld.conf" :
            ensure => file,
            content => template('scs/mysqld/supervisor.conf.erb'),
            ;
        "/var/log/mysqld" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            require => [
                Package['percona-server-server-5.6'],
            ],
            ;
        "/var/run/mysqld" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            require => [
                Package['percona-server-server-5.6'],
            ],
            ;
    }

    package {
        'percona-server-server-5.6' :
            ensure => installed,
            require => [
                Exec['apt-source:percona'],
                Exec['apt-update'],
            ],
            ;
    }
}
