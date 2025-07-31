FROM openjdk:8

WORKDIR /app

COPY target/bioMedical-0.0.1-SNAPSHOT.jar .

EXPOSE 8081

CMD ["java","-jar","bioMedical-0.0.1-SNAPSHOT.jar"]
