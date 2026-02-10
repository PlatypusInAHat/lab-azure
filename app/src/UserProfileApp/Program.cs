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

// Auto-create database tables and seed data on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        // EnsureCreated will create tables if they don't exist
        db.Database.EnsureCreated();

        // Seed data if empty
        if (!db.Users.Any())
        {
            db.Users.AddRange(
                new UserProfileApp.Models.User
                {
                    Name = "Nguyen Van An",
                    Email = "an.nguyen@email.com",
                    PhoneNumber = "0901234567",
                    Address = "123 Le Loi, Quan 1, TP.HCM",
                    ProfilePicturePath = "user-pictures/images.jpg"
                },
                new UserProfileApp.Models.User
                {
                    Name = "Tran Thi Binh",
                    Email = "binh.tran@email.com",
                    PhoneNumber = "0912345678",
                    Address = "456 Nguyen Hue, Quan 1, TP.HCM",
                    ProfilePicturePath = "user-pictures/images (1).jpg"
                },
                new UserProfileApp.Models.User
                {
                    Name = "Le Hoang Cuong",
                    Email = "cuong.le@email.com",
                    PhoneNumber = "0923456789",
                    Address = "789 Hai Ba Trung, Quan 3, TP.HCM",
                    ProfilePicturePath = "user-pictures/images (7).jpg"
                }
            );
            db.SaveChanges();
            Console.WriteLine("Database seeded with 3 users.");
        }
        else
        {
            Console.WriteLine($"Database already has {db.Users.Count()} users.");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database init error: {ex.Message}");
    }
}

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
