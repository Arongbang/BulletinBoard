# ---- Build Stage ----
# Uses Java 21 LTS (Eclipse Temurin) for broad library compatibility
FROM eclipse-temurin:21-jdk-noble AS builder
WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Cache dependencies before copying source (layer cache optimization)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build the application JAR
COPY src src
RUN mvn package -DskipTests -B

# ---- Runtime Stage ----
FROM eclipse-temurin:21-jre-noble
WORKDIR /app

COPY --from=builder /app/target/bulletin-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
