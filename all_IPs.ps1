$location = Get-Location
$file = "$location\all_IPs.csv"
if (Test-Path $file) {
    Remove-Item $file
} else {
    Write-Host ""
}

# Prompt the user to enter the start and end IP addresses for the range
$startIP = Read-Host "Enter the start IP address"
$endIP = Read-Host "Enter the end IP address"

# Convert the IP addresses to integer values for comparison
$startIPArray = $startIP.Split(".")
$endIPArray = $endIP.Split(".")
$startInt = [convert]::ToInt32($startIPArray[3], 10)
$endInt = [convert]::ToInt32($endIPArray[3], 10)

# Create empty lists to store successful and unsuccessful IP addresses
$IPs = @()

# Ping each IP address in the range
for ($i = $startInt; $i -le $endInt; $i++) {
    $currentIP = "$($startIPArray[0]).$($startIPArray[1]).$($startIPArray[2]).$i"
    Write-Host "Pinging $currentIP..."
    $ping = New-Object System.Net.NetworkInformation.Ping

    $pingReply = $ping.Send($currentIP)
    $hostname = ""
    if ($pingReply.Status -eq 'Success') {
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($currentIP).HostName
        } catch {
            Write-Host "No hostname found for $currentIP"
            $hostname = 'NOT AVAILABLE'
        }
        $IPs += [PSCustomObject]@{
            'IP Address' = $currentIP
            'Hostname' = $hostname
        }
    } else {
        $IPs += [PSCustomObject]@{
            'IP Address' = $currentIP
            'Hostname' = "FREE IP"
        }
    }
}

$IPs | Export-Csv -Path $file -NoTypeInformation