$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))
require 'facter'
require 'puppet/property/list'

Puppet::Type.newtype(:torque_node) do
  @doc = "Manage Torque nodes"

  feature :target_file, "The provider can specify node configuration file"
  feature :node_notes,  "The provider can modify node's notes"

  ensurable

  newparam(:name) do
    desc <<-EOT
      Torque node hostname. This is a network hostname
      of server running pbs_mom daemon.
    EOT

    isnamevar
  end

  newparam(:server_name) do
    desc <<-EOT
      Server FQDN
    EOT

    isrequired
  end

  newproperty(:np) do
    desc <<-EOT
      Processors count. Number of processors available for
      computation. Defaults to $::processorcount fact.
    EOT

    defaultto {
      Facter.value('processorcount')
    }

    validate do |value|
      unless Integer(value)>0
        raise ArgumentError, "Unsupported number of processors: #{value}"
      end
    end

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:num_node_boards) do
    desc <<-EOT
      NUMA nodes count.
    EOT

    validate do |value|
      unless Integer(value) >= 0
        raise ArgumentError, "Unsupported number of NUMA nodes: #{value}"
      end
    end

    munge do |value|
      Integer(value) 
    end
  end

  newproperty(:numa_board_str) do
    desc <<-EOT
      Non-uniform CPU distribution string.
    EOT

    validate do |value|
      String(value).split(",").each do |v|
        unless Integer(v) > 0
          raise ArgumentError, "Unsupported number of NUMA node processors: #{v}"
        end
      end
    end

    munge do |value|
      String(value)
    end
  end

  newproperty(:note, :required_features => :node_notes) do
    desc "Node note"

    munge do |value|
      String(value) 
    end
  end

  newproperty(:ntype) do
    desc <<-EOT
      Torque node type
    EOT

    defaultto 'cluster'

    newvalues('cluster','cloud','virtual','time-shared')
  end

  newproperty(:properties, :parent => Puppet::Property::List, :array_matching => :all) do
    desc "Node properties"

    defaultto []

    munge do |value|
      [value].flatten.map { |v| v.split(" ") }.flatten
    end

    def membership
      :membership
    end
  end

  newproperty(:target, :required_features => :target_file) do
    desc <<-EOT
      The file in which to store nodes information. Only used by those providers
      that write to disk. Usually defaults to `/var/spool/torque/server_priv/nodes`.
    EOT

    defaultto {
      if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
      else
        nil
      end
    }
  end

  newparam(:membership) do
    newvalues(:inclusive)
    defaultto :inclusive

    # "Minimum" membership doesn't work (don't know why),
    # if nodes aren't already in configuration files:
    # Error: /Stage[main]//Torque_node[test1.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test3.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test4.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test2.cerit-sc.cz]: Could not evaluate: stack level too deep
    # Error: /Stage[main]//Torque_node[test5.cerit-sc.cz]: Could not evaluate: stack level too deep
    #...
    #
    #newvalues(:inclusive, :minimum)
    #defaultto :minimum
  end
end
