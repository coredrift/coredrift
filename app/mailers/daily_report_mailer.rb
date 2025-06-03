class DailyReportMailer < ApplicationMailer
  def daily_summary(user, team, daily_setup, dailies, missing_users)
    @user = user
    @team = team
    @daily_setup = daily_setup
    @dailies = dailies
    @missing_users = missing_users
    @date = Date.current

    mail(
      to: user.email_address,
      subject: "Daily Summary for #{team.name} - #{@date.strftime('%A, %B %d')}"
    )
  end
end
