# =========================
# Stage 1: Build the JAR
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and download dependencies first (better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the project and build
COPY . .
RUN mvn clean package -DskipTests

# =========================
# Stage 2: Runtime Container
# =========================
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose 9090 as internal port
EXPOSE 9090

# Force Spring Boot / Tomcat app to listen on 9090
ENV JAVA_OPTS="-Dserver.port=9090 -Dserver.address=0.0.0.0"

# Run the JAR
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
