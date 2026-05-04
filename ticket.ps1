# Configuration
$ticketsDirectory = "1-tickets"
$templatesDirectory = "templates"

$ticketTypes = @(
    "pvsr"
    "cmpl"
    "other"
)

# Application code
$originalDirectory = $PWD

While ($true) {
    Clear-Host
    Write-Host @'
*****************************
*         New Ticket        *
*****************************
'@
    
    $isValidInput = $false
    $allowedInput = 0..($ticketTypes.Length - 1) + 'exit'

    While (-not $isValidInput) {
        for ($i = 0; $i -lt $ticketTypes.Length; $i++) {
                Write-Host "[$i] $($ticketTypes[$i])"
        }

        $userInput = Read-Host -Prompt "Choose ticket type or type 'exit'"    
 
        if ($userInput -notin $allowedInput) {
            Write-Host "Invaild option: $userInput. Please try again."
        } else {
            $isValidInput = $true
        }
    }    
        
    if ($userInput -eq 'exit') {
        exit
    } elseif ([int] $userInput -eq ($ticketTypes.Length - 1)) {
        $ticketType = ""
    } else {
        $ticketType = $ticketTypes[[int] $userInput]
        $templatePath = Join-Path -Path $templatesDirectory -ChildPath $ticketType
    }

    $ticketTopic = Read-Host -Prompt "Enter the topic"
    
    # Set location to the script root. This will make relative
    # paths easier.
    Set-Location $PSScriptRoot
    $workingDirectory = pwd

    # Build ticket name
    $index = [int] (Get-Content -Path "index.txt")
    $twoDigitYear = Get-Date -Format "yy"
    $ticketName = ""
    if ($ticketType -eq "") {
        $ticketName = "$twoDigitYear.$index$ticketType - $ticketTopic"
    } else {
        $ticketName = "$twoDigitYear.$index.$ticketType - $ticketTopic"
    } 

    $ticketPath = Join-Path -Path $ticketsDirectory -ChildPath $ticketName

    # Create the new directory
    New-Item -Path $ticketsDirectory -Name $ticketName -ItemType Directory | Out-Null
    $miscTempaltePath = Join-Path -Path $templatesDirectory -ChildPath "misc"

    # Copy the misc template directory
    Copy-Item -Path $miscTempaltePath -Destination $ticketPath -Recurse
    # Copy the appropriate template folder, if applicable
    if ($ticketType -ne "") {
        Copy-Item -Path $templatePath -Destination $ticketPath -Recurse
    }

    $index++
    Set-Content -Path "index.txt" -Value $index

    # Output the information for the new ticket
    Write-Host ""
    Write-Host "New ticket created. Details below."
    Write-Host "Ticket name:"
    Write-Host "$ticketName"
    Set-Clipboard $ticketName
    Write-Host "The ticket name has been copied to the clipboard"
    Read-Host "Press <enter> to continue..."
    Write-Host ""
    Write-Host "Path to new folder:"
    Write-Host $(Resolve-Path $ticketPath)
    Set-Clipboard $(Resolve-Path $ticketPath)
    Write-Host "The full path to the new folder has been copied to the clipboard"
    Read-Host "Press <enter> to continue..."
}

# Return the shell to the original condition after exiting.
Set-Location $originalDirectory
