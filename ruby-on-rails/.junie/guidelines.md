# Development Guidelines & Engineering Standards

To maximize overall productivity, code maintainability, and delivery reliability, all contributions to this project must adhere to the engineering standards and testing workflows defined below.

---

## 1. Test-Driven Development (TDD) Workflow

Every feature, bug fix, or endpoint enhancement must follow a strict **Red-Green-Refactor** cycle to prevent regressions and minimize debugging waste.

```
       ┌──────────────┐
       │  1. RED      │ ──> Write a failing test matching the specification
       └──────┬───────┘
              │
              ▼
       ┌──────────────┐
       │  2. GREEN    │ ──> Write the minimal application code to pass the test
       └──────┬───────┘
              │
              ▼
       ┌──────────────┐
       │  3. REFACTOR │ ──> Improve design, readability, and performance
       └──────────────┘
```

### Execution Steps
1. **Red**: Define request or model specifications in RSpec before writing business logic. Run the targeted test to ensure it fails for the expected reason:
   ```bash
   docker compose run --rm web bundle exec rspec spec/requests/people_controller_request_spec.rb
   ```
2. **Green**: Implement the simplest viable code in controllers, models, or serializers to make the spec turn green. Avoid premature abstraction.
3. **Refactor**: Clean up the implementation (e.g., extract private helpers, ensure serialization separation, apply guard clauses) while verifying all tests remain green.

---

## 2. Code Style & Ruby Conventions

Standardized code reduces cognitive load across the engineering lifecycle.

- **Frozen String Literals**: Always place `# frozen_string_literal: true` as the first line of every Ruby file (`.rb`) to optimize memory allocation.
- **Guard Clauses & Early Returns**: Prefer guard clauses over deeply nested conditionals to improve readability and code flow.
- **Explicit Serialization**: Do not render raw ActiveRecord models or call `to_json` in controllers. Always route serialization through `ActiveModelSerializers` (e.g., `PersonSerializer`).
- **Strong Parameters**: Use Strong Parameters (`params.require(...)` / `params.permit(...)` or `params.dig(...)`) to prevent mass-assignment vulnerabilities.
- **Type Normalization**: When comparing permission arrays or identifier values, normalize types (e.g., converting IDs and codes to strings) to prevent false negatives caused by integer/string mismatches.
- **HTTP Status Semantics**: Return proper HTTP response status codes:
  - `200 OK` for successful queries or successful evaluation outcomes (`{ "access": false }` is a valid 200 evaluation response).
  - `404 Not Found` when a referenced parent resource (like `Person`) does not exist.
  - `422 Unprocessable Entity` for unparseable input structures.

---

## 3. Git Commit Standards

Each discrete unit of work must produce an atomic commit to maintain a transparent, bisectable history.

- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
  - `feat(<scope>): <description>` — New feature or endpoint.
  - `test(<scope>): <description>` — Adding or updating test suites.
  - `fix(<scope>): <description>` — Bug fix or error resolution.
  - `docs(<scope>): <description>` — Documentation or planning updates.
  - `refactor(<scope>): <description>` — Code change that neither fixes a bug nor adds a feature.
- Example: `feat(api): implement check_access endpoint with permission code verification`

---

## 4. Docker Compose Command Reference

All commands must be executed within container boundaries to ensure environment parity and eliminate local environment discrepancies.

| Task | Command |
| :--- | :--- |
| **Start Application** | `docker compose up` |
| **Start Application in Background** | `docker compose up -d` |
| **Stop Application** | `docker compose down` |
| **Execute Migration** | `docker compose exec web bin/rails db:migrate` |
| **Rollback Migration** | `docker compose exec web bin/rails db:rollback` |
| **Run RSpec Test Suite** | `docker compose run --rm web bundle exec rspec` |
| **Run Specific Test File** | `docker compose run --rm web bundle exec rspec spec/requests/people_controller_request_spec.rb` |
| **Seed Database** | `docker compose exec web bin/rails db:seed` |
| **Open Rails Console** | `docker compose exec web bin/rails console` |
| **Rebuild Container Image** | `docker compose build` |
