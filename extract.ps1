$src = 'C:\Users\shubh\Desktop\index.html'
$outDir = 'C:\Users\shubh\.gemini\antigravity\scratch\portfolio'

# Read the HTML
Write-Host "Reading index.html..."
$html = [IO.File]::ReadAllText($src)
Write-Host ("Original size: " + [math]::Round($html.Length / 1MB, 2) + " MB")

# Find all base64 jpeg occurrences
$regex = [regex]'data:image/jpeg;base64,([A-Za-z0-9+/=]+)'
$found = $regex.Matches($html)
Write-Host ("Found " + $found.Count + " base64 image(s)")

$counter = 1
foreach ($m in $found) {
    $b64 = $m.Groups[1].Value
    $bytes = [Convert]::FromBase64String($b64)
    $imgName = "photo.jpg"
    if ($found.Count -gt 1) { $imgName = "photo" + $counter + ".jpg" }
    $imgPath = Join-Path $outDir $imgName
    [IO.File]::WriteAllBytes($imgPath, $bytes)
    Write-Host ("Saved " + $imgName + " (" + [math]::Round($bytes.Length / 1KB, 1) + " KB)")
    $html = $html.Replace($m.Value, $imgName)
    $counter++
}

# Write updated HTML
$outHtml = Join-Path $outDir 'index.html'
[IO.File]::WriteAllText($outHtml, $html, [System.Text.Encoding]::UTF8)
$newSize = (Get-Item $outHtml).Length
Write-Host ("New index.html size: " + [math]::Round($newSize / 1KB, 1) + " KB")
Write-Host "Done! Files saved to: $outDir"
