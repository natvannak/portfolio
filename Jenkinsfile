
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
    APP_IMAGE = 'sortsom/portfolio-laravel'
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
        
        stage('8.Docker Hub Login') {
        steps {
            withCredentials([
            usernamePassword(
                credentialsId: 'dockerhub-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )
            ]) {
            sh '''
                echo "$DOCKER_PASS" | docker login \
                    -u "$DOCKER_USER" --password-stdin
            '''
                }
            }
        }
        stage('9. Push Docker Image') {
            steps {
                sh '''
            echo "Pushing Docker images to Docker Hub..."

            docker push ${APP_IMAGE}:${BUILD_NUMBER}

            docker push ${APP_IMAGE}:latest

            echo "Docker images pushed successfully!"
        '''
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
