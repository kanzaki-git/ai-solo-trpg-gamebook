class GamebooksController < ApplicationController
  before_action :require_login

  def index
    @gamebooks = current_user.gamebooks.order(created_at: :desc)
  end
end
