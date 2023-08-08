using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.IRepositories;

namespace Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserRepository _userRepository;
        public UserController(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(UserDTO userDTO)
        {
            var result = await _userRepository.Register(userDTO);
            if (result.Type == false)
            {
                return BadRequest(result.Message);
            }
            return NoContent();
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login(UserDTO userDTO)
        {
            var result = await _userRepository.Login(userDTO);
            if (result == null)
            {
                return NotFound("User not found!");
            }
            return Ok(result);

        }
        [HttpGet("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            await _userRepository.Logout();
            return NoContent();
        }
        [HttpPost("createaccesstoken")]
        public async Task<IActionResult> CreateAccessToken([FromHeader] string refreshToken)
        {
            var result = await _userRepository.AccessToken(refreshToken);
            if (result == null)
            {
                return NotFound();
            }
            return Ok(result);
        }
        [HttpGet("username")]
        [Authorize]
        public async Task<IActionResult> GetUsername()
        {
            return Ok(await _userRepository.GetUsername());
        }
    }
}
