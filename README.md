A development container for a MySQL server.

Walkthrough
-----------

Provision a new base image called `scs-mysql`...

    git clone https://github.com/dpb587/scs-mysql.git
    cd scs-mysql/
    sudo docker build -t scs-mysql .

Create a couple new mount points, expose MySQL, and run it with the [`default`](./scs/config/default.pp) configuration...

    mkdir ~/docker-data/readme-mysqld-binlog
    mkdir ~/docker-data/readme-mysqld-data
    sudo docker run \
        -v "$HOME/docker-data/readme-mysqld-binlog":/scs/mnt/mysqld-binlog \
        -v "$HOME/docker-data/readme-mysqld-data":/scs/mnt/mysqld-data \
        -p 4567:3306 \
        scs-mysql

In a separate terminal, it's easier to finish setting things up after figuring out the full container ID...

    $ sudo docker ps
    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                    NAMES
    cae7ddace978        2f7c2fbe6f7e        /scs/scs/bin/run       6 seconds ago       Up 6 seconds        0.0.0.0:4567->3306/tcp   agitated_turing     
    $ sudo docker inspect cae7ddace978 | grep -E '"ID": "([^"]+)"' | sed -E 's/.*"ID": "([^"]+)".*/\1/'
    cae7ddace978e0c026600bd37e40875aaeb0d502e0349747f966df8dc3c96806

For example, run the `mysql_secure_installation` tool...

    $ sudo lxc-attach -n cae7ddace978e0c026600bd37e40875aaeb0d502e0349747f966df8dc3c96806 /usr/bin/mysql_secure_installation

Or adjust the root privileges...

    $ echo 'mysql -p -e "UPDATE mysql.user SET Host = \"%\" WHERE User = \"root\" AND Host NOT IN (\"localhost\", \"127.0.0.1\", \"::1\"); FLUSH PRIVILEGES;"' \
    | sudo lxc-attach -n cae7ddace978e0c026600bd37e40875aaeb0d502e0349747f966df8dc3c96806 /bin/bash

Or use `mysql` to login to the server from the host...

    $ mysql -h 127.0.0.1 -P 4567 -u root -p

Back in the `sudo docker run` command, press `Ctrl-C` to shutdown MySQL. If it will be reused, it's probably best to commit a new image from the container now that it's been configured...

    $ sudo docker commit cae7ddace978 scs-mysql-default
    a8c89c1066e440f6e381bbbfdef518dcea37f7286bb6815aa6c815d7e0d2ccbe

The container can easily be managed by a process manager like [supervisor](http://supervisord.org/) with a configuration like...

    command = docker run -v "$HOME/docker-data/readme-mysqld-binlog":/scs/mnt/mysqld-binlog -v "$HOME/docker-data/readme-mysqld-data":/scs/mnt/mysqld-data -p 4567:3306 scs-mysql-default
    startsecs = 10
