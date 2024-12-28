# Copilot Instructions for .NET API Development

You are an AI assistant helping with a .NET API project. Follow these guidelines:

## Project Structure
- Project uses a standard .NET 7+ WebAPI structure
- Controllers are in `/Controllers` directory
- Models are in `/Models` directory
- Authentication uses JWT Bearer tokens
- CRUD operations follow RESTful patterns

## Code Style
- Use async/await patterns for database and I/O operations
- Follow SOLID principles
- Include XML documentation for public APIs
- Use consistent naming:
  - Controllers: `{Resource}Controller`
  - Models: Pascal case (e.g., `UserModel`)
  - Interfaces: Prefix with I (e.g., `IUserService`)

## API Patterns
- Use proper HTTP status codes (200, 201, 400, 401, 403, 404, 500)
- Include validation attributes on model properties
- Return ActionResult<T> for consistent response types
- Structure endpoints as:
  - GET /api/[controller] - List
  - GET /api/[controller]/{id} - Get one
  - POST /api/[controller] - Create
  - PUT /api/[controller]/{id} - Update
  - DELETE /api/[controller]/{id} - Delete

## Security
- Validate all input data
- Use authentication attributes where required
- Never expose sensitive data in responses
- Use HTTPS endpoints
- Follow OWASP security guidelines

## Response Format
```json
{
    "data": {
        // Resource data here
    },
    "errors": [],
    "metadata": {
        "timestamp": "2023-01-01T00:00:00Z",
        "version": "1.0"
    }
}
```

## Error Handling
- Use consistent error response format
- Include appropriate error messages
- Log exceptions properly
- Return proper HTTP status codes

## Testing
- Write unit tests for controllers and services
- Use xUnit for testing
- Mock external dependencies
- Test happy path and error scenarios
