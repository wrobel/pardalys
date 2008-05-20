# Taken from http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe
Facter.add("virtual") do
  confine :kernel => :linux
  
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  
  result = "physical"
  
  setcode do
    
    if FileTest.exists?("/proc/user_beancounters")
      result = "openvz"
    end

    # lspci exists on openvz but fails, so it must be checked first and this      check must not be run on openvz
    if result == "physical"
      lspciexists = system "which lspci >&/dev/null"
      if $?.exitstatus == 0
        output = %x{lspci}
        output.each {|p|
          # --- look for the vmware video card to determine if it is virtual =>vmware.
          # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
          result = "vmware" if p =~ /VMware/
        }
      end
    end

    # VMware server 1.0.3 rpm places vmware-vmx in this place, other versions or platforms may not.
    if FileTest.exists?("/usr/lib/vmware/bin/vmware-vmx")
      result = "vmware_server"
    end

    if FileTest.exists?("/proc/sys/xen/independent_wallclock")
      result = "xenu"
    elsif FileTest.exists?("/proc/xen/capabilities")
      txt = File.read("/proc/xen/capabilities")
      if txt =~ /control_d/i
        result = "xen0"
      end
    end

    mountexists = system "which mount >&/dev/null"
    if $?.exitstatus == 0
      output = %x{mount}
      output.each {|p|
        result = "vserver" if p =~ /\/dev\/hdv1/
      }
    end

    result
  end
end
