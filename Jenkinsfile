pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "airfly:v1"
        REGISTRY_URL = "localhost:8082"
        SONARQUBE_SERVER = "SonarQube"
        NEXUS_REPO = "myrepo"
        NEXUS_CREDENTIALS = 'nexus-credentials'
        SONARQUBE_TOKEN = credentials('sonar-token')
        DOCKERHUB_IMAGE = "helmyyach/airfly:v1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/HelmyAch/Tunisair.git'
            }
        }

   /* stage ('ptrparer lenvironeùment python'){

        steps {
            sh '''
            python3 -m venv venv
            . venv/bin/activate
            pip install --upgrade pip
            pip install -r requirements.txt
        
           '''
        }
    }

    stage('lancer les teste'){

        steps {
            sh '''
            . venv/bin/activate
            python manage.py test
              '''
}

    }
    stage('Static Code Analysis (SonarQube)') {
            steps {
                script {
                    def scannerHome = tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv("${SONARQUBE_SERVER}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=airfly \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=${SONARQUBE_TOKEN}
                        """
                    }
                }
            }
        } */
stage('Initial Deploy (Docker Compose Up)') {
    steps {
        sh 'docker-compose up --build -d'
     }
}

stage('Database Migration') {
    steps {
        sh 'docker-compose run --rm django-app python manage.py migrate'
    }
}

    

        stage('Security Scan (Trivy)') {
            steps {
                sh """
                    trivy image ${DOCKER_IMAGE} \
                    --severity MEDIUM,HIGH,CRITICAL \
                    --format template \
                    --template @./html.tpl \
                    -o trivy-report.html
                """
                archiveArtifacts artifacts: 'trivy-report.html', fingerprint: true
            }
        }

stage('Run ZAP Scan') {
    steps {
        sh '''
            zap.sh -cmd -port 8090 -quickurl http://localhost:8000 -quickout  /var/lib/jenkins/workspace/TunisiaFly/zap_report.html
        '''
    }
}

stage('Archive ZAP Report') {
    steps {
        archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
    }
}



        stage('Push to Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS}", passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
                        sh """
                            docker login -u "$NEXUS_USER" -p "$NEXUS_PASSWORD" ${REGISTRY_URL}
                            docker tag ${DOCKER_IMAGE} ${REGISTRY_URL}/repository/${NEXUS_REPO}/${DOCKER_IMAGE}
                            docker push ${REGISTRY_URL}/repository/${NEXUS_REPO}/${DOCKER_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Shutdown Current App') {
            steps {
                sh 'docker-compose down'
            }
        } 

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh """
                            docker tag ${DOCKER_IMAGE} ${DOCKERHUB_IMAGE}
                            echo \$DOCKERHUB_PASS | docker login -u \$DOCKERHUB_USER --password-stdin
                            docker push ${DOCKERHUB_IMAGE}
                        """
                    }
                }
            }
        }

       stage('Final Deploy') {
            steps {
                sh 'docker-compose up --build -d'
            }
        }

        stage('Database Migration 2') {
            steps {
                sh 'docker-compose run --rm django-app python manage.py migrate'
            }
        } 
    }
}
