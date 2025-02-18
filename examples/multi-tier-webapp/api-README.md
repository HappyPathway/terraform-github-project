# ACME Shop API Development Guide

## Technology Stack
- Node.js
- Express.js
- TypeScript
- PostgreSQL
- Jest
- OpenAPI/Swagger

## Development Setup
1. Node.js 18+ required
2. PostgreSQL 14+ required
3. Install dependencies: `npm install`
4. Set up environment variables (copy .env.example)
5. Run migrations: `npm run migrate`
6. Start development server: `npm run dev`

## Project Structure
```
src/
├── controllers/   # Route handlers
├── services/     # Business logic
├── models/       # Data models
├── middleware/   # Express middleware
├── utils/        # Helper functions
└── config/       # Configuration
```

## API Documentation
- OpenAPI spec available at /api-docs
- Keep API documentation up to date
- Follow RESTful principles
- Use proper HTTP status codes

## Security Guidelines
- Implement rate limiting
- Use JWT for authentication
- Validate all inputs
- Implement proper error handling
- Use Helmet.js for security headers