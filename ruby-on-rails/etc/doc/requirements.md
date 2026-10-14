# Requirements Specification: Person & Organization API

## 1. Overview & Business Objectives
This service provides an authenticated JSON API gateway for querying person profiles and evaluating organizational access permissions based on role-based permission codes. The objective is to deliver high reliability, clean architectural separation, and deterministic access evaluation.

---

## 2. User Stories

### US-1: Person Profile Lookup
- **As an** API client application,
- **I want to** fetch a person's profile by their unique identifier,
- **So that** I can display their `first_name`, `last_name`, and `phone_number` without exposing internal permission codes or audit timestamps.

### US-2: Access Control Verification
- **As a** security gateway or authorization service,
- **I want to** query whether a person possesses active authorization to access a specified organization,
- **So that** security policies are enforced strictly and deterministically.

---

## 3. Data Dictionary

### Table: `people`
Stores individual user records along with access permission codes.

| Field Name | Type | Constraints / Nullability | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | Integer / BigInt | Primary Key, Auto-increment | — | Unique internal identifier. |
| `first_name` | String | `null: false` | — | First name of the person. |
| `last_name` | String | `null: false` | — | Last name of the person. |
| `phone_number` | String | `null: true` | `nil` | Contact phone number. |
| `active` | Boolean | `null: false` | `true` | Indicates whether the account is currently active. |
| `permission_codes` | JSON / Text | `null: false` (or defaults to `[]`) | `[]` | Array of organization code strings the person can access. |
| `created_at` | DateTime | `null: false` | Current Timestamp | Record creation timestamp. |
| `updated_at` | DateTime | `null: false` | Current Timestamp | Record last update timestamp. |

### Table: `organizations`
Stores organization entities with designated alphanumeric lookup codes.

| Field Name | Type | Constraints / Nullability | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | Integer / BigInt | Primary Key, Auto-increment | — | Unique internal identifier. |
| `name` | String | `null: false` | — | Legal or operational name of the organization. |
| `code` | String | `null: false`, Indexed | — | Alphanumeric business code matched against permissions. |
| `address` | Text / String | `null: true` | `nil` | Physical/mailing address. |
| `phone_number` | String | `null: true` | `nil` | Organization contact phone number. |
| `created_at` | DateTime | `null: false` | Current Timestamp | Record creation timestamp. |
| `updated_at` | DateTime | `null: false` | Current Timestamp | Record last update timestamp. |

---

## 4. API Endpoint Specifications

### 4.1. Show Person Profile
Retrieves sanitized personal profile attributes.

- **Path:** `/people/:id`
- **Method:** `GET`
- **Headers:** `Accept: application/json`

#### Response: Success (200 OK)
When a record matching `:id` exists in the database.
```json
{
  "first_name": "Jane",
  "last_name": "Doe",
  "phone_number": "555-0199"
}
```
*Note: Fields such as `id`, `active`, `permission_codes`, `created_at`, and `updated_at` MUST be excluded from the response payload.*

#### Response: Not Found (404 Not Found)
When no person record matches `:id`.
```json
{
  "error": "Person not found"
}
```

---

### 4.2. Check Organization Access
Evaluates whether a person has valid, active authorization to access an organization.

- **Path:** `/people/:id/check_access`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`, `Accept: application/json`

#### Request Payload Schema
```json
{
  "organization": {
    "id": 101
  }
}
```

#### Response: Success Evaluation (200 OK)
Returns evaluation boolean.

**Access Granted (`access: true`):**
```json
{
  "access": true
}
```

**Access Denied (`access: false`):**
```json
{
  "access": false
}
```

#### Response: Not Found (404 Not Found)
When no person record matches the `:id` parameter in the URL route:
```json
{
  "error": "Person not found"
}
```

---

## 5. Access Control Truth Matrix

The authorization outcome `access` is evaluated according to the following boolean rule:
$$\text{access} = \text{person.active} \land (\text{org} \neq \text{nil}) \land (\text{org.code} \in \text{person.permission\_codes})$$

| Case | Person Exists | `person.active` | Target Org Exists | `org.code` in `permission_codes` | HTTP Status | Response Payload |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | No | — | — | — | `404 Not Found` | `{"error": "Person not found"}` |
| **2** | Yes | `false` | Yes | Yes | `200 OK` | `{"access": false}` |
| **3** | Yes | `false` | Yes | No | `200 OK` | `{"access": false}` |
| **4** | Yes | `true` | No (ID invalid) | — | `200 OK` | `{"access": false}` |
| **5** | Yes | `true` | Yes | No (Code mismatch) | `200 OK` | `{"access": false}` |
| **6** | Yes | `true` | Yes | Yes (Code matches) | `200 OK` | `{"access": true}` |
| **7** | Yes | `true` | Payload Missing Org | — | `200 OK` | `{"access": false}` |

---

## 6. Non-Functional Requirements

1. **Deterministic Serialization:** Serialization must use `ActiveModelSerializers` to decouple representation logic from data persistence.
2. **Index Optimization:** The `code` column on the `organizations` table must be indexed to support sub-millisecond lookup latency.
3. **Robust Type Handling:** Permission codes must support mixed-type representations (e.g. comparing string `"100"` to integer `100`) via explicit string normalization before inclusion checks.
4. **Resilience & Fault Tolerance:** Invalid or missing request parameters in `POST /people/:id/check_access` must degrade gracefully to `{ "access": false }` without throwing unhandled `NoMethodError` or 500 server crashes.
