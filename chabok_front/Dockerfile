# Build Stage
FROM ghcr.io/cirruslabs/flutter:3.27.0

WORKDIR /app/

# Configure Flutter
RUN flutter config --no-analytics
RUN flutter config --no-cli-animations

# Prepare dependencies
COPY pubspec.yaml ./pubspec.yaml
RUN flutter pub get

# Copy model files
COPY lib/models ./lib/models
RUN dart run build_runner build --delete-conflicting-outputs

# Copy project files
COPY assets ./assets
COPY lib ./lib

# Build the Flutter web application
RUN flutter create --platforms=web .
# RUN dart run build_runner build --delete-conflicting-outputs
