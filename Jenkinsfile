def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]
pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }
    environment {
        SNAP_REPO = "vprofile-snapshot"
        NEXUS_USER = "admin"
        NEXUS_PASS = credentials('nexuspassword')
        NEXUS_REPO = "vprofile-release"
        CENTRAL_REPO = "vprofile-maven-central"
        NEXUSIP = "192.168.56.10"
        NEXUSPORT = "8081"
        NEXUS_GRP_REPO = "vpro-maven-group"
        NEXUS_LOGIN = 'nexuslogin'
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        NEXUS_GROUP_ID = "QA"
        NEXUS_ARTIFACT = "vproapp"
    }

    stages {
        stage("build") {
            steps {
                sh "mvn -s settings.xml -DskipTests install"
            }
            post {
                success {
                    echo "now archiving"
                    archiveArtifacts artifacts: "**/*.war"
                }
            }
        }
        stage("test") {
            steps {
                sh "mvn -s settings.xml test"
            }
        }
        stage("checkstyle analysis") {
            steps {
                sh "mvn -s settings.xml checkstyle:checkstyle"
            }
        }
        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
                withSonarQubeEnv("${SONARSERVER}") {
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml"
                }
            }
        }
        stage("qualty gate") {
            steps {
                timeout(time: 1, unit: "HOURS") {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage("upload to nexus") {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}--${env.BUILD_TIMESTAMP}",
                    repository: "${NEXUS_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [artifactId: "vproapp",
                        classifier: '',
                        file: 'target/vprofile-v2.war',
                        type: 'war']
                    ]
                )
            }
        }
        
        stage('create test env') {
            steps{
                ansiblePlaybook([
                        playbook: './ansible/tomcat_setup.yml',
                        inventory: './ansible/hosts',
                        credentialsId: 'ansible-ssh-key',
                        colorized: true,
                        disableHostKeyChecking: true])
            }
        }
        stage('deploy latest artifact') {
            steps {
                 
                ansiblePlaybook([
                    playbook: './ansible/vpro-app-setup.yml',
                    inventory: './ansible/hosts',
                    credentialsId: 'ansible-ssh-key',
                    colorized: true,
                    disableHostKeyChecking: true,
                    extraVars: [
                        USER: "${NEXUS_USER}",
                        PASS: "${NEXUS_PASS}",
                        nexusip: "${NEXUSIP}",
                        reponame: "${NEXUS_REPO}",
                        groupid: "${NEXUS_GROUP_ID}",
                        artifactid: "${NEXUS_ARTIFACT}",
                        build: "${env.BUILD_ID}",
                        time: "${env.BUILD_TIMESTAMP}"
                    ]
                ])
            }
        }
        
    }
    post {
        always {
            echo 'slack notifications'
            slackSend channel: '#cicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build: ${env.BUILD_NUMBER} \n more info at: ${env.BUILD_URL}"
        }
    }
}
