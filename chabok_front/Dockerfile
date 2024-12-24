# Build Stage
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS build

WORKDIR /app/

# Configure Flutter
RUN flutter config --no-analytics
RUN flutter config --no-cli-animations

# Prepare dependencies
COPY pubspec.yaml ./pubspec.yaml
RUN flutter pub get

# Copy project files
COPY assets ./assets
COPY lib ./lib

# Create .env file dynamically during build
# ENV FLASK_HOST=127.0.0.1
ENV FLASK_HOST=185.231.59.87
ENV FLASK_PORT=8000

# Build the Flutter web application
RUN flutter create --platforms=web .
RUN flutter build web --base-href '/' --web-renderer canvaskit  --dart-define=FLASK_HOST=${FLASK_HOST} --dart-define=FLASK_PORT=${FLASK_PORT}

# # Production Stage
# FROM nginx:alpine

# # Copy built web application to Nginx
# COPY --from=build /app/build/web /usr/share/nginx/html

# # Copy Nginx configuration
# COPY nginx.conf /etc/nginx/nginx.conf

# # Expose port 80
# EXPOSE 80

# # Start Nginx
# CMD ["nginx", "-g", "daemon off;"]
