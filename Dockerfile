# =========================
# Stage 1: Build the JAR
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY . .
RUN mvn clean package -DskipTests

# =========================
# Stage 2: Runtime
# =========================
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy JAR file (force rename to app.jar)
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 9090
ENV JAVA_OPTS="-Dserver.port=9090 -Dserver.address=0.0.0.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
