$htmlPath = 'C:\Users\shubh\.gemini\antigravity\scratch\portfolio\index.html'
$outDir   = 'C:\Users\shubh\.gemini\antigravity\scratch\portfolio'

$html = [IO.File]::ReadAllText($htmlPath)
$sizeMB = [math]::Round($html.Length / 1MB, 2)
Write-Host "Current HTML size: $sizeMB MB"

# Find all data URIs (images and PDFs)
$regex   = [regex]'data:([^;,]+);base64,([A-Za-z0-9+/=]+)'
$allHits = $regex.Matches($html)
$total   = $allHits.Count
Write-Host "Total embedded data URIs: $total"

$counter = 1
foreach ($hit in $allHits) {
    $mime  = $hit.Groups[1].Value
    $b64   = $hit.Groups[2].Value
    $approxKB = [math]::Round($b64.Length * 0.75 / 1024, 1)

    if ($mime -like '*jpeg*' -or $mime -like '*jpg*') { $ext = 'jpg' }
    elseif ($mime -like '*png*')  { $ext = 'png'  }
    elseif ($mime -like '*gif*')  { $ext = 'gif'  }
    elseif ($mime -like '*webp*') { $ext = 'webp' }
    elseif ($mime -like '*svg*')  { $ext = 'svg'  }
    elseif ($mime -like '*pdf*')  { $ext = 'pdf'  }
    else                          { $ext = 'bin'  }

    $fname = "asset" + $counter + "." + $ext
    Write-Host "  [$counter] $mime -- ${approxKB} KB => $fname"

    $bytes = [Convert]::FromBase64String($b64)
    [IO.File]::WriteAllBytes((Join-Path $outDir $fname), $bytes)

    $html = $html.Replace($hit.Value, $fname)
    $counter++
}

[IO.File]::WriteAllText($htmlPath, $html, [System.Text.Encoding]::UTF8)
$newKB = [math]::Round((Get-Item $htmlPath).Length / 1KB, 1)
Write-Host ""
Write-Host "New index.html size: $newKB KB"
Write-Host "All done!"
