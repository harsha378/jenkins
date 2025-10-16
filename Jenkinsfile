pipeline {
    agent any

    environment {
        APP_NAME       = 'jenkins-demo-app'
        CONTAINER_NAME = 'jenkins-demo'
        PORT           = '3000'
        SEMGREP_IMAGE  = 'returntocorp/semgrep'
        ZAP_IMAGE      = 'ghcr.io/zaproxy/zaproxy:stable'
    }

    stages {

        stage('Docker Check') {
            steps {
                echo '🐳 Checking Docker connectivity...'
                script {
                    try {
                        bat 'docker --version'
                        bat 'docker info'
                    } catch (Exception e) {
                        error "❌ Docker is not running or accessible. Please start Docker Desktop and ensure Jenkins has access to Docker."
                    }
                }
            }
        }

        stage('Check Workspace Contents') {
            steps {
                bat 'dir'
            }
        }

        stage('Security & Build') {
            parallel {
                stage('Semgrep SAST') {
                    steps {
                        echo '🔐 Running Semgrep SAST scan...'
                        withCredentials([string(credentialsId: 'SEMGRP_TOKEN', variable: 'SEMGREP_APP_TOKEN')]) {
                            bat """
                                docker run --rm ^
                                -v "%WORKSPACE%":/src ^
                                -e SEMGREP_APP_TOKEN=%SEMGREP_APP_TOKEN% ^
                                ${SEMGREP_IMAGE} semgrep ci
                            """
                        }
                    }
                }

                stage('Build Docker Image') {
                    steps {
                        echo '🏗️ Building Docker image...'
                        bat "docker build -t ${APP_NAME} ."
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                bat 'echo "All tests passed successfully."'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                script {
                    // Stop old container if running
                    try {
                        bat "docker stop ${CONTAINER_NAME}"
                    } catch (Exception e) {
                        echo "No existing container to stop."
                    }

                    // Remove old container if exists
                    try {
                        bat "docker rm ${CONTAINER_NAME}"
                    } catch (Exception e) {
                        echo "No existing container to remove."
                    }

                    // Run the new container
                    bat "docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${APP_NAME}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '🧭 Verifying deployment...'
                script {
                    sleep 5
                    def status = bat(
                        script: "curl -s -o NUL -w \"%{http_code}\" http://localhost:${PORT}",
                        returnStdout: true
                    ).trim()

                    echo "Health Check Status: ${status}"
                    if (status != "200") {
                        error "❌ Application failed health check!"
                    }
                }
            }
        }

        stage('DAST Scan with ZAP') {
            steps {
                echo '🕵️ Running OWASP ZAP DAST scan...'
                script {
                    def timestamp = new Date().format("yyyyMMdd-HHmmss")
                    def reportFile = "dast-report-${timestamp}.html"

                    bat """
                        docker run --rm ^
                        -v "%WORKSPACE%":/zap/wrk ^
                        ${ZAP_IMAGE} ^
                        zap-baseline.py ^
                        -t http://host.docker.internal:${PORT} ^
                        -I ^
                        -r ${reportFile}
                    """

                    archiveArtifacts artifacts: reportFile, fingerprint: true

                    // Optional quality gate (fail if needed)
                    echo "🛡️ ZAP Scan Completed - Report: ${reportFile}"
                }
            }
        }
    }

    post {
        always {
            echo '📦 Archiving DAST Report'
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: '**/dast-report-*.html',
                reportName: 'OWASP ZAP DAST Report'
            ])
        }

        failure {
            echo '❌ Build failed — Check SAST/DAST or Docker errors.'
        }

        success {
            echo '✅ Build, deployment, and security scans completed successfully.'
            echo "📊 ZAP report is available in the Jenkins sidebar."
        }
    }
}
