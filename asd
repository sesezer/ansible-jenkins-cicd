

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
        build = "3"
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
                withEnv([
                    "USER=${USER}",
                    "PASS=${PASS}",
                    "nexusip=${nexusip}",
                    "reponame=${reponame}",
                    "groupid=${groupid}",
                    "artifactid=${artifactid}",
                    "build=${build}",
                    "time=${time}",
                    "vprofile_version=${vprofile_version}"
                ]) {
                    ansiblePlaybook([
                        playbook: './ansible/vpro-app-setup.yml',
                        inventory: './ansible/hosts',
                        credentialsId: 'ansible-ssh-key',
                        colorized: true,
                        disableHostKeyChecking: true,
                        extraVars: [
                            USER: USER,
                            PASS: PASS,
                            nexusip: nexusip,
                            reponame: reponame,
                            groupid: groupid,
                            artifactid: artifactid,
                            build: build,
                            time: time,
                            vprofile_version: vprofile_version
                        ]
                    ])
                }
            }
        }
    }
    
}