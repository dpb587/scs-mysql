You might need to connect to the latest container to initialize it:

         host$ lxc-attach -n $(docker ps -notrunc -q --latest)


You might need to initialize a container that has a new volume:

    container$ mysql_secure_installation
             > ...snip...


You might need to restore a database:

    container$ wget -qO- "$BACKUP_URL" | mysql -u root -ppassword dbname
