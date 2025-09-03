pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "harigopal118/onlinebookstore"
        DOCKER_CREDENTIALS = 'dockerhub-creds'   // Jenkins credentials ID
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
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
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

        stage('Deploy to Tomcat') {
            steps {
                script {
                    // Deploy WAR directly to Tomcat if needed
                    sh 'cp target/*.war /opt/tomcat/webapps/onlinebookstore.war || true'

                    // Stop & remove old container if exists
                    sh 'docker rm -f onlinebookstore || true'

                    // Run new container
                    sh "docker run -d -p 9090:8080 --name onlinebookstore ${DOCKER_HUB_REPO}:latest"

                    // Optional: remove dangling images to save space
                    sh 'docker image prune -f || true'
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
            echo "✅ Build & Deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed!"
        }
    }
}
