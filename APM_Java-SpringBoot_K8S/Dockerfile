# Maven 
FROM maven:3.8.1-openjdk-11-slim AS builder
WORKDIR .
COPY pom.xml .
RUN mvn -e -B dependency:resolve

RUN mvn clean -e -B package

# RTSDK Java
FROM openjdk:11-jre-slim-buster
WORKDIR /app
COPY dd-java-agent.jar .
COPY --from=builder /target/demo-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java", "-javaagent:./dd-java-agent.jar", "-Ddd.service=dd-partner-demo", "-Ddd.version=0.0.1", "-Ddd.tags=partner.class:workshop,partner.app:javaspringboot-dummy,owner:ddog,customer:abc,team:team",  "-jar", "./cloud_consumer-1.0-jar-with-dependencies.jar"]
