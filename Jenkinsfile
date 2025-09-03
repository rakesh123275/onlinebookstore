pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "harigopal118/onlinebookstore"
        DOCKER_CREDENTIALS = 'dockerhub-creds'
        GIT_REPO = "https://github.com/Hari-9390-356441/onlinebookstore.git"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package -DskipTests=true || mvn clean package -DskipTests=true'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh './mvnw test || mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_HUB_REPO}:${BUILD_NUMBER} ${DOCKER_HUB_REPO}:latest"
                        sh "docker push ${DOCKER_HUB_REPO}:latest"
                    }
                }
            }
        }

        stage('Deploy to Docker') {
            steps {
                script {
                    sh 'docker rm -f onlinebookstore || true'
                    sh "docker run -d -p 9090:8080 --restart always --name onlinebookstore ${DOCKER_HUB_REPO}:latest"
                    sh 'docker image prune -f || true'
                    sh 'docker logs --tail 50 onlinebookstore || true'
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "⏳ Waiting for app to become healthy..."
                    // Try for 60s, checking every 5s
                    retry(12) {
                        sleep 5
                        sh '''
                          if curl -s http://localhost:9090/actuator/health | grep -q '"status":"UP"'; then
                            echo "✅ Application is healthy!"
                          else
                            echo "Still waiting for app..."
                            exit 1
                          fi
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
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
