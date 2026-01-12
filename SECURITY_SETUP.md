# Security Configuration Guide

## 🔒 Jenkins Security Setup

### 1. Enable Jenkins Authentication

1. **Access Jenkins**: http://localhost:8080
2. Click **Manage Jenkins** (left sidebar)
3. Click **Security** → **Configure Global Security**
4. Under **Security Realm**, select **Jenkins' own user database**
5. Check **"Allow users to sign up"** (temporarily, to create admin account)
6. Under **Authorization**, select **Matrix-based security** or **Project-based Matrix Authorization Strategy**
7. Add your username with all permissions
8. Click **Save**

### 2. Create Admin User

1. Click **Sign up** (top right)
2. Create your admin account:
   - Username: `admin`
   - Password: `[strong password]`
   - Full name: `Administrator`
   - Email: your-email@example.com
3. Click **Sign up**

### 3. Disable Public Signup

1. Go back to **Manage Jenkins** → **Security** → **Configure Global Security**
2. **Uncheck** "Allow users to sign up"
3. Click **Save**

### 4. Configure Credentials

Add credentials for your pipeline:

1. **Manage Jenkins** → **Credentials** → **(global)** → **Add Credentials**

**Add Docker Hub Credentials:**
- Kind: `Username with password`
- Scope: `Global`
- Username: `your-dockerhub-username`
- Password: `your-dockerhub-password`
- ID: `dockerhub-credentials`
- Description: `Docker Hub credentials`

**Add SSH Deploy Credentials (if needed):**
- Kind: `SSH Username with private key`
- ID: `ssh-deploy-credentials`
- Username: `deploy-user`
- Private Key: Enter directly or from file
- Passphrase: (if your key has one)

**Add Slack Webhook (optional):**
- Kind: `Secret text`
- Secret: `https://hooks.slack.com/services/YOUR/WEBHOOK/URL`
- ID: `slack-webhook`
- Description: `Slack notification webhook`

## 🔄 Automatic Pipeline Triggering

### Option 1: Poll SCM (Recommended for local Jenkins)

1. Open your pipeline job → **Configure**
2. Scroll to **Build Triggers**
3. Check **"Poll SCM"**
4. Schedule: `H/5 * * * *` (checks every 5 minutes)
5. Click **Save**

**Schedule Examples:**
- `H/5 * * * *` - Every 5 minutes
- `H/15 * * * *` - Every 15 minutes
- `H * * * *` - Every hour

### Option 2: GitHub Webhook (Requires public Jenkins)

1. **In Jenkins:**
   - Pipeline job → **Configure**
   - Build Triggers → Check **"GitHub hook trigger for GITScm polling"**
   - Click **Save**

2. **In GitHub:**
   - Go to your repository → **Settings** → **Webhooks** → **Add webhook**
   - Payload URL: `http://YOUR_JENKINS_URL/github-webhook/`
   - Content type: `application/json`
   - Events: **Just the push event**
   - Click **Add webhook**

**Note:** Jenkins must be publicly accessible for webhooks to work.

## 📝 Next Steps

After configuration:
1. Test authentication by logging out and back in
2. Verify credentials are working
3. Push a commit to test automatic triggering
4. Monitor build history for automatic builds

## 🛡️ Additional Security Recommendations

- Enable HTTPS/SSL for Jenkins
- Use strong passwords for all accounts
- Regularly update Jenkins and plugins
- Implement role-based access control (RBAC)
- Enable audit logging
- Backup Jenkins configuration regularly
