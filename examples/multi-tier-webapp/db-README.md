# ACME Shop Database Guide

## Technology Stack
- PostgreSQL 14+
- sqitch for migrations
- pg_dump for backups
- PostGIS for location data

## Database Setup
1. Install PostgreSQL 14+
2. Install sqitch
3. Create database: `createdb acme_shop`
4. Run migrations: `sqitch deploy`

## Schema Structure
```
schemas/
├── public/           # Main schema
├── audit/           # Audit logging
└── analytics/       # Analytics views
```

## Migration Guidelines
- Always be backward compatible
- Include rollback scripts
- Document schema changes
- Follow naming conventions
- Add appropriate indices
- Consider performance impact

## Backup Strategy
- Daily full backups
- Point-in-time recovery
- Regular backup testing
- Monitoring and alerts

## Performance Guidelines
- Use appropriate data types
- Implement proper indexing
- Regular VACUUM and analyze
- Monitor query performance