# =========================
# Stage 1: Build with Maven
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application (skip tests – handled in Jenkins)
RUN mvn clean package -DskipTests

# Rename the generated jar to app.jar (dynamic: ignores -sources.jar, -tests.jar, etc.)
RUN cp $(find target -type f -name "*.jar" ! -name "*sources.jar" ! -name "*tests.jar" | head -n 1) /app/app.jar


# =========================
# Stage 2: Runtime Image
# =========================
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Copy renamed jar from build stage
COPY --from=build /app/app.jar app.jar

# Change ownership for security
RUN chown appuser:appuser app.jar
USER appuser

# Expose Spring Boot default port
EXPOSE 8080

# Run application with container-friendly JVM options
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
