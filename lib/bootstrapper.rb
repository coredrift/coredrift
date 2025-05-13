if defined?(Rails::Railtie)
  class Bootstrapper < Rails::Railtie
    config.after_initialize do
      ActiveSupport.on_load(:after_initialize) do
        Rails.application.reload_routes!

        restricted_prefixes = [
          "rails/", "active_storage/", "sessions/", 
          "action_mailer/", "action_cable/", "action_controller/", "action_view/", "action_dispatch/"
        ]

        actions = Rails.application.routes.routes.filter_map do |route|
          c = route.defaults[:controller]
          a = route.defaults[:action]
          next if c&.match?(%r{^(rails/(mailers|info|welcome)|action_mailbox/|active_storage/|sessions/|action_mailer/|action_cable/|action_controller/|action_view/|action_dispatch/)})
          action_name = "#{c}##{a}" if c && a
          next if restricted_prefixes.any? { |prefix| c&.start_with?(prefix) }
          action_name
        end.uniq

        puts "[INFO] Controller actions:"
        actions.each { |a| puts " - #{a}" }

        actions.each do |action|
          Resource.find_or_create_by!(kind: "controller_action", value: action) do |resource|
            resource.name = action
            resource.description = "Auto-generated resource for #{action}"
          end
        end

        puts "[INFO] Resource synchronization complete."
      end
    end
  end
end