#FROM nginx
FROM ghcr.io/cirruslabs/flutter:3.27.0

RUN apt update
RUN apt install nginx -y

# Configure CWD
WORKDIR /app/

# Run flutter doctor
RUN flutter config --no-analytics
RUN flutter config --no-cli-animations

# Copy dependencies file and install them
COPY pubspec.yaml .
RUN flutter pub get

# # Build Web App
COPY . .
RUN dart run build_runner build --delete-conflicting-outputs
RUN flutter config --enable-web
RUN flutter create .
RUN flutter build web --release --base-href '/'

RUN rm -rf /var/www/html
RUN cp -r /app/build/web /var/www/html
RUN cp -r /app/assets /var/www/html/

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]