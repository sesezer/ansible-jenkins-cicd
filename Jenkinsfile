def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]
pipeline {
    agent any
    parameters {
        string(name: 'TIME', defaultValue: '')
        string(name: 'BUILD', defaultValue: '')

    }
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }
    environment {
        NEXUS_USER = "admin"
        NEXUS_PASS = credentials('nexuspassword')
        NEXUS_REPO = "vprofile-release"
        NEXUSIP = "192.168.56.10" 
        NEXUS_GROUP_ID = "QA"
        NEXUS_ARTIFACT = "vproapp"
    }

    
        
        stage('deploy prod artifact') {
            steps {
                 
                ansiblePlaybook([
                    playbook: './ansible/vpro-app-prod.yml',
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
                        build: "${env.BUILD}",
                        time: "${env.TIME}"
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
