# Incremental Implementation Tasks & TDD Execution Plan

This task matrix outlines the step-by-step implementation sequence. Each task represents an atomic unit of delivery designed for progressive verification via RSpec and individual Git commits.

---

## Task Matrix & Progression Breakdown

### Task 1: Database Migrations for `people` and `organizations`
- **Objective:** Define strict column types, nullability constraints, and indices for `people` and `organizations` tables.
- **Files Affected:**
  - `db/migrate/20250924140936_create_people.rb`
  - `db/migrate/20250924141004_create_organizations.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose exec web bin/rails db:migrate
  docker compose exec web bin/rails db:test:prepare
  ```
- **Proposed Git Commit:**
  `feat(db): create people and organizations tables with indexed codes`

---

### Task 2: ActiveRecord Models & JSON Serialization
- **Objective:** Configure `Person` and `Organization` models with presence validations and JSON array serialization for `permission_codes`.
- **Files Affected:**
  - `app/models/person.rb`
  - `app/models/organization.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose exec web bin/rails runner "p = Person.new(first_name: 'Test', last_name: 'User', permission_codes: ['A1']); p.save!; puts p.permission_codes.is_a?(Array)"
  ```
- **Proposed Git Commit:**
  `feat(models): add validations and JSON serialization for permission codes`

---

### Task 3: JSON Serialization Layer (`PersonSerializer`)
- **Objective:** Create `PersonSerializer` inheriting from `ActiveModel::Serializer` to whitelist `first_name`, `last_name`, and `phone_number` while keeping metadata private.
- **Files Affected:**
  - `app/serializers/person_serializer.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose exec web bin/rails runner "p = Person.create!(first_name: 'A', last_name: 'B', phone_number: '123', active: true); puts PersonSerializer.new(p).as_json"
  ```
- **Proposed Git Commit:**
  `feat(serializers): create PersonSerializer to sanitize response attributes`

---

### Task 4: `GET /people/:id` Controller Endpoint
- **Objective:** Implement `PeopleController#show` to return serialized profile data on success (200) and `{ "error": "Person not found" }` on missing records (404).
- **Files Affected:**
  - `app/controllers/people_controller.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose run --rm web bundle exec rspec spec/requests/people_controller_request_spec.rb -e "GET /people/{:id}"
  ```
- **Proposed Git Commit:**
  `feat(api): implement GET /people/:id with 200 and 404 response handling`

---

### Task 5: `POST /people/:id/check_access` Access Verification Endpoint
- **Objective:** Implement `PeopleController#check_access` evaluating `person.active`, organization existence, and `permission_codes` intersection.
- **Files Affected:**
  - `app/controllers/people_controller.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose run --rm web bundle exec rspec spec/requests/people_controller_request_spec.rb -e "POST /people/{:id}/check_access"
  ```
- **Proposed Git Commit:**
  `feat(api): implement POST /people/:id/check_access authorization logic`

---

### Task 6: Comprehensive RSpec Request Test Suite
- **Objective:** Flesh out all test scenarios in `spec/requests/people_controller_request_spec.rb` to cover all matrix cases (active/inactive, code matching, missing org, missing person).
- **Files Affected:**
  - `spec/requests/people_controller_request_spec.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose run --rm web bundle exec rspec spec/requests/people_controller_request_spec.rb
  ```
- **Proposed Git Commit:**
  `test(api): add comprehensive request specs for show and check_access endpoints`

---

### Task 7: Database Seed Data & End-to-End Sanity Verification
- **Objective:** Populate `db/seeds.rb` with sample people and organizations (matching access codes) for manual testing and local exploration.
- **Files Affected:**
  - `db/seeds.rb`
- **TDD / Verification Command:**
  ```bash
  docker compose exec web bin/rails db:seed
  docker compose run --rm web bundle exec rspec
  ```
- **Proposed Git Commit:**
  `chore(seeds): add demo seed records for people and organizations`

---

## Verification Runbook

Follow this terminal runbook to execute and validate all tasks from start to finish:

```bash
# 1. Apply database migrations
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails db:test:prepare

# 2. Execute full automated test suite
docker compose run --rm web bundle exec rspec

# 3. Seed demo data
docker compose exec web bin/rails db:seed
```
