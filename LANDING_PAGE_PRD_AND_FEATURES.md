# Landing Page PRD & Features (Merged)

## Overview & Goals

This document merges the Product Requirements Document (PRD) and the Features/Design documentation for the campaign landing pages and lead collection system. The goal is to provide a single source of truth for both business requirements and technical/design implementation, with clear status for each feature.

### Product Purpose

- Enable marketing teams to create, manage, and clone landing pages per campaign, each with customizable lead capture forms.
- Maximize user engagement and lead collection through urgency, FOMO, and modern design.
- Ensure compliance, security, and analytics for all collected data.

### Core Goals

- Modern, conversion-focused landing page with responsive, accessible design (Tailwind CSS).
- Dynamic, campaign-specific lead forms (always collect name, email, phone, marketing consent).
- Secure storage, analytics, and export of all lead data.
- RESTful API for lead submission, with idempotency, reCAPTCHA, and rate limiting.
- Admin UI for campaign/landing page/lead management.

---

## Landing Page Structure & Features

### Sections (Status: Implemented)

- **Navigation Header:** Fixed, glassy, responsive, with logo and navigation links.
- **Hero Section:** Large, bold headlines, gradient text, urgency badge, FOMO messaging.
- **Features Section:** Three-column grid, icon-based, hover animations.
- **Social Proof Section:** User avatars, ratings, testimonials, statistics.
- **About Section:** Company story, differentiators, mission.
- **Pricing Section:** Three-tier pricing, urgency messaging, feature comparison.
- **Contact/Waitlist Form:** Comprehensive form (name, email, phone, company, role, use case, newsletter opt-in), real-time validation, success/error handling.
- **Final CTA Section:** Strong call-to-action, trust indicators.
- **Footer:** Organized links, brand consistency.

### Interactive Elements (Status: Implemented)

- Smooth scrolling, countdown timer, mobile menu, scroll-to-top, floating elements.
- Waitlist form controller: handles validation, submission, feedback.

### Customization (Status: Implemented)

- Colors, content, images, and form fields are easily customizable via CSS variables and ERB templates.

---

## Technical & API Requirements

### Backend/API (Status: Partially Done)

- **RESTful API** for lead submission (`POST /api/landing_pages/:slug/leads`), with reCAPTCHA v3, idempotency, and rate limiting. [API & idempotency: DONE]
- **GET /api/landing_pages/:slug/leads** returns all leads for a landing page (id, created_at only) for waitlist stats. [DONE]
- **Dynamic form config** per landing page, stored in JSONB, drives frontend rendering and backend validation. [Planned]
- **Data model:**
  - Campaign, LandingPage, Lead (with encrypted email/phone, blind indexes, JSONB for custom fields, attribution metadata).
- **Security:**
  - Application-layer encryption for PII, blind indexes for lookup, no PII in logs, explicit consent capture, rate limiting, idempotency.
  - GDPR support: data export/deletion per user request.
- **Uniqueness:**
  - (To-Do) Enforce uniqueness of email/phone per campaign, unless campaign allows duplicates.

### Frontend (Status: Implemented)

- **Waitlist form:** Real-time validation, error handling, loading states, success messages, API integration.
- **Responsive design:** Mobile-first, accessible, with proper focus indicators and semantic HTML.
- **Customization:** Easy to update colors, content, and form fields.

---

## Customization & Extensibility

- **Form fields:** Add/remove fields as needed; update validation rules and labels.
- **Content:** Update text, company info, countdown duration, social proof stats.
- **Images:** Replace placeholders with brand assets.
- **Future enhancements:** A/B testing, analytics, CRM/email integration, dark mode, referral system, community features.

---

## Performance & Accessibility

- Minimal JS footprint, CSS animations, lazy loading for images.
- Accessibility: heading hierarchy, focus indicators, alt text, semantic HTML, accessible forms.

---

## Future Enhancements (Planned)

- A/B testing, analytics integration, CRM/email integration, dark mode, referral system, community features, image optimization, code splitting, CDN, caching.

---

## To-Do / Current Gaps

### 1. Idempotency

- **Status:** API supports idempotency via `Idempotency-Key` header and backend store. [DONE]
- **Next:** Review and document edge cases; ensure all endpoints that need idempotency have it.

### 2. Email/Phone Uniqueness Validation

- **Status:** Not yet enforced. [TO-DO]
- **Next:**
  - Add uniqueness validation for email/phone per campaign in the Lead model.
  - Add campaign-level override to allow duplicates if needed.
  - Update backend and frontend to handle duplicate errors gracefully.

---

## Open Questions

- Should landing pages support A/B testing or versioning?
- What integrations (CRM, email, etc.) are required for leads?
- Should there be a library of reusable field types/questions?

---

## Status Legend

- **Implemented:** Feature is live and in use.
- **Partially Done:** Some parts are implemented, others are planned.
- **Planned:** Feature is outlined but not yet started.
- **To-Do:** Feature is required and should be prioritized next.
- **Done:** Feature is complete and verified.
