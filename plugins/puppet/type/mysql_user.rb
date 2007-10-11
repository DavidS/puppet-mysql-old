# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
	@doc = "Manage a database user."
	ensurable
	newparam(:name) do
		desc "The name of the user."
	end
	newparam(:host) do
		desc "The host from where to connect."
	end
	newproperty(:password_hash) do
		desc "The password hash of the user. Use mysql_password() for creating such a hash."
	end
end

