#!/bin/bash

# MetaCline Initial Setup Script
echo "🚀 Setting up MetaCline development environment..."

# Check required tools
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required but not installed."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm is required but not installed."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }

# Check for Docker Compose (either standalone or Docker Desktop integrated)
if ! (command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1); then
    echo "❌ Docker Compose is required but not installed (neither standalone docker-compose nor Docker Desktop compose found)."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Setup environment variables
echo "🔧 Setting up environment variables..."
cp .env.example .env

# Start Docker services
echo "🐳 Starting Docker services..."
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose up -d
else
    docker compose up -d
fi

# Build the project
echo "🏗️ Building the project..."
npm run build

echo "✅ MetaCline development environment is ready!" 