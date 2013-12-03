class {
    'scs' :
        mysqld_options => {
            expire_logs_days => 7,
            max_binlog_size => '256M',
            server_id => 1024,
        }
        ;
}
