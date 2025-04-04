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
                    withCredentials([
                        usernamePassword(credentialsId: 'Github_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]) {
                        sh 'git config --global user.email "jenkin@gmail.com"'
                        sh 'git config --global user.name "Jenkin"'

                        sh "git remote set-url origin https://${USER}:${PWD}@github.com/ManhTrinhNguyen/Jenkin-Exercise-Java-Maven.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:Use_Share_Library'
                    } 
                }
            }
        }              
    }
} 
