#Requires -Version 5.1

#################################################################################
#MIT License                                                                    #
#                                                                               #
#Copyright (c) 2023-2026 MikeHorn-git                                           #
#                                                                               #
#Permission is hereby granted, free of charge, to any person obtaining a copy	#
#of this software and associated documentation files (the "Software"), to deal	#
#in the Software without restriction, including without limitation the rights	#
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
#copies of the Software, and to permit persons to whom the Software is          #
#furnished to do so, subject to the following conditions:                       #
#                                                                               #
#The above copyright notice and this permission notice shall be included in all	#
#copies or substantial portions of the Software.                                #
#                                                                               #
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE	#
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,	#
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE	#
#SOFTWARE.                                                                      #
#################################################################################

<#
.SYNOPSIS
Windows anti-forensics module.

.DESCRIPTION
Provides cleanup and system modification functions.

.PARAMETER All
Runs both cleanup and disable operations.

.PARAMETER Clean
Performs cleanup actions only.

.PARAMETER Disable
Applies system feature changes only.

.EXAMPLE
Import-Module .\Kakia.psm1
Invoke-Kakia -Clean

Description
---------------------------------------
Perform cleaning.

.NOTES
Requires Administrator privileges.

.OUTPUTS
None

.LINK
https://github.com/MikeHorn-git/Kakia.git
#>

# =========================
# ADMIN CHECK
# =========================
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# =========================
# PRIVATE HELPER
# =========================
function Remove-KakiaItems {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [hashtable]$Items
    )

    foreach ($itemKey in $Items.Keys) {
        $item = $Items[$itemKey]

        if ($null -ne $item) {
            try {
                if ($PSCmdlet.ShouldProcess($item, "Remove")) {
                    Remove-Item -Path $item -Recurse -Force -ErrorAction Stop
                }
                Write-Verbose "Removed: $item"
            }
            catch {
                Write-Warning "Failed to remove: $item - $_"
            }
        }
    }
}

<#
.SYNOPSIS
Performs system artifact cleanup.

.DESCRIPTION
Removes browser caches, temporary files, recent items, and user artifacts.

.EXAMPLE
Invoke-KakiaClean

.OUTPUTS
None
#>
function Invoke-KakiaClean {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $ItemsToRemove = @{
        ChromeCache = "$Home\AppData\Local\Google\Chrome\User Data\Default\Cache"
        ChromeHistory = "$Home\AppData\Local\Google\Chrome\User Data\Default\History"
        ChromeSessionRestore = "$Home\AppData\Local\Google\Chrome\User Data\Default"
        EdgeCache = "$Home\AppData\Local\Packages\microsoft.microsoftedge_*\AC\MicrosoftEdge\Cache"
        IEHistory = 'HKCU:\Software\Microsoft\Internet Explorer\TypedURLs'
        IEWebCache = "$Home\AppData\Local\Microsoft\Windows\WebCache\WebCacheV*.dat"
        FirefoxCache = "$Home\AppData\Local\Mozilla\Firefox\Profiles\*.default*\Cache"
        FirefoxHistory = "$Home\AppData\Roaming\Mozilla\Firefox\Profiles\*.default*\places.sqlite*"
        FirefoxSessionRestore = "$Home\AppData\Roaming\Mozilla\Firefox\Profiles\*.default*\sessionstore*"
        IECache = "$Home\AppData\Local\Microsoft\Windows\INetCache\IE"
        RecentItems = "$HOME\AppData\Roaming\Microsoft\Windows\Recent"
        RunMRU = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU'
        TempFiles = "C:\Windows\temp\*"
        PowerShellHistory = "$HOME\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    }

    Remove-KakiaItems -Items $ItemsToRemove
}

<#
.SYNOPSIS
Disables selected Windows features and telemetry-related components.

.DESCRIPTION
Modifies system settings including logging, telemetry services, and system tracking features.

.EXAMPLE
Invoke-KakiaDisable

.OUTPUTS
None
#>
function Invoke-KakiaDisable {
    [CmdletBinding(SupportsShouldProcess)]
     param (
        [switch]$Force
    )

    try {
        if ($PSCmdlet.ShouldProcess("System", "Apply disable actions")) {

            auditpol /set /subcategory:"Filtering Platform Connection" /success:disable /failure:enable > $null

            Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppPackage

            ipconfig /flushdns | Out-Null

            fsutil behavior set disablelastaccess 3 > $null

            Clear-RecycleBin -Force

            Stop-Service -Name DiagTrack -Force
            Set-Service -Name DiagTrack -StartupType Disabled

            Stop-Service -Name dmwappushservice -Force
            Set-Service -Name dmwappushservice -StartupType Disabled

            Get-Service CDPUserSvc* -ErrorAction SilentlyContinue | Stop-Service -Force

            "" | Out-File "C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl" -ErrorAction SilentlyContinue

            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'NtfsDisableLastAccessUpdate' -Value 1 -Force

            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name 'EnablePrefetcher' -Value 0 -Force
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name 'EnableSuperfetch' -Value 0 -Force

            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\' -Name 'DisableLocalPage' -Value 1 -Force

            Set-ItemProperty -Path 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell' -Name 'BagMRU Size' -Value 1 -Force

            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name 'Start_TrackProgs' -Value 0 -Force
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name 'Start_TrackEnabled' -Value 0 -Force

            wevtutil el 2>$null | ForEach-Object {
                try {
                    wevtutil cl "$_" 2>$null
                } catch {
                    Write-Verbose "Failed log: $($_)"
                }
            }

            if ($Force) {
                fsutil usn deletejournal /d c:
                Stop-Service -Name EventLog -Force
                Set-Service EventLog -StartupType Disabled
                vssadmin delete shadows /All
            } else {
                Write-Warning "Skipping EventLog service stop (use -Force to enable)"
            }

            Clear-History
        }
    }
    catch {
        Write-Error $_
    }
}

<#
.SYNOPSIS
Runs full cleanup and system modification sequence.

.EXAMPLE
Invoke-KakiaAntiForensics

.OUTPUTS
None
#>
function Invoke-KakiaAll {
    [CmdletBinding(SupportsShouldProcess)]
     param (
        [switch]$Force
    )

    Invoke-KakiaClean
    Invoke-KakiaDisable -Force:$Force
}

<#
.SYNOPSIS
Main entry point for Kakia module.

.DESCRIPTION
Executes cleanup, system modification, or both depending on parameters.

.PARAMETER All
Runs both cleanup and disable operations.

.PARAMETER Clean
Runs cleanup operations only.

.PARAMETER Disable
Runs system modification operations only.

.EXAMPLE
Invoke-Kakia -All

.EXAMPLE
Invoke-Kakia -Clean

.EXAMPLE
Invoke-Kakia -Disable

.OUTPUTS
None

.NOTES
Requires Administrator privileges.
#>
function Invoke-Kakia {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [switch]$All,
        [switch]$Clean,
        [switch]$Disable,
        [switch]$Force
    )

    if (-not (Test-IsAdmin)) {
        throw "Run PowerShell as Administrator."
    }

    if ($All) {
        Invoke-KakiaAll -Force:$Force
    }
    elseif ($Clean) {
        Invoke-KakiaClean
    }
    elseif ($Disable) {
        Invoke-KakiaDisable -Force:$Force
    }
    else {
        Write-Information "Usage: Invoke-Kakia -All | -Clean | -Disable"
    }
}

Export-ModuleMember -Function Invoke-Kakia
