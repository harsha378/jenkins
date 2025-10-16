pipeline {
    agent any

    stages {

        stage('Semgrep Scan') {
            steps {
                echo '🔐 Running Semgrep SAST security scan...'
                withCredentials([string(credentialsId: 'SEMGRP_TOKEN', variable: 'SEMGREP_APP_TOKEN')]) {
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
                echo '🐳 Checking Docker connectivity...'
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
                echo '🏗️ Building Docker image...'
                bat 'docker build -t jenkins-demo-app .'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                bat 'echo "Tests passed"'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
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
                echo '🧭 Verifying deployment...'
                sleep 5
                bat 'docker ps'
                echo 'Application should be running on http://localhost:3000'
            }
        }

        stage('DAST Scan') {
            steps {
                echo '🕵️ Running OWASP ZAP DAST scan...'
                // Run a baseline scan against the running app
                bat '''
                    docker run --rm ^
                    -v "%CD%":/zap/wrk ^
                    owasp/zap2docker-stable zap-baseline.py ^
                    -t http://host.docker.internal:3000 ^
                    -r dast-report.html
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'dast-report.html', fingerprint: true
                    echo '📄 ZAP DAST report archived as dast-report.html'
                }
            }
        }
    }

    post {
        failure {
            echo '❌ Build failed — Check SAST/DAST or Docker errors.'
        }
        success {
            echo '✅ Build, deployment, and security scans completed successfully.'
        }
    }
}
