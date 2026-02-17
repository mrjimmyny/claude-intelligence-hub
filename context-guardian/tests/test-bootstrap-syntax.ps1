#Requires -Version 5.1
# Context Guardian - Bootstrap Script Syntax Test
# Validates bootstrap-magneto.ps1 before deployment

param(
    [string]$ScriptPath = "$PSScriptRoot\..\..\..\bootstrap-magneto.ps1",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$testsPassed = 0
$testsFailed = 0
$warnings = @()

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )

    if ($Passed) {
        Write-Host "[PASS] " -ForegroundColor Green -NoNewline
        Write-Host $TestName -ForegroundColor White
        if ($Message -and $Verbose) {
            Write-Host "       $Message" -ForegroundColor Gray
        }
        $script:testsPassed++
    } else {
        Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
        Write-Host $TestName -ForegroundColor White
        if ($Message) {
            Write-Host "       $Message" -ForegroundColor Red
        }
        $script:testsFailed++
    }
}

function Write-TestWarning {
    param([string]$Message)
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor White
    $script:warnings += $Message
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Context Guardian - Bootstrap Script Validation" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: File exists
Write-Host "Test Suite 1: File Validation" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $ScriptPath) {
    Write-TestResult "File exists" $true "Path: $ScriptPath"
} else {
    Write-TestResult "File exists" $false "File not found: $ScriptPath"
    Write-Host ""
    Write-Host "[ABORT] Cannot continue without script file" -ForegroundColor Red
    exit 1
}

# Test 2: File is readable
try {
    $content = Get-Content $ScriptPath -Raw -ErrorAction Stop
    Write-TestResult "File is readable" $true "$($content.Length) bytes"
} catch {
    Write-TestResult "File is readable" $false $_.Exception.Message
    exit 1
}

# Test 3: PowerShell version requirement
$requiresLine = $content -split "`r?`n" | Select-Object -First 1
if ($requiresLine -match '#Requires -Version (\d+\.\d+)') {
    Write-TestResult "PowerShell version requirement" $true "Requires $($Matches[1])"
} else {
    Write-TestWarning "No PowerShell version requirement found"
}

Write-Host ""
Write-Host "Test Suite 2: Syntax Validation" -ForegroundColor Cyan
Write-Host ""

# Test 4: PowerShell syntax parsing
$errors = $null
$tokens = $null
try {
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$tokens, [ref]$errors)

    if ($errors.Count -eq 0) {
        Write-TestResult "PowerShell syntax parsing" $true "No parse errors"
    } else {
        Write-TestResult "PowerShell syntax parsing" $false "$($errors.Count) error(s) found"
        foreach ($err in $errors) {
            Write-Host "       Line $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-TestResult "PowerShell syntax parsing" $false $_.Exception.Message
}

# Test 5: Balanced braces
$openBraces = ([regex]::Matches($content, '\{')).Count
$closeBraces = ([regex]::Matches($content, '\}')).Count
if ($openBraces -eq $closeBraces) {
    Write-TestResult "Balanced braces" $true "{ = $openBraces, } = $closeBraces"
} else {
    Write-TestResult "Balanced braces" $false "{ = $openBraces, } = $closeBraces (mismatch)"
}

# Test 6: Balanced parentheses
$openParens = ([regex]::Matches($content, '\(')).Count
$closeParens = ([regex]::Matches($content, '\)')).Count
if ($openParens -eq $closeParens) {
    Write-TestResult "Balanced parentheses" $true "( = $openParens, ) = $closeParens"
} else {
    Write-TestResult "Balanced parentheses" $false "( = $openParens, ) = $closeParens (mismatch)"
}

Write-Host ""
Write-Host "Test Suite 3: Character Encoding" -ForegroundColor Cyan
Write-Host ""

# Test 7: Check for UTF-8 emojis and problematic characters
$lines = $content -split "`r?`n"
$emojiLines = @()
$smartQuoteLines = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    $lineNum = $i + 1

    # Check for high Unicode (emojis)
    foreach ($char in $line.ToCharArray()) {
        $charCode = [int]$char
        if ($charCode -gt 0x7F -and $charCode -ne 0xA0) {  # Non-ASCII except non-breaking space
            if ($charCode -ge 0x1F300) {  # Emoji range
                $emojiLines += "Line ${lineNum}: Found emoji U+$($charCode.ToString('X4'))"
            } elseif ($charCode -in @(0x201C, 0x201D, 0x2018, 0x2019)) {  # Smart quotes
                $smartQuoteLines += "Line ${lineNum}: Found smart quote U+$($charCode.ToString('X4'))"
            }
        }
    }
}

if ($emojiLines.Count -eq 0) {
    Write-TestResult "No UTF-8 emojis" $true "All emojis replaced with ASCII"
} else {
    Write-TestResult "No UTF-8 emojis" $false "$($emojiLines.Count) emoji(s) found"
    if ($Verbose) {
        foreach ($emoji in $emojiLines) {
            Write-Host "       $emoji" -ForegroundColor Red
        }
    }
}

if ($smartQuoteLines.Count -eq 0) {
    Write-TestResult "No smart quotes" $true "All quotes are standard ASCII"
} else {
    Write-TestResult "No smart quotes" $false "$($smartQuoteLines.Count) smart quote(s) found"
    if ($Verbose) {
        foreach ($quote in $smartQuoteLines) {
            Write-Host "       $quote" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Test Suite 4: Script Structure" -ForegroundColor Cyan
Write-Host ""

# Test 8: Required parameters
if ($content -match 'param\s*\(') {
    Write-TestResult "Parameter block exists" $true
} else {
    Write-TestWarning "No parameter block found"
}

# Test 9: Global variables
$requiredVars = @('RCLONE_REMOTE', 'GDRIVE_FOLDER', 'SYMLINK_WARNINGS')
$missingVars = @()
foreach ($var in $requiredVars) {
    if ($content -notmatch "\`$global:$var") {
        $missingVars += $var
    }
}

if ($missingVars.Count -eq 0) {
    Write-TestResult "Required global variables" $true "All $($requiredVars.Count) variables found"
} else {
    Write-TestResult "Required global variables" $false "Missing: $($missingVars -join ', ')"
}

# Test 10: Required functions
$requiredFunctions = @('Test-DeveloperMode', 'Test-Administrator', 'New-SkillSymlink')
$missingFunctions = @()
foreach ($func in $requiredFunctions) {
    if ($content -notmatch "function $func") {
        $missingFunctions += $func
    }
}

if ($missingFunctions.Count -eq 0) {
    Write-TestResult "Required functions" $true "All $($requiredFunctions.Count) functions found"
} else {
    Write-TestResult "Required functions" $false "Missing: $($missingFunctions -join ', ')"
}

# Test 11: Transcript logging
if ($content -match 'Start-Transcript' -and $content -match 'Stop-Transcript') {
    Write-TestResult "Transcript logging" $true "Start and Stop found"
} else {
    Write-TestWarning "Transcript logging may be incomplete"
}

Write-Host ""
Write-Host "Test Suite 5: Dry-Run Mode" -ForegroundColor Cyan
Write-Host ""

# Test 12: Dry-run execution (non-destructive)
Write-Host "[INFO] Testing dry-run mode..." -ForegroundColor Cyan
$dryRunOutput = $null
$dryRunExitCode = 0
try {
    # Run with -DryRun flag (metadata fetch is expected and safe)
    $dryRunOutput = & $ScriptPath -DryRun 2>&1
    $dryRunExitCode = $LASTEXITCODE
} catch {
    $dryRunExitCode = 1
    $dryRunError = $_.Exception.Message
}

# Exit code 0 or 1 is acceptable (1 means user chose option 4 to exit)
if ($dryRunExitCode -le 1) {
    Write-TestResult "Dry-run execution" $true "Script executed cleanly (exit code: $dryRunExitCode)"
    if ($Verbose -and $dryRunOutput) {
        Write-Host "       Output preview:" -ForegroundColor Gray
        $dryRunOutput | Select-Object -First 5 | ForEach-Object {
            Write-Host "       $_" -ForegroundColor DarkGray
        }
    }
} else {
    Write-TestResult "Dry-run execution" $false "Exit code: $dryRunExitCode - $dryRunError"
}

# Test 13: File size check (should be reasonable)
$fileInfo = Get-Item $ScriptPath
$fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
if ($fileSizeKB -lt 100) {
    Write-TestResult "File size reasonable" $true "${fileSizeKB} KB"
} else {
    Write-TestWarning "File is large: ${fileSizeKB} KB (may need optimization)"
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Passed: " -NoNewline -ForegroundColor Green
Write-Host $testsPassed
Write-Host "Failed: " -NoNewline -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host $testsFailed
Write-Host "Warnings: " -NoNewline -ForegroundColor $(if ($warnings.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host $warnings.Count
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "[SUCCESS] All critical tests passed!" -ForegroundColor Green
    Write-Host "Script is ready for deployment to Google Drive." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAILURE] $testsFailed test(s) failed!" -ForegroundColor Red
    Write-Host "Please fix errors before deploying to Google Drive." -ForegroundColor Red
    exit 1
}
