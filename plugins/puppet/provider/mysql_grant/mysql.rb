# A grant is either global or per-db. This can be distinguished by the syntax
# of the name:
# 	user@host => global
# 	user@host/db => per-db

Puppet::Type.type(:mysql_grant).provide(:mysql) do
	desc "Use mysql as database."

	commands :mysql => '/usr/bin/mysql'

	# this parses the
	def split_name(string)
		matches = /^([^@]*)@([^\/]*)(\/(.*))?$/.match(string).captures.compact
		case matches.length 
			when 2
				{
					:type => :user,
					:user => matches[0],
					:host => matches[1]
				}
			when 4
				{
					:type => :db,
					:user => matches[0],
					:host => matches[1],
					:db => matches[3]
				}
		end
	end

	def create
		name = split_name(@resource[:name])
		case name[:type]
		when :user
			mysql "mysql", "-e", "INSERT INTO user (host, user, %s) VALUES ('%s', '%s', %s)" % [
				@resource.should(:privileges).join(","),
				name[:host], name[:user],
				@resource.should(:privileges).map do |m| "'Y'" end.join(",")
			]
		when :db
			mysql "mysql", "-e", "INSERT INTO db (host, user, db, %s) VALUES ('%s', '%s', '%s', %s)" % [
				@resource.should(:privileges).join(","),
				name[:host], name[:user], name[:db],
				@resource.should(:privileges).map do |m| "'Y'" end.join(",")
			]
		end
	end
	def destroy
		#mysql "mysql", "-e", "REVOKE %s ON '%s'.* FROM '%s@%s'" % [ @resource[:privileges], @resource[:database], @resource[:name], @resource[:host] ]
	end
	
	def exists?
		name = split_name(@resource[:name])
		fields = [:user, :host]
		if name[:type] == :db
			fields << :db
		end
		mysql( "mysql", "-Be", 'SELECT user FROM %s WHERE %s' % [ name[:type], fields.map do |f| "%s = '%s'" % [f, name[f]] end.join(' AND ')])
	end

	def privileges 
		name = split_name(@resource[:name])
		privs = ""

		case name[:type]
		when :user
			privs = mysql "mysql", "-Be", 'select * from user where user="%s" and host="%s"' % [ name[:user], name[:host] ]
		when :db
			privs = mysql "mysql", "-Be", 'select * from db where user="%s" and host="%s" and db="%s"' % [ name[:user], name[:host], name[:db] ]
		end

		if privs.match(/^$/) 
			privs = [] # no result, no privs
		else
			# returns a line with field names and a line with values, each tab-separated
			privs = privs.split(/\n/).map! do |l| l.chomp.split(/\t/) end
			# transpose the lines, so we have key/value pairs
			privs = privs[0].zip(privs[1])
			privs = privs.select do |p| p[0].match(/_priv$/) and p[1] == 'Y' end
		end

		privs.collect do |p| symbolize(p[0].downcase) end
	end

	def privileges=(privs) 
		user_privs = [ :select_priv, :insert_priv, :update_priv, :delete_priv,
			:create_priv, :drop_priv, :reload_priv, :shutdown_priv,
			:process_priv, :file_priv, :grant_priv, :references_priv,
			:index_priv, :alter_priv, :show_db_priv, :super_priv,
			:create_tmp_table_priv, :lock_tables_priv, :execute_priv,
			:repl_slave_priv, :repl_client_priv, :create_view_priv,
			:show_view_priv, :create_routine_priv, :alter_routine_priv,
			:create_user_priv ]

		db_privs = [ :select_priv, :insert_priv, :update_priv, :delete_priv,
			:create_priv, :drop_priv, :grant_priv, :references_priv,
			:index_priv, :alter_priv, :create_tmp_table_priv, :lock_tables_priv,
			:create_view_priv, :show_view_priv, :create_routine_priv,
			:alter_routine_priv, :execute_priv ]

		begin

				  puts "Setting privs: ", privs.join(", ")
		name = split_name(@resource[:name])
		stmt = ''
		where = ''
		all_privs = []
		case name[:type]
		when :user
			stmt = 'update user set '
			where = ' where user="%s" and host="%s"' % [ name[:user], name[:host] ]
			all_privs = user_privs
		when :db
			stmt = 'update db set '
			where = ' where user="%s" and host="%s"' % [ name[:user], name[:host] ]
			all_privs = db_privs
		end
	
		puts "stmt:", stmt
		set = all_privs.collect do |p| "%s = '%s'" % [p, privs.include?(p) ? 'Y' : 'N'] end.join(', ')
		puts "set:", set
		stmt = stmt << set << where

		mysql "mysql", "-Be", stmt
		rescue NoMethodError => detail
			puts detail.backtrace
			puts detail.to_s
		end
	end
end

