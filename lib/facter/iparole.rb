Facter.add(:iparole) do
  confine kernel: 'Linux'
  setcode do
    pkicfg = '/etc/pki/pki-tomcat/ca/CS.cfg'

    if File.exist? pkicfg
      data = Facter::Core::Execution.execute("cat #{pkicfg}")
      role = if data.gsub!(%r{ca.crl.MasterCRL.enableCRLUpdates=true}, '')
               'master'
             elsif data.gsub!(%r{ca.crl.MasterCRL.enableCRLUpdates=false}, '')
               'replica'
             else
               nil
             end
    else
      role = if (!File.exist? '/usr/sbin/ipactl') && (File.exist? '/usr/sbin/ipa-client-install')
               'client'
             else
               nil
             end
    end
    role
  end
end
