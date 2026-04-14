# Kakia

![kakia](https://upload.wikimedia.org/wikipedia/commons/d/d4/Jan_van_de_Hoecke_-_Hercule_entre_le_vice_et_la_vertu.jpg)

> [!Warning]
> Backup your data and your registry before.

## Table of content

- [Description](https://github.com/MikeHorn-git/Kakia#description)
- [Installation](https://github.com/MikeHorn-git/Kakia#installation)
- [Usage](https://github.com/MikeHorn-git/Kakia#usage)
- [Features](https://github.com/MikeHorn-git/Kakia#features)
- [Credits](https://github.com/MikeHorn-git/Kakia#credits)

## Installation

```bash
Invoke-WebRequest https://raw.githubusercontent.com/MikeHorn-git/Kakia/main/Kakia.psm1 -Outfile Kakia.psm1
Import-Module .\Kakia.psm1
```

## Usage

```pwsh
Get-Help Kakia

Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
Invoke-Kakia                      Function  Kakia                     Main entry point for Kakia module.
Invoke-KakiaAll                   Function  Kakia                     Runs full cleanup and system modification sequence.
Invoke-KakiaClean                 Function  Kakia                     Performs system artifact cleanup.
Invoke-KakiaDisable               Function  Kakia                     Disables selected Windows features and telemetry-related components.
```

## Features

- Clean

  - Chrome cache - history - session restore
  - DNS cache
  - Edge cache - history
  - Firefox cache - history
  - Internet Explorer cache - history - session restore
  - Last-Visited MRU
  - OpenSave MRU
  - Plug and Play logs
  - PowerShell history
  - Prefetch
  - Recent items
  - RecycleBin
  - Run command history
  - Shadow copies
  - Shellbags
  - Simcache
  - System Resource Usage Monitor
  - Tempory files
  - Thumbcache
  - USB history
  - User Assist
  - VPN cache
  - Windows Timeline

- Disable

  - Keylogger
  - NTFS Last Acces Time
  - Prefetch
  - Shadow Copies
  - Shellbags
  - User Assist
  - UsnJrnl
  - Windows Event Logs
  - Windows Timeline

- Remove

  - Cortana

## Credits

- [Awesome anti-forensic](https://github.com/shadawck/awesome-anti-forensic)
- [Background](https://wallpapercave.com/wp/wp3438728.jpg)
- [Sans Forensics](https://www.sans.org/posters/windows-forensic-analysis/)
