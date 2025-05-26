class DailyReminderMailer < ApplicationMailer
  def reminder_email(user, daily_setup)
    @user = user
    @daily_setup = daily_setup
    @team = daily_setup.team
    @url = Rails.application.routes.url_helpers.new_daily_url(
      daily_setup_id: daily_setup.id,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
    mail(
      to: @user.email_address,
      subject: "Reminder: Daily for team #{@team.name}"
    )
  end
end
