def gv

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
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
                    echo "build Jar"
                    sh "mvn clean package"

                }
            }
        }

        stage("build docker image") {
            steps {
                script {
                    echo "build Image"
                    sh "docker build -t nguyenmanhtrinh/demo-app:java-maven-1.0 ."
                }
            }
        }

        stage("Login to Docker Hub") {
            steps {
                script {
                     echo "Login to Docker Hub"

                    withCredentials([
                        usernamePassword(credentialsId: 'Docker_Hub_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]){
                        sh "echo ${PWD} | docker login -u ${USER} --password-stdin"
                    }
                }
            }
        }

        stage("Push Image to Docker Hub"){
            steps {
                script {
                    echo "Push Image to Docker Hub"
                    sh 'docker push nguyenmanhtrinh/demo-app:java-maven-1.0'
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "deploy"
                }
            }
        }               
    }
} 
