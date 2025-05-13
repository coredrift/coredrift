class ApplicationMailer < ActionMailer::Base
  default from: "from@localhost.com"
  layout "mailer"
end
