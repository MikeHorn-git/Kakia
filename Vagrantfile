# frozen_string_literal: true

Vagrant.configure('2') do |config|
  ENV['LC_ALL'] = 'en_US.UTF-8'
  config.vm.box = 'gusztavvargadr/windows-11'
  config.vm.box_version = '2601.0.0'

  config.vm.boot_timeout = 1000
  config.vm.hostname = 'host'

  config.vm.network 'private_network', type: 'dhcp'
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = '8192'
    libvirt.cpus = '8'
    libvirt.default_prefix = 'Windows11'
    libvirt.storage_pool_name = 'default'
    libvirt.qemu_use_session = false
    libvirt.keymap = 'en-us'
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '8192'
    vb.cpus = '6'
    vb.name = 'Windows11'
    vb.gui = false
    vb.check_guest_additions = false
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end

  config.vm.provider 'vmware_desktop' do |vmware|
    vmware.memory = '8192'
    vmware.cpus = '6'
    vmware.gui = false
    vmware.utility_certificate_path = '/opt/vagrant-vmware-desktop/certificates'
  end

  config.vm.provision 'shell', inline: <<-POWERSHELL
    powershell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider NuGet -Force"
    powershell.exe -ExecutionPolicy Bypass -Command "Install-PackageProvider NuGet -Force"
    powershell.exe -ExecutionPolicy Bypass -Command "Install-Module PSScriptAnalyzer -Force -AllowClobber -Scope CurrentUser"
    powershell.exe -ExecutionPolicy Bypass -Command "Get-Module -ListAvailable PSScriptAnalyzer"
  POWERSHELL
end
