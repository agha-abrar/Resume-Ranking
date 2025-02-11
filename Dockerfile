# Use official Python image as base
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy project files into the container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 for Flask
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
