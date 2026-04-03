pipeline {
    agent any

    environment {
        DOCKER_HUB = "a01053912492@gmail.com"
    }

    stages {
        stage('Backend Build') {
            steps {
                sh 'docker build -t $DOCKER_HUB/backend:latest ./backend'
            }
        }

        stage('Frontend Build') {
            steps {
                sh 'docker build -t $DOCKER_HUB/frontend:latest ./frontend'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh 'docker push $DOCKER_HUB/backend:latest'
                sh 'docker push $DOCKER_HUB/frontend:latest'
            }
        }
    }
}