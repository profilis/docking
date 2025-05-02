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

# Download and install Manrope font from Google Fonts
WORKDIR /tmp
RUN mkdir -p /usr/share/fonts/truetype/manrope
RUN wget -q "https://fonts.google.com/download?family=Manrope" -O manrope.zip \
    && unzip -j manrope.zip -d manrope \
    && find manrope -name "*.ttf" -exec cp {} /usr/share/fonts/truetype/manrope/ \; \
    && rm -rf manrope manrope.zip

# Update font cache
RUN fc-cache -f -v

# Switch back to default user and working directory
WORKDIR /gotenberg
USER gotenberg

# Use the standard Gotenberg entrypoint
ENTRYPOINT ["/gotenberg"] 