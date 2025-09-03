# =========================
# Stage 1: Build with Maven
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory inside container
WORKDIR /app

# Copy pom.xml and download dependencies (better cache use)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy project source
COPY src ./src

# Build the application (skip tests for faster builds)
RUN mvn clean package -DskipTests

# =========================
# Stage 2: Create Runtime Image
# =========================
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copy only the final JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
