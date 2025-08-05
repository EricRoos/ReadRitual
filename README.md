# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

## Test Coverage

This project uses [SimpleCov](https://github.com/simplecov-ruby/simplecov) for test coverage reporting.

### Running Tests with Coverage

To run tests and generate coverage reports:

```bash
# Run all tests with coverage
rails test:coverage

# Or run tests normally (SimpleCov is automatically enabled in test environment)
rails test
```

### Viewing Coverage Reports

After running tests, coverage reports are generated in the `/coverage` directory:

- Open `coverage/index.html` in a browser to view the detailed HTML report
- The report shows line-by-line coverage for all application code
- Coverage is grouped by functionality (Controllers, Models, Helpers, etc.)

### Coverage Configuration

- **Minimum Coverage**: 60% (configured in `test/test_helper.rb`)
- **Coverage Type**: Line and branch coverage
- **Excluded Directories**: `/vendor/`, `/config/`, `/db/`, `/script/`, `/bin/`

The coverage threshold can be adjusted in `test/test_helper.rb` as test coverage improves.

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
