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

        stage('Deploy to Do
