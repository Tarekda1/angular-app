pipeline {
    agent {
        docker {
            image 'tare2da/custom-node-docker:latest' // Ensure Git is installed in this image
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
                git branch: 'main',
                    url: 'git@github.com:Tarekda1/angular-app.git',
                    credentialsId: 'github-ssh-key' // Use credentialsId for SSH key
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
                    sh 'npm run build -omit=dev'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    //def imageName = "${DOCKER_IMAGE}:${DOCKER_TAG}"

                    // 1. Check the builder platform (important!)
                    sh 'echo "Building on platform: $(uname -m)"'

                    // 2. Build for the correct architecture (if you know it)
                    // If your Jenkins agent is on the same platform as your staging server:
                    // sh "docker build -t ${imageName} ."

                    // 3. Multi-architecture build (recommended)
                    // Use a separate build script for more complex multi-arch builds
                    sh './build-multi-arch.sh' // See the script below
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

        stage('Test SSH') {
            steps {
                sshagent(['staging-server-ssh-key']) {
                    sh 'ls -la /var/jenkins_home/workspace/angular-pipeline@tmp/'
                    // Debug: List keys in the SSH agent
                    sh 'ssh-add -l'
                    sh "ssh -o StrictHostKeyChecking=no ${STAGING_USER}@${STAGING_SERVER} 'echo Success!'"
                }
            }
        }

        stage('Deploy to Staging Server') {
            steps {
                script {
                    sshagent(['staging-server-ssh-key']) {
                        sh """
                    ssh -o StrictHostKeyChecking=no ${STAGING_USER}@${STAGING_SERVER} << EOF
                        # 1. Verify Docker context (important!)
                        docker context ls  # List available contexts (if using Docker contexts)
                        docker context use default # Or the context you want to use
                        docker info # Check Docker version and platform on remote server

                        # 2. Pull the image (with error handling)
                        if ! docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}; then
                            echo "Error: Failed to pull image ${DOCKER_IMAGE}:${DOCKER_TAG}"
                            exit 1  # Fail the Jenkins job
                        fi

                        # 3. Stop and remove the container (ignore errors)
                        docker stop angular-app || true
                        docker rm angular-app || true

                        # 4. Run the container (with explicit platform if needed)
                        docker run -d --name angular-app -p 80:80 ${DOCKER_IMAGE}:${DOCKER_TAG} # Or the correct port mapping

                        # 5. Verify container is running
                        docker ps
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
