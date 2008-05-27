module Puppet
  newtype(:overlay) do
    @doc = "Installs a new overlay in your Gentoo system."

    newparam(:name) do
      desc "The name of the overlay"
    end

    newproperty(:ensure) do
      desc "Whether the overlay is present or not."

      defaultto :installed

      def retrieve
        search = '^\* ' + resource[:name] + ' '
	overlays = `/usr/bin/layman -l -N`
        overlays.match(search) ? :installed : :missing
      end

      newvalue :missing
      newvalue :installed do
        add = "/usr/bin/layman -a " + resource[:name]
        system(add)
      end
    end
  end
end
