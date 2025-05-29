# Stage 1: Build the WAR with Maven 3.9 and JDK 17
FROM maven:3.9.0-openjdk-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies (cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source and build the WAR file, skipping tests
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Use Tomcat to run the WAR
FROM tomcat:9.0-jdk17

# Remove default webapps to avoid conflicts
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from build stage to Tomcat webapps folder and rename to ROOT.war for root context
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
