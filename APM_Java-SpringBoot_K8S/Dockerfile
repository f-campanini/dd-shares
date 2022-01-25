FROM openjdk:11-jre-slim-buster
WORKDIR /app
COPY dd-java-agent.jar .
COPY /target/demo-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
ENTRYPOINT ["java", "-javaagent:./dd-java-agent.jar", "-Ddd.trace.debug=true", "-Ddd.jmxfetch.enabled=true", "-Ddd.service=dd-partner-demo", "-Ddd.version=0.0.1", "-Ddd.tags=partner.class:workshop,partner.app:javaspringboot-dummy,owner:ddog,customer:abc,team:team,env:dev",  "-jar", "./demo-0.0.1-SNAPSHOT.jar"]