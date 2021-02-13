cp ./ ($env:psmodulepath.split(';')[0]) -Recurse -Force

. ./libraries/cmdlets.ps1
New-TaskletDatabase | Out-Null