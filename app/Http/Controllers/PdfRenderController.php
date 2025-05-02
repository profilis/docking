<?php

namespace App\Http\Controllers;

use App\Events\PdfRendered;
use App\Http\Requests\PdfRenderAsyncRequest;
use App\Http\Requests\PdfRenderRequest;
use App\Jobs\RenderJob;
use App\Models\DocumentTemplate;
use App\Services\PdfRenderManager;
use App\Services\ThumbnailGenerator;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Storage;

class PdfRenderController extends Controller
{
    public function render(
        PdfRenderRequest $request,
        DocumentTemplate $documentTemplate,
        PdfRenderManager $manager
    ): JsonResponse {
        $renderResult = $manager->render(
            $documentTemplate,
            $request->input('variables') ?: [],
            [
                ...$documentTemplate->metadata,
                ...$request->getMetadata(),
            ],
        );

        if ($renderResult->isError()) {
            return new JsonResponse([
                'outcome' => $renderResult->getErrorResult()->errorCode,
            ], 400);
        }

        $okResult = $renderResult->getOkResult();

        Event::dispatch(new PdfRendered($okResult->file));

        return new JsonResponse([
            'outcome' => 'SUCCESS',
            'document_file_uuid' => $okResult->file->uuid,
            'url' => $okResult->file->url,
            'size' => $okResult->file->size,
        ]);
    }

    public function renderAsync(
        PdfRenderAsyncRequest $request,
        DocumentTemplate $documentTemplate
    ): JsonResponse {
        RenderJob::dispatch(
            $documentTemplate,
            $request->input('variables') ?: [],
            [
                ...$documentTemplate->metadata,
                ...$request->getMetadata(),
                'webhook_url' => $request->input('webhook_url'),
            ],
        );

        return new JsonResponse([
            'outcome' => 'QUEUED',
        ]);
    }

    /**
     * Generate a thumbnail preview of the document's first page
     */
    public function generateThumbnail(
        DocumentTemplate $documentTemplate,
        PdfRenderManager $manager,
        ThumbnailGenerator $thumbnailGenerator
    ): JsonResponse {
        // Render the PDF with default variables
        $renderResult = $manager->render(
            $documentTemplate,
            $documentTemplate->default_variables ?: [],
            [
                ...$documentTemplate->metadata,
                'is_preview' => true,
                'thumbnail_generation' => true,
            ]
        );

        if ($renderResult->isError()) {
            return new JsonResponse([
                'outcome' => $renderResult->getErrorResult()->errorCode,
            ], 400);
        }

        $okResult = $renderResult->getOkResult();
        $pdfFile = $okResult->file;

        // Get the full path to the PDF file
        $pdfFullPath = Storage::path($pdfFile->path);

        // Generate thumbnail from the PDF
        $thumbnailUrl = $thumbnailGenerator->generateFromPdf($pdfFullPath, 300, 400);

        if (!$thumbnailUrl) {
            return new JsonResponse([
                'outcome' => 'THUMBNAIL_GENERATION_FAILED',
            ], 500);
        }

        return new JsonResponse([
            'outcome' => 'SUCCESS',
            'thumbnail_url' => $thumbnailUrl,
        ]);
    }
}
