#!/bin/bash

# Create a simple HTML file that uses Manrope font
cat > test-manrope.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Manrope Font Test</title>
    <style>
        @font-face {
            font-family: 'Manrope';
            src: local('Manrope');
        }
        body {
            font-family: 'Manrope', sans-serif;
        }
        h1 {
            font-family: 'Manrope', sans-serif;
        }
    </style>
</head>
<body>
    <h1>This is a test of the Manrope font</h1>
    <p>This paragraph should be displayed using Manrope font if it's available.</p>
</body>
</html>
EOF

echo "Testing Manrope font with Gotenberg..."
echo "Converting HTML to PDF..."

# Send the HTML file to Gotenberg for conversion to PDF
curl -s --output test-manrope.pdf -F "files=@test-manrope.html" http://localhost:9898/forms/chromium/convert/html

echo "PDF created as test-manrope.pdf"
echo "If Manrope font is installed properly, it should be used in the generated PDF."
echo "Check the PDF to verify the font is working correctly." 