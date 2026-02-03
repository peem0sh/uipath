# UIPath Repository

This repository provides resources and documentation for integrating UIPath RPA (Robotic Process Automation) with GitHub.

## Overview

This repository serves as a central point for UIPath automation projects that need to interact with GitHub repositories. It includes documentation, examples, and configuration for enabling access from UIPath to this and other GitHub repositories.

## Accessing This Repository from UIPath

UIPath can interact with GitHub repositories using several methods. Below are the recommended approaches:

### Method 1: Using GitHub Personal Access Tokens (PAT)

This is the most straightforward method for UIPath automations to access GitHub.

#### Step 1: Generate a Personal Access Token

1. Go to GitHub Settings: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give your token a descriptive name (e.g., "UIPath Automation Token")
4. Select the required scopes:
   - `repo` - Full control of private repositories (required for read/write access)
   - `workflow` - Update GitHub Action workflows (if needed)
   - `read:org` - Read org and team membership (if working with organizations)
5. Click "Generate token"
6. **Important:** Copy the token immediately - you won't be able to see it again!

#### Step 2: Store the Token Securely in UIPath

In UIPath, use the **Credential Manager** or **Orchestrator Assets** to store the token securely:

```
Asset Name: GitHubToken
Asset Type: Credential
Value: <your-personal-access-token>
```

#### Step 3: Use the Token in UIPath

You can use the token with UIPath HTTP Request activities to interact with the GitHub API.

**Example: Get Repository Information**

```
HTTP Request Activity:
- Endpoint: https://api.github.com/repos/peem0sh/uipath
- Method: GET
- Headers:
  - Authorization: token <your-token>
  - Accept: application/vnd.github.v3+json
```

### Method 2: Using GitHub API with UIPath HTTP Activities

UIPath can make HTTP requests to the GitHub REST API for various operations:

#### Common API Endpoints

1. **Get Repository Contents:**
   ```
   GET https://api.github.com/repos/peem0sh/uipath/contents/
   ```

2. **List Commits:**
   ```
   GET https://api.github.com/repos/peem0sh/uipath/commits
   ```

3. **Create a File:**
   ```
   PUT https://api.github.com/repos/peem0sh/uipath/contents/{path}
   Body: {
     "message": "Commit message",
     "content": "<base64-encoded-content>"
   }
   ```

4. **Read a File:**
   ```
   GET https://api.github.com/repos/peem0sh/uipath/contents/{path}
   ```

5. **Create an Issue:**
   ```
   POST https://api.github.com/repos/peem0sh/uipath/issues
   Body: {
     "title": "Issue title",
     "body": "Issue description"
   }
   ```

### Method 3: Using Git Commands via UIPath

UIPath can execute Git commands using the **Execute Command** or **PowerShell** activities.

#### Prerequisites:
- Git must be installed on the machine running UIPath
- Clone the repository first

#### Example Commands:

```powershell
# Clone the repository
git clone https://<token>@github.com/peem0sh/uipath.git

# Pull latest changes
cd uipath
git pull origin main

# Add and commit changes
git add .
git commit -m "Automated commit from UIPath"

# Push changes
git push origin main
```

### Method 4: Using GitHub Actions as Triggers

You can set up GitHub Actions in this repository to trigger UIPath processes:

1. Create a webhook in GitHub that calls UIPath Orchestrator API
2. Configure GitHub Actions to run on specific events (push, pull request, etc.)
3. Use the GitHub Actions to trigger UIPath workflows via Orchestrator

## Security Best Practices

1. **Never hardcode tokens** in your UIPath workflows
2. **Use Orchestrator Assets** or Windows Credential Manager for sensitive data
3. **Limit token scopes** to only what's necessary
4. **Rotate tokens regularly** (recommended: every 90 days)
5. **Use repository secrets** for GitHub Actions
6. **Enable two-factor authentication** on your GitHub account

## Example UIPath Workflow Structure

```
Main.xaml
├── Initialize (Sequence)
│   ├── Get GitHub Token from Orchestrator Asset
│   └── Set API Base URL
├── Process (Sequence)
│   ├── HTTP Request: Get Repository Info
│   ├── HTTP Request: List Files
│   └── HTTP Request: Read/Write Files
└── Cleanup (Sequence)
    └── Log Results
```

## Common Use Cases

### 1. Automated Code Deployment
- UIPath reads configuration from this repository
- Updates are pulled automatically
- Deploys changes to target systems

### 2. Issue Management
- UIPath creates GitHub issues for errors or exceptions
- Automatically updates issue status based on resolution

### 3. Configuration Management
- Store UIPath configuration files in this repository
- UIPath reads configs at runtime
- Version control for all configurations

### 4. Documentation Updates
- UIPath generates reports and commits them to the repository
- Automatic documentation updates based on process runs

## Troubleshooting

### Authentication Issues
- Verify your token has the correct scopes
- Check if the token has expired
- Ensure the Authorization header format is correct: `token <your-token>`

### API Rate Limits
- GitHub API has rate limits (5,000 requests/hour for authenticated requests)
- Implement retry logic with exponential backoff
- Consider using conditional requests with ETags

### Connection Issues
- Check network connectivity
- Verify firewall rules allow HTTPS traffic to github.com
- Test API endpoints using tools like Postman first

## Additional Resources

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [UIPath HTTP Request Activity](https://docs.uipath.com/activities/docs/http-request)
- [UIPath Orchestrator Assets](https://docs.uipath.com/orchestrator/docs/managing-assets)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

## Support

For questions or issues related to this repository, please:
1. Check the documentation above
2. Review GitHub API documentation
3. Create an issue in this repository
4. Contact the repository maintainer

## License

This repository is provided as-is for UIPath automation purposes.