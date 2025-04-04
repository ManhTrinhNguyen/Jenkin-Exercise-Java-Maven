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
                    sh "docker build -t java-maven:1.0 ."

                    echo "Login to Docker Hub"

                    withCredentials([
                        usernamePassword(credentials: 'Docker_Hub_Credential', usernameVariable: USER, passwordVariable: PWD)
                    ]){
                        sh "docker login -u ${USER} -p ${PWD}"
                    }
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
