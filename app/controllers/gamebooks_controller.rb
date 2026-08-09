class GamebooksController < ApplicationController
  before_action :require_login

  def index
    @gamebooks = current_user.gamebooks.order(created_at: :desc)
  end

  def show
    @gamebook = current_user.gamebooks.find(params[:id])
    @playing_session = current_user.play_sessions
                                   .playing
                                   .where(gamebook: @gamebook)
                                   .order(updated_at: :desc)
                                   .first
  rescue ActiveRecord::RecordNotFound
    redirect_to gamebooks_path, alert: "ゲームブックが見つかりませんでした"
  end
end
