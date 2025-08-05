# GitHub Copilot Environment Setup

This directory contains GitHub Actions workflows that provide environment setup for GitHub Copilot agents working with the ReadRitual application.

## Available Workflows

### 1. `copilot-setup.yml` - Full Environment Setup
**Purpose**: Complete development environment setup for Copilot agents.

**Features**:
- PostgreSQL 15 database service
- Ruby 3.3.0 environment
- Rails application setup with database preparation
- Environment variable configuration
- Comprehensive verification steps

**Trigger**: 
- Manual dispatch with optional Rails environment selection (development/test)
- Workflow call from other workflows

**Usage**:
```yaml
# Call from another workflow
uses: ./.github/workflows/copilot-setup.yml
with:
  rails_env: development
```

### 2. `env-setup.yml` - Minimal Database Setup
**Purpose**: Lightweight PostgreSQL setup for basic database operations.

**Features**:
- PostgreSQL 15 service
- DATABASE_URL environment variable
- Database connection verification

**Trigger**:
- Manual dispatch
- Workflow call

### 3. `setup-postgres.yml` - Reusable PostgreSQL Service
**Purpose**: Reusable workflow component for PostgreSQL setup.

**Features**:
- PostgreSQL service with health checks
- Database URL output for consuming workflows
- Connection testing

**Usage**:
```yaml
# Use as a reusable workflow
jobs:
  setup-db:
    uses: ./.github/workflows/setup-postgres.yml
  
  my-job:
    needs: setup-db
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: ${{ needs.setup-db.outputs.database-url }}
```

## Environment Variables

All workflows provide the following environment variables:

- `DATABASE_URL`: Connection string for PostgreSQL database
  - Format: `postgres://[user]:[password]@localhost:5432[/database_name]`
  - User: configurable via `POSTGRES_USER` (defaults to 'postgres')
  - Password: configurable via GitHub secrets `POSTGRES_PASSWORD` (defaults to 'postgres')
  - Default port: `5432`

## Security Configuration

To use these workflows with custom database credentials, set up the following GitHub repository secrets:

- `POSTGRES_PASSWORD`: Custom PostgreSQL password (defaults to 'postgres' if not set)

### Environment Variables

The workflows use the following environment variables:
- `POSTGRES_USER`: PostgreSQL username (defaults to 'postgres')
- `POSTGRES_PASSWORD`: PostgreSQL password (from GitHub secrets or defaults to 'postgres')
- `RAILS_ENV`: Rails environment (development/test)
- `DATABASE_URL`: Constructed automatically from the above variables

For development environments, the workflow defaults to standard PostgreSQL credentials, but production deployments should use GitHub secrets for secure credential management.

## DevContainer Support

The `.devcontainer/` directory provides GitHub Codespaces support:

- **devcontainer.json**: VSCode configuration with Ruby LSP and extensions
- **docker-compose.yml**: Multi-service setup with app and PostgreSQL

**Features**:
- Pre-configured Ruby 3.3.0 environment
- PostgreSQL database service
- Rails-specific VSCode extensions
- Automatic dependency installation
- Port forwarding for Rails server (3000) and PostgreSQL (5432)

## For GitHub Copilot Agents

Copilot agents can use these workflows to:

1. **Quick database setup**: Use `env-setup.yml` for basic PostgreSQL access
2. **Full environment**: Use `copilot-setup.yml` for complete Rails development setup
3. **Codespaces**: Use the devcontainer configuration for persistent development environments

### Example Copilot Usage

When a Copilot agent needs to run Rails commands or access the database:

1. Trigger the `copilot-setup.yml` workflow
2. Use the provided `DATABASE_URL` environment variable
3. Run Rails commands in the configured environment

The environment will include:
- Working PostgreSQL instance
- Properly configured Rails application
- All necessary system dependencies
- Database prepared and ready for use