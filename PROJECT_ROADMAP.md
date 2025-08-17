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
