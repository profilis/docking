<?php

namespace App\Services;

use Exception;
use Illuminate\Http\File;
use Illuminate\Support\Facades\Storage;

class ThumbnailGenerator
{
    /**
     * Generate a thumbnail from the first page of a PDF file using GhostScript.
     *
     * @param string $pdfPath Path to the PDF file
     * @param int $width Thumbnail width in pixels
     * @param int $height Thumbnail height in pixels
     * @return string|null The URL of the generated thumbnail or null if generation failed
     */
    public function generateFromPdf(string $pdfPath, int $width = 300, int $height = 400): ?string
    {
        try {
            // Create a temporary file for the thumbnail PNG
            $outputPath = tempnam(sys_get_temp_dir(), 'gs_thumbnail_') . '.png';

            // Use GhostScript to generate a PNG thumbnail of the first page
            // The -dFirstPage=1 -dLastPage=1 ensures only the first page is processed
            // The -sDEVICE=png16m selects a PNG output with 16 million colors
            // The -dGraphicsAlphaBits=4 -dTextAlphaBits=4 parameters provide anti-aliasing
            $resolution = 150; // Higher resolution for better quality

            $command = "gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dFirstPage=1 -dLastPage=1 -r{$resolution} -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sOutputFile={$outputPath} {$pdfPath} 2>&1";

            $output = shell_exec($command);

            if ($output !== null && !file_exists($outputPath)) {
                error_log("Failed to generate thumbnail: " . $output);
                return null;
            }

            // Store the thumbnail in the storage
            $file = new File($outputPath);
            $storedPath = Storage::putFile('thumbnails', $file, [
                'visibility' => 'public',
            ]);

            if ($storedPath === false) {
                return null;
            }

            // Clean up temporary file
            @unlink($outputPath);

            // Return the URL of the stored thumbnail
            return Storage::url($storedPath);
        } catch (Exception $e) {
            error_log($e->getMessage());
            return null;
        }
    }
}
