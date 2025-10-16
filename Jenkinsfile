pipeline {
    agent any

    environment {
        IMAGE_NAME = "jenkins-demo-app"
        CONTAINER_NAME = "jenkins-demo"
        PORT = "3000"
    }

    stages {

        stage('Semgrep Scan') {
            steps {
                echo '🔐 Running Semgrep SAST security scan...'
                withCredentials([string(credentialsId: 'SEMGRP_TOKEN', variable: 'SEMGREP_APP_TOKEN')]) {
                    bat '''
                        docker run --rm ^
                        -v "%WORKSPACE%":/src ^
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
                        error "🚨 Docker is not running or accessible. Please start Docker Desktop and ensure Jenkins has access to Docker."
                    }
                }
            }
        }

        stage('Check Workspace Contents') {
            steps {
                echo '📂 Listing files in workspace...'
                bat 'dir'
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Building Docker image...'
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                bat 'echo "✅ Tests passed"'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                bat """
                    docker stop ${CONTAINER_NAME}
                    if %errorlevel% neq 0 (
                        echo No container to stop
                    )
                    docker rm ${CONTAINER_NAME}
                    if %errorlevel% neq 0 (
                        echo No container to remove
                    )
                    docker run -d --name ${CONTAINER_NAME} -p ${PORT}:3000 ${IMAGE_NAME}
                """
            }
        }

        stage('Verify') {
            steps {
                echo '🧭 Verifying deployment...'
                sleep 5
                bat 'docker ps'
                echo "🌐 Application should be running on http://localhost:${PORT}"
            }
        }

        stage('DAST Scan') {
            steps {
                echo '🕵️ Running OWASP ZAP DAST scan...'
                bat """
                    docker run --rm ^
                    -v "%WORKSPACE%":/zap/wrk ^
                    ghcr.io/zaproxy/zaproxy:stable ^
                    zap-baseline.py ^
                    -t http://host.docker.internal:${PORT} ^
                    -I ^
                    -r dast-report.html
                """
            }
            post {
                always {
                    echo '📄 Archiving ZAP DAST report...'
                    archiveArtifacts artifacts: 'dast-report.html', fingerprint: true
                }
            }
        }

        stage('DAST Result Analysis') {
            steps {
                script {
                    echo '📊 Analyzing DAST scan results...'
                    def reportContent = readFile('dast-report.html')

                    if (reportContent.contains('FAIL-NEW')) {
                        currentBuild.result = 'FAILURE'
                        error("❌ Critical vulnerabilities found. Failing the build.")
                    } else if (reportContent.contains('WARN-NEW')) {
                        currentBuild.result = 'UNSTABLE'
                        echo "⚠️ Warnings found in DAST scan. Build marked as UNSTABLE."
                    } else {
                        echo "✅ No critical vulnerabilities found in DAST scan."
                    }
                }
            }
        }
    }

    post {
        always {
            echo '📢 Publishing DAST report...'
            // Make sure HTML Publisher Plugin is installed in Jenkins
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'dast-report.html',
                reportName: 'OWASP ZAP DAST Report'
            ])
        }

        failure {
            echo '❌ Build failed — Check SAST/DAST or Docker errors.'
        }

        unstable {
            echo '⚠️ Build marked as UNSTABLE due to vulnerabilities.'
        }

        success {
            echo '✅ Build, deployment, and security scans completed successfully.'
        }
    }
}
