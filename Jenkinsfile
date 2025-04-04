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
                    sh "mvn clean build"

                }
            }
        }

        stage("build image") {
            steps {
                script {
                    echo "build Image"
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
