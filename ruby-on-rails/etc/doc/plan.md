# Technical Implementation Plan & IntelliJ Docker Integration Guide

## 1. System Architecture & Component Design

The application follows the idiomatic Ruby on Rails MVC architecture with an added ActiveModel Serializers presentation layer.

```
                  ┌───────────────────────────────┐
                  │       Incoming HTTP Request   │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │      ActionDispatch Router    │
                  │       (config/routes.rb)      │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │       PeopleController        │
                  │ (app/controllers/people_...)  │
                  └───────┬───────────────┬───────┘
                          │               │
        [Data Fetch & Business Logic]   [Presentation / Output]
                          │               │
                          ▼               ▼
          ┌─────────────────────┐   ┌───────────────────────────┐
          │ ActiveRecord Models │   │  ActiveModelSerializers   │
          │(Person/Organization)│   │    (PersonSerializer)     │
          └──────────┬──────────┘   └─────────────┬─────────────┘
                     │                            │
                     ▼                            ▼
          ┌─────────────────────┐   ┌───────────────────────────┐
          │   SQLite Database   │   │     JSON HTTP Response    │
          └─────────────────────┘   └───────────────────────────┘
```

### Layer Responsibilities
1. **Routing (`config/routes.rb`):** Directs incoming HTTP requests to controller actions (`GET /people/:id` -> `PeopleController#show`, `POST /people/:id/check_access` -> `PeopleController#check_access`).
2. **Controller (`app/controllers/people_controller.rb`):** Orchestrates parameter extraction, delegates database queries, invokes authorization checks, and dispatches JSON serializers.
3. **Model Layer (`app/models/person.rb`, `app/models/organization.rb`):** Enforces validations, scopes, and array-level JSON serialization for `permission_codes`.
4. **Serialization Layer (`app/serializers/person_serializer.rb`):** Whitelists attributes for external representation, safeguarding private fields from unauthorized exposure.

---

## 2. Database & Migration Strategy

### 2.1. Migration Design

#### Initial Table Setup Migrations
- `db/migrate/20250924140936_create_people.rb` (creates base `people` table with timestamps)
- `db/migrate/20250924141004_create_organizations.rb` (creates base `organizations` table with timestamps)

#### `db/migrate/20260930100001_add_attributes_to_people.rb`
```ruby
class AddAttributesToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :first_name, :text, null: false
    add_column :people, :last_name, :text, null: false
    add_column :people, :phone_number, :text
    add_column :people, :active, :boolean, default: true, null: false
    add_column :people, :permission_codes, :json, default: []
  end
end
```

#### `db/migrate/20260930100002_add_attributes_to_organizations.rb`
```ruby
class AddAttributesToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :name, :text, null: false
    add_column :organizations, :code, :text, null: false
    add_column :organizations, :address, :text
    add_column :organizations, :phone_number, :text
    add_index :organizations, :code
  end
end
```

### 2.2. Migration Execution Workflow
Migrations are executed strictly inside the containerized environment:
```bash
# Run pending migrations
docker compose exec web bin/rails db:migrate

# Prepare test database schema
docker compose exec web bin/rails db:test:prepare
```

---

## 3. Core Component Implementation Details

### 3.1. Models

#### `app/models/person.rb`
```ruby
# frozen_string_literal: true

class Person < ApplicationRecord
  serialize :permission_codes, coder: JSON

  validates :first_name, presence: true
  validates :last_name, presence: true
end
```

#### `app/models/organization.rb`
```ruby
# frozen_string_literal: true

class Organization < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true
end
```

### 3.2. Serializer

#### `app/serializers/person_serializer.rb`
```ruby
# frozen_string_literal: true

class PersonSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :phone_number
end
```

### 3.3. Controller

#### `app/controllers/people_controller.rb`
```ruby
# frozen_string_literal: true

class PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    person = Person.find(params[:id])
    render json: person, serializer: PersonSerializer, status: :ok
  end

  def check_access
    person = Person.find(params[:id])
    org_id = params.dig(:organization, :id)
    org = Organization.find_by(id: org_id)

    has_access = person.active? && org.present? && Array(person.permission_codes).map(&:to_s).include?(org.code.to_s)
    render json: { access: has_access }, status: :ok
  end

  private

  def record_not_found
    render json: { error: "Person not found" }, status: :not_found
  end
end
```

---

## 4. IntelliJ IDEA & RubyMine Docker Integration Guide

IntelliJ IDEA Ultimate and RubyMine provide native toolchain integration with Docker Compose, enabling remote test execution, syntax resolution, and interactive debugging directly inside containers without polluting the host machine.

### Step 1: Docker Daemon Configuration
1. Open **Settings** (on Linux/Windows: `Ctrl + Alt + S`, on macOS: `Cmd + ,`).
2. Navigate to **Build, Execution, Deployment -> Docker**.
3. Click the **+** button to add a new Docker connection.
4. Select the connection type:
   - **Unix socket** (`unix:///var/run/docker.sock`) for Linux/macOS.
   - **Docker for Windows / Desktop** for Windows.
5. Verify the connection displays `Connection successful`.

### Step 2: Configure Remote Ruby SDK via Docker Compose
1. Navigate to **Languages & Frameworks -> Ruby SDK and Gems**.
2. Click **+** and select **New remote...**.
3. In the dialog, select **Docker Compose**.
4. Configure the settings:
   - **Server:** Select the Docker server configured in Step 1.
   - **Configuration file(s):** Select `docker-compose.yml`.
   - **Service:** Select `web`.
5. Click **Next / OK**. IntelliJ will connect to the container image, inspect the Ruby 3.3.1 runtime, and index all gems from `Gemfile.lock`.
6. Set this remote SDK as the project default SDK.

### Step 3: Configure RSpec Test Runner
1. Navigate to **Run -> Edit Configurations...**.
2. Click **+** and select **RSpec**.
3. Set the configuration options:
   - **Name:** `All RSpec Specs (Docker)`
   - **Test type:** `All in folder` -> select `spec/` folder.
   - **Ruby SDK:** Use the Remote Docker Compose Ruby SDK created in Step 2.
4. Click **Apply** and **OK**.
5. You can now execute or debug all specs or click the green gutter icon next to any `describe` or `it` block in `spec/requests/people_controller_request_spec.rb` to execute individual test cases inside Docker.

### Step 4: Interactive Debugging & Breakpoints
1. Ensure the `debug` gem is available in `development, test` group in `Gemfile`.
2. Set a breakpoint in `PeopleController` or `PersonSerializer` by clicking in the editor gutter (a red circle appears).
3. Right-click the RSpec run configuration or gutter icon and select **Debug '...'**.
4. IntelliJ boots the container, attaches the remote debugger, and pauses execution at your breakpoint, providing live variable inspection and step-through debugging.

### Step 5: Container Logs & Terminal in Services Tool Window
1. Open the **Services** tool window (`Alt + 8` or `View -> Tool Windows -> Services`).
2. Expand the **Docker** node to see the `ruby-on-rails` Compose application.
3. Click on the `web` container to view live server logs, inspect CPU/Memory utilization, and open an interactive container terminal shell.

---

## 5. Risk Assessment & Mitigations

| Risk / Failure Mode | Likelihood | Impact | Mitigation Strategy |
| :--- | :---: | :---: | :--- |
| **SQLite JSON Array Type Mismatch** | Medium | High | Use `serialize :permission_codes, coder: JSON` in `Person` model to guarantee consistent Ruby `Array` instances regardless of underlying SQLite column storage. |
| **Permission Code Type Inconsistency** (`"123"` vs `123`) | High | High | Explicitly convert both permission codes and organization codes via `.map(&:to_s).include?(org.code.to_s)` before equality evaluation. |
| **Nil Parameter Crashing in `check_access`** | Medium | Medium | Use `params.dig(:organization, :id)` to handle payloads safely even if the `organization` root key is missing. |
| **Sensitive Field Leakage** | Low | High | Enforce `ActiveModelSerializers` whitelist; avoid rendering raw model objects in responses. |
