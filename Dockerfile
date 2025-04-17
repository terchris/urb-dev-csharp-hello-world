# filename: templates/csharp-basic-webserver/Dockerfile
# Multi-stage build for ASP.NET Core application
# Maintains port configuration parity with Program.cs (3000)

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/WebApplication/WebApplication.csproj", "WebApplication/"]
RUN dotnet restore "WebApplication/WebApplication.csproj"
COPY . .
WORKDIR "/src/WebApplication"

# Publish with port configuration
RUN dotnet publish "WebApplication.csproj" \
    -c Release \
    -o /app/publish \
    -p:ASP NETCORE_URLS=http://+:3000  # Set default port for container

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Expose port 3000 to match Program.cs configuration
EXPOSE 3000

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "WebApplication.dll"]