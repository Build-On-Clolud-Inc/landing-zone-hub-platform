param location string
param utcValue string = utcNow()

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInlineWithOutput'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '8.3'
    scriptContent: '''
    $charlist = [char]94..[char]126 + [char]65..[char]90 + [char]47..[char]57
    $PasswordProfile = ($charlist | Get-Random -count 66) -join ''
    Write-Output $PasswordProfile
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["text"] = $PasswordProfile
    '''
    arguments: '-name'
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
output result string = runPowerShellInlineWithOutput.properties.outputs.text
