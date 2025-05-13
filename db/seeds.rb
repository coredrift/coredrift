require 'uuidtools'
require 'bcrypt'

# Generate UUIDs
superadmin_uuid = UUIDTools::UUID.random_create.to_s
admin_uuid = UUIDTools::UUID.random_create.to_s
johndoe_uuid = UUIDTools::UUID.random_create.to_s
juliasmith_uuid = UUIDTools::UUID.random_create.to_s
organization_uuid = UUIDTools::UUID.random_create.to_s

superadmin_role_uuid = UUIDTools::UUID.random_create.to_s
admin_role_uuid = UUIDTools::UUID.random_create.to_s
user_role_uuid = UUIDTools::UUID.random_create.to_s

resource_id_1 = UUIDTools::UUID.random_create.to_s
resource_id_2 = UUIDTools::UUID.random_create.to_s
permission_id_2 = UUIDTools::UUID.random_create.to_s
resource_permission_id = UUIDTools::UUID.random_create.to_s
user_permission_id = UUIDTools::UUID.random_create.to_s

# Generate password hash
password = BCrypt::Password.create("password123")

# Create users
User.create!(
  id: superadmin_uuid,
  name: 'Super Admin',
  username: 'superadmin',
  email_address: 'superadmin@example.com',
  password_digest: password,
  role: 'superadmin'
)

User.create!(
  id: admin_uuid,
  name: 'Admin',
  username: 'admin',
  email_address: 'admin@example.com',
  password_digest: password,
  role: 'admin'
)

User.create!(
  id: johndoe_uuid,
  name: 'John Doe',
  username: 'johndoe',
  email_address: 'johndoe@example.com',
  password_digest: password,
  role: 'member'
)

User.create!(
  id: juliasmith_uuid,
  name: 'Julia Smith',
  username: 'juliasmith',
  email_address: 'juliasmith@example.com',
  password_digest: password,
  role: 'member'
)

# Create organization
organization = Organization.find_or_create_by!(id: organization_uuid, slug: 'default', name: 'Default Organization') do |org|
  org.short_description = 'This is the default organization.'
  org.description = 'This organization is created by default during seeding.'
  org.owner_id = superadmin_uuid
end

OrganizationOwner.find_or_create_by!(organization_id: organization_uuid, user_id: superadmin_uuid)

# Create sessions
[
  { user_id: superadmin_uuid, ip_address: "::1", user_agent: "Mozilla/5.0", created_at: Time.now, updated_at: Time.now },
  { user_id: superadmin_uuid, ip_address: "::1", user_agent: "Mozilla/5.0", created_at: Time.now, updated_at: Time.now }
].each do |session_data|
  Session.create!(session_data.merge(id: UUIDTools::UUID.random_create.to_s))
end

# Create roles
Role.create!(id: superadmin_role_uuid, name: "Superadmin", description: "Has full access", status: "enabled", created_at: Time.now, updated_at: Time.now)
Role.create!(id: admin_role_uuid, name: "Admin", description: "Administrative user", status: "enabled", created_at: Time.now, updated_at: Time.now)
Role.create!(id: user_role_uuid, name: "User", description: "Regular user", status: "enabled", created_at: Time.now, updated_at: Time.now)

# Create meaningful permissions
permissions = [
  { name: "Manage-Users", description: "Create, update, and delete any user." },
  { name: "Configure-System", description: "Change global settings and application preferences." },
  { name: "View-All-Data", description: "Access all teams, projects, and reports." },
  { name: "Assign-Roles", description: "Set or modify roles for any user." },
  { name: "Access-Audit-Logs", description: "View detailed logs of all user activities." },
  { name: "Manage-Teams", description: "Create teams and manage membership." },
  { name: "Assign-Tasks", description: "Assign tasks to users within their teams." },
  { name: "Edit-Projects", description: "Update project details, phases, and structure." },
  { name: "View-Team-Reports", description: "Access performance and status reports for their teams." },
  { name: "Comment-Tasks", description: "Participate in task discussions." },
  { name: "View-Assigned-Tasks", description: "Access tasks assigned to them." },
  { name: "Update-Task-Status", description: "Change the status of their tasks." },
  { name: "View-Team-Info", description: "See basic info about their team and members." },
  { name: "Export-Data", description: "Allow exporting reports or datasets to external formats." },
  { name: "Impersonate-User", description: "Temporarily access the system as another user for support or debugging." },
  { name: "Bypass-Restrictions", description: "Override validation or workflow restrictions for exceptional cases." }
]

permission_records = permissions.map do |perm|
  Permission.create!(
    id: UUIDTools::UUID.random_create.to_s,
    name: perm[:name],
    description: perm[:description],
    created_at: Time.now,
    updated_at: Time.now
  )
end

# Define permission sets by role
admin_permissions = %w[
  Manage-Users Configure-System View-All-Data Assign-Roles Access-Audit-Logs
  Manage-Teams Assign-Tasks Edit-Projects View-Team-Reports Comment-Tasks
  Export-Data Impersonate-User Bypass-Restrictions
]

manager_permissions = %w[
  Manage-Teams Assign-Tasks Edit-Projects View-Team-Reports Comment-Tasks
]

user_permissions = %w[
  View-Assigned-Tasks Update-Task-Status Comment-Tasks View-Team-Info
]

# Helper to find permission ID
def find_permission_id_by_name(records, name)
  records.find { |p| p.name == name }&.id
end

# Create RolePermission records
(admin_permissions + manager_permissions + user_permissions).uniq.each do |perm_name|
  permission_id = find_permission_id_by_name(permission_records, perm_name)
  role_ids = []
  role_ids << superadmin_role_uuid if admin_permissions.include?(perm_name)
  role_ids << admin_role_uuid if admin_permissions.include?(perm_name) || manager_permissions.include?(perm_name)
  role_ids << user_role_uuid if user_permissions.include?(perm_name)

  role_ids.uniq.each do |role_id|
    RolePermission.find_or_create_by!(
      id: UUIDTools::UUID.random_create.to_s,
      role_id: role_id,
      permission_id: permission_id
    )
  end
end

# Assign roles to users
UserRole.create!(user_id: superadmin_uuid, role_id: superadmin_role_uuid)
UserRole.create!(user_id: admin_uuid, role_id: admin_role_uuid)
UserRole.create!(user_id: johndoe_uuid, role_id: user_role_uuid)
UserRole.create!(user_id: juliasmith_uuid, role_id: user_role_uuid)

# Generic resource
Resource.create!(id: resource_id_1, name: "Resource", description: "New", kind: "controller-name#action-name", value: "controller-name#action-name", created_at: Time.now, updated_at: Time.now)

# Resource for test controller action
resource = Resource.create!(
  id: resource_id_2,
  name: "Test Fake Action",
  description: "Resource for testing fake_action",
  kind: "controller_action",
  value: "test#fake_action",
  created_at: Time.now,
  updated_at: Time.now
)

# Permission for resource
permission = Permission.create!(
  id: permission_id_2,
  name: "Access Fake Action",
  description: "Permission to access test#fake_action",
  created_at: Time.now,
  updated_at: Time.now
)

# Link permission to resource
ResourcePermission.create!(
  id: resource_permission_id,
  resource_id: resource.id,
  permission_id: permission.id,
  created_at: Time.now,
  updated_at: Time.now
)

# Assign permission directly to admin user (example of user-specific permission)
UserPermission.create!(
  id: user_permission_id,
  user_id: admin_uuid,
  permission_id: permission.id,
  created_at: Time.now,
  updated_at: Time.now
)

# Create teams
team_1_uuid = UUIDTools::UUID.random_create.to_s
team_2_uuid = UUIDTools::UUID.random_create.to_s
team_3_uuid = UUIDTools::UUID.random_create.to_s

Team.create!(id: team_1_uuid, organization_id: organization_uuid, slug: 'team-1', name: 'Team 1', description: 'First team in the organization.')
Team.create!(id: team_2_uuid, organization_id: organization_uuid, slug: 'team-2', name: 'Team 2', description: 'Second team in the organization.')
Team.create!(id: team_3_uuid, organization_id: organization_uuid, slug: 'team-3', name: 'Team 3', description: 'Third team in the organization.')

# Create additional users and assign them to teams
(1..15).each do |i|
  user_uuid = UUIDTools::UUID.random_create.to_s
  team_id = case i
            when 1..5 then team_1_uuid
            when 6..10 then team_2_uuid
            else team_3_uuid
            end

  user = User.create!(
    id: user_uuid,
    name: "User #{i}",
    username: "user#{i}",
    email_address: "user#{i}@example.com",
    password_digest: password,
    role: 'member'
  )

  TeamMembership.create!(
    id: UUIDTools::UUID.random_create.to_s,
    team_id: team_id,
    user_id: user.id,
    relation_type: 'direct'
  )
end
