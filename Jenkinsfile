pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "harigopal118/onlinebookstore"
        DOCKER_CREDENTIALS = "dockerhub-creds"
        GIT_REPO = "https://github.com/Hari-9390-356441/onlinebookstore.git"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        stage('Build App') {
            steps {
                sh 'chmod +x mvnw || true'
                sh './mvnw clean package -DskipTests || mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_NUMBER} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
                    sh "docker tag ${DOCKER_HUB_REPO}:${BUILD_NUMBER} ${DOCKER_HUB_REPO}:latest"
                    sh "docker push ${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker rm -f onlinebookstore || true'
                sh "docker run -d -p 9090:8080 --restart always --name onlinebookstore ${DOCKER_HUB_REPO}:latest"
                sh 'docker image prune -f || true'
            }
        }
    }

    post {
        success {
            echo "✅ Build & Deployment Successful!"
        }
        failure {
            echo "❌ Pipeline Failed!"
        }
    }
}
