#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting .NET API initialization...${NC}"

cp .example.env .env

# Replace the current git config lines with these interactive prompts
echo "Configure Git settings:"
read -p "Enter your Git name: " gitname
read -p "Enter your Git email: " gitemail

git config --global --add safe.directory $PWD
git config --global init.defaultBranch main
git config --global user.name "$gitname"
git config --global user.email "$gitemail"

read -p "Enter new Git remote URL (leave blank to unset from clone): " -r newRemote
if [ -z "$newRemote" ]; then
    # Remove remote origin
    git remote remove origin
else
    git remote set-url origin "$newRemote"
fi

# Create new WebAPI project if it doesn't exist
if [ ! -d "DevcontainerDotnetApi" ]; then
    echo -e "${BLUE}Creating new .NET WebAPI project...${NC}"
    dotnet new webapi -n DevcontainerDotnetApi
    
    # Move all files from the created directory to the root
    mv DevcontainerDotnetApi/* .
    rm -rf DevcontainerDotnetApi

    # Delete the default WeatherForecast files
    rm -rf Controllers
    rm -rf Models
    rm WeatherForecast.cs

    echo -e "${BLUE}Adding recommended frameworks (e.g., Swagger)...${NC}"
    dotnet add package Swashbuckle.AspNetCore
    
    read -p "Do you want to set up advanced scaffolding (e.g., auth, user model, CRUD)? (y/N) " -r setupScaffolding
    if [[ $setupScaffolding =~ ^[Yy]$ ]]; then
        # Call CRUD scaffolding script
        bash .devcontainer/scripts/dotnet-crud.sh
        
        # Call Auth scaffolding script
        bash .devcontainer/scripts/dotnet-auth.sh
    fi
    
    echo -e "${GREEN}WebAPI project created successfully!${NC}"
else
    echo -e "${RED}Project directory already exists. Skipping project creation.${NC}"
fi

# Restore dependencies
echo -e "${BLUE}Restoring .NET dependencies...${NC}"
dotnet restore
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Dependencies restored successfully!${NC}"
else
    echo -e "${RED}Error restoring dependencies${NC}"
    exit 1
fi

# Build the project
echo -e "${BLUE}Building the project...${NC}"
dotnet build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Project built successfully!${NC}"
else
    echo -e "${RED}Error building project${NC}"
    exit 1
fi

# Create SSL certificate for development
echo -e "${BLUE}Setting up SSL certificate for development...${NC}"
dotnet dev-certs https --clean
dotnet dev-certs https --trust
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SSL certificate created and trusted successfully!${NC}"
else
    echo -e "${RED}Error setting up SSL certificate${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 .NET API initialization complete!${NC}"
echo -e "${BLUE}You can now run the API using:${NC}"
echo -e "${GREEN}dotnet run${NC}"