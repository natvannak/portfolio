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
            ]
        )

        gitParameter(
            name: 'VERSION',
            type: 'PT_TAG',
            defaultValue: '',
            description: 'Select Git tag, for example v1.0.1',
            tagFilter: '*',
            sortMode: 'DESCENDING_SMART',
            selectedValue: 'TOP',
            quickFilterEnabled: true
        )
    }

    environment {
        DOCKERHUB_REPO        = 'natvannak/portfolio'

        MANAGER_HOST          = '3.209.10.87'
        MANAGER_USER          = 'ubuntu'

        STACK_NAME            = 'portfolio'
        SERVICE_NAME          = 'portfolio_web'
        COMPOSE_FILE_NAME     = 'docker-compose.yml'   // stack file used for deploy (dev file docker-compose.yml is untouched)

        APP_DOCKERFILE        = 'docker/php/Dockerfile'      // Laravel (php-fpm) image => natvannak/portfolio:<tag>
        NGINX_DOCKERFILE      = 'docker/nginx/Dockerfile'    // nginx image => natvannak/portfolio:nginx-<tag> (skipped if file not found)
        REMOTE_DIR            = '/home/ubuntu/portfolio'  // remote directory on Swarm manager where docker-compose.yml is copied

        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'      // Username with password (use Access Token)
        SSH_CREDENTIALS       = 'swarm-ssh-key'              // SSH Username with private key
        DB_PASSWORD_CRED      = 'laravel-db-password'        // Secret text
        DB_ROOT_PASSWORD_CRED = 'laravel-db-root-password'   // Secret text

        PATH = '/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin'
    }

    stages {

        stage('Validate Parameters') {
            steps {
                script {
                    def action  = params.ACTION?.trim()
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

                        if (!env.STACK_NAME?.trim() || !env.SERVICE_NAME?.trim()) {
                            error('STACK_NAME / SERVICE_NAME is not configured.')
                        }
                    }

                    env.IMAGE_TAG       = version ?: ''
                    env.FULL_IMAGE_NAME = version
                        ? "${env.DOCKERHUB_REPO}:${version}"
                        : ''
                    env.NGINX_IMAGE_NAME = version
                        ? "${env.DOCKERHUB_REPO}:nginx-${version}"
                        : ''

                    echo "IMAGE TAG : ${env.IMAGE_TAG ?: '(not required)'}"
                    echo "IMAGE     : ${env.FULL_IMAGE_NAME ?: '(not required)'}"
                }
            }
        }

        stage('Checkout Selected Version') {
            steps {
                checkout scm

                sh '''
                    set -eu

                    echo "Fetching Git tags..."
                    git fetch --tags --force origin

                    echo "Checking selected tag: ${IMAGE_TAG}"

                    if ! git rev-parse -q --verify \
                        "refs/tags/${IMAGE_TAG}^{commit}" >/dev/null
                    then
                        echo "ERROR: Git tag '${IMAGE_TAG}' does not exist."
                        exit 1
                    fi

                    echo "Checking out Git tag: ${IMAGE_TAG}"
                    git checkout --force "refs/tags/${IMAGE_TAG}"

                    if [ ! -f "${COMPOSE_FILE_NAME}" ]; then
                        echo "ERROR: ${COMPOSE_FILE_NAME} not found in tag ${IMAGE_TAG}."
                        exit 1
                    fi

                    echo "Tag : ${IMAGE_TAG}"
                '''
            }
        }

        stage('Check Required Commands') {
            when {
                expression {
                    params.ACTION in ['build', 'push']
                }
            }

            steps {
                sh '''
                    set -eu

                    echo "Checking required commands..."

                    command -v git >/dev/null 2>&1 || {
                        echo "ERROR: git is not installed."
                        exit 1
                    }

                    command -v docker >/dev/null 2>&1 || {
                        echo "ERROR: docker is not installed."
                        exit 1
                    }

                    docker version
                    docker compose version
                '''
            }
        }

        stage('Build Docker Image') {
            when {
                expression {
                    params.ACTION == 'build'
                }
            }

            steps {
                sh '''
                    set -eu

                    echo "======================================"
                    echo "Building Docker images"
                    echo "Image: ${FULL_IMAGE_NAME}"
                    echo "======================================"

                    export DOCKER_DEFAULT_PLATFORM=linux/amd64

                    docker build \
                        --platform linux/amd64 \
                        --pull \
                        --file "${APP_DOCKERFILE}" \
                        --tag "${FULL_IMAGE_NAME}" \
                        .

                    if [ -f "${NGINX_DOCKERFILE}" ]; then
                        docker build \
                            --platform linux/amd64 \
                            --pull \
                            --file "${NGINX_DOCKERFILE}" \
                            --tag "${NGINX_IMAGE_NAME}" \
                            .
                    else
                        echo "WARNING: ${NGINX_DOCKERFILE} not found, nginx image not built."
                    fi

                    docker image inspect \
                        "${FULL_IMAGE_NAME}" \
                        --format \
                        'Image ID: {{.Id}} | Created: {{.Created}}'
                '''
            }
        }

        stage('Push to Docker Hub') {
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

                        echo "======================================"
                        echo "Logging in to Docker Hub"
                        echo "======================================"

                        printf '%s' "${DH_PASS}" \
                        | docker login \
                            --username "${DH_USER}" \
                            --password-stdin

                        # Build the images if they do not exist locally yet
                        if ! docker image inspect "${FULL_IMAGE_NAME}" >/dev/null 2>&1
                        then
                            echo "Image not found locally, building..."

                            export DOCKER_DEFAULT_PLATFORM=linux/amd64

                            docker build \
                                --platform linux/amd64 \
                                --pull \
                                --file "${APP_DOCKERFILE}" \
                                --tag "${FULL_IMAGE_NAME}" \
                                .

                            if [ -f "${NGINX_DOCKERFILE}" ]; then
                                docker build \
                                    --platform linux/amd64 \
                                    --pull \
                                    --file "${NGINX_DOCKERFILE}" \
                                    --tag "${NGINX_IMAGE_NAME}" \
                                    .
                            else
                                echo "WARNING: ${NGINX_DOCKERFILE} not found, nginx image not built."
                            fi
                        fi

                        echo "======================================"
                        echo "Pushing Docker image"
                        echo "Image: ${FULL_IMAGE_NAME}"
                        echo "======================================"

                        docker push "${FULL_IMAGE_NAME}"

                        if docker image inspect "${NGINX_IMAGE_NAME}" >/dev/null 2>&1
                        then
                            docker push "${NGINX_IMAGE_NAME}"
                            docker manifest inspect "${NGINX_IMAGE_NAME}" >/dev/null
                        fi

                        echo "======================================"
                        echo "Verifying image on Docker Hub"
                        echo "======================================"

                        docker manifest inspect "${FULL_IMAGE_NAME}" >/dev/null

                        echo "Successfully pushed:"
                        echo "${FULL_IMAGE_NAME}"
                    '''
                }
            }
        }

        stage('Test SSH Connection') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                sshagent(["${SSH_CREDENTIALS}"]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Testing SSH connection"
                        echo "Manager: ${MANAGER_USER}@${MANAGER_HOST}"
                        echo "======================================"

                        ssh \
                            -o BatchMode=yes \
                            -o ConnectTimeout=10 \
                            -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            '
                                set -eu

                                echo "Hostname: $(hostname)"
                                echo "User    : $(whoami)"

                                command -v docker >/dev/null 2>&1 || {
                                    echo "ERROR: Docker is not installed."
                                    exit 1
                                }

                                docker info >/dev/null

                                echo "Docker connection successful."
                            '
                    '''
                }
            }
        }

        stage('Deploy / Rollback Docker Swarm Stack') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
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
                    sshagent(["${SSH_CREDENTIALS}"]) {
                        sh '''
                            set -eu

                            ENV_FILE="${WORKSPACE}/deploy.env"
                            SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=15 \
-o ServerAliveInterval=10 -o ServerAliveCountMax=6 \
-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

                            cleanup() {
                                rm -f "${ENV_FILE}"
                            }

                            trap cleanup EXIT INT TERM

                            echo "======================================"
                            echo "${ACTION} information"
                            echo "======================================"
                            echo "Stack   : ${STACK_NAME}"
                            echo "Service : ${SERVICE_NAME}"
                            echo "Version : ${IMAGE_TAG}"
                            echo "Image   : ${FULL_IMAGE_NAME}"
                            echo "======================================"

                            # Temporary env file (variables used by docker-compose.yml)
                            umask 077
                            printf "IMAGE_TAG='%s'\\nDOCKERHUB_REPO='%s'\\nDB_PASSWORD='%s'\\nDB_ROOT_PASSWORD='%s'\\n" \
                                "${IMAGE_TAG}" \
                                "${DOCKERHUB_REPO}" \
                                "${DB_PASSWORD}" \
                                "${DB_ROOT_PASSWORD}" \
                                > "${ENV_FILE}"

                            echo "Preparing remote directory..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "mkdir -p '${REMOTE_DIR}'"

                            echo "Copying compose file and env file..."

                            scp ${SSH_OPTS} \
                                "${COMPOSE_FILE_NAME}" \
                                "${MANAGER_USER}@${MANAGER_HOST}:${REMOTE_DIR}/docker-compose.yml"

                            scp ${SSH_OPTS} \
                                "${ENV_FILE}" \
                                "${MANAGER_USER}@${MANAGER_HOST}:${REMOTE_DIR}/deploy.env"

                            echo "Logging Docker into Docker Hub on manager..."

                            printf '%s' "${DH_PASS}" \
                            | ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "docker login --username '${DH_USER}' --password-stdin"

                            echo "Deploying stack..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                bash -s -- \
                                "${STACK_NAME}" \
                                "${SERVICE_NAME}" \
                                "${FULL_IMAGE_NAME}" \
                                "${REMOTE_DIR}" <<'REMOTE_SCRIPT'
set -eu

STACK_NAME="$1"
SERVICE_NAME="$2"
FULL_IMAGE_NAME="$3"
REMOTE_DIR="$4"

cd "${REMOTE_DIR}"

cleanup_remote() {
    rm -f "${REMOTE_DIR}/deploy.env"
}

trap cleanup_remote EXIT INT TERM

SWARM_CONTROL="$(docker info --format '{{.Swarm.ControlAvailable}}')"

if [ "${SWARM_CONTROL}" != "true" ]; then
    echo "ERROR: This server is not a Swarm Manager."
    exit 1
fi

echo "Checking image on Docker Hub: ${FULL_IMAGE_NAME}"
docker manifest inspect "${FULL_IMAGE_NAME}" >/dev/null

PREVIOUS_IMAGE="$(docker service inspect \
    --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
    "${SERVICE_NAME}" 2>/dev/null || echo '(none)')"

echo "Previous image: ${PREVIOUS_IMAGE}"
echo "New image     : ${FULL_IMAGE_NAME}"

# Load variables for docker-compose.yml
set -a
. "${REMOTE_DIR}/deploy.env"
set +a

docker stack deploy \
    --compose-file "${REMOTE_DIR}/docker-compose.yml" \
    --with-registry-auth \
    --resolve-image always \
    --prune \
    --detach=false \
    "${STACK_NAME}"

UPDATED_IMAGE="$(docker service inspect \
    --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
    "${SERVICE_NAME}")"

echo "======================================"
echo "Result"
echo "======================================"
echo "Expected: ${FULL_IMAGE_NAME}"
echo "Current : ${UPDATED_IMAGE}"

case "${UPDATED_IMAGE}" in
    "${FULL_IMAGE_NAME}"|"${FULL_IMAGE_NAME}@sha256:"*)
        echo "Stack deployment completed successfully."
        ;;
    *)
        echo "ERROR: Image verification failed."
        docker service ps --no-trunc "${SERVICE_NAME}"
        exit 1
        ;;
esac
REMOTE_SCRIPT
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                sshagent(["${SSH_CREDENTIALS}"]) {
                    sh '''
                        set -eu

                        ssh \
                            -o BatchMode=yes \
                            -o ConnectTimeout=10 \
                            -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            bash -s -- "${STACK_NAME}" "${SERVICE_NAME}" <<'REMOTE_SCRIPT'
set -eu

STACK_NAME="$1"
SERVICE_NAME="$2"

echo "======================================"
echo "Stack Services (web, db)"
echo "======================================"
docker stack services "${STACK_NAME}"

echo "======================================"
echo "Current Web Image"
echo "======================================"
docker service inspect \
    --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
    "${SERVICE_NAME}"

echo "======================================"
echo "Web Update Status"
echo "======================================"
docker service inspect \
    --format '{{json .UpdateStatus}}' \
    "${SERVICE_NAME}"

echo "======================================"
echo "Stack Tasks"
echo "======================================"
docker stack ps --no-trunc "${STACK_NAME}"
REMOTE_SCRIPT
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'Pipeline completed successfully.'
            echo "ACTION : ${params.ACTION}"
            echo "VERSION: ${params.VERSION ?: '(not required)'}"
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'Pipeline failed.'
            echo 'Check the failed stage logs above.'
            echo '======================================'
        }

        aborted {
            echo 'Pipeline was aborted.'
        }

        always {
            sh '''
                rm -f "$WORKSPACE/deploy.env" 2>/dev/null || true
            '''

            cleanWs(
                cleanWhenNotBuilt: false,
                deleteDirs: true,
                disableDeferredWipeout: false,
                notFailBuild: true
            )
        }
    }
}