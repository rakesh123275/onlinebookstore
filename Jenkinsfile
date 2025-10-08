pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO   = "rakesh123275/onlinebookstore"
        DOCKER_CREDENTIALS = "dockerhub-creds"
        GIT_REPO           = "https://github.com/rakesh123275/onlinebookstore.git"
        CONTAINER_NAME     = "onlinebookstore"
        APP_PORT           = "9090"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_NUMBER} -t ${DOCKER_HUB_REPO}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_HUB_REPO}:latest"
                    }
                }
            }
        }

        stage('Deploy to Docker') {
            steps {
                script {
                    // Stop and remove old container (ignore errors)
                    sh "docker rm -f ${CONTAINER_NAME} || true"

                    // Run new container
                    sh """
                      docker run -d --name ${CONTAINER_NAME} \
                        -p ${APP_PORT}:${APP_PORT} \
                        --restart unless-stopped \
                        ${DOCKER_HUB_REPO}:latest
                    """

                    // Quick health check: container status + port open
                    sh """
                      sleep 5
                      docker ps --filter "name=${CONTAINER_NAME}"
                      # Fail if container exited
                      if [ "\$(docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME})" != "true" ]; then
                        echo "Container is not running. Recent logs:"
                        docker logs --tail=200 ${CONTAINER_NAME} || true
                        exit 1
                      fi
                    """
                }
            }
        }

        stage('App Health Check') {
            steps {
                script {
                    // Try reaching Tomcat on the mapped port, retry a few times
                    retry(10) {
                        sleep 3
                        sh """
                          if curl -sSf http://localhost:${APP_PORT}/ >/dev/null; then
                            echo "App responded OK."
                          else
                            echo "Waiting for app on port ${APP_PORT}..."
                            exit 1
                          fi
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "---- Container Logs (tail) ----"
            sh "docker logs --tail=100 ${CONTAINER_NAME} || true"
            cleanWs()
        }
        success {
            echo "✅ Build, Push & Deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed!"
        }
    }
}
