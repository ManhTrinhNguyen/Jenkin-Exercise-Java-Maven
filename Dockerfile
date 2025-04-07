FROM amazoncorretto:8-alpine3.17-jre

EXPOSE 8080

COPY ./target/java-maven-app-*.jar /usr/app/java-maven-app.jar
WORKDIR /usr/app

CMD java -jar java-maven-app.jar
