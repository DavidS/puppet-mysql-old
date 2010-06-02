# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
	@doc = "Manage a database user."
	ensurable
	newparam(:name) do
		desc "The name of the user. This uses the 'username@hostname' form."
	end
	newproperty(:password_hash) do
		desc "The password hash of the user. Use mysql_password() for creating such a hash."
	end

	newparam(:defaults) do
		desc "A my.cnf file containing defaults to connect to the DB server"
		defaultto ""

		# TODO: only valid paths allowed
	end
end

