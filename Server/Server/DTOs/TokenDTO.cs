namespace Server.DTOs
{
    public class TokenDTO
    {
        public string RefreshToken { get; set; } = null!;
        public string AccessToken { get; set; } = null!;
    }
}
