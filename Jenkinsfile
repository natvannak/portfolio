
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
    APP_IMAGE = 'portfolio-app'
    COMPOSE_PROJECT_NAME = 'portfolio-ci'
    DOCKERHUB_USER = 'msr160004'
    }

    stages {

        stage('1. Checkout GitHub') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('2. Prepare CI Environment') {
            steps {
                sh '''
                    cp .env.example .env
                    test -f .env
                    echo "CI environment prepared"
                '''
            }
        }

        stage('3. Build CI Runtime') {
            steps {
                sh 'docker compose build app'
            }
        }

        stage('4. Install Composer Dependencies') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    composer install \
                    --no-interaction \
                    --prefer-dist
                '''
            }
        }

        stage('5. Generate Testing Key') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan key:generate --force
                '''
            }
        }

        stage('6. PHPUnit Tests') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan test
                '''
            }
        }

        stage('7. Build Production Docker Image') {
            steps {
                sh '''
                    docker build \
                    --pull \
                    -t ${APP_IMAGE}:${BUILD_NUMBER} \
                    -t ${APP_IMAGE}:latest \
                    -f docker/php/Dockerfile .
                '''
            }
        }
        stage('8. Push Image to Docker Hub') {
            steps {
             withCredentials([
             usernamePassword(
                credentialsId: 'dockerhub-credentials',
                usernameVariable: 'DOCKERHUB_USERNAME',
                passwordVariable: 'DOCKERHUB_TOKEN'
            )
            ]) {
            sh '''
                echo "$DOCKERHUB_TOKEN" | docker login \
                    -u "$DOCKERHUB_USERNAME" \
                    --password-stdin

                docker tag ${APP_IMAGE}:${BUILD_NUMBER} \
                    ${DOCKERHUB_USER}/${APP_IMAGE}:${BUILD_NUMBER}

                docker tag ${APP_IMAGE}:latest \
                    ${DOCKERHUB_USER}/${APP_IMAGE}:latest

                docker push ${DOCKERHUB_USER}/${APP_IMAGE}:${BUILD_NUMBER}
                docker push ${DOCKERHUB_USER}/${APP_IMAGE}:latest

                docker logout
            '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker compose down --remove-orphans || true'
        }

        success {
            echo 'CI Pipeline completed successfully!'
        }

        failure {
            echo 'CI Pipeline failed. Check the stage logs.'
        }
    }
}
