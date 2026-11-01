pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)

        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: [
                'build',
                'push',
                'deploy',
                'rollback'
            ],
            description: 'Select pipeline action'
        )

        gitParameter(
            name: 'VERSION',
            type: 'PT_TAG',
            defaultValue: '',
            description: 'Select Git tag, for example v1.6.0',
            tagFilter: '*',
            sortMode: 'DESCENDING_SMART',
            selectedValue: 'TOP',
            quickFilterEnabled: true
        )
    }

    environment {
        GITHUB_REPO = 'https://github.com/natvannak/portfolio.git'

        DOCKERHUB_REPO = 'natvannak/portfolio'

        MANAGER_HOST = '3.209.10.87'
        MANAGER_USER = 'ubuntu'

        STACK_NAME = 'portfolio'

        APP_SERVICE = 'portfolio_app'
        NGINX_SERVICE = 'portfolio_nginx'
        DB_SERVICE = 'portfolio_db'

        COMPOSE_FILE_NAME = 'docker-compose.yml'

        APP_DOCKERFILE = 'docker/php/Dockerfile'
        NGINX_DOCKERFILE = 'docker/nginx/Dockerfile'

        REMOTE_DIR = '/home/ubuntu/portfolio'

        DOCKERHUB_CREDENTIALS = 'docker-hub-id'
        SSH_CREDENTIALS = 'portfolio-swarm-key'

        DB_PASSWORD_CRED = 'portfolio-db-password'
        DB_ROOT_PASSWORD_CRED = 'portfolio-db-root-password'

        PATH = '/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin'
    }


    stages {

        /*
         * ============================================
         * 1. Validate Parameters
         * ============================================
         */
        stage('Validate Parameters') {
            steps {
                script {
                    def action = params.ACTION?.trim()
                    def version = params.VERSION?.trim()

                    echo '======================================'
                    echo "ACTION  : ${action}"
                    echo "VERSION : ${version ?: '(not selected)'}"
                    echo '======================================'

                    if (!action) {
                        error('ACTION is required.')
                    }

                    if (action in ['build', 'push', 'deploy', 'rollback']) {

                        if (!version) {
                            error(
                                'VERSION is required. ' +
                                'Create and push a Git tag, then select it.'
                            )
                        }

                        if (!(version ==~ /^[A-Za-z0-9][A-Za-z0-9._-]*$/)) {
                            error(
                                "Invalid VERSION '${version}'. " +
                                'Use letters, numbers, dots, underscores or hyphens.'
                            )
                        }
                    }

                    if (action == 'deploy' || action == 'rollback') {
                        if (!env.MANAGER_HOST?.trim()) {
                            error('MANAGER_HOST is not configured.')
                        }

                        if (!env.MANAGER_USER?.trim()) {
                            error('MANAGER_USER is not configured.')
                        }
                    }
                }
            }
        }


        /*
         * ============================================
         * 2. Prepare Workspace
         * ============================================
         */
        stage('Prepare Workspace') {
            steps {
                deleteDir()

                echo '======================================'
                echo 'Preparing workspace'
                echo '======================================'
            }
        }


        /*
         * ============================================
         * 3. Checkout Selected Git Tag
         * ============================================
         */
        stage('Checkout Git Tag') {
            steps {
                checkout([
                    $class: 'GitSCM',

                    branches: [[
                        name: "refs/tags/${params.VERSION}"
                    ]],

                    userRemoteConfigs: [[
                        url: "${GITHUB_REPO}",
                        refspec: '+refs/tags/*:refs/tags/*'
                    ]]
                ])

                sh '''
                    set -eu

                    echo "======================================"
                    echo "Git Information"
                    echo "======================================"

                    echo "Requested tag : ${VERSION}"

                    git rev-parse HEAD

                    CHECKED_TAG="$(git describe --tags --exact-match)"

                    echo "Checked tag   : ${CHECKED_TAG}"

                    if [ "${CHECKED_TAG}" != "${VERSION}" ]; then
                        echo "ERROR: Checked-out tag does not match VERSION."
                        exit 1
                    fi
                '''
            }
        }


        /*
         * ============================================
         * 4. Validate Deployment Files
         * ============================================
         */
        stage('Validate Deployment Files') {
            steps {
                sh '''
                    set -eu

                    echo "======================================"
                    echo "Validating deployment files"
                    echo "======================================"

                    if [ ! -f "${APP_DOCKERFILE}" ]; then
                        echo "ERROR: ${APP_DOCKERFILE} not found."
                        exit 1
                    fi

                    if [ ! -f "${NGINX_DOCKERFILE}" ]; then
                        echo "ERROR: ${NGINX_DOCKERFILE} not found."
                        exit 1
                    fi

                    if [ ! -f "${COMPOSE_FILE_NAME}" ]; then
                        echo "ERROR: ${COMPOSE_FILE_NAME} not found."
                        exit 1
                    fi

                    command -v docker >/dev/null 2>&1 || {
                        echo "ERROR: docker command not found."
                        exit 1
                    }

                    command -v ssh >/dev/null 2>&1 || {
                        echo "ERROR: ssh command not found."
                        exit 1
                    }

                    command -v scp >/dev/null 2>&1 || {
                        echo "ERROR: scp command not found."
                        exit 1
                    }

                    echo "Validation successful."
                '''
            }
        }


        /*
         * ============================================
         * 5. Build Images
         * ============================================
         */
        stage('Build Docker Images') {

            when {
                anyOf {
                    expression {
                        params.ACTION == 'build'
                    }

                    expression {
                        params.ACTION == 'push'
                    }
                }
            }

            steps {
                sh '''
                    set -eu

                    APP_IMAGE="${DOCKERHUB_REPO}:${VERSION}"
                    NGINX_IMAGE="${DOCKERHUB_REPO}:nginx-${VERSION}"

                    echo "======================================"
                    echo "Building Docker Images"
                    echo "======================================"

                    echo "App image   : ${APP_IMAGE}"
                    echo "Nginx image : ${NGINX_IMAGE}"

                    docker build \
                        -f "${APP_DOCKERFILE}" \
                        -t "${APP_IMAGE}" \
                        .

                    docker build \
                        -f "${NGINX_DOCKERFILE}" \
                        -t "${NGINX_IMAGE}" \
                        .

                    echo "======================================"
                    echo "Docker build completed"
                    echo "======================================"
                '''
            }
        }


        /*
         * ============================================
         * 6. Push Images
         * ============================================
         */
        stage('Push Docker Images') {

            when {
                expression {
                    params.ACTION == 'push'
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    )
                ]) {

                    sh '''
                        set -eu

                        APP_IMAGE="${DOCKERHUB_REPO}:${VERSION}"
                        NGINX_IMAGE="${DOCKERHUB_REPO}:nginx-${VERSION}"

                        echo "======================================"
                        echo "Docker Hub Login"
                        echo "======================================"

                        printf '%s' "${DH_PASS}" |
                            docker login \
                            --username "${DH_USER}" \
                            --password-stdin

                        echo "======================================"
                        echo "Pushing application image"
                        echo "======================================"

                        docker push "${APP_IMAGE}"

                        echo "======================================"
                        echo "Pushing nginx image"
                        echo "======================================"

                        docker push "${NGINX_IMAGE}"

                        echo "======================================"
                        echo "Push completed"
                        echo "======================================"
                    '''
                }
            }
        }


        /*
         * ============================================
         * 7. Deploy / Rollback Docker Swarm
         * ============================================
         */
        stage('Deploy / Rollback Docker Swarm Stack') {

            when {
                anyOf {
                    expression {
                        params.ACTION == 'deploy'
                    }

                    expression {
                        params.ACTION == 'rollback'
                    }
                }
            }

            steps {

                withCredentials([

                    usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    ),

                    string(
                        credentialsId: "${DB_PASSWORD_CRED}",
                        variable: 'DB_PASSWORD'
                    ),

                    string(
                        credentialsId: "${DB_ROOT_PASSWORD_CRED}",
                        variable: 'DB_ROOT_PASSWORD'
                    )

                ]) {

                    sshagent(credentials: ["${SSH_CREDENTIALS}"]) {

                        sh '''
                            set -eu

                            ENV_FILE="${WORKSPACE}/deploy.env"

                            SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=10 -o ServerAliveCountMax=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

                            cleanup_local() {
                                rm -f "${ENV_FILE}"
                            }

                            trap cleanup_local EXIT INT TERM

                            APP_IMAGE="${DOCKERHUB_REPO}:${VERSION}"
                            NGINX_IMAGE="${DOCKERHUB_REPO}:nginx-${VERSION}"

                            echo "======================================"
                            echo "Deployment Information"
                            echo "======================================"

                            echo "Action      : ${ACTION}"
                            echo "Stack       : ${STACK_NAME}"
                            echo "Version     : ${VERSION}"
                            echo "App image   : ${APP_IMAGE}"
                            echo "Nginx image : ${NGINX_IMAGE}"
                            echo "Manager     : ${MANAGER_HOST}"

                            echo "======================================"

                            if [ "${ACTION}" = "rollback" ]; then

                                echo "Starting rollback..."

                                ssh ${SSH_OPTS} \
                                    "${MANAGER_USER}@${MANAGER_HOST}" \
                                    "
                                    set -eu

                                    echo 'Rolling back ${APP_SERVICE}...'

                                    if docker service inspect '${APP_SERVICE}' >/dev/null 2>&1; then
                                        docker service rollback '${APP_SERVICE}'
                                    else
                                        echo 'ERROR: ${APP_SERVICE} not found.'
                                        exit 1
                                    fi

                                    echo 'Rolling back ${NGINX_SERVICE}...'

                                    if docker service inspect '${NGINX_SERVICE}' >/dev/null 2>&1; then
                                        docker service rollback '${NGINX_SERVICE}'
                                    else
                                        echo 'WARNING: ${NGINX_SERVICE} not found.'
                                    fi

                                    echo 'Rollback commands completed.'
                                    "

                                exit 0
                            fi


                            echo "Creating temporary deploy.env..."

                            umask 077

                            {
                                printf 'VERSION=%s\\n' "${VERSION}"
                                printf 'DOCKERHUB_REPO=%s\\n' "${DOCKERHUB_REPO}"
                                printf 'APP_IMAGE=%s\\n' "${APP_IMAGE}"
                                printf 'NGINX_IMAGE=%s\\n' "${NGINX_IMAGE}"
                                printf 'DB_PASSWORD=%s\\n' "${DB_PASSWORD}"
                                printf 'DB_ROOT_PASSWORD=%s\\n' "${DB_ROOT_PASSWORD}"
                            } > "${ENV_FILE}"


                            echo "Checking SSH connection..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "echo 'SSH connection successful.'"


                            echo "Creating remote deployment directory..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "mkdir -p '${REMOTE_DIR}'"


                            echo "Uploading deployment files..."

                            scp ${SSH_OPTS} \
                                "${COMPOSE_FILE_NAME}" \
                                "${ENV_FILE}" \
                                "${MANAGER_USER}@${MANAGER_HOST}:${REMOTE_DIR}/"


                            echo "Logging Docker Swarm manager into registry..."

                            printf '%s' "${DH_PASS}" |
                                ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "docker login \
                                --username '${DH_USER}' \
                                --password-stdin"


                            echo "Deploying Docker Swarm stack..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "
                                set -eu

                                cd '${REMOTE_DIR}'

                                set -a
                                . ./deploy.env
                                set +a

                                echo '======================================'
                                echo 'Deploying stack'
                                echo '======================================'

                                echo \"Version: \\${VERSION}\"
                                echo \"App    : \\${APP_IMAGE}\"
                                echo \"Nginx  : \\${NGINX_IMAGE}\"

                                docker stack deploy \
                                    --with-registry-auth \
                                    --prune \
                                    -c '${COMPOSE_FILE_NAME}' \
                                    '${STACK_NAME}'

                                echo '======================================'
                                echo 'Stack services'
                                echo '======================================'

                                docker stack services '${STACK_NAME}'

                                rm -f ./deploy.env
                                "

                            echo "======================================"
                            echo "Deployment command completed"
                            echo "======================================"
                        '''
                    }
                }
            }
        }


        /*
         * ============================================
         * 8. Verify Deployment
         * ============================================
         */
        stage('Verify Deployment') {

            when {
                anyOf {
                    expression {
                        params.ACTION == 'deploy'
                    }

                    expression {
                        params.ACTION == 'rollback'
                    }
                }
            }

            steps {

                sshagent(credentials: ["${SSH_CREDENTIALS}"]) {

                    sh '''
                        set -eu

                        SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=10 -o ServerAliveCountMax=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

                        echo "======================================"
                        echo "Docker Swarm Nodes"
                        echo "======================================"

                        ssh ${SSH_OPTS} \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            "docker node ls"

                        echo "======================================"
                        echo "Stack Services"
                        echo "======================================"

                        ssh ${SSH_OPTS} \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            "docker stack services '${STACK_NAME}'"

                        echo "======================================"
                        echo "Stack Tasks"
                        echo "======================================"

                        ssh ${SSH_OPTS} \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            "docker stack ps '${STACK_NAME}' --no-trunc"
                    '''
                }
            }
        }


        /*
         * ============================================
         * 9. Safe Docker Cleanup
         * ============================================
         */
        stage('Safe Docker Cleanup') {

            when {
                anyOf {
                    expression {
                        params.ACTION == 'deploy'
                    }

                    expression {
                        params.ACTION == 'rollback'
                    }
                }
            }

            steps {

                sshagent(credentials: ["${SSH_CREDENTIALS}"]) {

                    sh '''
                        set -eu

                        SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=10 -o ServerAliveCountMax=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

                        echo "======================================"
                        echo "Safe Docker Cleanup"
                        echo "======================================"

                        ssh ${SSH_OPTS} \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            "
                            set -eu

                            echo 'Disk usage before cleanup:'
                            docker system df || true

                            echo 'Removing dangling images only...'

                            docker image prune -f || true

                            echo 'Removing stopped containers...'

                            docker container prune -f || true

                            echo 'Removing unused build cache...'

                            docker builder prune -f || true

                            echo 'Disk usage after cleanup:'
                            docker system df || true

                            echo 'Cleanup completed.'
                            "
                    '''
                }
            }
        }
    }


    /*
     * ============================================
     * Post Actions
     * ============================================
     */
    post {

        success {
            echo '======================================'
            echo 'Pipeline completed successfully.'
            echo "ACTION : ${params.ACTION}"
            echo "VERSION: ${params.VERSION}"
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'Pipeline failed.'
            echo "ACTION : ${params.ACTION}"
            echo "VERSION: ${params.VERSION}"
            echo 'Check the failed stage logs above.'
            echo '======================================'
        }

        always {

            sh '''
                set +e

                rm -f "${WORKSPACE}/deploy.env"

                exit 0
            '''

            cleanWs()
        }
    }
}