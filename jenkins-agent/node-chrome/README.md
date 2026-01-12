Jenkins Node+Chrome Agent
=========================

This folder contains a Dockerfile to build a Jenkins inbound agent image with Node.js and Chromium installed so that Karma/ChromeHeadless tests can run in CI.

Build and run (example):

1. Build the image:

```bash
docker build -t jenkins-node-chrome:latest .
```

2. Run the agent and connect to your Jenkins master. You must provide `JENKINS_URL`, `JENKINS_AGENT_NAME`, and `JENKINS_SECRET` (or `JENKINS_AGENT_WORKDIR`) as environment variables. Example (replace values):

```bash
docker run -d --name jenkins-node-chrome \
  -e JENKINS_URL="http://your.jenkins.host:8080" \
  -e JENKINS_AGENT_NAME="node-chrome-1" \
  -e JENKINS_SECRET="<agent-secret>" \
  jenkins-node-chrome:latest
```

3. In Jenkins, create a new permanent agent (or use the Kubernetes plugin) and configure labels: `node` so the `Jenkinsfile` can target it.

Notes:
- The image is based on `jenkins/inbound-agent`. Adjust the base image tag to match your Jenkins master Java version.
- You may need to install additional packages (fonts, build tools) depending on your Angular/Karma setup.
- On Windows hosts, run the agent in a Linux VM or WSL; the agent expects a Linux container runtime.
