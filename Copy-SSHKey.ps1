# Attempts to est up SSH Key Id, or whatever

$keyfile = "~\.ssh\id_rsa.pub";

$cred = $Args[0].Split("@");

if ( Test-Path -Path $keyfile ) 
{
    $session = New-PSSession -HostName $cred[1] -UserName $cred[0];
    $key = Get-Content -Path $keyfile;

    Invoke-Command -Session $session -ScriptBlock { 
        # make sure the .ssh dir exists
        if (!( Test-Path -Path ~/.ssh )) {
            New-Item -Path ~/.ssh -ItemType Directory;
            Invoke-Command -Session $session -ScriptBlock { 
                chmod 700 ~/.ssh
            }
        }
        # copy the key
        Invoke-Command -Session $session -Args $key -ScriptBlock {
            param([string] $key) Out-File -FilePath ~/.ssh/authorized_keys -Append -InputObject $key
        }
        # set some permissions
        Invoke-Command -Session $session -ScriptBlock {
            chmod 600 ~/.ssh/authorized_keys
        }
    }
}
else {
    Write-Host "You're going to need to create a key file. Run keygen.exe.";
}

