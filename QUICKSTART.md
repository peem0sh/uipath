# Quick Start Guide: UIPath GitHub Integration

This guide will help you quickly set up access from UIPath to this GitHub repository.

## Prerequisites

- UIPath Studio installed on your machine
- A GitHub account with access to this repository
- Basic understanding of UIPath workflows

## Step-by-Step Setup (5 minutes)

### Step 1: Generate GitHub Personal Access Token (2 minutes)

1. Open your browser and go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Fill in the token details:
   - **Note:** `UIPath Automation Token`
   - **Expiration:** 90 days (or choose custom)
   - **Select scopes:**
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (if you need to trigger GitHub Actions)
4. Click **"Generate token"** at the bottom
5. **IMPORTANT:** Copy the token immediately - you won't see it again!
   - The token looks like: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Step 2: Store Token in UIPath Orchestrator (1 minute)

#### Option A: Using UIPath Orchestrator
1. Open UIPath Orchestrator
2. Navigate to **Tenant** → **Assets**
3. Click **"Add"** button
4. Create a new asset:
   - **Name:** `GitHubToken`
   - **Type:** `Credential`
   - **Username:** Your GitHub username
   - **Password:** Your Personal Access Token (from Step 1)
5. Click **"Save"**

#### Option B: Using Windows Credential Manager (Local Development)
1. Open Windows Credential Manager
2. Click **"Windows Credentials"**
3. Click **"Add a generic credential"**
4. Fill in:
   - **Internet or network address:** `GitHubToken`
   - **User name:** Your GitHub username
   - **Password:** Your Personal Access Token
5. Click **"OK"**

### Step 3: Create Your First UIPath Workflow (2 minutes)

1. Open UIPath Studio
2. Create a new **Process**
3. Add the following activities to your workflow:

#### A. Get the GitHub Token
- Add **"Get Credential"** activity
   - Asset Name: `GitHubToken`
   - Output: Create variable `githubToken` (String)

#### B. Make Your First API Call
- Add **"HTTP Request"** activity
   - Configure:
     ```
     Endpoint: "https://api.github.com/repos/peem0sh/uipath"
     Method: GET
     ```
   - In **Headers** (click "Edit Headers"):
     - Add Header:
       - Name: `Authorization`
       - Value: `"token " + githubToken.Password`
     - Add Header:
       - Name: `Accept`
       - Value: `application/vnd.github.v3+json`
   - Output: Create variable `repoInfo` (String)

#### C. Display the Result
- Add **"Message Box"** activity
   - Text: `repoInfo`
   - Title: `"Repository Information"`

4. **Run your workflow!** (Press F5)

### Step 4: Verify It Works

When you run the workflow, you should see a message box with JSON data about this repository, including:
- Repository name
- Description
- Creation date
- Number of stars, forks, etc.

## What's Next?

Now that you have basic access working, you can:

1. **Read the detailed examples:**
   - See [UIPath-GitHub-Integration-Examples.md](./UIPath-GitHub-Integration-Examples.md)

2. **Try more complex workflows:**
   - Reading files from the repository
   - Creating or updating files
   - Listing commits
   - Creating issues automatically

3. **Use the configuration file:**
   - Load [config/github-config.json](config/github-config.json) in your workflows
   - Use it to store API endpoints and settings

4. **Implement error handling:**
   - Add Try-Catch blocks
   - Implement retry logic
   - Log errors to GitHub issues

## Common Issues and Solutions

### Issue: "401 Unauthorized"
**Solution:** 
- Verify your token is correct
- Make sure the token hasn't expired
- Check that you selected the `repo` scope when creating the token

### Issue: "Asset not found"
**Solution:**
- Verify the asset name is exactly `GitHubToken`
- Make sure you created the asset in the correct Orchestrator folder
- For local development, check Windows Credential Manager

### Issue: "Could not connect to the remote server"
**Solution:**
- Check your internet connection
- Verify firewall allows HTTPS connections to github.com
- Try accessing https://api.github.com/repos/peem0sh/uipath in your browser

### Issue: "The remote server returned an error: (404) Not Found"
**Solution:**
- Verify the repository name is correct: `peem0sh/uipath`
- Make sure the repository exists and you have access to it
- Check if the repository is private (token needs appropriate permissions)

## Testing Your Setup

### Quick Test Using PowerShell (Optional)

You can test your token quickly using PowerShell before implementing in UIPath:

```powershell
# Replace with your actual token
$token = "ghp_your_token_here"

# Test API call
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$response = Invoke-RestMethod -Uri "https://api.github.com/repos/peem0sh/uipath" -Headers $headers -Method Get

# Display result
$response | ConvertTo-Json -Depth 3
```

If this works, your token is valid and UIPath will work too!

## Security Reminders

⚠️ **Important Security Practices:**
- Never commit your Personal Access Token to any repository
- Never log or display the token in your workflows
- Store tokens only in secure locations (Orchestrator Assets or Credential Manager)
- Rotate tokens every 90 days
- Use minimum required scopes for your token
- Revoke tokens immediately if compromised

## Need Help?

If you encounter issues:
1. Check the detailed [README.md](README.md) for comprehensive documentation
2. Review the [integration examples](examples/UIPath-GitHub-Integration-Examples.md)
3. Create an issue in this repository with:
   - Description of the problem
   - Error messages (without tokens!)
   - Steps you've tried

## Additional Resources

- [UIPath Documentation](https://docs.uipath.com/)
- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [UIPath HTTP Request Activity](https://docs.uipath.com/activities/docs/http-request)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

**Congratulations!** You now have UIPath connected to this GitHub repository! 🎉
