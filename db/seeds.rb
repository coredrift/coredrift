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
  (0...8).map { [ *'a'..'z', *'A'..'Z', *'0'..'9' ].sample }.join
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
declare_user.call(uuids['support_user'],    'Tech Support', 'techsupport', 'support@example.com',    :support,    "password123")

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
    contextual: false,
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
  business_analyst: permission_records.select { |p| [ 'Generate Team Report', 'Generate Org Report', 'Export Data' ].include?(p.name) }.map(&:id)
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
        relation_type: 'direct'
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

# ─── Add a daily setup to the first team ───────────────────────────────────────
first_team = Team.where(organization_id: organization.id).first
if first_team && !first_team.daily_setup
  DailySetup.create!(
    team: first_team,
    slug: "first-team-daily-setup",
    name: "The Daily Ritual of Looking Busy",
    description: "Hey, pretend to be productive and call it a win.",
    visible_at: "09:30",
    reminder_at: "08:00",
    daily_report_time: "10:30",
    weekly_report_day: "fri",
    weekly_report_time: "17:00",
    template: "freeform",
    allow_comments: true,
    active: true,
    settings: {}
  )
end

# ─── Add a daily setup to the test team ───────────────────────────────────────
test_team = Team.find_by(slug: 'test-team')
if test_team && !test_team.daily_setup
  DailySetup.create!(
    team: test_team,
    slug: "test-team-daily-setup",
    name: "The Daily Ritual of Looking Busy",
    description: "Hey, pretend to be productive and call it a win.",
    visible_at: "09:30",
    reminder_at: "08:00",
    daily_report_time: "10:30",
    weekly_report_day: "fri",
    weekly_report_time: "17:00",
    template: "freeform",
    allow_comments: true,
    active: true,
    settings: {}
  )
end

# ─── Team Lead A in Two Teams ────────────────────────────────────────────────
team_lead_a = User.find_or_create_by!(email_address: 'test-team-lead@example.com') do |u|
  u.name = 'Test Team Lead'
  u.username = 'test-team-lead'
  u.password_digest = password_digest('test-team-lead')
  u.role = 'team_lead'
end

# Create two teams
team1 = Team.find_or_create_by!(slug: 'team-lead-a-1') do |t|
  t.organization_id = organization.id
  t.name = 'Team Lead A Team 1'
  t.description = 'First team for Team Lead A'
end
team2 = Team.find_or_create_by!(slug: 'team-lead-a-2') do |t|
  t.organization_id = organization.id
  t.name = 'Team Lead A Team 2'
  t.description = 'Second team for Team Lead A'
end

# Add team lead as team_lead in team1
TeamMembership.find_or_create_by!(team_id: team1.id, user_id: team_lead_a.id) do |tm|
  tm.relation_type = 'direct'
end
UserRole.find_or_create_by!(user_id: team_lead_a.id, role_id: roles[:team_lead])

# Add team lead as member in team2
TeamMembership.find_or_create_by!(team_id: team2.id, user_id: team_lead_a.id) do |tm|
  tm.relation_type = 'direct'
end
UserRole.find_or_create_by!(user_id: team_lead_a.id, role_id: roles[:team_lead])

# Daily setups for both teams
daily_setup1 = DailySetup.find_or_create_by!(team_id: team1.id) do |ds|
  ds.slug = 'team-lead-a-1-daily-setup'
  ds.name = 'Daily for Team Lead A Team 1'
  ds.description = 'Daily setup for Team Lead A in Team 1.'
  ds.visible_at = '09:30'
  ds.reminder_at = '08:00'
  ds.daily_report_time = '10:30'
  ds.weekly_report_day = 'fri'
  ds.weekly_report_time = '17:00'
  ds.template = 'yesterday_today_blockers'
  ds.allow_comments = true
  ds.active = true
  ds.settings = {}
end
daily_setup2 = DailySetup.find_or_create_by!(team_id: team2.id) do |ds|
  ds.slug = 'team-lead-a-2-daily-setup'
  ds.name = 'Daily for Team Lead A Team 2'
  ds.description = 'Daily setup for Team Lead A in Team 2.'
  ds.visible_at = '09:30'
  ds.reminder_at = '08:00'
  ds.daily_report_time = '10:30'
  ds.weekly_report_day = 'fri'
  ds.weekly_report_time = '17:00'
  ds.template = 'yesterday_today_blockers'
  ds.allow_comments = true
  ds.active = true
  ds.settings = {}
end

# ─── Example: assign a contextual role to a user for a specific team
team = Team.first
user = User.first
role = Role.first
if team && user && role
  UserRole.create!(user_id: user.id, role_id: role.id, context_type: "Team", context_id: team.id)
end

# ─── Print passwords for privileged users ──────────────────────────────────────
puts "\nGenerated passwords for privileged users:"
File.open("password.txt", "w") do |f|
  f.puts "Generated passwords for privileged users:"
  generated_passwords.each do |user_key, pw|
    username = user_key.gsub('_user', '')
    line = "  #{username}: #{pw}"
    puts line
    f.puts line
  end
end
