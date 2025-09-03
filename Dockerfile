# =========================
# Stage 1: Build WAR with Maven
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY . .
RUN mvn clean package -DskipTests

# =========================
# Stage 2: Tomcat Runtime
# =========================
FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat/webapps/

# Remove default ROOT app
RUN rm -rf ROOT

# Copy WAR from build stage and deploy as ROOT
COPY --from=build /app/target/*.war ROOT.war

# Expose custom port
EXPOSE 9090

# Change Tomcat to listen on 9090 instead of 8080
RUN sed -i 's/port="8080"/port="9090"/' /usr/local/tomcat/conf/server.xml

CMD ["catalina.sh", "run"]
