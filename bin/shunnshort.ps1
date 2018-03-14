param([string]$infile, [string]$outfile)

# Perhaps: https://www.powershellgallery.com/packages/Pscx/3.3.2

# https://stackoverflow.com/questions/34559553/create-a-temporary-directory-in-powershell
function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

# Figure out where everything is
$ShunnShortStoryDir=Join-Path $PSScriptRoot "..\shunn\short"

# Create a temporary data directory
# Set it in the environment for lua scripts.
echo "Creating temporary directory."
$env:PANDOC_DATA_DIR=New-TemporaryDirectory
echo "Directory created: $env:PANDOC_DATA_DIR"

# Copy template and reference directories
Write-Output "Copying $ShunnShortStoryDir\template to $env:PANDOC_DATA_DIR\reference."
Copy-Item -Path $ShunnShortStoryDir\template $env:PANDOC_DATA_DIR\reference -Recurse
Write-Output "Template copied."

# Run pandoc
Write-Output "Running Pandoc."
pandoc $infile --from markdown --to docx --lua-filter $ShunnShortStoryDir/shunnshort.lua --data-dir $env:PANDOC_DATA_DIR --output $outfile
Write-Output "Pandoc completed successfully."

# Clean up the temporary directory
Write-Output "Removing $env:PANDOC_DATA_DIR"
Remove-Item $env:PANDOC_DATA_DIR -Recurse
Write-Output "Done."
