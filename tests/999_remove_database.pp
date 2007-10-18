
err("Will remove 'test_db' again")
mysql_database { "test_db": ensure => absent }

