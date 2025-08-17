# Product Requirements Document (PRD)

## Product:

**Flexible Campaign Landing Pages & Lead Collection System**

---

### 1. **Overview**

This system enables marketing teams to create, manage, and clone landing pages per campaign (no shared reuse in MVP), each with customizable lead capture forms. The platform supports B2B use cases, ensuring core lead data is always collected while allowing for campaign-specific fields. All data is securely stored and associated with the relevant campaign and landing page for analytics and compliance.

---

### 2. **Goals**

- Allow creation and management of multiple marketing campaigns.
- Enable each campaign to have one or more landing pages, which are cloned per campaign (no shared reuse in MVP).
- Support dynamic, campaign-specific lead forms with both required and optional fields.
- Always collect core lead data: name, email, and phone number.
- Store all lead data securely, with campaign and landing page associations.
- Provide analytics, export, and filtering capabilities for all leads.
- Ensure compliance with privacy and security best practices (e.g., GDPR).

---

### 3. **Core Features**

#### 3.1. **Campaign Management**

- Create, edit, archive, and delete campaigns.
- Assign one or more landing pages to each campaign.
- Set campaign goals and metadata.

#### 3.2. **Landing Page Management**

- Create new landing pages or clone existing ones within a campaign.
- Define the form config for each landing page via an admin UI (lightweight config: fields, types, required/optional, constraints).
- Support draft vs. published states and preview before publishing.
 - Content editing (MVP): copy-only. Editable fields: headline, subheadline, body, primary CTA label and URL. Fixed template with no theme customization (colors, fonts, layout) in MVP. Slug derived from campaign; per-page meta editor deferred.

#### 3.3. **Dynamic Lead Forms**

- Render forms dynamically on the frontend based on the landing page’s lightweight field config.
- Always include required fields: name, email, phone.
 - Always include required fields: name, email, phone, and a marketing consent checkbox.
- Support additional fields (e.g., company, job title, custom questions) as defined per campaign.
- Validate required fields and constraints on both frontend and backend using the same config as source of truth.

Lightweight field config (MVP) per landing page:

```json
{
  "schema_version": 1,
  "fields": [
    { "key": "company", "label": "Company", "type": "string", "required": false, "maxLength": 100 },
    { "key": "role", "label": "Role", "type": "enum", "options": ["founder","manager","other"], "required": false },
    { "key": "employees", "label": "Company Size", "type": "number", "required": false, "min": 1, "max": 100000 },
    { "key": "launch_date", "label": "Target Launch Date", "type": "date", "required": false },
    { "key": "website", "label": "Company Website", "type": "url", "required": false },
    { "key": "newsletter", "label": "Subscribe to updates", "type": "checkbox", "required": false },
    { "key": "deployment", "label": "Preferred Deployment", "type": "radio", "options": ["cloud","on-prem"], "required": false }
  ]
}
```

#### 3.4. **Lead Data Storage**

- Store leads with fixed columns for name, email, phone.
- Store additional fields in a flexible JSONB column.
- Associate each lead with its campaign and landing page.
- Timestamp all submissions.
- Capture attribution and context metadata on submission: `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`, `gclid`, `fbclid`, `msclkid`, `referrer_url`, `landing_url`, `user_agent`, `ip_address`, and referral tracking (`referral_code`, `referred_by`).

#### 3.5. **API & Integration**

- Provide a RESTful API endpoint for lead submission.
- Accept all form data, validate required fields, and store securely.
- Return success/failure responses for frontend handling.
- Require Google reCAPTCHA v3 token on submission; verify server-side with threshold ≥ 0.5.
- Auto-capture UTM and click IDs from query parameters and headers.
- Derive `referrer_url`, `landing_url`, `user_agent`, and `ip_address` from the request.
- Accept optional `ref` parameter for referral attribution; generate and return a `referral_code` for the created lead.
 - Accept optional `ref` parameter for referral attribution; generate and return a `referral_code` for the created lead. Referrals are limited to the same campaign only (codes must belong to an existing lead within the same campaign).

#### 3.6. **Admin & Analytics**

- List, filter, and export leads by campaign, landing page, and custom fields.
- View submission analytics (counts, conversion rates, field breakdowns).
- Export data as CSV.
- Form Builder UI (MVP): add/remove/reorder fields; edit key, label, type (string, textarea, email, tel, number, enum/select, checkbox, radio, date, url), required, constraints (min/max/length), options for enums/radios; draft vs. published; live preview using the same renderer.
  - Filtering specifics: by campaign, landing page, date ranges, UTM params, and presence/value of custom fields.
  - CSV export must stream results and handle at least 50k rows within 10s in typical conditions.
  - CSV export available to admins only; marketers cannot export CSV.
  - Admin CSV exports include PII (email and phone) by default.
  - Role-based access control (RBAC): admin vs. marketer roles; marketers restricted to their campaigns.
  - Track lightweight events (page views, submissions) to compute conversion rates and diagnose drops. Skip error events in MVP.

#### 3.7. **Security & Compliance**

- Encrypt sensitive data (email, phone) using application‑layer encryption (e.g., Lockbox) with blind indexes for lookup (e.g., BlindIndex). Normalize before hashing: email lowercased; phone in E.164. Keys are stored in Rails credentials per‑env; plan rotation post‑MVP.
- Never log PII in server logs.
- Support GDPR: allow data export and deletion per user request.
 - Consent capture: require a marketing consent checkbox on all forms. Persist `marketing_consent` (boolean), `consented_at` (datetime), `consent_source` (string/URL), and `privacy_policy_version` (string) at submission time.
  - Implement spam protection:
   - CAPTCHA: Google reCAPTCHA v3; server-side verification; threshold 0.5 (log score; reject < 0.5).
    - Rate limiting (Rack::Attack):
      - Per-IP: 10 requests/min (burst allowed), 200/hour.
      - Per-landing-page: 60 requests/min aggregate.
      - Temporary IP ban after ≥5 failed CAPTCHA validations within 5 minutes.
      - Implementation notes: Middleware is enabled app-wide; throttles respond with JSON 429 via a centralized responder. Failed reCAPTCHA validations increment a per-IP counter in cache for 5 minutes and trigger a temporary block when ≥5.
   - Bot deterrents: hidden honeypot field (must be empty) and minimum submit time of 1.5s from form render.
   - Email verification: excluded from MVP; consider post‑MVP double opt‑in.
- Treat IP address and user agent as personal data; restrict retention and access as needed. Avoid storing full referrer if it contains sensitive tokens.
 - Data retention: leads/events kept 24 months by default (configurable). IP and user agent retained for a maximum of 90 days, then purged or truncated.
 - Write-time deduplication: do not dedupe by email/phone; allow multiple leads with the same contact. Use `Idempotency-Key` only to prevent immediate replays; analytics dedupe can be performed offline.

#### 3.8. **API Contract (MVP)**

- Endpoint: `POST /api/landing_pages/:slug/leads`
- Authentication: public; protected via reCAPTCHA and rate limiting.
- Idempotency: accept `Idempotency-Key` header. Duplicate keys within 24h return the original response.
  - Implementation notes: Dedicated `ApiIdempotencyKey` store persists `(key, endpoint, request_hash)` with the original JSON body and HTTP status. Entries expire after 24 hours and are checked before processing new submissions.
- Request (example):

```json
{
  "core": { "name": "Alice", "email": "a@example.com", "phone": "+15551234", "marketing_consent": true },
  "custom": { "company": "Acme", "role": "founder" },
  "utm": { "utm_source": "ads", "utm_campaign": "q3" },
  "ref": "abc123",
  "recaptcha_token": "<token>"
}
```

- Responses:
  - 201 Created: `{ "id": "<uuid>", "status": "accepted", "referral_code": "<code>" }`
  - 422 Unprocessable Entity: `{ "errors": { "email": ["is invalid"] } }`
  - 429 Too Many Requests (rate limited)
  - 400/403 for invalid reCAPTCHA or malformed payload

#### 3.9. **SEO & Routing**

- Canonical URLs, OpenGraph/Twitter meta tags, sitemap, robots.txt.
- Unpublished (draft) pages must be `noindex` and unlinked.
- Preserve and propagate UTM parameters across internal navigations.
- Guard reserved slugs (e.g., `admin`, `api`, `assets`) to avoid collisions; return 404 or redirect appropriately.
 - Meta content (MVP): auto-generated from campaign/page copy; no per-page meta editor in MVP; OG image uses a default template.

---

### 4. **Non-Functional Requirements**

- **Performance:** Lead submission latency p50 < 300ms, p95 < 800ms (app-only, excluding network). CSV export for 50k rows completes < 10s.
- **Scalability:** Support hundreds of campaigns and 100k+ leads overall; query and export without timeouts.
- **Reliability & Durability:** 99.9% durability for stored leads; zero data loss on successful 201 responses.
- **Backup/Restore:** RPO 1 hour, RTO 24 hours (daily backups with point‑in‑time within 1h where supported).
- **Operability:** Structured logs without PII, basic dashboards for submission rates and errors, alert on sustained 5xx > 1% for 5m.
- **Usability:** Admin UI for campaign/landing page management must be intuitive.
- **Accessibility:** All forms and admin pages must be accessible (WCAG 2.1 AA).
 - **Localization:** Single locale in MVP; no multi-locale or RTL support.

---

### 5. **Data Model (Simplified)**

#### **Campaign**

- id, name, metadata, status, etc.

#### **LandingPage**

- id, campaign_id (required), schema (JSONB), schema_version (integer), template, status (draft/published), published_at (datetime)

#### **Lead**

- id, campaign_id, landing_page_id, name, email (encrypted), phone (encrypted), data (JSONB),
- utm_source, utm_medium, utm_campaign, utm_term, utm_content,
- gclid, fbclid, msclkid,
- referrer_url, landing_url, user_agent, ip_address,
- referral_code (unique within campaign), referred_by_lead_id (nullable),
- idempotency_key,
- schema_version_at_submit (integer),
- created_at

Encryption & lookup (PII): Provide blind index columns for encrypted fields to enable lookups without plaintext (e.g., `email_bidx`, `phone_bidx`). Normalize inputs for indexing (email lowercased; phone E.164). Do not enforce uniqueness constraints on blind indexes in MVP.

#### **Event**

- id, type (view|submit), campaign_id, landing_page_id, lead_id (nullable), metadata (JSONB), created_at

---

### 6. **User Stories**

- As a marketer, I can create a new campaign and assign a landing page to it.
- As a marketer, I can define which fields are required/optional for each campaign’s lead form.
- As a visitor, I can submit my information on a landing page, always providing name, email, and phone.
- As an admin, I can view, filter, and export all leads for any campaign or landing page.
- As a user, I can request my data to be deleted or exported (GDPR).

---

### 7. **Open Questions**

- Should landing pages support A/B testing or versioning?
- Should there be a library of reusable field types/questions?
- What integrations (CRM, email, etc.) are required for leads?

---

### 7a. **MVP Decisions**

- Landing pages are cloned per campaign. Shared reusable landing pages are out of scope for MVP and can be reconsidered post‑MVP.

---

### 7b. **MVP Scope**

- Single campaign → single landing page in MVP (additional pages per campaign deferred to Phase 2).
- Dynamic form config (lightweight, versioned) drives frontend rendering and backend validation.
- Backend lead capture with idempotency, reCAPTCHA v3 verification, and basic rate limiting.
- Admin: lead list with filters; CSV export (streamed); minimal RBAC.
- Basic analytics: submission counts and conversion rate per campaign/landing page.
- No A/B testing, templates marketplace, or external integrations in MVP.

---

### 7c. **Security, Privacy, and Abuse Mitigations (Actionable)**

- Application-layer encryption for email and phone with searchable blind indexes; keys managed via secure secrets (e.g., Rails credentials/KMS).
- Explicit consent capture (checkbox + timestamp + source); optional double opt‑in for email.
- Data subject requests (export/delete) supported with audit logs.
- No PII in logs; mask emails/phones; redact tokens from URLs.
- Rate limiting (e.g., IP + user fingerprint) for lead submission.
- Idempotency via `Idempotency-Key` header to avoid duplicate leads.

---

### 7d. **Risks & Tradeoffs**

- Clone-per-campaign is simpler but duplicates content; true reuse would require many-to-many relationships and versioning.
- Encryption with blind indexes complicates search and export; plan indices and export flows accordingly.

---

### 8. **Next Steps**

- Confirm this PRD and clarify any open questions.
- Begin technical design: database migrations, API endpoints, admin UI wireframes.
- Implement core models and endpoints.
- Build dynamic form rendering and validation on the frontend.
- Define rate limiting and idempotency strategy; set up reCAPTCHA verification. [DONE]
 - Plan observability (metrics, logs, alerts) and SEO defaults.
