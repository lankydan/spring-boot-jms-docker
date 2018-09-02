FROM openjdk:8-jdk-alpine
MAINTAINER Dan Newton
ARG JAR_FILE
ADD target/${JAR_FILE} app.jar
#ADD target/spring-boot-jms-tutorial-1.0.0.jar app.jar
EXPOSE 8080
#ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
ENTRYPOINT ["java", "-jar", "/app.jar"]