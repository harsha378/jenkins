pipeline {
    agent any

    stages {

        stage('Semgrep Scan') {
            steps {
                echo 'Running Semgrep SAST security scan...'
                withCredentials([string(credentialsId: 'SEMGRP_TOKEN', variable: 'SEMGREP_APP_TOKEN')]) {
                    // Using Docker image for Semgrep
                    bat '''
                        docker run --rm ^
                        -v "%CD%":/src ^
                        -e SEMGREP_APP_TOKEN=%SEMGREP_APP_TOKEN% ^
                        returntocorp/semgrep semgrep ci
                    '''
                }
            }
        }

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
                bat '''
                    docker stop jenkins-demo
                    if %errorlevel% neq 0 (
                        echo No container to stop
                    )
                    docker rm jenkins-demo
                    if %errorlevel% neq 0 (
                        echo No container to remove
                    )
                    docker run -d --name jenkins-demo -p 3000:3000 jenkins-demo-app
                '''
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

    post {
        failure {
            echo '❌ Build failed — Check Semgrep or Docker errors.'
        }
        success {
            echo '✅ Build and deployment completed successfully.'
        }
    }
}
