# Create a uniquely named folder to simplify keeping related documents together.
# Different types of tickets are offered. Each type has a different
# template that determines what is initially populated in the new folder.
# There is also a misc template that is copied to every new ticket folder.
#
# The types of new tickets that are offered is determined by the names
# of the directories in the templates folder. Only types/templates that are
# ready to be used should be listed in the template folder. Draft templates
# should be kept in a separate folder.
#
# There is no "other" type. Instead, the "misc" type based on the "misc"
# template folder name is used. Some branching is hard coded based on a 
# ticket type of "misc". Removing the misc template folder/ type option 
# without updating the code will result in errors.

$originalDirectory = Get-Location

# Set location to the script root. This will make relative paths easier.
Set-Location $PSScriptRoot

# Use the directory names in the templates directory as the source
# of ticket types. The names are converted to strings to make them easier
# work with.
$ticketTypes = [string []] (Get-ChildItem -Path $templatesDirectory -Directory)

$ticketsDirectory = "1-tickets"
$templatesDirectory = "templates"

While ($true) {
    Clear-Host
    Write-Host @'
*****************************
*         New Ticket        *
*****************************
'@
    
    $isValidInput = $false
    # Use numbered input instead of typing the full name of the ticket type
    $allowedInput = 0..($ticketTypes.Length - 1)

    While (-not $isValidInput) {
        for ($i = 0; $i -lt $ticketTypes.Length; $i++) {
                Write-Host "[$i] $($ticketTypes[$i])"
        }

        $userInput = Read-Host -Prompt "Choose ticket type or type 'exit'" 
        if ($userInput.ToLower() -eq 'exit') {
            exit   
        }    
 
        if ($userInput -notin $allowedInput) {
            Write-Host "Invaild option: $userInput. Please try again."
        } else {
            $isValidInput = $true
        }
    }          

    $ticketTopic = Read-Host -Prompt "Enter the topic"  
    if ($ticketTopic.ToLower() -eq 'exit') {
        exit
    }
    
    #Convert the number input to a string that decribes the type of ticket
    $ticketType = $ticketTypes[[int] $userInput]      
    
    # Build ticket name
    $index = [int] (Get-Content -Path "index.txt")
    $twoDigitYear = Get-Date -Format "yy"
    $ticketName = "" 

    if ($ticketType -ne "misc") { 
        $flair = $ticketType.ToUpper()
        $ticketName = "$twoDigitYear.$index.$flair - $ticketTopic"
        $templatePath = Join-Path -Path $templatesDirectory -ChildPath $ticketType
    } else {
        $ticketName = "$twoDigitYear.$index - $ticketTopic"
    }

    $ticketPath = Join-Path -Path $ticketsDirectory -ChildPath $ticketName

    # Create the new directory
    New-Item -Path $ticketsDirectory -Name $ticketName -ItemType Directory | Out-Null
        

    # Copy the misc template directory
    $miscTempaltePath = Join-Path -Path $templatesDirectory -ChildPath "misc"
    Copy-Item -Path $miscTempaltePath -Destination $ticketPath -Recurse

    # Copy the appropriate template folder, if applicable
    if ($ticketType -ne "misc") {
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

# Return the shell to the original location before exiting.
Set-Location $originalDirectory
