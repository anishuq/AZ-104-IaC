$projectRoot = Read-Host "Enter the name for the new project "

if (Test-Path -Path $projectRoot) {
    Write-Host "Project directory '$projectRoot' already exists. Aborting." -ForegroundColor Red
    exit
}

$projectSubdirectories = @("$projectRoot/architecture", 
                            "$projectRoot/scripts", 
                            "$projectRoot/screenshots", 
                            "$projectRoot/docs")



foreach ($subdir in $projectSubdirectories) {
    New-Item -ItemType Directory -Path $subdir -Force
}

New-Item -ItemType File -Path "$projectRoot/README.md" -Force
New-Item -ItemType File -Path "$projectRoot/lessons-learned.md" -Force