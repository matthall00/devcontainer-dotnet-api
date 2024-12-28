#!/bin/bash

echo "Would you like to add authentication scaffolding? (y/N)"
read -r scaffoldAuth
if [[ $scaffoldAuth =~ ^[Yy]$ ]]; then
    echo "Setting up authentication..."
    
    # Install JWT packages
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
    dotnet add package System.IdentityModel.Tokens.Jwt
    
    # Create directory structure
    mkdir -p Features/Auth/Models Features/Auth/Controllers
    
    # Create auth models
    cat <<'EOF' > Features/Auth/Models/AuthModel.cs
using System.ComponentModel.DataAnnotations;

namespace WebApi.Features.Auth.Models
{
    public class LoginModel
    {
        [Required]
        public string Username { get; set; }
        [Required]
        public string Password { get; set; }
    }

    public class RegisterModel : LoginModel
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}
EOF

    # Create JWT settings
    cat <<'EOF' > appsettings.json
{
  "Jwt": {
    "Key": "YourSecretKey",
    "Issuer": "YourIssuer",
    "Audience": "YourAudience",
    "DurationInMinutes": 60
  }
}
EOF

    # Create authentication controller
    cat <<'EOF' > Features/Auth/Controllers/AuthController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WebApi.Features.Auth.Models;

namespace WebApi.Features.Auth.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;

        public AuthController(IConfiguration config)
        {
            _config = config;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginModel login)
        {
            if (login.Username == "test" && login.Password == "password")
            {
                var tokenString = GenerateJWT();
                return Ok(new { Token = tokenString });
            }
            return Unauthorized();
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterModel register)
        {
            // Add user registration logic here
            return Ok();
        }

        private string GenerateJWT()
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, "test"),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(Convert.ToDouble(_config["Jwt:DurationInMinutes"])),
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
EOF

    echo "Authentication scaffolding created."
fi
