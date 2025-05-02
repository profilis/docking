FROM gotenberg/gotenberg:8

# Install necessary packages and fonts
USER root
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    fontconfig \
    fonts-roboto \
    fonts-open-sans \
    fonts-noto \
    fonts-liberation \
    fonts-lato \
    && rm -rf /var/lib/apt/lists/*

# Download and install Manrope font
WORKDIR /tmp
RUN mkdir -p /usr/share/fonts/truetype/manrope
RUN wget -q https://github.com/sharanda/manrope/releases/download/v4.504/manrope-4.504.zip \
    && unzip manrope-4.504.zip -d manrope \
    && cp manrope/*.ttf /usr/share/fonts/truetype/manrope/ \
    && rm -rf /tmp/manrope /tmp/manrope-4.504.zip

# Update font cache
RUN fc-cache -f -v

# Switch back to default user and working directory
WORKDIR /gotenberg
USER gotenberg

# Use the standard Gotenberg entrypoint
ENTRYPOINT ["/gotenberg"] 