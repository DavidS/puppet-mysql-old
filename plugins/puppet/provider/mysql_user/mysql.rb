Puppet::Type.type(:mysql_user).provide(:mysql) do
	desc "Use mysql as database."
	commands :mysql => '/usr/bin/mysql'

	def create
		mysql "mysql", "-e", "create user '%s@%s' identified by '%s'" % [ @resource[:name], @resource[:host], @resource[:password] ]
	end
	def destroy
		mysql "mysql", "-e", "drop user '%s@%s'" % [ @resource[:name], @resource[:host] ]
	end
	def exists?
		if /^#{@resource[:name]}@#{@resource[:host]}$/.match( mysql( "mysql", "-Be", 'SELECT CONCAT(user, "@", host) FROM user' ) )
			true
		else
			false
		end
	end

	def password_hash
		mysql("mysql", "-NBe", "select password from user where user='#{@resource[:name]}' and host='#{@resource[:host]}'").chomp
	end

	def password_hash=(string)
		mysql "mysql", "-e", "SET PASSWORD FOR '#{@resource[:name]}'@'#{@resource[:host]}' = '#{string}'"
	end
end

