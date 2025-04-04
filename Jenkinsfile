library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/ManhTrinhNguyen/Share_Library_Exercise.git',
     credentialsId: 'Github_Credential'
    ]
)

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    environment {
        DOCKER_REPO = 'nguyenmanhtrinh/demo-app'
    }
    stages {
        stage("Version Increment Dynamic"){
            steps {
                script {
                    Increment_Version_Maven()
                }
            }
        }

        stage("test") {
            steps {
                script {
                    echo "testing"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    Build_Maven_Jar()
                }
            }
        }

        stage("build docker image") {
            steps {
                script {
                    Docker_Build_Image()
                }
            }
        }

        stage("Login to Docker Hub") {
            steps {
                script {
                     Docker_Login()
                }
            }
        }

        stage("Push Image to Docker Hub"){
            steps {
                script {
                    Docker_Push_Image()
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "deploy ....."
                }
            }
        } 

        stage("Commit to Git Repo") {
            steps {
                script {
                    Commit_to_Git_Repo()
                }
            }
        }              
    }
} 
