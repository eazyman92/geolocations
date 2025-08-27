pipeline {
    agent any
    tools{
        maven 'Maven3'
        jdk 'jdk'
    }
    environment{
        GIT_BRANCH              = 'main'
        GIT_URL                 = 'https://github.com/eazyman92/geolocations.git'
        GITLEAKS_REPORT_FILE    = 'report-file.json'
        DnVd_API_KEY            = 'e2f410b5-f830-492f-9c11-35847adf5272'
        PROJECT_NAME            = 'Biomedical'
      //  NEXUS_VERSION           = 'nexus3'
      //  NEXUS_PROTOCOL          = 'http'
     //   NEXUS_URL               = '54.226.249.252:8081'
      //  ARTIFACT_VERSION        = '0.0.1-SNAPSHOT'
     //   NEXUS_CRED              =  credentials('NexusCred')
     //   ARTIFACT_ID             = 'bioMedical'
     //   ARTIFACT_PATH           = 'target/bioMedical-0.0.1-SNAPSHOT.jar'
     //   ARTIFACT_EXTENSION      = 'jar'
        IMAGE_NAME              = 'biomedical/images'
        ECR_URL                 = '381492147345.dkr.ecr.us-east-1.amazonaws.com'
        TRIVY_IMAGE_SCAN_RESULT = 'image-report.html'
        AWS_REGION              = 'us-east-1'
        GITHUB_USER_EMAIL       = 'tijaniisiaq92@gmail.com'
        GITHUB_USERNAME         = 'eazyman92'
        MANIFEST_BRANCH         = 'manifest-files-branch'
    }
    
    stages {
        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }
        stage ("SCM CheckOut") {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_URL}"
            }
        }
        stage ("Gitleaks Scan") {
            steps {
                sh "gitleaks detect --source . -v -r ${GITLEAKS_REPORT_FILE} -f json || true"
            }
        }
        stage("Unit Test"){
            steps{
                sh 'mvn clean test'
            }
        }
        stage('Build Artifact'){
            steps{
                sh 'mvn package -DskipTests'
            }
        }
        stage('Coce Coverage'){
            steps{
                sh 'mvn jacoco:report'
            }
        } 
        stage('SCA=> OWASP DepChecK'){
            steps{
                sh 'mvn dependency-check:purge'
                sh 'mvn dependency-check:check -X -DnvdApiKey=${DnVd_API_KEY}'
               }
            } 
        stage('SAST'){
            steps{
                withSonarQubeEnv(installationName: 'sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.projectName="${PROJECT_NAME}"'
                }
            } 
        }
        stage('quality gate'){
            steps{
                waitForQualityGate abortPipeline: true
            }
        } 
        stage('Artifact Upload'){
            steps{
                 nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: 'localhost:8081',
                    groupId: 'com.spring',
                    version:  '0.0.1-SNAPSHOT',
                    repository: 'maven-snapshots',
                    credentialsId: 'NexusCred',
                    artifacts: [
                        [artifactId: 'bioMedical',
                         classifier: '',
                         file: 'target/bioMedical-0.0.1-SNAPSHOT.jar',
                         type: 'jar']
                        ]
                    )
            }
        }
        stage('build image'){
            steps{
                sh 'docker build -t ${IMAGE_NAME} .'
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
                sh 'docker tag ${IMAGE_NAME}:latest ${ECR_URL}/${IMAGE_NAME}:latest'
                sh 'docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER}'
             }
                
            }
            stage('scan image'){
                steps{
                    sh 'trivy image --scanners vuln ${IMAGE_NAME}:latest > ${TRIVY_IMAGE_SCAN_RESULT}'
                }
            }
            stage('Smoke Test'){
                steps{
                    sh 'docker rm -f smoketest > /dev/null'
                    sh 'docker run -d -p 8082:8082 --name smoketest ${IMAGE_NAME}:${BUILD_NUMBER}'
                    sh 'sleep 60'
                    sh 'chmod +x check.sh; ./check.sh'
                    sh 'chmod +x image-scan-check.sh; ./image-scan-check.sh'
                    sh 'docker rm -f smoketest'
                }
            }
            stage('Image Push to ECR'){
                steps{
                    script{
                        sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}'
                        sh 'docker push ${ECR_URL}/${IMAGE_NAME}:latest'
                        sh 'docker push ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER}'
                    }
                }
            }
            stage('Update & Push K8s Manifest to VCS'){
                steps{
                    script{
                        sh """
                        git checkout ${GIT_BRANCH}
                        git fetch origin
                        git checkout -B ${MANIFEST_BRANCH}
                        git config --global user.email "${GITHUB_USER_EMAIL}"
                        git config --global user.name "${GITHUB_USERNAME}"
                        sed -i "s|image: ${ECR_URL}/${IMAGE_NAME}:.*|image: ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER}|" k8s-manifest.yaml
                        git add k8s-manifest.yaml
                        git commit -m "k8s-manifest.yaml file is updated"
                        git pull
                        """
                        withCredentials([gitUsernamePassword(credentialsId: 'github-cred', gitToolName: 'Default')]) {
                            sh 'git push "${GIT_URL}" ${MANIFEST_BRANCH}'
                        }
                    }
                }
            }
        }
    post {
       always {
            emailext body: '''Hello Team,
                The jenkins job **${JOB_NAME}** has been done with a BUILD STATUS: ${BUILD_STATUS}.
                Please, review the build results and logs via ths build URL: ${BUILD_URL}.
 
                Best Regards,
                DevOps Team''', subject: '${JOB_NAME} Build #${BUILD_NUMBER} = ${BUILD_STATUS}', to: 'samuminata@gmail.com'
       }
   }

}
