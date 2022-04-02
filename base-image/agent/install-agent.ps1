#!/bin/pwsh

[CmdletBinding()] 
param(
  [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
  [string] $pathAgent = "~/agent",
  [Parameter(Position = 1, Mandatory, ValueFromPipeline)]
  [string] $targetArchPlataform = "linux-x64",
  [Parameter(Position = 2, Mandatory, ValueFromPipeline)]
  [string] $urlYourDevOps = "https://dev.azure.com/yourdevops",
  [Parameter(Position = 3, Mandatory, ValueFromPipeline)]
  [string] $patYourDevOps = "jyczbexxxxxxxxxxxxxxxxxxx"
)


Set-Item -Path Env:TARGETARCH -Value $targetArchPlataform 
Set-Item -Path Env:AZP_URL -Value $urlYourDevOps
Set-Item -Path Env:AZP_PAT -Value $patYourDevOps 



Write-Host "Starting: $($MyInvocation.MyCommand.Definition)"

if (-not (Test-Path $pathAgent)) {
  New-Item $pathAgent -ItemType directory | Out-Null
}
  
Set-Location $pathAgent


if (-not (Test-Path $pathAgent/bin/Agent.Listener.dll)) {
    
  ##[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
  $Method = "GET"
  $ApiUrl = "$env:AZP_URL/_apis/distributedtask/packages/agent?platform=$env:TARGETARCH&top=1"

  Write-Host "Downloading Azure Pipelines agent... $ApiUrl" -ForegroundColor Cyan

  $Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $env:AZP_PAT)))

  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Basic $Base64AuthInfo")


  $objRetorno = Invoke-RestMethod -Uri $ApiUrl `
    -Method $Method `
    -ContentType "application/json" `
    -Headers $headers
  #-Proxy $WebProxy.Address.OriginalString


  Invoke-WebRequest `
    -Uri $objRetorno.value[0].downloadUrl `
    -OutFile $objRetorno.value[0].filename

   
  tar -xvzf $objRetorno.value[0].filename -C $pathAgent

  Remove-Item -Path $objRetorno.value[0].filename
   
}
else {
  Write-Host "Agent is already installed... $pathAgent/bin/Agent.Listener.dll"
}
