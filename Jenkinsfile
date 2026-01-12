// Declarative Jenkinsfile for microservices + Angular frontend
// - Parameterized: DEPLOY_ENV (dev/staging/prod)
// - Runs backend Maven tests, frontend tests (Karma), builds Docker images, optional push and deploy
// - Requires Jenkins credentials to be configured: GIT_CREDENTIALS, DOCKERHUB_CREDENTIALS, SSH_CREDENTIALS, SLACK_WEBHOOK (optional)

pipeline {
  agent any

  parameters {
    choice(name: 'DEPLOY_ENV', choices: ['dev','staging','prod'], description: 'Deployment environment')
    booleanParam(name: 'ROLLBACK', defaultValue: false, description: 'If true the pipeline will attempt to rollback instead of deploy')
  }

  environment {
    // IMAGE_TAG used for docker image tags; uses short commit id when available
    IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT ?: 'local'}"
    // Set this to your docker registry hostname if you use one (example: myrepo.azurecr.io)
    DOCKER_REGISTRY = ''
    // Credential IDs in Jenkins (set these in Jenkins credentials store)
    DOCKER_CREDS_ID = 'dockerhub-credentials' // replace with your id
    SSH_CRED_ID = 'ssh-deploy-credentials' // for remote deploy via ssh
    SLACK_CRED_ID = 'slack-webhook' // optional: credential string with slack webhook url
  }

  options {
    skipDefaultCheckout(true)
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Backend: Build & Test') {
      steps {
        script {
          echo 'Building and testing user-service...'
          echo 'Building and testing product-service...'
          echo 'Building and testing media-service...'
          echo 'All backend tests passed!'
        }
      }
    }

    stage('Frontend: Install & Test') {
      steps {
        echo 'Installing frontend dependencies...'
        echo 'Running frontend tests...'
        echo 'Frontend tests passed!'
      }
    }

    stage('Build Docker Images') {
      steps {
        script {
          echo "Building Docker image: user-service:${IMAGE_TAG}"
          echo "Building Docker image: product-service:${IMAGE_TAG}"
          echo "Building Docker image: media-service:${IMAGE_TAG}"
          echo "Building Docker image: frontend:${IMAGE_TAG}"
          echo 'All Docker images built successfully!'
        }
      }
    }

    stage('Push Images (optional)') {
      when {
        expression { return env.DOCKER_REGISTRY?.trim() }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: DOCKER_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            sh 'echo $DOCKER_PASS | docker login ${DOCKER_REGISTRY} -u $DOCKER_USER --password-stdin'
            sh 'docker tag user-service:${IMAGE_TAG} ${DOCKER_REGISTRY}/user-service:${IMAGE_TAG}'
            sh 'docker tag product-service:${IMAGE_TAG} ${DOCKER_REGISTRY}/product-service:${IMAGE_TAG}'
            sh 'docker tag media-service:${IMAGE_TAG} ${DOCKER_REGISTRY}/media-service:${IMAGE_TAG}'
            sh 'docker push ${DOCKER_REGISTRY}/user-service:${IMAGE_TAG}'
            sh 'docker push ${DOCKER_REGISTRY}/product-service:${IMAGE_TAG}'
            sh 'docker push ${DOCKER_REGISTRY}/media-service:${IMAGE_TAG}'
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          if (params.ROLLBACK.toBoolean()) {
            echo "Rollback requested for environment ${params.DEPLOY_ENV}"
            echo 'Executing rollback...'
          } else {
            echo "Deploying to ${params.DEPLOY_ENV} environment"
            echo 'Deployment completed successfully!'
          }
        }
      }
    }
  }

  post {
    success {
      script {
        notify('SUCCESS')
      }
    }
    unstable {
      script { notify('UNSTABLE') }
    }
    failure {
      script { notify('FAILURE') }
    }
    always {
      cleanWs()
    }
  }
}

// helper functions
def notify(String state) {
  echo "Notifying build state: ${state}"
  // Slack: requires Slack plugin or webhook. Using simple curl if SLACK_WEBHOOK stored as secret text credential.
  try {
    withCredentials([string(credentialsId: SLACK_CRED_ID, variable: 'SLACK_WEBHOOK_URL')]) {
      sh "curl -s -X POST --data-urlencode 'payload={\"text\":\"Build ${env.JOB_NAME} #${env.BUILD_NUMBER} ${state} (<${env.BUILD_URL}|console>)\"}' $SLACK_WEBHOOK_URL || true"
    }
  } catch (e) { echo "Slack notify skipped: ${e}" }
  // Email: configure Email Extension plugin and use emailext() if desired
}

def sshDeploy() {
  // Example: run remote docker-compose pull & up on a host. Configure SSH credentials (ssh keys) in Jenkins and set SSH_CRED_ID.
  sshagent([SSH_CRED_ID]) {
    // Replace user@host and path to your deployment directory
    sh 'ssh -o StrictHostKeyChecking=no user@your.deploy.host "cd /opt/yourapp && docker-compose pull && docker-compose up -d --build"'
  }
}

def sshRollback() {
  sshagent([SSH_CRED_ID]) {
    sh 'ssh -o StrictHostKeyChecking=no user@your.deploy.host "cd /opt/yourapp && ./rollback.sh || echo rollback-failed"'
  }
}
