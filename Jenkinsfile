
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

        stage('1. Prepare Workspace') {
            steps {
                deleteDir()
                echo "Action: ${params.DEPLOY_ACTION}"
                echo "Version: ${params.GIT_TAG}"
            }
        }

        stage('2. Checkout Selected Git Tag') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "refs/tags/${params.GIT_TAG}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/natvannak/portfolio.git',
                        refspec: '+refs/tags/*:refs/tags/*'
                    ]]
                ])

                sh '''
                    set -eu
                    git describe --tags --exact-match
                    git rev-parse HEAD
                '''
            }
        }

        stage('3. Validate Deployment Files') {
            steps {
                sh '''
                    set -eu
                    test -f .env.example
                    test -f docker/php/Dockerfile
                    test -f docker/nginx/Dockerfile
                    echo "Deployment files validated."
                '''
            }
        }

        stage('4. Prepare CI Environment') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh 'cp .env.example .env'
            }
        }

        stage('5. Build CI Runtime') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh 'docker compose build app'
            }
        }

        stage('6. Install Composer Dependencies') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    composer install --no-interaction --prefer-dist
                '''
            }
        }

        stage('7. Generate Testing Key') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan key:generate --force
                '''
            }
        }

        stage('8. PHPUnit Tests') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh '''
                    docker compose run --rm --no-deps app \
                    php artisan test
                '''
            }
        }

        stage('9. Build Versioned Images') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh '''
                    set -eu

                    docker build --pull \
                    -t ${APP_IMAGE}:${GIT_TAG} \
                    -f docker/php/Dockerfile .

                    docker build --pull \
                    -t ${NGINX_IMAGE}:${GIT_TAG} \
                    -f docker/nginx/Dockerfile .
                '''
            }
        }

        stage('10. Docker Hub Login') {
            when {
                expression {
                    params.DEPLOY_ACTION == 'DEPLOY' ||
                    params.DEPLOY_ACTION == 'ROLLBACK'
                }
            }
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

        stage('11. Push Versioned Images') {
            when {
                expression { params.DEPLOY_ACTION == 'DEPLOY' }
            }
            steps {
                sh '''
                    docker push ${APP_IMAGE}:${GIT_TAG}
                    docker push ${NGINX_IMAGE}:${GIT_TAG}
                '''
            }
        }

        stage('12. Verify Rollback Images') {
            when {
                expression { params.DEPLOY_ACTION == 'ROLLBACK' }
            }
            steps {
                sh '''
                    set -eu

                    docker manifest inspect \
                    ${APP_IMAGE}:${GIT_TAG} > /dev/null

                    docker manifest inspect \
                    ${NGINX_IMAGE}:${GIT_TAG} > /dev/null

                    echo "Both rollback images are available."
                '''
            }
        }
    }

    post {
        always {
            sh 'docker compose down --remove-orphans || true'
            sh 'docker logout || true'
        }

        success {
            echo "Pipeline completed: ${params.DEPLOY_ACTION} ${params.GIT_TAG}"
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
