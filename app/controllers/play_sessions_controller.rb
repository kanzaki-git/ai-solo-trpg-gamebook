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

    unless choice.available_for?(@play_session)
      redirect_to play_session_path(@play_session),
                  alert: "この選択肢は現在選べません。"
      return
    end

    ActiveRecord::Base.transaction do
      @play_session.play_histories.create!(
        scene: current_scene,
        choice: choice,
        visited_at: Time.current
      )

      choice.choice_flag_rules.add.find_each do |rule|
        @play_session.play_session_flags.find_or_create_by!(
          flag: rule.flag
        )
      end

      choice.choice_flag_rules.remove.find_each do |rule|
        @play_session.play_session_flags.find_by(
          flag: rule.flag
        )&.destroy!
      end

      choice.choice_item_rules.add.find_each do |rule|
        @play_session.play_session_items.find_or_create_by!(
          item: rule.item
        )
      end

      choice.choice_item_rules.remove.find_each do |rule|
        @play_session.play_session_items.find_by(
          item: rule.item
        )&.destroy!
      end

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
    @choices = @current_scene.choices.order(:position).select { |choice| choice.available_for?(@play_session) }
    @items = @play_session.items
  end
end
