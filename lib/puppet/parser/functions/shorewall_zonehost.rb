#
# shorewall_zonehost.rb
#

module Puppet::Parser::Functions
  newfunction(:shorewall_zonehost, :type => :rvalue, :doc => <<-EOT
    This function joins an array of hosts with ',' prefixing the given zone name.

    EOT
  ) do |arguments|
    raise(Puppet::ParseError, "shorewall_zonehost(zone, hosts): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    zone = arguments[0]
    raise(Puppet::ParseError, "shorewall_zonehost(zone, hosts): Requires zone to be a string (is #{zone.class} => #{zone})") unless zone.is_a?(String)

    # load required functions
    Puppet::Parser::Functions.autoloader.load(:hostname2ip) unless Puppet::Parser::Functions.autoloader.loaded?(:hostname2ip)

    hosts = [arguments[1]].flatten.uniq
    hosts.delete_if { |host| host == nil }
    if hosts.empty?
      return zone
    else
      hosts.collect! { |host| function_hostname2ip([host]) }
      joinedhosts = hosts.uniq.sort.join(',').strip
      return "#{zone}:#{joinedhosts}"
    end
  end
end

# vim: set ts=2 sw=2 et :
