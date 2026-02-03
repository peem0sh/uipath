# Test your GitHub API access with this PowerShell script
# This script tests your GitHub Personal Access Token before using it in UIPath

# IMPORTANT: Replace 'YOUR_TOKEN_HERE' with your actual GitHub Personal Access Token
$token = "YOUR_TOKEN_HERE"

# Repository information
$repoOwner = "peem0sh"
$repoName = "uipath"

# Test Configuration
$tests = @(
    @{
        Name = "Test 1: Get Repository Info"
        Endpoint = "https://api.github.com/repos/$repoOwner/$repoName"
        Method = "GET"
    },
    @{
        Name = "Test 2: List Repository Contents"
        Endpoint = "https://api.github.com/repos/$repoOwner/$repoName/contents"
        Method = "GET"
    },
    @{
        Name = "Test 3: List Recent Commits"
        Endpoint = "https://api.github.com/repos/$repoOwner/$repoName/commits?per_page=5"
        Method = "GET"
    },
    @{
        Name = "Test 4: Get Rate Limit Status"
        Endpoint = "https://api.github.com/rate_limit"
        Method = "GET"
    }
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub API Access Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if token is set
if ($token -eq "YOUR_TOKEN_HERE") {
    Write-Host "❌ ERROR: Please replace 'YOUR_TOKEN_HERE' with your actual GitHub token" -ForegroundColor Red
    Write-Host ""
    Write-Host "To get a token:" -ForegroundColor Yellow
    Write-Host "1. Go to https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host "2. Click 'Generate new token (classic)'" -ForegroundColor Yellow
    Write-Host "3. Select 'repo' scope" -ForegroundColor Yellow
    Write-Host "4. Generate and copy the token" -ForegroundColor Yellow
    Write-Host "5. Replace 'YOUR_TOKEN_HERE' in this script" -ForegroundColor Yellow
    exit 1
}

# Setup headers
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "UIPath-Test-Script"
}

$testResults = @()

# Run each test
foreach ($test in $tests) {
    Write-Host "Running: $($test.Name)..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri $test.Endpoint -Headers $headers -Method $test.Method -ErrorAction Stop
        
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        
        # Display relevant information based on test
        switch ($test.Name) {
            "Test 1: Get Repository Info" {
                Write-Host "   Repository: $($response.full_name)" -ForegroundColor Gray
                Write-Host "   Description: $($response.description)" -ForegroundColor Gray
                Write-Host "   Private: $($response.private)" -ForegroundColor Gray
                Write-Host "   Stars: $($response.stargazers_count)" -ForegroundColor Gray
            }
            "Test 2: List Repository Contents" {
                Write-Host "   Found $($response.Count) items in root directory" -ForegroundColor Gray
                $response | ForEach-Object {
                    Write-Host "   - $($_.name) ($($_.type))" -ForegroundColor Gray
                }
            }
            "Test 3: List Recent Commits" {
                Write-Host "   Found $($response.Count) recent commits" -ForegroundColor Gray
                $response | Select-Object -First 3 | ForEach-Object {
                    Write-Host "   - $($_.sha.Substring(0,7)): $($_.commit.message.Split("`n")[0])" -ForegroundColor Gray
                }
            }
            "Test 4: Get Rate Limit Status" {
                Write-Host "   Core API - Remaining: $($response.resources.core.remaining)/$($response.resources.core.limit)" -ForegroundColor Gray
                $resetTime = [DateTimeOffset]::FromUnixTimeSeconds($response.resources.core.reset).LocalDateTime
                Write-Host "   Resets at: $resetTime" -ForegroundColor Gray
            }
        }
        
        $testResults += @{
            Test = $test.Name
            Status = "PASSED"
        }
    }
    catch {
        Write-Host "❌ FAILED" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            Write-Host "   Status Code: $statusCode" -ForegroundColor Red
            
            switch ($statusCode) {
                401 { 
                    Write-Host "   This usually means your token is invalid or expired" -ForegroundColor Yellow 
                }
                403 { 
                    Write-Host "   This could mean rate limiting or insufficient permissions" -ForegroundColor Yellow 
                }
                404 { 
                    Write-Host "   The repository or resource was not found" -ForegroundColor Yellow 
                }
            }
        }
        
        $testResults += @{
            Test = $test.Name
            Status = "FAILED"
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passedTests = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
$totalTests = $testResults.Count

Write-Host "Passed: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

foreach ($result in $testResults) {
    $color = if ($result.Status -eq "PASSED") { "Green" } else { "Red" }
    $symbol = if ($result.Status -eq "PASSED") { "✅" } else { "❌" }
    Write-Host "$symbol $($result.Test): $($result.Status)" -ForegroundColor $color
}

Write-Host ""

if ($passedTests -eq $totalTests) {
    Write-Host "🎉 All tests passed! Your token is working correctly." -ForegroundColor Green
    Write-Host "You can now use this token in your UIPath workflows." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed. Please review the errors above." -ForegroundColor Yellow
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- Invalid or expired token" -ForegroundColor Yellow
    Write-Host "- Insufficient token permissions (need 'repo' scope)" -ForegroundColor Yellow
    Write-Host "- Repository access denied" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
