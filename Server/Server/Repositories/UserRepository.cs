using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using Server.DTOs;
using Server.IRepositories;
using Server.IServices;
using Server.Models;

namespace Server.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly UserAppDbContext _yourPlacesDbContext;
        private readonly ITokenService _tokenService;
        private readonly IUserService _userService;

        public UserRepository(UserAppDbContext yourPlacesDbContext, ITokenService tokenService, IUserService userService)
        {
            _yourPlacesDbContext = yourPlacesDbContext;
            _tokenService = tokenService;
            _userService = userService;
        }
        public async Task<CustomReturnDTO> Register(UserDTO userDTO)
        {
            var user = await _yourPlacesDbContext.Users.Where(u => u.Username == userDTO.Username).FirstOrDefaultAsync();
            if (user == null)
            {
                await _yourPlacesDbContext.Users.AddAsync(new User
                {
                    Password = BCrypt.Net.BCrypt.HashPassword(userDTO.Password),
                    Username = userDTO.Username
                });
                await _yourPlacesDbContext.SaveChangesAsync();
                return new CustomReturnDTO { Type = true };

            }
            return new CustomReturnDTO { Type = false, Message = "This username already exists!" };
        }
        public async Task<TokenDTO?> Login(UserDTO userDTO)
        {
            var user = await _yourPlacesDbContext.Users.Where(u => u.Username == userDTO.Username).FirstOrDefaultAsync();
            if (user == null)
            {
                return null;
            }
            if (!BCrypt.Net.BCrypt.Verify(userDTO.Password, user.Password))
            {
                return null;
            }
            user.Refreshtoken = Convert.ToHexString(RandomNumberGenerator.GetBytes(64));
            user.Refreshtokenexpiredate = DateTime.Now.AddDays(7);
            await _yourPlacesDbContext.SaveChangesAsync();
            return new TokenDTO { RefreshToken = user.Refreshtoken, AccessToken = _tokenService.CreateToken(user.Id) };
        }
        public async Task<CustomReturnDTO> Logout()
        {
            var userId = _userService.GetUserId();
            var user = await _yourPlacesDbContext.Users.Where(u => u.Id == userId).FirstOrDefaultAsync();
            user!.Refreshtokenexpiredate = null;
            user.Refreshtoken = null;
            await _yourPlacesDbContext.SaveChangesAsync();
            return new CustomReturnDTO { Type = true };
        }
        public async Task<TokenDTO?> AccessToken(string refreshToken)
        {
            var user = await _yourPlacesDbContext.Users.Where(u => u.Refreshtoken == refreshToken && DateTime.Now <= u.Refreshtokenexpiredate).FirstOrDefaultAsync();
            if (user == null)
            {
                return null;
            }
            user.Refreshtoken = Convert.ToHexString(RandomNumberGenerator.GetBytes(64));
            user.Refreshtokenexpiredate = DateTime.Now.AddDays(7);
            await _yourPlacesDbContext.SaveChangesAsync();
            return new TokenDTO { RefreshToken = user.Refreshtoken, AccessToken = _tokenService.CreateToken(user.Id) };
        }

        public async Task<string> GetUsername()
        {
            var userId = _userService.GetUserId();
            return (await _yourPlacesDbContext!.Users.Where(u => u.Id == userId).FirstOrDefaultAsync())!.Username;
        }
    }
}
