Puppet::Type.type(:mysql_database).provide(:mysql) do
	desc "Use mysql as database."
	commands :mysqladmin => '/usr/bin/mysqladmin'
	commands :mysqlshow => '/usr/bin/mysqlshow'

	def create
		mysqladmin "create", @resource[:name]
	end
	def destroy
		mysqladmin "-f", "drop", @resource[:name]
	end
	def exists?
		if /\| #{@resource[:name]} /.match(mysqlshow)
			true
		else
			false
		end
	end
end

