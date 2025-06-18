#Dockerfile for containerizing the HelloSpringBoot app

FROM amazoncorretto:17-alpine
ARG JAR_FILE=target/hellospringboot-app.jar
COPY $JAR_FILE .
ENTRYPOINT ["java", "-jar", "hellospringboot-app.jar"]
