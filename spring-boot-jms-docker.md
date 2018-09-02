I have finally got round to learning how to use Docker past the level of knowing what it is and does without ever using it. This is my first post that I have attempted to use Docker in and will probably be what I refer to whenever I start a new project (for Java or Kotlin anyway). 

This will be a short post that takes an existing project (from one of my other posts) and alter it so it can run inside of containers. I doubt this post will contain anything impressive but I know it will help me in the future and maybe it will help you now. 

Before we begin, lets take a quick look at the existing project. Here are links to the [code](https://github.com/lankydan/spring-boot-jms) and the corresponding [blog post](https://lankydanblog.com/2017/06/18/using-jms-in-spring-boot/). The blog post covers all information about the code. Here's the quick rundown so we can get on with this post. The old project is a Spring Boot application with a MongoDB database and ActiveMQ message queue. All these components are prime fodder for containerisation.

One last comment, for the content of this post, I am assuming that you have already installed Docker or can figure out how to do so yourself.

### Converting the Spring App

First up, the Spring Boot application.

This is the only part of the project that contains our code. The rest are just images downloaded from someone elses repository. To start moving this application towards running in a container, we need to create a `Dockerfile` that specifies the content of an image:
```Dockerfile
FROM openjdk:8-jdk-alpine
MAINTAINER Dan Newton
ADD target/spring-boot-jms-tutorial-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```
This takes the base image of `openjdk:8-jdk-alpine` which is a good starting point for the application, adds the Jar built from the application code (naming it `app.jar`) and exposes a port that can be communicated with between containers. The final line defines the command that is run when the image is ran in a container. This is what starts the Spring application.

To build an image from the `Dockerfile` run the command below:
```
docker build -t spring-boot-jms-tutorial .
```
There is now an image named `spring-boot-jms-tutorial` (`-t` lets us define a name). This can now be used to create a container that executes the code that packed into the image's Jar:
```
docker run --name application -p 4000:8000 spring-boot-jms-tutorial
```
This will create and run a container built from the `spring-boot-jms-tutorial` image. It names the container `application` and the `-p` property allows a port from local machine to mapped to a port inside the container. To access port `8080` of the container we simply need to use port `4000` on our own machine.

If we stopped this container and wanted to run it again, we should use the command:
```
docker start application
```
Where `application` is the name of the container we created before. If `docker run` was used again it would create another new container rather than reusing the existing one. Actually, because we provided a name to the container, running the same `run` command from earlier will lead to an error.

Now the Spring application is successfully running in a container, but the logs are not looking very good. Let's have a quick look so we know what we need to do next.

MongoDB connection failing:
```
Exception in monitor thread while connecting to server mongocontainer:27017

com.mongodb.MongoSocketException: mongocontainer: Name does not resolve
	at com.mongodb.ServerAddress.getSocketAddress(ServerAddress.java:188) ~[mongodb-driver-core-3.6.4.jar!/:na]
	at com.mongodb.connection.SocketStreamHelper.initialize(SocketStreamHelper.java:59) ~[mongodb-driver-core-3.6.4.jar!/:na]
	at com.mongodb.connection.SocketStream.open(SocketStream.java:57) ~[mongodb-driver-core-3.6.4.jar!/:na]
	at com.mongodb.connection.InternalStreamConnection.open(InternalStreamConnection.java:126) ~[mongodb-driver-core-3.6.4.jar!/:na]
	at com.mongodb.connection.DefaultServerMonitor$ServerMonitorRunnable.run(DefaultServerMonitor.java:114) ~[mongodb-driver-core-3.6.4.jar!/:na]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_171]
Caused by: java.net.UnknownHostException: mongocontainer: Name does not resolve
	at java.net.Inet4AddressImpl.lookupAllHostAddr(Native Method) ~[na:1.8.0_171]
	at java.net.InetAddress$2.lookupAllHostAddr(InetAddress.java:928) ~[na:1.8.0_171]
	at java.net.InetAddress.getAddressesFromNameService(InetAddress.java:1323) ~[na:1.8.0_171]
	at java.net.InetAddress.getAllByName0(InetAddress.java:1276) ~[na:1.8.0_171]
	at java.net.InetAddress.getAllByName(InetAddress.java:1192) ~[na:1.8.0_171]
	at java.net.InetAddress.getAllByName(InetAddress.java:1126) ~[na:1.8.0_171]
	at java.net.InetAddress.getByName(InetAddress.java:1076) ~[na:1.8.0_171]
	at com.mongodb.ServerAddress.getSocketAddress(ServerAddress.java:186) ~[mongodb-driver-core-3.6.4.jar!/:na]
	... 5 common frames omitted
```
ActiveMQ also isn't there:
```
Could not refresh JMS Connection for destination 'OrderTransactionQueue' - retrying using FixedBackOff{interval=5000, currentAttempts=1, maxAttempts=unlimited}. Cause: Could not connect to broker URL: tcp://activemqcontainer:61616. Reason: java.net.UnknownHostException: activemqcontainer
```
We will sort these out in the next sections so the application can work in its entirety.

One last thing before we move onto looking at Mongo and ActiveMQ.

You could also use the `dockerfile-maven-plugin` to help with the above which also builds the container as part of running `mvn install`. I chose not to use it since I couldn't get it to work properly with `docker-compose`. Below is a quick example of using the plugin:
```xml
<build>
    </plugins>
        <plugin>
            <groupId>com.spotify</groupId>
            <artifactId>dockerfile-maven-plugin</artifactId>
            <version>1.4.4</version>
            <executions>
                <execution>
                    <id>default</id>
                    <goals>
                        <goal>build</goal>
                        <goal>push</goal>
                    </goals>
                </execution>
            </executions>
            <configuration>
                <!-- Names the image: spring-boot-jms-tutorial -->
                <repository>${project.artifactId}</repository>
                <buildArgs>
                    <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
                </buildArgs>
            </configuration>
        </plugin>
    </plugins>
</build>
```
This then allows us to replace a few of the lines in the `Dockerfile`:
```Dockerfile
FROM openjdk:8-jdk-alpine
MAINTAINER Dan Newton
ARG JAR_FILE 
ADD target/${JAR_FILE} app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```
Here one line has been added and one existing line is changed. The `JAR_FILE` argument replaces the original name of the Jar which is injected in by the plugin from the `pom.xml`. Make these changes and run `mvn install` and bam, your container built with all the required code.


### Content that helped me write this post
[https://docs.docker.com/get-started/part2/](https://docs.docker.com/get-started/part2/)
[http://www.briansjavablog.com/2016/08/docker-multi-container-app.html](http://www.briansjavablog.com/2016/08/docker-multi-container-app.html)
[https://docs.docker.com/compose/gettingstarted/#step-3-define-services-in-a-compose-file](https://docs.docker.com/compose/gettingstarted/#step-3-define-services-in-a-compose-file)
[https://docs.docker.com/compose/compose-file/#build](https://docs.docker.com/compose/compose-file/#build)
[https://www.linkedin.com/pulse/dockerize-spring-boot-mongodb-application-aymen-kanzari](https://www.linkedin.com/pulse/dockerize-spring-boot-mongodb-application-aymen-kanzari)
