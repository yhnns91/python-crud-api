pipeline {
    agent any

    environment {
        PYTHONUNBUFFERED = '1'
        REGISTRY_NAME    = 'python-crud-api'
        CONTAINER_NAME   = 'production-api-container'
        PORT_MAPPING     = '5000:5000'
        VOLUME_NAME      = 'production-api-data'
        // Kontainer API disambungkan ke jaringan yang sama dengan Jenkins,
        // supaya health check bisa memanggil API lewat nama kontainernya.
        DOCKER_NETWORK   = 'jenkins-net'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo 'Checking out source code from GitHub'
                checkout scm
            }
        }

        stage('2. Code Syntax Verification') {
            steps {
                sh 'python3 --version'
                sh 'python3 -m py_compile app.py'
            }
        }

        stage('3. Build Docker Image') {
            steps {
                // Tugas D: tag image berbasis commit SHA, selain BUILD_NUMBER dan latest
                sh '''
                    SHORT_SHA=$(git rev-parse --short HEAD)
                    echo "Commit SHA: ${SHORT_SHA}"
                    docker build -t ${REGISTRY_NAME}:${BUILD_NUMBER} .
                    docker tag ${REGISTRY_NAME}:${BUILD_NUMBER} ${REGISTRY_NAME}:${SHORT_SHA}
                    docker tag ${REGISTRY_NAME}:${BUILD_NUMBER} ${REGISTRY_NAME}:latest
                    docker images ${REGISTRY_NAME}
                '''
            }
        }

        stage('4. Automated Deployment') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker volume create ${VOLUME_NAME}
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      --network ${DOCKER_NETWORK} \
                      -p ${PORT_MAPPING} \
                      -v ${VOLUME_NAME}:/var/lib/backend_data \
                      ${REGISTRY_NAME}:latest
                '''
            }
        }

        stage('5. Health Check') {
            steps {
                // Catatan: "localhost" di dalam kontainer Jenkins = kontainer Jenkins itu sendiri,
                // bukan laptop. Karena itu API dipanggil lewat nama kontainernya di jenkins-net.
                sh '''
                    echo "Menunggu aplikasi siap..."
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                      if curl -fsS http://${CONTAINER_NAME}:5000/health; then
                        echo ""
                        echo "Health check curl dari Jenkins: BERHASIL (percobaan ke-$i)"
                        break
                      fi
                      if [ "$i" -eq 10 ]; then
                        echo "Health check GAGAL setelah 10 percobaan"
                        docker logs --tail 50 ${CONTAINER_NAME}
                        exit 1
                      fi
                      sleep 2
                    done
                    echo "Status Docker HEALTHCHECK saat ini: $(docker inspect --format '{{.State.Health.Status}}' ${CONTAINER_NAME})"
                    docker logs --tail 20 ${CONTAINER_NAME}
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Inspect Console Output.'
        }
    }
}
