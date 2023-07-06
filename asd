pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }
    stages {
        stage('Clone Repository') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/sesezer/ansible-jenkins-cicd.git']]])
            }
        }
        stage('create test env') {
            steps{
                ansiblePlaybook(
                        playbook: './ansible/tomcat_setup.yml',
                        inventory: './ansible/hosts',
                        credentialsId: 'ansible-ssh-key',
                        colorized: true)
            }
        }
    }
}