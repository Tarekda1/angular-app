pipeline {
   agent {
        docker {
            image 'tare2da/custom-node-docker:latest'
        }
    }

    environment {
        DOCKER_IMAGE = 'tare2da/angular-app'
        DOCKER_TAG = "v${BUILD_NUMBER}"
        STAGING_SERVER = '216.215.105.137'
        STAGING_USER = 'tdaaboul'
    }

    stages {

        stage('Checkout') {
            steps {
                sshagent(['github-ssh-key']) { // Assuming 'github-ssh-key' is your SSH key credential ID
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']], // Or specify a branch like '*/main', '*/develop'
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                            credentialsId: 'github-ssh-key', // Same credential ID as sshagent
                            url: 'git@github.com:Tarekda1/angular-app.git'
                        ]]
                    ])
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
                    // Install dependencies and build the Angular app
                    sh 'npm install'
                    sh 'npm run build --prod'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Log in to Docker Hub (or your container registry)
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                    // Push the Docker image to Docker Hub
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to Staging Server') {
            steps {
                script {
                    // SSH into the staging server and pull/run the latest Docker image
                    sshagent(['github-ssh-key']) {
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