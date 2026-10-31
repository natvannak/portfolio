
pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_ACTION',
            choices: ['DEPLOY', 'ROLLBACK'],
            description: 'Select deployment action'
        )

        choice(
            name: 'GIT_TAG',
            choices: ['v1.3.0', 'v1.2.0', 'v1.0.0'],
            description: 'Select Git release version'
        )
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        APP_IMAGE = 'sortsom/portfolio-laravel'
        NGINX_IMAGE = 'sortsom/portfolio-nginx'
        COMPOSE_PROJECT_NAME = 'portfolio-ci'
    }

    stages {
        stage('1. Checkout Selected Git Tag') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "refs/tags/${params.GIT_TAG}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/natvannak/portfolio.git'
                    ]]
                ])

                sh 'git describe --tags --exact-match'
            }
        }

        stage('2. Prepare CI Environment') {
            steps {
                sh '''
                    cp .env.example .env
                    test -f .env
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
                    composer install --no-interaction --prefer-dist
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

        stage('7. Build Versioned Images') {
            steps {
                sh '''
                    docker build --pull \
                    -t ${APP_IMAGE}:${GIT_TAG} \
                    -f docker/php/Dockerfile .

                    docker build --pull \
                    -t ${NGINX_IMAGE}:${GIT_TAG} \
                    -f docker/nginx/Dockerfile .
                '''
            }
        }

        stage('8. Docker Hub Login') {
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

        stage('9. Push Versioned Images') {
            steps {
                sh '''
                    docker push ${APP_IMAGE}:${GIT_TAG}
                    docker push ${NGINX_IMAGE}:${GIT_TAG}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker compose down --remove-orphans || true'
        }

        success {
            echo 'Versioned CI Build completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check stage logs.'
        }
    }
}
