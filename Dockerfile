# ===== Stage 1: Build =====
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copy Gradle wrapper + cấu hình trước để cache dependency
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon > /dev/null 2>&1 || true

# Copy source và build jar (bỏ qua test vì test cần DB)
COPY src ./src
RUN ./gradlew bootJar -x test --no-daemon

# ===== Stage 2: Runtime =====
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
