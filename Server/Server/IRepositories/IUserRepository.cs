using Server.DTOs;

namespace Server.IRepositories
{
    public interface IUserRepository
    {
        public Task<CustomReturnDTO> Register(UserDTO userDTO);
        public Task<TokenDTO?> Login(UserDTO userDTO);
        public Task<CustomReturnDTO> Logout();
        public Task<TokenDTO?> AccessToken(string refreshToken);
        public Task<string> GetUsername();
    }
}
