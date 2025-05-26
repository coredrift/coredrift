# frozen_string_literal: true

require 'uuidtools'
require 'bcrypt'

# ─── Helpers ────────────────────────────────────────────────────────────────
def password_digest(password)
  BCrypt::Password.create(password)
end

def random_password
  (0...8).map { [ *'a'..'z', *'A'..'Z', *'0'..'9' ].sample }.join
end

# ─── UUID Cache ─────────────────────────────────────────────────────────────
uuids = {}
SEED_UUIDS = uuids

# ─── Superadmin User ────────────────────────────────────────────────────────
superadmin_password = random_password
superadmin_id = UUIDTools::UUID.random_create.to_s
uuids['superadmin_user'] = superadmin_id

superadmin = User.find_or_create_by!(username: 'superadmin') do |u|
  u.id = superadmin_id
  u.name = 'Super Admin'
  u.email_address = 'superadmin@example.com'
  u.password_digest = password_digest(superadmin_password)
  u.role = 'superadmin'
end

# ─── Organization ───────────────────────────────────────────────────────────
organization_id = UUIDTools::UUID.random_create.to_s
uuids['organization'] = organization_id

org = Organization.find_or_create_by!(slug: 'default') do |o|
  o.id = organization_id
  o.name = 'Default Organization'
  o.short_description = 'Default single-instance organization'
  o.description = 'Seeded default organization for initial setup.'
  o.owner_id = superadmin.id
end

OrganizationOwner.find_or_create_by!(organization_id: org.id, user_id: superadmin.id)

# ─── Roles ──────────────────────────────────────────────────────────────────
global_roles = %w[superadmin admin owner director internal_support external_support finance audit user]
contextual_roles = %w[team_lead software_engineer designer product_owner qa_engineer devops_engineer scrum_master business_analyst]

roles = {}

global_roles.each do |name|
  id = UUIDTools::UUID.random_create.to_s
  roles[name.to_sym] = id
  Role.find_or_create_by!(name: name) do |r|
    r.id = id
    r.description = "Global role: #{name}"
    r.contextual = false
    r.status = 'enabled'
  end
end

contextual_roles.each do |name|
  id = UUIDTools::UUID.random_create.to_s
  roles[name.to_sym] = id
  Role.find_or_create_by!(name: name) do |r|
    r.id = id
    r.description = "Contextual role: #{name}"
    r.contextual = true
    r.status = 'enabled'
  end
end

# ─── Permissions ────────────────────────────────────────────────────────────
global_permissions = %w[
  admin_system manage_auth manage_team generate_org_report export_data view_audit_logs manage_billing grant_permissions
]

contextual_permissions = %w[
  send_daily_report view_team_reports define_daily_setup moderate_daily_comments
  create_project manage_board manage_tickets move_ticket assign_ticket generate_team_report view_team_membership
]

permission_map = {}

(global_permissions + contextual_permissions).each do |perm|
  id = UUIDTools::UUID.random_create.to_s
  permission_map[perm.to_sym] = id
  Permission.find_or_create_by!(name: perm.gsub('_', ' ').split.map(&:capitalize).join(' ')) do |p|
    p.id = id
    p.description = "Permission: #{perm}"
    p.created_at = Time.now
    p.updated_at = Time.now
  end
end

# ─── Assign Global Permissions to Superadmin ────────────────────────────────
global_permissions.each do |perm|
  RolePermission.find_or_create_by!(
    role_id: roles[:superadmin],
    permission_id: permission_map[perm.to_sym]
  )
end

UserRole.find_or_create_by!(user_id: superadmin.id, role_id: roles[:superadmin])

# ─── Test Teams & Users ─────────────────────────────────────────────────────
role_list = contextual_roles
num_teams = 3
natural_users = [
  { name: 'John Doe', username: 'john-doe' },
  { name: 'Jane Smith', username: 'jane-smith' },
  { name: 'Charlie Brown', username: 'charlie-brown' },
  { name: 'Alice Johnson', username: 'alice-johnson' },
  { name: 'Bob Martin', username: 'bob-martin' },
  { name: 'Emily Davis', username: 'emily-davis' }
]

num_teams.times do |i|
  team_n = i + 1
  team_id = UUIDTools::UUID.random_create.to_s
  team_slug = "test-team-#{team_n}"

  team = Team.find_or_create_by!(slug: team_slug) do |t|
    t.id = team_id
    t.organization_id = org.id
    t.name = "Test Team #{team_n}"
    t.description = "Seeded test team ##{team_n}"
  end

  # Archetypical users (one per role)
  role_list.each do |role|
    username = "#{role.gsub('_', '-')}-test-#{team_n}"
    user_id = UUIDTools::UUID.random_create.to_s
    name = username.split('-').map(&:capitalize).join(' ')

    user = User.find_or_create_by!(username: username) do |u|
      u.id = user_id
      u.name = name
      u.email_address = "#{username}@example.com"
      u.password_digest = password_digest(username)
      u.role = role
    end

    TeamMembership.find_or_create_by!(team_id: team.id, user_id: user.id) do |tm|
      tm.relation_type = 'direct'
    end

    UserRole.find_or_create_by!(
      user_id: user.id,
      role_id: roles[role.to_sym],
      context_type: 'Team',
      context_id: team.id
    )
  end

  # Natural-looking users (round robin)
  naturals = natural_users.rotate(i)
  naturals.each do |nu|
    uid = UUIDTools::UUID.random_create.to_s
    user = User.find_or_create_by!(username: nu[:username]) do |u|
      u.id = uid
      u.name = nu[:name]
      u.email_address = "#{nu[:username]}@example.com"
      u.password_digest = password_digest(nu[:username])
      u.role = 'user'
    end

    TeamMembership.find_or_create_by!(team_id: team.id, user_id: user.id) do |tm|
      tm.relation_type = 'direct'
    end
  end

  # Daily Setup
  DailySetup.find_or_create_by!(team_id: team.id) do |ds|
    ds.slug = "#{team_slug}-daily-setup"
    ds.name = "Daily Ritual for #{team.name}"
    ds.description = "Seeded daily setup for team #{team_n}"
    ds.visible_at = '09:30'
    ds.reminder_at = '08:00'
    ds.daily_report_time = '10:30'
    ds.weekly_report_day = 'fri'
    ds.weekly_report_time = '17:00'
    ds.template = 'freeform'
    ds.allow_comments = true
    ds.active = true
    ds.settings = {}
  end
end

# ─── Print Superadmin Credentials ───────────────────────────────────────────
line = "Superadmin login → username: superadmin | password: #{superadmin_password}"
puts "\n\n\e[32m#{line}\e[0m"

File.open('seed.out', 'w') { |f| f.puts line }
