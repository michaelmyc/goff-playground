# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy the dist folder contents to the Nginx html directory
COPY dist/ /usr/share/nginx/html/

# Copy the custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8000
EXPOSE 8000

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]