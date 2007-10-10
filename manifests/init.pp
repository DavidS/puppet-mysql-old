# mysql.pp
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class mysql::server {

	package { "mysql-server":
		ensure => installed,
	}

	munin::plugin {
		[mysql_bytes, mysql_queries, mysql_slowqueries, mysql_threads]:
	}

	service { mysql:
		ensure => running,
		hasstatus => true,
		require => Package["mysql-server"],
	}

	# Collect all databases and users
	Mysql_database<<||>>
	Mysql_user<<||>>

}
