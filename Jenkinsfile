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
        /*
         * Docker Hub
         */
        DOCKERHUB_REPO = 'natvannak/portfolio'

        /*
         * Docker Swarm Manager
         */
        MANAGER_HOST = '3.209.10.87'
        MANAGER_USER = 'ubuntu'

        /*
         * Docker Swarm Stack
         */
        STACK_NAME = 'portfolio'

        APP_SERVICE_NAME   = 'portfolio_app'
        NGINX_SERVICE_NAME = 'portfolio_nginx'
        DB_SERVICE_NAME    = 'portfolio_db'

        COMPOSE_FILE_NAME = 'docker-compose.yml'

        /*
         * Dockerfiles
         */
        APP_DOCKERFILE   = 'docker/php/Dockerfile'
        NGINX_DOCKERFILE = 'docker/nginx/Dockerfile'

        /*
         * Remote deployment directory
         */
        REMOTE_DIR = '/home/ubuntu/portfolio'

        /*
         * Jenkins Credential IDs
         */
        DOCKERHUB_CREDENTIALS = 'docker-hub-id'
        SSH_CREDENTIALS       = 'portfolio-swarm-key'

        DB_PASSWORD_CRED      = 'portfolio-db-password'
        DB_ROOT_PASSWORD_CRED = 'portfolio-db-root-password'

        /*
         * Docker cleanup configuration
         *
         * Keep two Swarm task history entries.
         * Delete only unused Docker resources older than seven days.
         */
        TASK_HISTORY_LIMIT = '2'
        CLEANUP_OLDER_THAN = '168h'
        CLEANUP_IMAGE      = 'docker:27-cli'

        PATH = '/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin'
    }

    stages {

        /*
         * ============================================================
         * Validate Parameters
         * ============================================================
         */
        stage('Validate Parameters') {
            steps {
                script {
                    def action  = params.ACTION?.trim()
                    def version = params.VERSION?.trim()

                    echo '======================================'
                    echo 'Pipeline Parameters'
                    echo '======================================'
                    echo "ACTION  : ${action ?: '(not selected)'}"
                    echo "VERSION : ${version ?: '(not selected)'}"
                    echo '======================================'

                    if (!action) {
                        error('ACTION is required.')
                    }

                    if (!(action in ['build', 'push', 'deploy', 'rollback'])) {
                        error("Unsupported ACTION: ${action}")
                    }

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

                    if (action in ['deploy', 'rollback']) {
                        if (!env.MANAGER_HOST?.trim()) {
                            error('MANAGER_HOST is not configured.')
                        }

                        if (!env.MANAGER_USER?.trim()) {
                            error('MANAGER_USER is not configured.')
                        }

                        if (
                            !env.STACK_NAME?.trim() ||
                            !env.APP_SERVICE_NAME?.trim() ||
                            !env.NGINX_SERVICE_NAME?.trim() ||
                            !env.DB_SERVICE_NAME?.trim()
                        ) {
                            error(
                                'STACK_NAME, APP_SERVICE_NAME, ' +
                                'NGINX_SERVICE_NAME and DB_SERVICE_NAME ' +
                                'must be configured.'
                            )
                        }
                    }

                    env.IMAGE_TAG = version

                    env.FULL_IMAGE_NAME =
                        "${env.DOCKERHUB_REPO}:${version}"

                    env.NGINX_IMAGE_NAME =
                        "${env.DOCKERHUB_REPO}:nginx-${version}"

                    echo '======================================'
                    echo 'Generated Image Names'
                    echo '======================================'
                    echo "App image   : ${env.FULL_IMAGE_NAME}"
                    echo "Nginx image : ${env.NGINX_IMAGE_NAME}"
                    echo '======================================'

                    if (action == 'rollback') {
                        echo 'ROLLBACK MODE'
                        echo "The selected version ${version} will be redeployed."
                    }
                }
            }
        }

        /*
         * ============================================================
         * Checkout Selected Git Tag
         * ============================================================
         */
        stage('Checkout Selected Version') {
            steps {
                checkout scm

                sh '''
                    set -eu

                    echo "======================================"
                    echo "Fetching Git Tags"
                    echo "======================================"

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

                    echo "Current commit:"
                    git log -1 --oneline

                    if [ ! -f "${COMPOSE_FILE_NAME}" ]; then
                        echo "ERROR: ${COMPOSE_FILE_NAME} not found."
                        echo "Selected tag: ${IMAGE_TAG}"
                        exit 1
                    fi

                    if [ ! -f "${APP_DOCKERFILE}" ]; then
                        echo "ERROR: App Dockerfile not found:"
                        echo "${APP_DOCKERFILE}"
                        exit 1
                    fi

                    if [ ! -f "${NGINX_DOCKERFILE}" ]; then
                        echo "ERROR: Nginx Dockerfile not found:"
                        echo "${NGINX_DOCKERFILE}"
                        exit 1
                    fi

                    echo "Git tag checkout completed successfully."
                '''
            }
        }

        /*
         * ============================================================
         * Check Jenkins Agent Commands
         * ============================================================
         */
        stage('Check Required Commands') {
            when {
                expression {
                    params.ACTION in ['build', 'push']
                }
            }

            steps {
                sh '''
                    set -eu

                    echo "======================================"
                    echo "Checking Required Commands"
                    echo "======================================"

                    command -v git >/dev/null 2>&1 || {
                        echo "ERROR: git is not installed."
                        exit 1
                    }

                    command -v docker >/dev/null 2>&1 || {
                        echo "ERROR: docker is not installed."
                        exit 1
                    }

                    docker version

                    if docker compose version >/dev/null 2>&1; then
                        docker compose version
                    else
                        echo "WARNING: Docker Compose plugin is not available."
                        echo "The build can continue because docker build is used."
                    fi
                '''
            }
        }

        /*
         * ============================================================
         * Build Docker Images
         * ============================================================
         */
        stage('Build Docker Images') {
            when {
                expression {
                    params.ACTION == 'build'
                }
            }

            steps {
                sh '''
                    set -eu

                    echo "======================================"
                    echo "Building Docker Images"
                    echo "======================================"
                    echo "App image   : ${FULL_IMAGE_NAME}"
                    echo "Nginx image : ${NGINX_IMAGE_NAME}"
                    echo "======================================"

                    export DOCKER_DEFAULT_PLATFORM=linux/amd64

                    echo "Building Laravel application image..."

                    docker build \
                        --platform linux/amd64 \
                        --pull \
                        --file "${APP_DOCKERFILE}" \
                        --tag "${FULL_IMAGE_NAME}" \
                        .

                    echo "Building Nginx image..."

                    docker build \
                        --platform linux/amd64 \
                        --pull \
                        --file "${NGINX_DOCKERFILE}" \
                        --tag "${NGINX_IMAGE_NAME}" \
                        .

                    echo "======================================"
                    echo "Application Image Information"
                    echo "======================================"

                    docker image inspect \
                        "${FULL_IMAGE_NAME}" \
                        --format \
                        'Image={{index .RepoTags 0}} ID={{.Id}} Created={{.Created}}'

                    echo "======================================"
                    echo "Nginx Image Information"
                    echo "======================================"

                    docker image inspect \
                        "${NGINX_IMAGE_NAME}" \
                        --format \
                        'Image={{index .RepoTags 0}} ID={{.Id}} Created={{.Created}}'

                    echo "Docker images built successfully."
                '''
            }
        }

        /*
         * ============================================================
         * Push Docker Images
         * ============================================================
         */
        stage('Push to Docker Hub') {
            when {
                expression {
                    params.ACTION == 'push'
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.DOCKERHUB_CREDENTIALS,
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    )
                ]) {
                    sh '''
                        set -eu

                        logout_docker() {
                            docker logout >/dev/null 2>&1 || true
                        }

                        trap logout_docker EXIT INT TERM

                        echo "======================================"
                        echo "Logging in to Docker Hub"
                        echo "======================================"

                        printf '%s' "${DH_PASS}" |
                            docker login \
                                --username "${DH_USER}" \
                                --password-stdin

                        export DOCKER_DEFAULT_PLATFORM=linux/amd64

                        /*
                         * Build app image if it is not available locally.
                         */
                        if ! docker image inspect \
                            "${FULL_IMAGE_NAME}" >/dev/null 2>&1
                        then
                            echo "App image is not available locally."
                            echo "Building ${FULL_IMAGE_NAME}..."

                            docker build \
                                --platform linux/amd64 \
                                --pull \
                                --file "${APP_DOCKERFILE}" \
                                --tag "${FULL_IMAGE_NAME}" \
                                .
                        else
                            echo "App image already exists locally."
                        fi

                        /*
                         * Build Nginx image independently.
                         *
                         * This avoids skipping Nginx when the app image
                         * exists but the Nginx image does not exist.
                         */
                        if ! docker image inspect \
                            "${NGINX_IMAGE_NAME}" >/dev/null 2>&1
                        then
                            echo "Nginx image is not available locally."
                            echo "Building ${NGINX_IMAGE_NAME}..."

                            docker build \
                                --platform linux/amd64 \
                                --pull \
                                --file "${NGINX_DOCKERFILE}" \
                                --tag "${NGINX_IMAGE_NAME}" \
                                .
                        else
                            echo "Nginx image already exists locally."
                        fi

                        push_retry() {
                            image="$1"
                            attempt=1
                            maximum_attempts=5

                            while true; do
                                echo "Pushing ${image}"
                                echo "Attempt ${attempt}/${maximum_attempts}"

                                if docker push "${image}"; then
                                    return 0
                                fi

                                if [ "${attempt}" -ge "${maximum_attempts}" ]; then
                                    echo "ERROR: Push failed after ${attempt} attempts."
                                    echo "Image: ${image}"
                                    return 1
                                fi

                                attempt=$((attempt + 1))

                                echo "Push failed. Retrying in 15 seconds..."
                                sleep 15
                            done
                        }

                        echo "======================================"
                        echo "Pushing Application Image"
                        echo "======================================"

                        push_retry "${FULL_IMAGE_NAME}"

                        echo "======================================"
                        echo "Pushing Nginx Image"
                        echo "======================================"

                        push_retry "${NGINX_IMAGE_NAME}"

                        echo "======================================"
                        echo "Verifying Images on Docker Hub"
                        echo "======================================"

                        docker manifest inspect \
                            "${FULL_IMAGE_NAME}" >/dev/null

                        docker manifest inspect \
                            "${NGINX_IMAGE_NAME}" >/dev/null

                        echo "Successfully pushed:"
                        echo "App   : ${FULL_IMAGE_NAME}"
                        echo "Nginx : ${NGINX_IMAGE_NAME}"
                    '''
                }
            }
        }

        /*
         * ============================================================
         * Test SSH Connection
         * ============================================================
         */
        stage('Test SSH Connection') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                sshagent([env.SSH_CREDENTIALS]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Testing SSH Connection"
                        echo "======================================"
                        echo "Manager: ${MANAGER_USER}@${MANAGER_HOST}"
                        echo "======================================"

                        ssh \
                            -o BatchMode=yes \
                            -o ConnectTimeout=15 \
                            -o ServerAliveInterval=10 \
                            -o ServerAliveCountMax=3 \
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

                                SWARM_STATE="$(
                                    docker info \
                                        --format "{{.Swarm.LocalNodeState}}"
                                )"

                                SWARM_CONTROL="$(
                                    docker info \
                                        --format "{{.Swarm.ControlAvailable}}"
                                )"

                                echo "Swarm state   : ${SWARM_STATE}"
                                echo "Control access: ${SWARM_CONTROL}"

                                if [ "${SWARM_STATE}" != "active" ]; then
                                    echo "ERROR: Docker Swarm is not active."
                                    exit 1
                                fi

                                if [ "${SWARM_CONTROL}" != "true" ]; then
                                    echo "ERROR: Server is not a Swarm manager."
                                    exit 1
                                fi

                                echo "SSH and Docker connection successful."
                            '
                    '''
                }
            }
        }

        /*
         * ============================================================
         * Verify Images Before Deployment
         * ============================================================
         */
        stage('Verify Deployment Images') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.DOCKERHUB_CREDENTIALS,
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    )
                ]) {
                    sshagent([env.SSH_CREDENTIALS]) {
                        sh '''
                            set -eu

                            SSH_OPTS="-o BatchMode=yes \
-o ConnectTimeout=15 \
-o ServerAliveInterval=10 \
-o ServerAliveCountMax=6 \
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null"

                            echo "Logging Docker into Docker Hub on manager..."

                            printf '%s' "${DH_PASS}" |
                                ssh ${SSH_OPTS} \
                                    "${MANAGER_USER}@${MANAGER_HOST}" \
                                    "docker login \
                                        --username '${DH_USER}' \
                                        --password-stdin"

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                bash -s -- \
                                "${FULL_IMAGE_NAME}" \
                                "${NGINX_IMAGE_NAME}" <<'REMOTE_SCRIPT'
set -eu

APP_IMAGE="$1"
NGINX_IMAGE="$2"

echo "======================================"
echo "Checking Application Image"
echo "======================================"
echo "${APP_IMAGE}"

if ! docker manifest inspect "${APP_IMAGE}" >/dev/null 2>&1
then
    echo "ERROR: Application image does not exist on Docker Hub."
    echo "Image: ${APP_IMAGE}"
    exit 1
fi

echo "Application image is available."

echo "======================================"
echo "Checking Nginx Image"
echo "======================================"
echo "${NGINX_IMAGE}"

if ! docker manifest inspect "${NGINX_IMAGE}" >/dev/null 2>&1
then
    echo "ERROR: Nginx image does not exist on Docker Hub."
    echo "Image: ${NGINX_IMAGE}"
    exit 1
fi

echo "Nginx image is available."
echo "Deployment image verification completed."
REMOTE_SCRIPT
                        '''
                    }
                }
            }
        }

        /*
         * ============================================================
         * Deploy or Roll Back Stack
         *
         * Rollback means redeploying the selected older Git tag.
         * ============================================================
         */
        stage('Deploy / Rollback Docker Swarm Stack') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.DOCKERHUB_CREDENTIALS,
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    ),
                    string(
                        credentialsId: env.DB_PASSWORD_CRED,
                        variable: 'DB_PASSWORD'
                    ),
                    string(
                        credentialsId: env.DB_ROOT_PASSWORD_CRED,
                        variable: 'DB_ROOT_PASSWORD'
                    )
                ]) {
                    sshagent([env.SSH_CREDENTIALS]) {
                        sh '''
                            set -eu

                            ENV_FILE="${WORKSPACE}/deploy.env"

                            SSH_OPTS="-o BatchMode=yes \
-o ConnectTimeout=15 \
-o ServerAliveInterval=10 \
-o ServerAliveCountMax=6 \
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null"

                            cleanup_local() {
                                rm -f "${ENV_FILE}"
                            }

                            trap cleanup_local EXIT INT TERM

                            echo "======================================"
                            echo "Deployment Information"
                            echo "======================================"
                            echo "Action      : ${ACTION}"
                            echo "Stack       : ${STACK_NAME}"
                            echo "Version     : ${IMAGE_TAG}"
                            echo "App image   : ${FULL_IMAGE_NAME}"
                            echo "Nginx image : ${NGINX_IMAGE_NAME}"
                            echo "Manager     : ${MANAGER_HOST}"
                            echo "======================================"

                            if [ "${ACTION}" = "rollback" ]; then
                                echo "ROLLBACK MODE"
                                echo "Redeploying selected version: ${IMAGE_TAG}"
                            fi

                            /*
                             * Encode database passwords so deploy.env can
                             * safely handle spaces and shell characters.
                             *
                             * Base64 is not encryption. The file is temporary,
                             * permission 600 and deleted after deployment.
                             */
                            DB_PASSWORD_B64="$(
                                printf '%s' "${DB_PASSWORD}" |
                                    base64 |
                                    tr -d '\\n'
                            )"

                            DB_ROOT_PASSWORD_B64="$(
                                printf '%s' "${DB_ROOT_PASSWORD}" |
                                    base64 |
                                    tr -d '\\n'
                            )"

                            umask 077

                            {
                                printf 'IMAGE_TAG=%s\\n' "${IMAGE_TAG}"
                                printf 'DOCKERHUB_REPO=%s\\n' "${DOCKERHUB_REPO}"
                                printf 'DB_PASSWORD_B64=%s\\n' "${DB_PASSWORD_B64}"
                                printf 'DB_ROOT_PASSWORD_B64=%s\\n' \
                                    "${DB_ROOT_PASSWORD_B64}"
                            } > "${ENV_FILE}"

                            chmod 600 "${ENV_FILE}"

                            echo "Preparing remote deployment directory..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "mkdir -p '${REMOTE_DIR}' && \
                                 chmod 700 '${REMOTE_DIR}'"

                            echo "Copying Docker Compose file..."

                            scp ${SSH_OPTS} \
                                "${COMPOSE_FILE_NAME}" \
                                "${MANAGER_USER}@${MANAGER_HOST}:${REMOTE_DIR}/docker-compose.yml"

                            echo "Copying temporary environment file..."

                            scp ${SSH_OPTS} \
                                "${ENV_FILE}" \
                                "${MANAGER_USER}@${MANAGER_HOST}:${REMOTE_DIR}/deploy.env"

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                "chmod 600 \
                                '${REMOTE_DIR}/docker-compose.yml' \
                                '${REMOTE_DIR}/deploy.env'"

                            echo "Logging Docker into Docker Hub on manager..."

                            printf '%s' "${DH_PASS}" |
                                ssh ${SSH_OPTS} \
                                    "${MANAGER_USER}@${MANAGER_HOST}" \
                                    "docker login \
                                        --username '${DH_USER}' \
                                        --password-stdin"

                            echo "Starting Docker Swarm deployment..."

                            ssh ${SSH_OPTS} \
                                "${MANAGER_USER}@${MANAGER_HOST}" \
                                bash -s -- \
                                "${ACTION}" \
                                "${STACK_NAME}" \
                                "${APP_SERVICE_NAME}" \
                                "${NGINX_SERVICE_NAME}" \
                                "${DB_SERVICE_NAME}" \
                                "${FULL_IMAGE_NAME}" \
                                "${NGINX_IMAGE_NAME}" \
                                "${REMOTE_DIR}" \
                                "${TASK_HISTORY_LIMIT}" <<'REMOTE_SCRIPT'
set -eu

ACTION="$1"
STACK_NAME="$2"
APP_SERVICE_NAME="$3"
NGINX_SERVICE_NAME="$4"
DB_SERVICE_NAME="$5"
EXPECTED_APP_IMAGE="$6"
EXPECTED_NGINX_IMAGE="$7"
REMOTE_DIR="$8"
TASK_HISTORY_LIMIT="$9"

COMPOSE_FILE="${REMOTE_DIR}/docker-compose.yml"
ENV_FILE="${REMOTE_DIR}/deploy.env"

cleanup_remote() {
    rm -f "${ENV_FILE}"
}

trap cleanup_remote EXIT INT TERM

cd "${REMOTE_DIR}"

echo "======================================"
echo "Checking Docker Swarm Manager"
echo "======================================"

SWARM_STATE="$(
    docker info --format '{{.Swarm.LocalNodeState}}'
)"

SWARM_CONTROL="$(
    docker info --format '{{.Swarm.ControlAvailable}}'
)"

echo "Swarm state   : ${SWARM_STATE}"
echo "Control access: ${SWARM_CONTROL}"

if [ "${SWARM_STATE}" != "active" ]; then
    echo "ERROR: Docker Swarm is not active."
    exit 1
fi

if [ "${SWARM_CONTROL}" != "true" ]; then
    echo "ERROR: This server is not a Swarm manager."
    exit 1
fi

echo "Setting Swarm task history limit to ${TASK_HISTORY_LIMIT}..."

docker swarm update \
    --task-history-limit "${TASK_HISTORY_LIMIT}" \
    >/dev/null

if [ ! -f "${COMPOSE_FILE}" ]; then
    echo "ERROR: Compose file does not exist:"
    echo "${COMPOSE_FILE}"
    exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
    echo "ERROR: Deployment environment file does not exist:"
    echo "${ENV_FILE}"
    exit 1
fi

echo "======================================"
echo "Checking Images on Docker Hub"
echo "======================================"

if ! docker manifest inspect \
    "${EXPECTED_APP_IMAGE}" >/dev/null 2>&1
then
    echo "ERROR: Application image is unavailable."
    echo "${EXPECTED_APP_IMAGE}"
    exit 1
fi

if ! docker manifest inspect \
    "${EXPECTED_NGINX_IMAGE}" >/dev/null 2>&1
then
    echo "ERROR: Nginx image is unavailable."
    echo "${EXPECTED_NGINX_IMAGE}"
    exit 1
fi

PREVIOUS_APP_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${APP_SERVICE_NAME}" 2>/dev/null ||
        echo '(not deployed)'
)"

PREVIOUS_NGINX_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${NGINX_SERVICE_NAME}" 2>/dev/null ||
        echo '(not deployed)'
)"

echo "======================================"
echo "Deployment Image Changes"
echo "======================================"
echo "Action               : ${ACTION}"
echo "Previous app image   : ${PREVIOUS_APP_IMAGE}"
echo "New app image        : ${EXPECTED_APP_IMAGE}"
echo "Previous nginx image : ${PREVIOUS_NGINX_IMAGE}"
echo "New nginx image      : ${EXPECTED_NGINX_IMAGE}"
echo "======================================"

/*
 * Load non-sensitive values and Base64 password values.
 */
set -a
. "${ENV_FILE}"
set +a

export DB_PASSWORD="$(
    printf '%s' "${DB_PASSWORD_B64}" |
        base64 --decode
)"

export DB_ROOT_PASSWORD="$(
    printf '%s' "${DB_ROOT_PASSWORD_B64}" |
        base64 --decode
)"

unset DB_PASSWORD_B64
unset DB_ROOT_PASSWORD_B64

echo "Validating Docker Stack configuration..."

docker stack config \
    --compose-file "${COMPOSE_FILE}" \
    >/dev/null

echo "Docker Stack configuration is valid."

echo "======================================"
echo "Deploying Docker Stack"
echo "======================================"

docker stack deploy \
    --compose-file "${COMPOSE_FILE}" \
    --with-registry-auth \
    --resolve-image always \
    --prune \
    --detach=false \
    "${STACK_NAME}"

unset DB_PASSWORD
unset DB_ROOT_PASSWORD

echo "======================================"
echo "Waiting for Services"
echo "======================================"

ATTEMPT=0
MAX_ATTEMPTS=60

while true; do
    APP_REPLICAS="$(
        docker service ls \
            --filter "name=${APP_SERVICE_NAME}" \
            --format '{{.Replicas}}'
    )"

    NGINX_REPLICAS="$(
        docker service ls \
            --filter "name=${NGINX_SERVICE_NAME}" \
            --format '{{.Replicas}}'
    )"

    DB_REPLICAS="$(
        docker service ls \
            --filter "name=${DB_SERVICE_NAME}" \
            --format '{{.Replicas}}'
    )"

    echo "Attempt       : $((ATTEMPT + 1))/${MAX_ATTEMPTS}"
    echo "App replicas  : ${APP_REPLICAS:-not-found}"
    echo "Nginx replicas: ${NGINX_REPLICAS:-not-found}"
    echo "DB replicas   : ${DB_REPLICAS:-not-found}"

    app_ready=false
    nginx_ready=false
    db_ready=false

    case "${APP_REPLICAS}" in
        */*)
            APP_CURRENT="${APP_REPLICAS%/*}"
            APP_DESIRED="${APP_REPLICAS#*/}"

            if [ "${APP_CURRENT}" = "${APP_DESIRED}" ] &&
               [ "${APP_DESIRED}" != "0" ]; then
                app_ready=true
            fi
            ;;
    esac

    case "${NGINX_REPLICAS}" in
        */*)
            NGINX_CURRENT="${NGINX_REPLICAS%/*}"
            NGINX_DESIRED="${NGINX_REPLICAS#*/}"

            if [ "${NGINX_CURRENT}" = "${NGINX_DESIRED}" ] &&
               [ "${NGINX_DESIRED}" != "0" ]; then
                nginx_ready=true
            fi
            ;;
    esac

    case "${DB_REPLICAS}" in
        */*)
            DB_CURRENT="${DB_REPLICAS%/*}"
            DB_DESIRED="${DB_REPLICAS#*/}"

            if [ "${DB_CURRENT}" = "${DB_DESIRED}" ] &&
               [ "${DB_DESIRED}" != "0" ]; then
                db_ready=true
            fi
            ;;
    esac

    if [ "${app_ready}" = "true" ] &&
       [ "${nginx_ready}" = "true" ] &&
       [ "${db_ready}" = "true" ]; then
        echo "All services reached their desired replica count."
        break
    fi

    ATTEMPT=$((ATTEMPT + 1))

    if [ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]; then
        echo "ERROR: Services did not become ready in time."

        echo "======================================"
        echo "Stack Services"
        echo "======================================"
        docker stack services "${STACK_NAME}" || true

        echo "======================================"
        echo "Stack Tasks"
        echo "======================================"
        docker stack ps --no-trunc "${STACK_NAME}" || true

        exit 1
    fi

    sleep 10
done

CURRENT_APP_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${APP_SERVICE_NAME}"
)"

CURRENT_NGINX_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${NGINX_SERVICE_NAME}"
)"

image_matches() {
    current_image="$1"
    expected_image="$2"

    case "${current_image}" in
        "${expected_image}"|"${expected_image}@sha256:"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

echo "======================================"
echo "Image Verification"
echo "======================================"
echo "Expected app   : ${EXPECTED_APP_IMAGE}"
echo "Current app    : ${CURRENT_APP_IMAGE}"
echo "Expected nginx : ${EXPECTED_NGINX_IMAGE}"
echo "Current nginx  : ${CURRENT_NGINX_IMAGE}"
echo "======================================"

if ! image_matches \
    "${CURRENT_APP_IMAGE}" \
    "${EXPECTED_APP_IMAGE}"
then
    echo "ERROR: Application image verification failed."

    docker service ps \
        --no-trunc \
        "${APP_SERVICE_NAME}" || true

    exit 1
fi

if ! image_matches \
    "${CURRENT_NGINX_IMAGE}" \
    "${EXPECTED_NGINX_IMAGE}"
then
    echo "ERROR: Nginx image verification failed."

    docker service ps \
        --no-trunc \
        "${NGINX_SERVICE_NAME}" || true

    exit 1
fi

echo "======================================"
echo "${ACTION} Completed Successfully"
echo "======================================"

docker stack services "${STACK_NAME}"
REMOTE_SCRIPT
                        '''
                    }
                }
            }
        }

        /*
         * ============================================================
         * Verify Deployment
         * ============================================================
         */
        stage('Verify Deployment') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                sshagent([env.SSH_CREDENTIALS]) {
                    sh '''
                        set -eu

                        ssh \
                            -o BatchMode=yes \
                            -o ConnectTimeout=15 \
                            -o ServerAliveInterval=10 \
                            -o ServerAliveCountMax=6 \
                            -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            bash -s -- \
                            "${STACK_NAME}" \
                            "${APP_SERVICE_NAME}" \
                            "${NGINX_SERVICE_NAME}" \
                            "${DB_SERVICE_NAME}" \
                            "${FULL_IMAGE_NAME}" \
                            "${NGINX_IMAGE_NAME}" <<'REMOTE_SCRIPT'
set -eu

STACK_NAME="$1"
APP_SERVICE_NAME="$2"
NGINX_SERVICE_NAME="$3"
DB_SERVICE_NAME="$4"
EXPECTED_APP_IMAGE="$5"
EXPECTED_NGINX_IMAGE="$6"

echo "======================================"
echo "Docker Swarm Nodes"
echo "======================================"

docker node ls

echo "======================================"
echo "Docker Stack Services"
echo "======================================"

docker stack services "${STACK_NAME}"

echo "======================================"
echo "Running Stack Tasks"
echo "======================================"

docker stack ps \
    --filter desired-state=running \
    --no-trunc \
    "${STACK_NAME}"

APP_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${APP_SERVICE_NAME}"
)"

NGINX_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${NGINX_SERVICE_NAME}"
)"

DB_IMAGE="$(
    docker service inspect \
        --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' \
        "${DB_SERVICE_NAME}"
)"

echo "======================================"
echo "Current Service Images"
echo "======================================"
echo "App   : ${APP_IMAGE}"
echo "Nginx : ${NGINX_IMAGE}"
echo "DB    : ${DB_IMAGE}"
echo "======================================"

case "${APP_IMAGE}" in
    "${EXPECTED_APP_IMAGE}"|"${EXPECTED_APP_IMAGE}@sha256:"*)
        echo "Application image verification: PASS"
        ;;
    *)
        echo "ERROR: Application image verification failed."
        exit 1
        ;;
esac

case "${NGINX_IMAGE}" in
    "${EXPECTED_NGINX_IMAGE}"|"${EXPECTED_NGINX_IMAGE}@sha256:"*)
        echo "Nginx image verification: PASS"
        ;;
    *)
        echo "ERROR: Nginx image verification failed."
        exit 1
        ;;
esac

echo "======================================"
echo "Service Replica Verification"
echo "======================================"

for SERVICE in \
    "${APP_SERVICE_NAME}" \
    "${NGINX_SERVICE_NAME}" \
    "${DB_SERVICE_NAME}"
do
    REPLICAS="$(
        docker service ls \
            --filter "name=${SERVICE}" \
            --format '{{.Replicas}}'
    )"

    echo "${SERVICE}: ${REPLICAS:-not-found}"

    case "${REPLICAS}" in
        */*)
            CURRENT="${REPLICAS%/*}"
            DESIRED="${REPLICAS#*/}"

            if [ "${CURRENT}" != "${DESIRED}" ] ||
               [ "${DESIRED}" = "0" ]; then
                echo "ERROR: ${SERVICE} is not ready."

                docker service ps \
                    --no-trunc \
                    "${SERVICE}" || true

                exit 1
            fi
            ;;
        *)
            echo "ERROR: Cannot determine replicas for ${SERVICE}."
            exit 1
            ;;
    esac
done

echo "======================================"
echo "Service Update Status"
echo "======================================"

docker service inspect \
    --format 'App: {{json .UpdateStatus}}' \
    "${APP_SERVICE_NAME}"

docker service inspect \
    --format 'Nginx: {{json .UpdateStatus}}' \
    "${NGINX_SERVICE_NAME}"

echo "Deployment verification completed successfully."
REMOTE_SCRIPT
                    '''
                }
            }
        }

        /*
         * ============================================================
         * Safe Docker Cleanup
         *
         * Runs on every Swarm node.
         * Does not prune volumes.
         * ============================================================
         */
        stage('Safe Docker Cleanup') {
            when {
                expression {
                    params.ACTION in ['deploy', 'rollback']
                }
            }

            steps {
                sshagent([env.SSH_CREDENTIALS]) {
                    sh '''
                        set -eu

                        ssh \
                            -o BatchMode=yes \
                            -o ConnectTimeout=15 \
                            -o ServerAliveInterval=10 \
                            -o ServerAliveCountMax=6 \
                            -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null \
                            "${MANAGER_USER}@${MANAGER_HOST}" \
                            bash -s -- \
                            "${CLEANUP_IMAGE}" \
                            "${CLEANUP_OLDER_THAN}" <<'REMOTE_SCRIPT'
set -eu

CLEANUP_IMAGE="$1"
CLEANUP_OLDER_THAN="$2"

CLEANUP_SERVICE="portfolio-docker-cleanup-$(date +%s)"

remove_cleanup_service() {
    docker service rm \
        "${CLEANUP_SERVICE}" >/dev/null 2>&1 || true
}

trap remove_cleanup_service EXIT INT TERM

echo "======================================"
echo "Docker Disk Usage Before Cleanup"
echo "======================================"

docker system df

echo "======================================"
echo "Creating Cleanup Job"
echo "======================================"
echo "Image      : ${CLEANUP_IMAGE}"
echo "Remove age : ${CLEANUP_OLDER_THAN}"
echo "Volumes    : NOT PRUNED"
echo "======================================"

docker service create \
    --name "${CLEANUP_SERVICE}" \
    --mode global-job \
    --restart-condition none \
    --mount \
        type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    "${CLEANUP_IMAGE}" \
    sh -c "
        set -eu

        echo '======================================'
        echo 'Node Docker Cleanup Started'
        echo '======================================'

        docker container prune \
            --force \
            --filter 'until=${CLEANUP_OLDER_THAN}'

        docker image prune \
            --all \
            --force \
            --filter 'until=${CLEANUP_OLDER_THAN}'

        docker builder prune \
            --force \
            --filter 'until=${CLEANUP_OLDER_THAN}'

        echo '======================================'
        echo 'Node Docker Cleanup Completed'
        echo 'Docker volumes were not pruned.'
        echo '======================================'
    "

echo "Waiting for cleanup tasks..."

ATTEMPT=0
MAX_ATTEMPTS=60

while true; do
    TOTAL_TASKS="$(
        docker service ps \
            --format '{{.ID}}' \
            "${CLEANUP_SERVICE}" |
            wc -l |
            tr -d ' '
    )"

    COMPLETED_TASKS="$(
        docker service ps \
            --filter desired-state=shutdown \
            --format '{{.CurrentState}}' \
            "${CLEANUP_SERVICE}" |
            grep -c '^Complete' || true
    )"

    FAILED_TASKS="$(
        docker service ps \
            --format '{{.CurrentState}}' \
            "${CLEANUP_SERVICE}" |
            grep -Ec '^(Failed|Rejected)' || true
    )"

    echo "Total=${TOTAL_TASKS} Completed=${COMPLETED_TASKS} Failed=${FAILED_TASKS}"

    if [ "${FAILED_TASKS}" -gt 0 ]; then
        echo "ERROR: Cleanup failed on one or more nodes."

        docker service ps \
            --no-trunc \
            "${CLEANUP_SERVICE}" || true

        exit 1
    fi

    if [ "${TOTAL_TASKS}" -gt 0 ] &&
       [ "${COMPLETED_TASKS}" -eq "${TOTAL_TASKS}" ]; then
        echo "Cleanup completed on all Swarm nodes."
        break
    fi

    ATTEMPT=$((ATTEMPT + 1))

    if [ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]; then
        echo "ERROR: Cleanup job timed out."

        docker service ps \
            --no-trunc \
            "${CLEANUP_SERVICE}" || true

        exit 1
    fi

    sleep 5
done

echo "======================================"
echo "Cleanup Task Results"
echo "======================================"

docker service ps \
    --no-trunc \
    "${CLEANUP_SERVICE}"

remove_cleanup_service
trap - EXIT INT TERM

echo "======================================"
echo "Docker Disk Usage After Cleanup"
echo "======================================"

docker system df

echo "Safe Docker cleanup completed."
echo "MySQL volumes were not pruned."
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
            echo "VERSION: ${params.VERSION}"
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'Pipeline failed.'
            echo "ACTION : ${params.ACTION}"
            echo "VERSION: ${params.VERSION ?: '(not selected)'}"
            echo 'Check the failed stage logs above.'
            echo '======================================'
        }

        aborted {
            echo '======================================'
            echo 'Pipeline was aborted.'
            echo "ACTION : ${params.ACTION}"
            echo "VERSION: ${params.VERSION ?: '(not selected)'}"
            echo '======================================'
        }

        always {
            sh '''
                set +e

                rm -f "${WORKSPACE}/deploy.env" \
                    >/dev/null 2>&1 || true

                docker logout \
                    >/dev/null 2>&1 || true

                exit 0
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