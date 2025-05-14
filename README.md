![License: PolyForm Noncommercial](https://img.shields.io/badge/license-PolyForm--Noncommercial-blue)

# CoreDrift

CoreDrift is an async daily stand-up facilitator for distributed teams. It lets everyone share updates on their own schedule, keeps history organized, and includes a simple permissions layer for access control.

## Screenshot

A sample screenshot of the app:

![List User Permissions](docs/img/gallery/list-user-permissions.png)

[See more screenshots in the gallery...](docs/gallery.md)

## Seeding for Initial Exploration

The seeding process is designed for the initial exploration phase of the application. It creates predefined users, roles, and permissions to help developers and testers understand the system's functionality.

In addition to other users, the following have been created to facilitate manual testing during this phase of development. These users are particularly useful for testing features and verifying permissions.

| Role              | Email                              | Password              |
|-------------------|------------------------------------|-----------------------|
| Team Lead         | test-team-lead@example.com         | test-team-lead        |
| Software Engineer | test-software-engineer@example.com | test-software-engineer|
| Designer          | test-designer@example.com          | test-designer         |
| Product Owner     | test-product-owner@example.com     | test-product-owner    |
| QA Engineer       | test-qa-engineer@example.com       | test-qa-engineer      |
| DevOps Engineer   | test-devops-engineer@example.com   | test-devops-engineer  |
| Scrum Master      | test-scrum-master@example.com      | test-scrum-master     |
| Business Analyst  | test-business-analyst@example.com  | test-business-analyst |

These credentials are useful for testing and manual verification purposes during development.

## Notes

- [ ] Ensure the `superadmin` user password is changed after the first login to avoid vulnerabilities. (*) This will be enforced in future updates.
- [ ] Run `rails db:seed` to initialize the database with required data. (This step may not be necessary in the future, or seeding values will be adjusted appropriately for production.)

To reset the database and reseed it for testing purposes, you can use the following rake task:

```bash
rake db:full_reset
