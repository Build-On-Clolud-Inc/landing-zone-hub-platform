@description('The location of the VM.')
param location string

// NIC Params
@description('Network Interface name')
param nicName string

@description('Id of Network Subnet')
param subnetId string

// VM Params
@description('Virtual machine name')
param vmName string

@description('Virtual machine size')
param vmSize string

@description('Virtual machine admin username')
param adminUsername string

@secure()
@minLength(8)
@description('Virtual machine admin password')
param adminPasswordOrPublicKey string

@description('Select the authentication type: (Password for Windows and SSH Public Key for Linux)')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrPublicKey
      }
    ]
  }
}

@description('Select the OS type to deploy:')
@allowed([
  'Windows'
  'Linux'
])
param operatingSystem string

@description('The OS version (SKU):') 
@allowed([ 
'win10' 
'winServer19' 
'ubuntu2004' 
'ubuntu2004gen2' 
]) 
param operatingSystemSKU string 

@description('According SKU following config will set')
var osImageReference = {
  win10: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: '21h1-pron-g2'
    version: 'latest'
  }
  winServer19: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-Datacenter'
    version: 'latest'
  }
  ubuntu2004: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts'
    version: 'latest'
  }
  ubuntu2004gen2: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
}


@allowed([
  'Dynamic'
  'Static'
])
@description('IP Allocation method for NIC') 
param ipAllocationMethod string = 'Dynamic'

@description('Static IP Address') 
param staticIpAddress string = ''


param WorkspaceId string
param WorkspaceKey string

// https://github.com/Azure/bicep/issues/387
resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: ipAllocationMethod
          privateIPAddress: staticIpAddress
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrPublicKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: osImageReference[operatingSystemSKU].publisher
        offer: osImageReference[operatingSystemSKU].offer
        sku: osImageReference[operatingSystemSKU].sku
        version: osImageReference[operatingSystemSKU].version
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource VmLinuxLaw 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = if (operatingSystem == 'Linux') {
  name: 'OmsAgentForLinux'
  location: location  
  parent: vm
  properties:{
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.13'
    autoUpgradeMinorVersion: true
    settings:{
      workspaceId: WorkspaceId
      stopOnMultipleConnections: false
    }
    protectedSettings:{
      workspaceKey: WorkspaceKey 
    }
  }
}


resource VmWindowsLaw 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = if (operatingSystem == 'Windows') {
  name: 'MicrosoftMonitoringAgent'
  parent: vm
  location: location
  properties:{
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings:{
      workspaceId: WorkspaceId
    }
    protectedSettings:{
      workspaceKey: WorkspaceKey
    }
  }
}
