namespace :resources do
  desc "Synchronize resources with controller actions"
  task sync: :environment do
    controller_actions = Rails.application.routes.routes.filter_map do |route|
      reqs = route.defaults
      c = reqs[:controller]
      a = reqs[:action]
      next if c&.start_with?("rails/", "action_mailbox/", "active_storage/", "rails/mailers", "rails/info", "rails/welcome")
      "#{c}##{a}" if c && a
    end.uniq

    puts "Detected controller actions:"
    controller_actions.each { |action| puts action }

    controller_actions.each do |action|
      Resource.find_or_create_by!(kind: "controller_action", value: action) do |resource|
        resource.name = action
        resource.description = "Auto-generated resource for #{action}"
      end
    end

    puts "Resource synchronization complete."
  end
end