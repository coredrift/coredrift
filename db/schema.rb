# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_14_142620) do
# Could not dump table "daily_setups" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "organization_owners" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "organizations" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "permissions" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "resource_permissions" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "resources" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "role_permissions" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "roles" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "sessions" because of following StandardError
#   Unknown type 'uuid' for column 'user_id'


# Could not dump table "team_memberships" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "teams" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "user_permissions" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "user_roles" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "users" because of following StandardError
#   Unknown type 'uuid' for column 'id'


  add_foreign_key "daily_setups", "teams"
  add_foreign_key "organization_owners", "organizations"
  add_foreign_key "organization_owners", "users"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "resource_permissions", "permissions"
  add_foreign_key "resource_permissions", "resources"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "sessions", "users"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "teams", "organizations"
  add_foreign_key "user_permissions", "permissions"
  add_foreign_key "user_permissions", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
