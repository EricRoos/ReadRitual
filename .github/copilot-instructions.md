# ReadRitual - Reading Tracker Application

ReadRitual is a Ruby on Rails 8.0.2 web application for tracking personal reading habits, goals, and progress. Users can track books they're reading, set yearly reading goals (default 100 books), manage authors, and automatically fetch book cover images.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the information here.

## Working Effectively

### Initial Environment Setup

CRITICAL: Follow these steps exactly in order. Do NOT skip any step.

1. **Install System Dependencies**:
   ```bash
   sudo service postgresql start
   sudo gem install bundler foreman
   ```

2. **Setup PostgreSQL Authentication**:
   ```bash
   sudo -u postgres createuser -s $(whoami)
   sudo -u postgres psql -c "ALTER USER $(whoami) PASSWORD 'postgres';"
   sudo -u postgres createdb read_ritual_development
   sudo -u postgres createdb read_ritual_test
   ```

3. **Install Project Dependencies**:
   ```bash
   sudo bin/bundle install
   ```
   - **NEVER CANCEL**: Takes ~2 minutes. Set timeout to 5+ minutes minimum.
   - Uses sudo due to system Ruby gem permissions
   - Installs 133 gems including Rails 8.0.2, PostgreSQL, Tailwind CSS

4. **Setup Application Environment**:
   ```bash
   export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
   bin/setup --skip-server
   ```
   - **NEVER CANCEL**: Takes ~2 minutes. Set timeout to 5+ minutes minimum.
   - Prepares database and clears logs/temp files

### Development Server

- **Start development server**: 
  ```bash
  export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
  bin/dev
  ```
  - Runs both Rails server (port 3000) and Tailwind CSS watcher
  - Requires Foreman gem (installed in setup)
  - Server starts in ~10 seconds

- **Alternative server command**:
  ```bash
  export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
  bin/rails server -p 3000
  ```

### Testing

- **Unit Tests**:
  ```bash
  export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_test"
  bin/rails db:test:prepare
  bin/rails test
  ```
  - **Runtime**: ~3 seconds for 43 tests
  - **Timeout**: Set to 2+ minutes minimum

- **System Tests** (Browser automation with Capybara/Selenium):
  ```bash
  export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_test"
  bin/rails test:system
  ```
  - **NEVER CANCEL**: Takes ~5 minutes 27 seconds for 60 tests
  - **Timeout**: Set to 10+ minutes minimum
  - Runs parallel tests with Chrome browser
  - Creates screenshots on failure in `tmp/screenshots/`

- **All Tests** (CI equivalent):
  ```bash
  export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_test"
  bin/rails db:test:prepare test test:system
  ```
  - **NEVER CANCEL**: Takes ~6+ minutes total
  - **Timeout**: Set to 15+ minutes minimum

### Linting and Security

Always run these before committing or the CI (.github/workflows/ci.yml) will fail:

- **RuboCop** (Code style):
  ```bash
  bin/rubocop
  ```
  - **Runtime**: ~2 seconds, 85 files checked
  - **Timeout**: Set to 2+ minutes minimum

- **Brakeman** (Security analysis):
  ```bash
  bin/brakeman --no-pager
  ```
  - **Runtime**: ~2 seconds
  - **Timeout**: Set to 2+ minutes minimum

- **Import Security Audit**:
  ```bash
  bin/importmap audit
  ```
  - **Runtime**: ~1 second
  - **Timeout**: Set to 1+ minute minimum

- **Run all linting**:
  ```bash
  bin/rubocop && bin/brakeman --no-pager && bin/importmap audit
  ```

## Validation Scenarios

After making changes, ALWAYS test these complete user workflows:

### Core Application Validation

1. **Database Connection Test**:
   ```bash
   export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
   bin/rails runner "puts 'Database connection: ' + (User.count >= 0 ? 'SUCCESS' : 'FAILED')"
   ```
   - Should output: "Database connection: SUCCESS"

2. **User/Book Creation Test**:
   ```bash
   export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
   bin/rails runner "User.create!(email_address: 'test@example.com', password: 'password123'); puts 'User creation: SUCCESS'"
   bin/rails runner "puts 'Total users: ' + User.count.to_s"
   ```

3. **Server Health Check Test**:
   ```bash
   # Start server in background:
   export DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/read_ritual_development"
   timeout 30 bin/rails server -p 3001 &
   sleep 10
   
   # Test health endpoint:
   curl -I http://127.0.0.1:3001/up
   # Should return: HTTP/1.1 200 OK
   
   # Stop server:
   pkill -f "rails server"
   ```

## Critical Environment Details

### Ruby Version Compatibility
- **Project requires**: Ruby 3.3.0
- **System has**: Ruby 3.2.3 (2024-01-18)
- **Status**: COMPATIBLE - Application works correctly with 3.2.3
- **Action**: No action needed, version mismatch warning can be ignored

### Database Configuration
- **PostgreSQL Version**: 16.9
- **Authentication**: Password required (not peer authentication)
- **Required Environment Variable**: `DATABASE_URL="postgres://$(whoami):postgres@127.0.0.1:5432/database_name"`
- **Development DB**: `read_ritual_development`
- **Test DB**: `read_ritual_test`

### Gem Installation Notes
- **Requires sudo**: System Ruby installation requires elevated privileges
- **Warning is normal**: "Don't run Bundler as root" can be ignored
- **Bundler version**: Automatically manages 2.5.3 vs 2.7.1 version conflicts

## Application Architecture

### Key Models
- **User**: Authentication, reading goals (default 100 books/year), statistics
- **Book**: Title, start/finish dates, series, belongs to user and authors
- **Author**: Name, associated with multiple books
- **Session**: User authentication sessions

### Key Controllers
- **SandboxController**: Homepage dashboard (root route)
- **BooksController**: CRUD operations for book tracking
- **AuthorsController**: Author management
- **SessionsController**: User authentication
- **ProfileController**: User profile and statistics

### Key Features
- Reading goal tracking (books per year)
- Book cover image fetching (via jobs)
- Reading statistics and progress calculation
- Book series detection
- Recently completed books display

### Routes
- Root: `/` → SandboxController#index (dashboard)
- Books: `/books` → full CRUD
- Profile: `/profile` → user statistics
- Health check: `/up` → Rails health status

## Troubleshooting

### Common Issues

1. **Gem Installation Permissions**:
   - **Problem**: "You don't have write permissions for the /var/lib/gems/3.2.0 directory"
   - **Solution**: Use `sudo bin/bundle install`

2. **PostgreSQL Connection Refused**:
   - **Problem**: "connection to server at localhost:5432 failed"
   - **Solution**: `sudo service postgresql start`

3. **Database Authentication Failed**:
   - **Problem**: "fe_sendauth: no password supplied"
   - **Solution**: Ensure DATABASE_URL includes password: `postgres://user:password@host:port/db`

4. **Rails Console YAML Error**:
   - **Problem**: "YAML syntax error occurred while parsing config/cache.yml"
   - **Workaround**: Use `bin/rails runner` instead of `bin/rails console`

5. **System Tests Chrome Missing**:
   - **Problem**: Chrome browser not found for Selenium
   - **Solution**: Install via `sudo apt-get install google-chrome-stable`

### Performance Notes
- System tests are intentionally slow due to browser automation
- Tailwind CSS compilation happens automatically during development
- Book cover fetching is asynchronous via background jobs
- Database queries include proper caching for user statistics

## CI/CD Pipeline

The application includes comprehensive GitHub Actions workflows:

- **Linting**: RuboCop style checking
- **Security**: Brakeman and Importmap audits
- **Testing**: Full test suite with PostgreSQL service
- **System Requirements**: Ubuntu, PostgreSQL 15+, Chrome browser

Always ensure local tests pass before pushing to avoid CI failures.