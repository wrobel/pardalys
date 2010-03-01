# Determine if these are regular files

package_use = '/etc/portage/package.use'

Facter.add('use_isfile') do
  setcode do
    if FileTest.file?(package_use)
      true
    else
      false
    end
  end
end

package_keywords = '/etc/portage/package.keywords'

Facter.add('keywords_isfile') do
  setcode do
    if FileTest.file?(package_keywords)
      true
    else
      false
    end
  end
end

package_mask = '/etc/portage/package.mask'

Facter.add('mask_isfile') do
  setcode do
    if FileTest.file?(package_mask)
      true
    else
      false
    end
  end
end

package_unmask = '/etc/portage/package.unmask'

Facter.add('unmask_isfile') do
  setcode do
    if FileTest.file?(package_unmask)
      true
    else
      false
    end
  end
end

package_license = '/etc/portage/package.license'

Facter.add('license_isfile') do
  setcode do
    if FileTest.file?(package_license)
      true
    else
      false
    end
  end
end
