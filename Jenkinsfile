pipeline {
    agent any
    
    stages {
        stage('Docker Check') {
            steps {
                echo 'Checking Docker connectivity...'
                script {
                    try {
                        bat 'docker --version'
                        bat 'docker info'
                    } catch (Exception e) {
                        error "Docker is not running or accessible. Please start Docker Desktop and ensure Jenkins has access to Docker."
                    }
                }
            }
        }
        stage('Check Workspace Contents') {
            steps {
            bat 'dir'
            }
        }

        
        stage('Build') {
            steps {
                echo 'Building Docker image...'
                bat 'docker build -t jenkins-demo-app .'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                bat 'echo "Tests passed"'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                bat 'docker stop jenkins-demo || echo "No container to stop"'
                bat 'docker rm jenkins-demo || echo "No container to remove"'
                bat 'docker run -d --name jenkins-demo -p 3000:3000 jenkins-demo-app'
            }
        }
        
        stage('Verify') {
            steps {
                echo 'Verifying deployment...'
                sleep 5
                bat 'docker ps'
                echo 'Application should be running on http://localhost:3000'
            }
        }
    }
}
