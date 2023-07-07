

pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }
    environment {
        USER = "admin"
        PASS = credentials('nexuspassword')
        nexusip = "192.168.56.10"
        reponame = "vprofile-release"
        groupid = "QA"
        artifactid = "vproapp"
        build = "3-"
        time = "23-07-06-19-41-57"
        vprofile_version = "vproapp-3--23-07-06-19-41-57.war"
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/sesezer/ansible-jenkins-cicd.git']]])
            }
        }
        stage('create test env') {
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
}
    
