err("Change DELETE to UPDATE privilege for test_user@%/test_user")

mysql_grant {
	"test_user@%/test_user":
		privileges => [ "select_priv", 'insert_priv', 'update_priv'],
}


