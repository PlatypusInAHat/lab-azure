using Microsoft.AspNetCore.Mvc;
using UserProfileApp.Services;

namespace UserProfileApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ImagesController : ControllerBase
{
    private readonly IBlobStorageService _blobService;
    private readonly ILogger<ImagesController> _logger;

    public ImagesController(IBlobStorageService blobService, ILogger<ImagesController> logger)
    {
        _blobService = blobService;
        _logger = logger;
    }

    /// <summary>
    /// Get image from blob storage for display
    /// Path format: container-name/blob-name (e.g., user-pictures/user1.jpg)
    /// </summary>
    [HttpGet("{**path}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetImage(string path)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                _logger.LogWarning("Invalid image path requested");
                return BadRequest("Image path is required");
            }

            // Try to get blob stream from Azure Blob Storage
            var stream = await _blobService.GetBlobStreamAsync(path);
            
            if (stream == null)
            {
                _logger.LogWarning("Image not found: {Path}", path);
                return NotFound($"Image '{path}' not found in blob storage");
            }

            // Determine content type based on file extension
            var contentType = GetContentType(path);
            
            _logger.LogInformation("Serving image from blob: {Path}", path);
            return File(stream, contentType);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving image {Path}", path);
            return StatusCode(StatusCodes.Status500InternalServerError, "Error retrieving image");
        }
    }

    /// <summary>
    /// Get signed URL for direct blob access (for development/testing)
    /// This generates a SAS URL with 1-hour expiration
    /// </summary>
    [HttpGet("url/{**path}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetImageUrl(string path)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(path))
                return BadRequest("Image path is required");

            var url = await _blobService.GetBlobUrlAsync(path);
            
            if (string.IsNullOrEmpty(url))
            {
                _logger.LogWarning("Failed to generate URL for image: {Path}", path);
                return NotFound($"Image '{path}' not found");
            }

            return Ok(new { url });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating image URL for {Path}", path);
            return StatusCode(StatusCodes.Status500InternalServerError, "Error generating image URL");
        }
    }

    private string GetContentType(string filePath)
    {
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        return extension switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".webp" => "image/webp",
            ".bmp" => "image/bmp",
            ".svg" => "image/svg+xml",
            _ => "application/octet-stream"
        };
    }
}
