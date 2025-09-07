# =========================
# Stage 1: Build WAR with Maven
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY . .
RUN mvn -B clean package -DskipTests

# =========================
# Stage 2: Tomcat 9 Runtime (javax.servlet compatible)
# =========================
FROM tomcat:9.0-jdk17-temurin
ENV CATALINA_HOME=/usr/local/tomcat
WORKDIR $CATALINA_HOME

# Clean default webapps and deploy our WAR as ROOT
RUN rm -rf webapps/*
COPY --from=build /app/target/onlinebookstore.war webapps/ROOT.war

# Switch Tomcat HTTP connector to 9090
RUN sed -i 's/port="8080"/port="9090"/' conf/server.xml

EXPOSE 9090

CMD ["catalina.sh", "run"]
