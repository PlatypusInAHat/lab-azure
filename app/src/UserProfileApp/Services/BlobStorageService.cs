using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;

namespace UserProfileApp.Services;

public interface IBlobStorageService
{
    Task<string> GetBlobUrlAsync(string blobPath);
    Task<Stream?> GetBlobStreamAsync(string blobPath);
    Task<string> UploadBlobAsync(string containerName, string blobName, Stream content, string contentType);
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
                return "";
            }

            var containerName = parts[0];
            var blobName = parts[1];

            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            if (await blobClient.ExistsAsync())
            {
                // Use User Delegation Key for SAS (works with Managed Identity)
                var userDelegationKey = await _blobServiceClient.GetUserDelegationKeyAsync(
                    DateTimeOffset.UtcNow.AddMinutes(-5),
                    DateTimeOffset.UtcNow.AddHours(1));

                var sasBuilder = new BlobSasBuilder
                {
                    BlobContainerName = containerName,
                    BlobName = blobName,
                    Resource = "b",
                    ExpiresOn = DateTimeOffset.UtcNow.AddHours(1)
                };
                sasBuilder.SetPermissions(BlobSasPermissions.Read);

                var sasUri = new BlobUriBuilder(blobClient.Uri)
                {
                    Sas = sasBuilder.ToSasQueryParameters(userDelegationKey, _blobServiceClient.AccountName)
                };
                
                return sasUri.ToUri().ToString();
            }

            _logger.LogWarning("Blob not found: {BlobPath}", blobPath);
            return "";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting blob URL for {BlobPath}", blobPath);
            // Fallback: return proxy URL
            return $"/api/images/{blobPath}";
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

    public async Task<string> UploadBlobAsync(string containerName, string blobName, Stream content, string contentType)
    {
        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            await containerClient.CreateIfNotExistsAsync();
            
            var blobClient = containerClient.GetBlobClient(blobName);
            await blobClient.UploadAsync(content, new BlobHttpHeaders { ContentType = contentType });
            
            return $"{containerName}/{blobName}";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading blob {ContainerName}/{BlobName}", containerName, blobName);
            throw;
        }
    }
}
