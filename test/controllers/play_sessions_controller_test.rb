require "test_helper"

class PlaySessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Play Session Test User",
      email: "play-session-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Other Play Session User",
      email: "other-play-session@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "未ログイン時はプレイを開始できない" do
    gamebook = create_gamebook(user: @user)
    create_start_scene(gamebook: gamebook)

    assert_no_difference "PlaySession.count" do
      post gamebook_play_sessions_path(gamebook)
    end

    assert_redirected_to login_path
  end

  test "ログイン中は最初からプレイを開始できる" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    login_as(@user)

    assert_difference "PlaySession.count", 1 do
      post gamebook_play_sessions_path(gamebook)
    end

    play_session = PlaySession.last

    assert_equal @user, play_session.user
    assert_equal gamebook, play_session.gamebook
    assert_equal start_scene, play_session.current_scene
    assert_predicate play_session, :playing?
    assert_not_nil play_session.started_at
    assert_redirected_to play_session_path(play_session)
  end

  test "ログイン中は自分のプレイ画面を表示できる" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)
    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    item = gamebook.items.create!(
      key: "old_lantern",
      name: "古びたランタン",
      description: "暗い場所を照らせるランタン"
    )

    play_session.play_session_items.create!(
      item: item
    )

    login_as(@user)
    get play_session_path(play_session)

    assert_response :success
    assert_includes response.body, "物語の始まり"
    assert_includes response.body, "あなたは深い森の入口に立っている。"
    assert_includes response.body, "冒険の開始地点"
    assert_includes response.body, "森の奥へ進む"
    assert_includes response.body, "古びたランタン"
  end

  test "未ログイン時はプレイ画面を表示できない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    get play_session_path(play_session)

    assert_redirected_to login_path
  end

  test "他のユーザーのプレイ画面は表示できない" do
    gamebook = create_gamebook(user: @other_user)
    start_scene = create_start_scene(gamebook: gamebook)

    play_session = @other_user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)
    get play_session_path(play_session)

    assert_response :not_found
  end

  test "開始シーンがない場合はプレイを開始できない" do
    gamebook = create_gamebook(user: @user)

    login_as(@user)

    assert_no_difference "PlaySession.count" do
      post gamebook_play_sessions_path(gamebook)
    end

    assert_redirected_to gamebook_path(gamebook)
    assert_equal(
      "開始シーンが見つからないため、プレイを開始できません。",
      flash[:alert]
    )
  end

  test "選択肢を選ぶと履歴を保存して次のシーンへ進む" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_difference "PlayHistory.count", 1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload
    play_history = PlayHistory.last

    assert_equal next_scene, play_session.current_scene
    assert_equal play_session, play_history.play_session
    assert_equal start_scene, play_history.scene
    assert_equal choice, play_history.choice
    assert_not_nil play_history.visited_at
    assert_redirected_to play_session_path(play_session)
    assert_equal choice.result_text, flash[:notice]
  end

  test "他のユーザーのプレイは進められない" do
    gamebook = create_gamebook(user: @other_user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @other_user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    assert_response :not_found
    assert_equal start_scene, play_session.reload.current_scene
  end

  private

  def login_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end

  def create_gamebook(user:)
    user.gamebooks.create!(
      title: "プレイテスト用ゲームブック",
      summary: "プレイテスト用の概要",
      genre: "ファンタジー",
      world_setting: "魔法が存在する世界",
      tone: "シリアス",
      difficulty: "普通",
      play_time: 30,
      generation_status: :completed
    )
  end

  def create_start_scene(gamebook:)
    gamebook.scenes.create!(
      scene_key: "start",
      title: "物語の始まり",
      body: "あなたは深い森の入口に立っている。",
      situation: "冒険の開始地点",
      scene_type: :introduction,
      is_start: true,
      position: 1
    )
  end
end
