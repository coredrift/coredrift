# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!({id: "a8596275-09d4-4608-9b52-0b6b86446c8e", email_address: "admin@localhost.com", password_digest: "$2a$12$341piM5eq/V0rBK2Ge274et0RLyqZs9sVhm4tn6qkYgQmbFvUZHkG", username: "admin", slug: nil, last_login_at: nil, last_login_ip: nil, is_active: 1, session_stamp: 0, created_by: nil, updated_by: nil, created_at: "2025-05-11 20:44:37", updated_at: "2025-05-12 11:32:20.228559"})
User.create!({id: "fb8f8eef-09b8-47d7-89cb-ea7930d4e489", email_address: "pepe@gmail.com", password_digest: "$2a$12$yfOyv9MY4zqz.YZCztVE.O1wTEyP8NAXxto77iQlc6gyuezZ8kZri", username: "pepe", slug: nil, last_login_at: nil, last_login_ip: nil, is_active: 1, session_stamp: 0, created_by: nil, updated_by: nil, created_at: "2025-05-11 21:12:39.512102", updated_at: "2025-05-11 21:12:39.512102"})
Session.create!({id: 7, user_id: "a8596275-09d4-4608-9b52-0b6b86446c8e", ip_address: "::1", user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36", created_at: "2025-05-12 12:16:36.564162", updated_at: "2025-05-12 12:16:36.564162"})
Session.create!({id: 11, user_id: "a8596275-09d4-4608-9b52-0b6b86446c8e", ip_address: "::1", user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36", created_at: "2025-05-12 12:26:12.556266", updated_at: "2025-05-12 12:26:12.556266"})
Role.create!({id: "1d4632e2-e209-4a13-a775-2db0c05aded4", slug: nil, name: "Role", description: "Description", status: "enabled", created_by: nil, updated_by: nil, created_at: "2025-05-12 08:41:49.863488", updated_at: "2025-05-12 08:41:49.863488"})
Permission.create!({id: "3acc1264-c553-4c40-bf85-23a00f283a3b", slug: nil, name: "FromRole", description: "From Role Description", created_by: nil, updated_by: nil, created_at: "2025-05-12 09:12:58.186654", updated_at: "2025-05-12 12:13:38.503107"})
Permission.create!({id: "577b2607-a049-4411-9fa4-a53eb0103c8e", slug: nil, name: "Direct", description: "Direct Permission", created_by: nil, updated_by: nil, created_at: "2025-05-12 12:13:52.124169", updated_at: "2025-05-12 12:13:52.124169"})
Permission.create!({id: "97143a9f-afde-4e5d-aafb-40494ac57862", slug: nil, name: "Second From Role", description: "Second", created_by: nil, updated_by: nil, created_at: "2025-05-12 12:25:42.260662", updated_at: "2025-05-12 12:25:42.260662"})
Resource.create!({id: "39c7c3b6-3c22-44b6-b66c-42eb94edb13e", slug: nil, name: "Resource", description: "New", label: nil, kind: "controller-name#action-name", value: "controller-name#action-name", created_by: nil, updated_by: nil, created_at: "2025-05-12 09:21:46.718608", updated_at: "2025-05-12 09:22:02.445098"})
UserRole.create!({id: "7cda9016-84e0-4abd-b764-d5d3de826780", user_id: "a8596275-09d4-4608-9b52-0b6b86446c8e", role_id: "1d4632e2-e209-4a13-a775-2db0c05aded4", created_at: "2025-05-12 13:47:10.773058", updated_at: "2025-05-12 13:47:10.773058"})
RolePermission.create!({id: "66f68e08-dc39-4702-a82b-7e2bc48436eb", role_id: "1d4632e2-e209-4a13-a775-2db0c05aded4", permission_id: "3acc1264-c553-4c40-bf85-23a00f283a3b", created_at: "2025-05-12 12:10:07.522046", updated_at: "2025-05-12 12:10:07.522046"})
RolePermission.create!({id: "a74b0a54-e9d8-4427-9ba5-b72ea1cd76e9", role_id: "1d4632e2-e209-4a13-a775-2db0c05aded4", permission_id: "97143a9f-afde-4e5d-aafb-40494ac57862", created_at: "2025-05-12 12:25:51.526641", updated_at: "2025-05-12 12:25:51.526641"})

# Create a resource for the test controller action
resource = Resource.create!(
  id: "d3f8c3b6-3c22-44b6-b66c-42eb94edb13e",
  name: "Test Fake Action",
  description: "Resource for testing fake_action",
  kind: "controller_action",
  value: "test#fake_action",
  created_at: Time.now,
  updated_at: Time.now
)

# Create a permission for the resource
permission = Permission.create!(
  id: "e4f8c3b6-3c22-44b6-b66c-42eb94edb13e",
  name: "Access Fake Action",
  description: "Permission to access test#fake_action",
  created_at: Time.now,
  updated_at: Time.now
)

# Associate the permission with the resource
ResourcePermission.create!(
  id: "f5f8c3b6-3c22-44b6-b66c-42eb94edb13e",
  resource: resource,
  permission: permission,
  created_at: Time.now,
  updated_at: Time.now
)

# Optionally assign the permission to the admin user
admin_user = User.find_by(username: "admin")
UserPermission.create!(
  id: "g6f8c3b6-3c22-44b6-b66c-42eb94edb13e",
  user: admin_user,
  permission: permission,
  created_at: Time.now,
  updated_at: Time.now
)

# Create an alternative permission for testing roles
Permission.create!(
  id: "f7e8c3b6-3c22-44b6-b66c-42eb94edb13e",
  name: "Alt Access Fake Action",
  description: "Alternative permission to access test#fake_action for testing roles",
  created_at: Time.now,
  updated_at: Time.now
)