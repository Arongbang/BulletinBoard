pipeline {
    agent any

    environment {
        DOCKER_HUB = "arongbang"
		VERSION = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Backend Build') {
            steps {
				sh 'docker build -t $DOCKER_HUB/backend:$VERSION ./bulletin-backend'
                sh 'docker build -t $DOCKER_HUB/backend:latest ./bulletin-backend'
            }
        }

        stage('Frontend Build') {
            steps {
				sh 'docker build -t $DOCKER_HUB/frontend:$VERSION ./bulletin-frontend'
                sh 'docker build -t $DOCKER_HUB/frontend:latest ./bulletin-frontend'
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
				sh 'docker push $DOCKER_HUB/backend:$VERSION'
                sh 'docker push $DOCKER_HUB/backend:latest'
				sh 'docker push $DOCKER_HUB/frontend:$VERSION'
                sh 'docker push $DOCKER_HUB/frontend:latest'
            }
        }
    }
}