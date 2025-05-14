![License: PolyForm Noncommercial](https://img.shields.io/badge/license-PolyForm--Noncommercial-blue)

# CoreDrift

CoreDrift is the foundation of a work-in-progress project. For now, it includes an authentication and authorization system based on the following:

- **Users**: Represent individuals who interact with the system.
- **Roles**: Define a set of permissions that can be assigned to users.
- **Permissions**: Specify the actions that can be performed within the system.
- **Resources**: Represent the entities or areas that permissions apply to.
- **Organization**: Serve as the umbrella entity that owns all other entities, such as teams, users, and and all entities are scoped under it.
- **Teams**: Represent user groupings within an organization, allowing logical organization of users for collaboration and management.

Users acquire permissions through their assigned roles and directly, enabling them to access specific resources. Eventually, this logic may be generalized for use in other projects.

## Screenshot

A sample screenshot of the app:

![List User Permissions](docs/img/gallery/list-user-permissions.png)

[See more screenshots in the gallery...](docs/gallery.md)

## Seeding for Initial Exploration

The seeding process is designed for the initial exploration phase of the application. It creates predefined users, roles, and permissions to help developers and testers understand the system's functionality.

In addition to other users, the following have been created to facilitate manual testing during this phase of development. These users are particularly useful for testing features and verifying permissions.

Below is the list of predefined users and their credentials:

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

```
rake db:full_reset
```