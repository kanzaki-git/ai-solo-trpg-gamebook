class PlaySessionsController < ApplicationController
  before_action :require_login

  def create
    gamebook = Gamebook.find(params[:gamebook_id])
    start_scene = gamebook.scenes.find_by(is_start: true)

    unless start_scene
      redirect_to gamebook_path(gamebook),
                  alert: "開始シーンが見つからないため、プレイを開始できません。"
      return
    end

    play_session = current_user.play_sessions.build(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    if play_session.save
      redirect_to play_session_path(play_session)
    else
      redirect_to gamebook_path(gamebook),
                  alert: "プレイを開始できませんでした。"
    end
  end

  def advance
    @play_session = current_user.play_sessions.find(params[:id])
    current_scene = @play_session.current_scene
    choice = current_scene.choices.find(params[:choice_id])

    PlaySession.transaction do
      @play_session.play_histories.create!(
        scene: current_scene,
        choice: choice,
        visited_at: Time.current
      )

      @play_session.update!(
        current_scene: choice.next_scene
      )
    end

    redirect_to play_session_path(@play_session),
                notice: choice.result_text
  end

  def show
    @play_session = current_user.play_sessions.find(params[:id])
    @current_scene = @play_session.current_scene
    @choices = @current_scene.choices.order(:position)
    @items = @play_session.items
  end
end
