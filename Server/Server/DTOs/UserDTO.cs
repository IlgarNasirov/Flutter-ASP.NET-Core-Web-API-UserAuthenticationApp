using System.ComponentModel.DataAnnotations;

namespace Server.DTOs
{
    public class UserDTO
    {
        [Required]
        [MinLength(3)]
        [MaxLength(50)]
        public string Username { get; set; } = null!;
        [Required]
        [MinLength(6)]
        public string Password { get; set; } = null!;
    }
}
