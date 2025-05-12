class TestController < ApplicationController
  def fake_action
    render plain: "You have access to this action!"
  end
end