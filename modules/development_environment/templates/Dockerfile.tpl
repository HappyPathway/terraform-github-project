FROM ${base_image}

# Install git (required for Copilot)
RUN apt-get update && apt-get install -y git

# Any additional setup would go here