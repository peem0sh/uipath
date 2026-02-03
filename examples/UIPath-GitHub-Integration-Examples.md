# UIPath GitHub Integration Examples

This document provides practical examples of UIPath workflows that interact with this GitHub repository.

## Example 1: Read File from Repository

This example shows how to read a file from the GitHub repository using UIPath.

### Workflow Steps:

1. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`
   - Output: `githubToken`

2. **Build API URL**
   - Activity: `Assign`
   - Variable: `apiUrl = "https://api.github.com/repos/peem0sh/uipath/contents/config/github-config.json"`

3. **Create HTTP Request**
   - Activity: `HTTP Request`
   - Endpoint: `apiUrl`
   - Method: `GET`
   - Headers:
     ```
     Authorization: "token " + githubToken
     Accept: "application/vnd.github.v3+json"
     User-Agent: "UIPath-Automation"
     ```
   - Output: `responseContent`

4. **Parse Response**
   - Activity: `Deserialize JSON`
   - Input: `responseContent`
   - Output: `jsonObject`

5. **Decode Content**
   - The file content is Base64 encoded in the `content` field
   - Activity: `Invoke Code`
   - Code:
     ```vb
     Dim base64Content As String = jsonObject("content").ToString().Replace(vbLf, "")
     Dim bytes As Byte() = Convert.FromBase64String(base64Content)
     fileContent = System.Text.Encoding.UTF8.GetString(bytes)
     ```

### Expected Output:
The `fileContent` variable will contain the decoded file contents.

---

## Example 2: Create or Update File in Repository

This example demonstrates how to create or update a file in the repository.

### Workflow Steps:

1. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`
   - Output: `githubToken`

2. **Prepare File Content**
   - Activity: `Assign`
   - Variable: `fileContent = "Your file content here"`
   
3. **Encode Content to Base64**
   - Activity: `Assign`
   - Variable: `base64Content = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(fileContent))`

4. **Build Request Body**
   - Activity: `Serialize JSON`
   - Input Object:
     ```json
     {
       "message": "Update from UIPath automation",
       "content": base64Content,
       "branch": "main"
     }
     ```
   - Output: `requestBody`

5. **Send HTTP Request**
   - Activity: `HTTP Request`
   - Endpoint: `"https://api.github.com/repos/peem0sh/uipath/contents/output/automation-result.txt"`
   - Method: `PUT`
   - Headers:
     ```
     Authorization: "token " + githubToken
     Accept: "application/vnd.github.v3+json"
     User-Agent: "UIPath-Automation"
     ```
   - Body: `requestBody`
   - Output: `response`

### Note:
- To update an existing file, you must include the file's SHA in the request body
- To get the SHA, first make a GET request to the file's endpoint

---

## Example 3: Create GitHub Issue

This example shows how to automatically create a GitHub issue when an error occurs in your UIPath workflow.

### Workflow Steps:

1. **Error Handling** (Try-Catch Block)
   - Place your main workflow in a Try block
   - In the Catch block, capture the exception

2. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`
   - Output: `githubToken`

3. **Build Issue Body**
   - Activity: `Assign`
   - Variables:
     ```vb
     issueTitle = "UIPath Automation Error: " + exception.Message
     issueBody = "Error occurred at: " + Now.ToString() + vbCrLf + _
                 "Error Message: " + exception.Message + vbCrLf + _
                 "Stack Trace: " + exception.StackTrace
     ```

4. **Create Request Body**
   - Activity: `Serialize JSON`
   - Input Object:
     ```json
     {
       "title": issueTitle,
       "body": issueBody,
       "labels": ["automation", "error"]
     }
     ```
   - Output: `requestBody`

5. **Send HTTP Request**
   - Activity: `HTTP Request`
   - Endpoint: `"https://api.github.com/repos/peem0sh/uipath/issues"`
   - Method: `POST`
   - Headers:
     ```
     Authorization: "token " + githubToken
     Accept: "application/vnd.github.v3+json"
     User-Agent: "UIPath-Automation"
     ```
   - Body: `requestBody`
   - Output: `response`

---

## Example 4: List Recent Commits

This example retrieves the list of recent commits from the repository.

### Workflow Steps:

1. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`
   - Output: `githubToken`

2. **Build API URL**
   - Activity: `Assign`
   - Variable: `apiUrl = "https://api.github.com/repos/peem0sh/uipath/commits?per_page=10"`

3. **Send HTTP Request**
   - Activity: `HTTP Request`
   - Endpoint: `apiUrl`
   - Method: `GET`
   - Headers:
     ```
     Authorization: "token " + githubToken
     Accept: "application/vnd.github.v3+json"
     User-Agent: "UIPath-Automation"
     ```
   - Output: `responseContent`

4. **Parse Commits**
   - Activity: `Deserialize JSON Array`
   - Input: `responseContent`
   - Output: `commitsArray`

5. **Iterate Through Commits**
   - Activity: `For Each`
   - Collection: `commitsArray`
   - Item: `commit`
   - Body:
     ```vb
     Log Message("Commit SHA: " + commit("sha").ToString())
     Log Message("Author: " + commit("commit")("author")("name").ToString())
     Log Message("Message: " + commit("commit")("message").ToString())
     Log Message("Date: " + commit("commit")("author")("date").ToString())
     ```

---

## Example 5: Clone Repository Using Git Commands

This example shows how to clone the repository using Git commands from UIPath.

### Prerequisites:
- Git must be installed on the machine
- Machine must have network access to GitHub

### Workflow Steps:

1. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`
   - Output: `githubToken`

2. **Set Clone Directory**
   - Activity: `Assign`
   - Variable: `cloneDirectory = "C:\UIPath\Repositories\uipath"`

3. **Build Git Clone Command**
   - Activity: `Assign`
   - Variable: `gitCommand = "git clone https://" + githubToken + "@github.com/peem0sh/uipath.git " + cloneDirectory`

4. **Execute Git Command**
   - Activity: `Execute Command Line` or `Start Process`
   - FileName: `cmd.exe`
   - Arguments: `/c ` + gitCommand
   - Working Directory: `C:\UIPath\Repositories`
   - Output: `cloneOutput`

5. **Verify Clone**
   - Activity: `Path Exists`
   - Path: `cloneDirectory`
   - Output: `cloneSuccess`

### Alternative: Using PowerShell

```powershell
# PowerShell Activity
$token = "<github-token>"
$repoUrl = "https://${token}@github.com/peem0sh/uipath.git"
$localPath = "C:\UIPath\Repositories\uipath"

if (Test-Path $localPath) {
    Set-Location $localPath
    git pull origin main
} else {
    git clone $repoUrl $localPath
}
```

---

## Example 6: Read Configuration from Repository

This example demonstrates how to read the `github-config.json` file and use it in your UIPath workflow.

### Workflow Steps:

1. **Get GitHub Token**
   - Activity: `Get Credential`
   - Asset Name: `GitHubToken`

2. **Read Config File**
   - Use Example 1 to read the file content
   - File Path: `config/github-config.json`

3. **Deserialize Configuration**
   - Activity: `Deserialize JSON`
   - Input: `fileContent`
   - Output: `configObject`

4. **Use Configuration**
   - Activity: `Assign`
   - Variables:
     ```vb
     apiBaseUrl = configObject("github")("api_base_url").ToString()
     repoOwner = configObject("github")("repository")("owner").ToString()
     repoName = configObject("github")("repository")("name").ToString()
     timeoutSeconds = CInt(configObject("github")("timeout_seconds"))
     ```

5. **Build Dynamic API URLs**
   - Activity: `Assign`
   - Variable: `commitsUrl = apiBaseUrl + configObject("github")("endpoints")("commits").ToString()`

---

## Best Practices for UIPath Integration

### 1. Error Handling
Always wrap your HTTP requests in Try-Catch blocks:
```
Try:
    - HTTP Request
Catch (Exception):
    - Log Error
    - Retry Logic
    - Create GitHub Issue (optional)
```

### 2. Rate Limiting
Implement delays between requests to avoid hitting rate limits:
```
For Each item in items:
    - Process item
    - HTTP Request
    - Delay (1 second)
```

### 3. Secure Token Management
Never log or display tokens:
```
- Get Credential (GitHubToken) → Use secure string
- Use token in Authorization header
- Never log the token value
```

### 4. Response Validation
Always check HTTP status codes:
```
If statusCode = 200 Then
    - Success path
ElseIf statusCode = 401 Then
    - Authentication error
ElseIf statusCode = 404 Then
    - Resource not found
Else
    - Handle other errors
```

### 5. Content Type Headers
Always set appropriate headers:
```
Headers:
- Accept: application/vnd.github.v3+json
- Content-Type: application/json (for POST/PUT)
- User-Agent: UIPath-Automation
- Authorization: token <your-token>
```

---

## Testing Your Integration

### 1. Test with Postman First
Before implementing in UIPath, test your API calls with Postman:
1. Set up the headers
2. Test the endpoint
3. Verify the response
4. Copy the working configuration to UIPath

### 2. Use UIPath Debug Mode
- Set breakpoints in your workflow
- Inspect variable values
- Check HTTP response content
- Verify status codes

### 3. Enable Logging
Log all important steps:
```
Log Message: "Starting GitHub API call"
Log Message: "API URL: " + apiUrl
Log Message: "Response Status: " + statusCode
Log Message: "Response Content Length: " + responseContent.Length.ToString()
```

---

## Troubleshooting Common Issues

### Issue: 401 Unauthorized
**Solution:**
- Verify token is correct and not expired
- Check token has required scopes (repo access)
- Ensure Authorization header format: `token <your-token>`

### Issue: 404 Not Found
**Solution:**
- Verify repository name and owner are correct
- Check file path exists in repository
- Ensure branch name is correct

### Issue: 403 Forbidden / Rate Limit
**Solution:**
- You've hit GitHub's rate limit
- Wait for rate limit reset (check X-RateLimit-Reset header)
- Implement exponential backoff
- Reduce request frequency

### Issue: SSL/TLS Errors
**Solution:**
- Update .NET Framework on the machine
- Install latest root certificates
- Check corporate proxy settings
- Use TLS 1.2 or higher

---

## Additional Resources

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [UIPath Activities Guide](https://docs.uipath.com/activities)
- [UIPath HTTP Request Activity](https://docs.uipath.com/activities/docs/http-request)
- [GitHub API Rate Limiting](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting)
