
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
        GIT_TAG = "${params.GIT_TAG}"
    }

    stages {

        stage('1. Checkout Selected Git Tag') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "refs/tags/${params.GIT_TAG}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/natvannak/portfolio.git',
                        refspec: '+refs/tags/*:refs/remotes/origin/tags/*'
                    ]]
                ])

                sh '''
                    echo "Selected Version: ${GIT_TAG}"
                    git describe --tags --exact-match
                    git log -1 --oneline
                '''
            }
        }

        stage('2. Validate Deployment Files') {
            steps {
                sh '''
                    set -eu

                    test -f .env.example
                    test -f docker/php/Dockerfile
                    test -f docker/nginx/Dockerfile

                    echo "All required files found."
                '''
            }
        }

        stage('3. Prepare CI Environment') {
            steps {
                sh '''
                    cp .env.example .env
                    test -f .env
                    echo "CI environment prepared."
                '''
            }
        }

        stage('4. Build CI Runtime') {
            steps {
                sh 'docker compose build app'
            }
        }

        stage('5. Install Composer Dependencies') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    composer install \
                    --no-interaction \
                    --prefer-dist
                '''
            }
        }

        stage('6. Generate Testing Key') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan key:generate --force
                '''
            }
        }

        stage('7. PHPUnit Tests') {
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan test
                '''
            }
        }

        stage('8. Build Versioned Docker Images') {
            steps {
                sh '''
                    set -eu

                    echo "Building Laravel: ${GIT_TAG}"

                    docker build --pull \
                    -t ${APP_IMAGE}:${GIT_TAG} \
                    -f docker/php/Dockerfile .

                    echo "Building Nginx: ${GIT_TAG}"

                    docker build --pull \
                    -t ${NGINX_IMAGE}:${GIT_TAG} \
                    -f docker/nginx/Dockerfile .

                    echo "Both Docker images built successfully."
                '''
            }
        }

        stage('9. Docker Hub Login') {
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

        stage('10. Push Versioned Images') {
            steps {
                sh '''
                    set -eu

                    docker push ${APP_IMAGE}:${GIT_TAG}
                    docker push ${NGINX_IMAGE}:${GIT_TAG}

                    echo "Version ${GIT_TAG} pushed successfully."
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
            echo 'Pipeline failed. Check the failed stage in Console Output.'
        }
    }
}
