#!/bin/bash

echo "Would you like to add basic CRUD scaffolding? (y/N)"
read -r scaffoldCrud
if [[ $scaffoldCrud =~ ^[Yy]$ ]]; then
    echo "Creating Features-based structure..."
    
    # Create directory structure
    mkdir -p Features/Weather/Models Features/Weather/Controllers Features/Users/Models Features/Users/Controllers

    # Create Weather feature files
    cat <<'EOF' > Features/Weather/Models/WeatherForecast.cs
using System;

namespace WebApi.Features.Weather.Models
{
    public class WeatherForecast
    {
        public DateTime Date { get; set; }
        public int TemperatureC { get; set; }
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
        public string Summary { get; set; }
    }
}
EOF

    cat <<'EOF' > Features/Weather/Controllers/WeatherForecastController.cs
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using WebApi.Features.Weather.Models;

namespace WebApi.Features.Weather.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        [HttpGet]
        public IEnumerable<WeatherForecast> Get()
        {
            var rng = new Random();
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateTime.Now.AddDays(index),
                TemperatureC = rng.Next(-20, 55),
                Summary = Summaries[rng.Next(Summaries.Length)]
            })
            .ToArray();
        }
    }
}
EOF

    # Create User model
    cat <<'EOF' > Features/Users/Models/User.cs
using System;

namespace WebApi.Features.Users.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
EOF

    # Create User controller
    cat <<'EOF' > Features/Users/Controllers/UserController.cs
using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using WebApi.Features.Users.Models;

namespace WebApi.Features.Users.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private static List<User> _users = new List<User>();

        [HttpGet]
        public ActionResult<IEnumerable<User>> GetAll()
        {
            return Ok(_users);
        }

        [HttpGet("{id}")]
        public ActionResult<User> GetById(int id)
        {
            var user = _users.Find(u => u.Id == id);
            if (user == null) return NotFound();
            return Ok(user);
        }

        [HttpPost]
        public ActionResult<User> Create(User user)
        {
            user.Id = _users.Count + 1;
            user.CreatedAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;
            _users.Add(user);
            return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, User user)
        {
            var index = _users.FindIndex(u => u.Id == id);
            if (index < 0) return NotFound();
            
            user.Id = id;
            user.UpdatedAt = DateTime.UtcNow;
            _users[index] = user;
            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var index = _users.FindIndex(u => u.Id == id);
            if (index < 0) return NotFound();
            
            _users.RemoveAt(index);
            return NoContent();
        }
    }
}
EOF
    
    echo "CRUD scaffolding created."
fi
