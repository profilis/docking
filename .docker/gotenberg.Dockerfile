FROM gotenberg/gotenberg:8

USER root

# Install common fonts from apt repositories
RUN apt-get update && apt-get install -y \
    curl \
    fonts-roboto \
    fonts-open-sans \
    fonts-noto \
    fonts-liberation \
    fonts-lato \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a fonts directory for our custom Manrope fonts
RUN mkdir -p /tmp/manrope_fonts

# Download Manrope font files directly
WORKDIR /tmp/manrope_fonts
RUN curl -s -o manrope-regular.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggexSg.ttf" && \
    curl -s -o manrope-bold.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggmxSg.ttf" && \
    curl -s -o manrope-medium.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggSxSg.ttf" && \
    curl -s -o manrope-light.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggixSg.ttf" && \
    curl -s -o manrope-semibold.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggqxSg.ttf" && \
    curl -s -o manrope-extrabold.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggOxSg.ttf" && \
    curl -s -o manrope-extralight.ttf "https://fonts.gstatic.com/s/manrope/v14/xn7gYHE41ni1AdIRggaxSg.ttf"

# Copy fonts to the recommended location
RUN cp -r /tmp/manrope_fonts/*.ttf /usr/local/share/fonts/ && \
    fc-cache -f -v && \
    rm -rf /tmp/manrope_fonts

USER gotenberg

# Use the correct entrypoint
ENTRYPOINT ["/usr/local/bin/gotenberg"] 