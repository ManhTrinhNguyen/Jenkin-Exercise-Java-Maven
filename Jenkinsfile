def gv

pipeline {   
    agent any
    tools {
        maven 'Maven'
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
