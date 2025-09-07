
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

        stage('Build WAR with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
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
                    // stop old container
                    sh 'docker rm -f onlinebookstore || true'

                    // run new container
                    sh "docker run -d -p 9090:9090 --restart always --name onlinebookstore ${DOCKER_HUB_REPO}:latest"

                    // cleanup unused images
                    sh 'docker image prune -f || true'
                }
            }
        }
    }

    post {
        always {
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
