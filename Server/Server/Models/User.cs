namespace Server.Models;

public partial class User
{
    public int Id { get; set; }

    public string Password { get; set; } = null!;

    public string Username { get; set; } = null!;

    public string? Refreshtoken { get; set; }

    public DateTime? Refreshtokenexpiredate { get; set; }
}
