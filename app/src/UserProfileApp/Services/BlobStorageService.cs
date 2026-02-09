using Azure.Identity;
using Azure.Storage.Blobs;

namespace UserProfileApp.Services;

public interface IBlobStorageService
{
    Task<string> GetBlobUrlAsync(string blobPath);
    Task<Stream?> GetBlobStreamAsync(string blobPath);
}

public class BlobStorageService : IBlobStorageService
{
    private readonly BlobServiceClient _blobServiceClient;
    private readonly ILogger<BlobStorageService> _logger;

    public BlobStorageService(IConfiguration configuration, ILogger<BlobStorageService> logger)
    {
        _logger = logger;
        
        var storageAccountName = configuration["AzureStorage:AccountName"];
        
        // Use Managed Identity for authentication
        var blobUri = new Uri($"https://{storageAccountName}.blob.core.windows.net");
        _blobServiceClient = new BlobServiceClient(blobUri, new DefaultAzureCredential());
    }

    public async Task<string> GetBlobUrlAsync(string blobPath)
    {
        try
        {
            // blobPath format: "container-name/blob-name" e.g., "user-pictures/user1.jpg"
            var parts = blobPath.Split('/', 2);
            if (parts.Length != 2)
            {
                _logger.LogWarning("Invalid blob path format: {BlobPath}", blobPath);
                return "/images/default-avatar.png";
            }

            var containerName = parts[0];
            var blobName = parts[1];

            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            if (await blobClient.ExistsAsync())
            {
                // Generate SAS token for temporary access (valid for 1 hour)
                var sasUri = blobClient.GenerateSasUri(
                    Azure.Storage.Sas.BlobSasPermissions.Read,
                    DateTimeOffset.UtcNow.AddHours(1));
                
                return sasUri.ToString();
            }

            _logger.LogWarning("Blob not found: {BlobPath}", blobPath);
            return "/images/default-avatar.png";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting blob URL for {BlobPath}", blobPath);
            return "/images/default-avatar.png";
        }
    }

    public async Task<Stream?> GetBlobStreamAsync(string blobPath)
    {
        try
        {
            var parts = blobPath.Split('/', 2);
            if (parts.Length != 2) return null;

            var containerName = parts[0];
            var blobName = parts[1];

            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            if (await blobClient.ExistsAsync())
            {
                var response = await blobClient.DownloadStreamingAsync();
                return response.Value.Content;
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting blob stream for {BlobPath}", blobPath);
            return null;
        }
    }
}
