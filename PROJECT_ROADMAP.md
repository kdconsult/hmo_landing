# PROJECT ROADMAP

## Admin Campaign Views Tailwind Refactor (2024-06, updated for 2025 trends)

### Goal

Refactor all admin campaign views to use the latest 2025 design trends: modern, beautiful, and highly functional UI with Tailwind CSS, including dark/light theme support, responsive layouts, and improved usability.

### Scope

- Files to refactor:
  - app/views/campaigns/\_campaign.html.erb
  - app/views/campaigns/\_form.html.erb
  - app/views/campaigns/index.html.erb
  - app/views/campaigns/show.html.erb
  - app/views/campaigns/new.html.erb
  - app/views/campaigns/edit.html.erb

### Requirements (2025 Design Trends)

- Use a modern, responsive table for campaign listing (index), with sticky headers, zebra striping, and right-aligned action icons.
- Use card layouts for show, edit, and new views, with grouped fields, subtle dividers, and floating labels for forms.
- Modern error display and action buttons at the bottom of cards.
- Use Tailwind CSS dark: variants for all backgrounds, text, borders, and focus states.
- Ensure full mobile responsiveness and accessibility.
- No search/filter bar for now.
- No marketing/animated elements; keep it minimal and admin-focused.
- Do not change any functionality or data.

### Next Steps

1. Refactor index.html.erb to use a modern, responsive table UI.
2. Refactor show.html.erb to use a card layout for details.
3. Refactor edit.html.erb and new.html.erb to use card layouts and modern forms.
4. Refactor \_form.html.erb for floating labels and grouped fields.
5. Refactor \_campaign.html.erb for card consistency if needed.
6. Review with user, iterate as needed.
7. Update documentation as changes are made.

## Waitlist Spots & Leads API Integration (2024-06)

### Goal

Implement a robust, efficient system for tracking and displaying "spots remaining" and "joined today" on the landing page waitlist, using real backend data and minimal API calls.

### Scope

- Add a GET /api/landing_pages/:slug/leads endpoint to return all leads for a given landing page (with only id and created_at fields).
- Update the Stimulus controller (waitlist_form_controller.js) to:
  - Fetch all leads for the landing page on connect.
  - Calculate spots remaining as MAX_SPOTS (constant in JS) minus the number of leads returned.
  - Calculate joined today by filtering leads by today's date.
  - Track spots and joined today locally after the initial fetch (no polling).
  - On form submit, POST to the API, and on success, update local state and UI accordingly.

### Requirements

- Backend must expose only the necessary data (id, created_at) for privacy and performance.
- Frontend must not poll or refetch after the initial load; all state changes after are local.
- Must be robust to race conditions (occasional overbooking is acceptable for this use case).
- All changes must be documented in this roadmap and explained to the user after implementation.

### Next Steps

1. Update routes.rb to add the GET endpoint.
2. Implement the index action in Api::LeadsController.
3. Update waitlist_form_controller.js to use the new API and local state logic.
4. Review with user, iterate as needed.
5. Update documentation as changes are made.
