# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_grant) do
	@doc = "Manage a database user's rights."
	ensurable
	newparam(:name) do
		desc "The primary key: either user@host for global privilges or user@host/database for database specific privileges"
	end
	newproperty(:privileges, :array_matching => :all) do
		desc "The privileges the user should have. The possible values are implementation dependent."
		munge do |v|
			symbolize(v)
		end
	end
end

