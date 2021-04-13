Function Get-KeyPress([string]$regexPattern='[ynq]', [string]$message=$null, [int]$timeOutMilliSeconds=0)
{
    $key = $null

    $Host.UI.RawUI.FlushInputBuffer() 

    if (![string]::IsNullOrEmpty($message))
    {
        Write-Host -NoNewLine $message
    }

    $counter = $timeOutMilliSeconds / 250
    while($key -eq $null -and ($timeOutMilliSeconds -eq 0 -or $counter-- -gt 0))
    {
        if (($timeOutMilliSeconds -eq 0) -or $Host.UI.RawUI.KeyAvailable)
        {                       
            $key_ = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,IncludeKeyUp")
            if ($key_.KeyDown -and $key_.Character -match $regexPattern)
            {
                $key = $key_                    
            }
        }
        else
        {
            Start-Sleep -m 250  # Milliseconds
        }
    }                       

    if (-not ($key -eq $null))
    {
        Write-Host -NoNewLine "$($key.Character)" 
    }

    if (![string]::IsNullOrEmpty($message))
    {
        Write-Host "" # newline
    }       

    return $(if ($key -eq $null) {$null} else {$key.Character})
}