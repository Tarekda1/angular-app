pipeline {
    agent {
        docker {
            image 'tare2da/custom-node-docker:latest' // Custom image with Node.js and Docker CLI
        }
    }

    environment {
        DOCKER_IMAGE = 'tare2da/angular-app'
        DOCKER_TAG = "v${BUILD_NUMBER}"
        STAGING_SERVER = '216.215.105.13'
        STAGING_USER = 'tdaaboul'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Clear the workspace before starting
            }
        }

        stage('Checkout') {
            steps {
                sshagent(['github-ssh-key']) {
                    script {
                        git branch: 'main',
                            url: 'git@github.com:Tarekda1/angular-app.git'
                    }
                }
            }
        }

        stage('Verify Node.js Version') {
            steps {
                sh 'node --version'
                sh 'npm --version'
            }
        }

        stage('Build Angular App') {
            steps {
                script {
                    sh 'npm install'
                    sh 'npm run build -- --prod'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to Staging Server') {
            steps {
                script {
                    sshagent(['staging-server-ssh-key']) {
                        sh """
                            ssh ${STAGING_USER}@${STAGING_SERVER} << EOF
                                docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                                docker stop angular-app || true
                                docker rm angular-app || true
                                docker run -d --name angular-app -p 80:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                            EOF
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment to staging server successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}