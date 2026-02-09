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

app.Run();
