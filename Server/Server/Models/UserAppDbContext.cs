using Microsoft.EntityFrameworkCore;

namespace Server.Models;

public partial class UserAppDbContext : DbContext
{
    private readonly IConfiguration _configuration;
    public UserAppDbContext(DbContextOptions<UserAppDbContext> options, IConfiguration configuration)
        : base(options)
    {
        _configuration = configuration;
    }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    => optionsBuilder.UseSqlServer(_configuration.GetConnectionString("Default"));

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("user");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Password)
                .HasMaxLength(65)
                .IsUnicode(false)
                .HasColumnName("password");
            entity.Property(e => e.Refreshtoken)
                .HasMaxLength(130)
                .IsUnicode(false)
                .HasColumnName("refreshtoken");
            entity.Property(e => e.Refreshtokenexpiredate).HasColumnName("refreshtokenexpiredate");
            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .HasColumnName("username");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
