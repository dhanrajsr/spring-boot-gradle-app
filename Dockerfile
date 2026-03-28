# ---- Stage 1: Build ----
FROM gradle:8.5-jdk17 AS builder

WORKDIR /app

# Copy build files first and download dependencies (cached layer)
COPY build.gradle settings.gradle ./
RUN gradle dependencies -q --no-daemon

# Copy source and build the jar
COPY src ./src
RUN gradle bootJar -q --no-daemon

# ---- Stage 2: Run ----
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the built jar from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
