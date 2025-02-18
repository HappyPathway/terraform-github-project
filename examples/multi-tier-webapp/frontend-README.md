# ACME Shop Frontend Development Guide

## Technology Stack
- React 18+
- TypeScript
- Vite
- TailwindCSS
- React Query
- React Router
- Jest + React Testing Library

## Development Setup
1. Node.js 18+ required
2. Install dependencies: `npm install`
3. Start development server: `npm run dev`
4. Run tests: `npm test`

## Project Structure
```
src/
├── components/     # Reusable UI components
├── pages/         # Route components
├── hooks/         # Custom React hooks
├── services/      # API integration
├── store/         # State management
└── utils/         # Helper functions
```

## Coding Standards
- Use functional components with hooks
- Write unit tests for all components
- Follow AirBnB style guide
- Use TypeScript strict mode
- Implement proper error boundaries
- Use lazy loading for routes