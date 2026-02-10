using Microsoft.EntityFrameworkCore;
using UserProfileApp.Data;
using UserProfileApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddRazorPages();

// Add DbContext with connection string from Key Vault
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Blob Storage service
builder.Services.AddSingleton<IBlobStorageService, BlobStorageService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();

// Health check endpoint for Application Gateway
app.MapGet("/health", () => Results.Ok("Healthy"));

// Image proxy endpoint - serves blob images through App Service
// This works even when blob storage is private (App Service uses Managed Identity)
app.MapGet("/api/images/{container}/{*blobName}", async (string container, string blobName, IBlobStorageService blobService) =>
{
    var blobPath = $"{container}/{blobName}";
    var stream = await blobService.GetBlobStreamAsync(blobPath);
    
    if (stream == null)
        return Results.NotFound();

    // Determine content type from extension
    var ext = Path.GetExtension(blobName).ToLowerInvariant();
    var contentType = ext switch
    {
        ".jpg" or ".jpeg" => "image/jpeg",
        ".png" => "image/png",
        ".gif" => "image/gif",
        ".webp" => "image/webp",
        ".svg" => "image/svg+xml",
        _ => "application/octet-stream"
    };

    return Results.Stream(stream, contentType);
});

app.Run();
