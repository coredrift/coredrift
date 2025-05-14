require 'uuidtools'
require 'bcrypt'

# ─── UUIDS ─────────────────────────────────────────────────────────────────────
uuids = {}
%w[
  superadmin_user admin_user director_user support_user
  organization
  superadmin_role admin_role director_role support_role user_role
  team_lead_role software_engineer_role designer_role product_owner_role qa_engineer_role devops_engineer_role scrum_master_role business_analyst_role
].each do |key|
  uuids[key] = UUIDTools::UUID.random_create.to_s
end

SEED_UUIDS = uuids

# ─── Passwords ─────────────────────────────────────────────────────────────────
def password_digest(password)
  BCrypt::Password.create(password)
end

def random_password
  (0...8).map { [*'a'..'z', *'A'..'Z', *'0'..'9'].sample }.join
end

generated_passwords = {
  'superadmin_user' => random_password,
  'admin_user'      => random_password,
  'director_user'   => random_password
}

# ─── Global Users ──────────────────────────────────────────────────────────────
declare_user = ->(uuid, name, username, email, role_sym, password) do
  User.create!(
    id: uuid,
    name: name,
    username: username,
    email_address: email,
    password_digest: password_digest(password),
    role: role_sym.to_s
  )
end

declare_user.call(uuids['superadmin_user'], 'Super Admin', 'superadmin', 'superadmin@example.com', :superadmin, generated_passwords['superadmin_user'])
declare_user.call(uuids['admin_user'],      'Admin',       'admin',      'admin@example.com',      :admin,      generated_passwords['admin_user'])
declare_user.call(uuids['director_user'],   'Director',    'director',   'director@example.com',   :director,   generated_passwords['director_user'])
declare_user.call(uuids['support_user'],    'Tech Support','techsupport','support@example.com',    :support,    "password123")

# ─── Organization ──────────────────────────────────────────────────────────────
def organization
  uuids = SEED_UUIDS
  @org ||= Organization.find_or_create_by!(id: uuids['organization'], slug: 'default', name: 'Default Organization') do |org|
    org.short_description = 'Default single-instance organization'
    org.description       = 'Seeded default organization for initial setup.'
    org.owner_id          = uuids['superadmin_user']
  end
end

OrganizationOwner.find_or_create_by!(organization_id: organization.id, user_id: uuids['superadmin_user'])

# ─── Roles ─────────────────────────────────────────────────────────────────────
roles = {
  superadmin: uuids['superadmin_role'],
  admin:      uuids['admin_role'],
  director:   uuids['director_role'],
  support:    uuids['support_role'],
  user:       uuids['user_role'],
  team_lead:          uuids['team_lead_role'],
  software_engineer:  uuids['software_engineer_role'],
  designer:           uuids['designer_role'],
  product_owner:      uuids['product_owner_role'],
  qa_engineer:        uuids['qa_engineer_role'],
  devops_engineer:    uuids['devops_engineer_role'],
  scrum_master:       uuids['scrum_master_role'],
  business_analyst:   uuids['business_analyst_role']
}

roles.each do |name, id|
  Role.create!(
    id: id,
    name: name.to_s.capitalize.gsub('_', ' '),
    description: "Role: #{name.to_s.capitalize.gsub('_', ' ')}",
    status: 'enabled',
    created_at: Time.now,
    updated_at: Time.now
  )
end

# ─── Permissions ───────────────────────────────────────────────────────────────
permissions = [
  { name: 'Admin System',           description: 'Almost superadmin rights with system control' },
  { name: 'Manage Auth',            description: 'Manage user authentication and roles' },
  { name: 'Manage Team',            description: 'Create and update teams and memberships' },
  { name: 'Send Daily Report',      description: 'Submit your asynchronous daily standup report' },
  { name: 'Create Ticket',          description: 'Create new tickets in the system' },
  { name: 'Generate Team Report',   description: 'Generate report for a specific team' },
  { name: 'Generate Org Report',    description: 'Generate report for the entire organization' },
  { name: 'Export Data',            description: 'Export data to external formats' }
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

# ─── Permissions → Roles ───────────────────────────────────────────────────────
role_map = {
  superadmin:      permission_records.map(&:id),
  admin:           permission_records.select { |p| p.name == 'Admin System' }.map(&:id),
  director:        permission_records.select { |p| p.name == 'Manage Auth' }.map(&:id),
  team_lead:       permission_records.select { |p| p.name == 'Manage Team' }.map(&:id),
  scrum_master:    permission_records.select { |p| p.name == 'Send Daily Report' }.map(&:id),
  business_analyst: permission_records.select { |p| ['Generate Team Report', 'Generate Org Report', 'Export Data'].include?(p.name) }.map(&:id)
}

role_map.each do |role_sym, perm_ids|
  role_id = roles[role_sym]
  perm_ids.each do |pid|
    RolePermission.find_or_create_by!(
      id: UUIDTools::UUID.random_create.to_s,
      role_id: role_id,
      permission_id: pid
    )
  end
end

# ─── Assign Global Roles to Global Users ───────────────────────────────────────
UserRole.create!(user_id: uuids['superadmin_user'], role_id: roles[:superadmin])
UserRole.create!(user_id: uuids['admin_user'],      role_id: roles[:admin])
UserRole.create!(user_id: uuids['director_user'],   role_id: roles[:director])
UserRole.create!(user_id: uuids['support_user'],    role_id: roles[:support])

# ─── Equipos de desarrollo ─────────────────────────────────────────────────────
team_structure = {
  team_lead:          1,
  software_engineer:  2,
  designer:           1,
  product_owner:      1,
  qa_engineer:        1,
  devops_engineer:    1,
  scrum_master:       1,
  business_analyst:   1
}

3.times do |t|
  team_uuid = UUIDTools::UUID.random_create.to_s
  team = Team.create!(
    id:             team_uuid,
    organization_id: organization.id,
    slug:           "team-#{t+1}",
    name:           "Team #{t+1}",
    description:    "Cross-functional Team #{t+1}"
  )

  team_structure.each do |role_sym, count|
    count.times do |i|
      user_uuid = UUIDTools::UUID.random_create.to_s
      name = "Team#{t+1} #{role_sym.to_s.split('_').map(&:capitalize).join(' ')} #{i+1}"
      username = "team-#{t+1}-#{role_sym.to_s.gsub('_', '-')}-#{i+1}"
      email = "#{username}@example.com"

      User.create!(
        id:              user_uuid,
        name:            name,
        username:        username,
        email_address:   email,
        password_digest: password_digest("password123"),
        role:            role_sym.to_s
      )

      TeamMembership.create!(
        id:           UUIDTools::UUID.random_create.to_s,
        team_id:      team_uuid,
        user_id:      user_uuid,
        relation_type:'direct'
      )

      UserRole.create!(user_id: user_uuid, role_id: roles[role_sym])
    end
  end
end

# ─── Test Dataset (Test Team) ──────────────────────────────────────────────────
# This section is for development convenience only during early phases.
test_team_id = UUIDTools::UUID.random_create.to_s
Team.create!(
  id: test_team_id,
  organization_id: organization.id,
  slug: 'test-team',
  name: 'Test Team',
  description: 'Temporary test team for development purposes'
)

test_roles = %i[team_lead software_engineer designer product_owner qa_engineer devops_engineer scrum_master business_analyst]

test_roles.each do |role_sym|
  username = "test-#{role_sym.to_s.gsub('_', '-')}"
  user_id = UUIDTools::UUID.random_create.to_s

  User.create!(
    id: user_id,
    name: username.split('-').map(&:capitalize).join(' '),
    username: username,
    email_address: "#{username}@example.com",
    password_digest: password_digest(username),
    role: role_sym.to_s
  )

  TeamMembership.create!(
    id: UUIDTools::UUID.random_create.to_s,
    team_id: test_team_id,
    user_id: user_id,
    relation_type: 'direct'
  )

  UserRole.create!(
    user_id: user_id,
    role_id: roles[role_sym]
  )
end

# ─── Print passwords for privileged users ──────────────────────────────────────
puts "\nGenerated passwords for privileged users:"
generated_passwords.each do |user_key, pw|
  username = user_key.gsub('_user', '')
  puts "  #{username}: #{pw}"
end
