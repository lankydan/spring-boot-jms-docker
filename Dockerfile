FROM openjdk:8-jdk-alpine
MAINTAINER Dan Newton
VOLUME /tmp
ARG JAR_FILE
#COPY ${JAR_FILE} app.jar
COPY target/${JAR_FILE} app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]

#docker ps -f status=exited returns exited containers
#docker ps -q -f status=exited returns exited container ids
# -d means run in background
#docker run -d --name activemqcontainer -p 8161:8161 --network=spring-boot-jms rmohr/activemq
#docker run -d --name mongocontainer --network=spring-boot-jms -v ~/mongo-data:/data/db mongo
#docker run -p 4000:8000 --network=spring-boot-jms springio/spring-boot-jms-tutorial