FROM gotenberg/gotenberg:8

# Install necessary packages and fonts
USER root
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    fontconfig \
    fonts-roboto \
    fonts-open-sans \
    fonts-noto \
    fonts-liberation \
    fonts-lato \
    && rm -rf /var/lib/apt/lists/*

# Download and install Manrope font directly from Google Fonts CDN
WORKDIR /tmp
RUN mkdir -p /usr/share/fonts/truetype/manrope

# Download each Manrope variant directly from Google Fonts CDN
RUN curl -s -o /usr/share/fonts/truetype/manrope/manrope-regular.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggexSg.ttf" \
    && curl -s -o /usr/share/fonts/truetype/manrope/manrope-bold.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggmxSg.ttf" \
    && curl -s -o /usr/share/fonts/truetype/manrope/manrope-medium.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggSxSg.ttf" \
    && curl -s -o /usr/share/fonts/truetype/manrope/manrope-light.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggixSg.ttf"

# Update font cache
RUN fc-cache -f -v

# Switch back to default user and working directory
WORKDIR /gotenberg
USER gotenberg

# Use the standard Gotenberg entrypoint
ENTRYPOINT ["/gotenberg"] 