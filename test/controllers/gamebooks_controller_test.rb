require "test_helper"

class GamebooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Gamebook Test User",
      email: "gamebook-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Other User",
      email: "other-user@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "ログイン中はゲームブック一覧画面を表示できる" do
    login_as(@user)

    get gamebooks_path

    assert_response :success
  end

  test "ログイン中は自分のゲームブック詳細画面を表示できる" do
    gamebook = create_gamebook(
      user: @user,
      title: "詳細画面用ゲームブック"
    )

    login_as(@user)
    get gamebook_path(gamebook)

    assert_response :success
    assert_includes response.body, "詳細画面用ゲームブック"
    assert_includes response.body, "テスト用ゲームブックの概要"
  end

  test "ログインユーザーのゲームブックだけが表示される" do
    create_gamebook(
      user: @user,
      title: "自分のゲームブック"
    )

    create_gamebook(
      user: @other_user,
      title: "他のユーザーのゲームブック"
    )

    login_as(@user)
    get gamebooks_path

    assert_includes response.body, "自分のゲームブック"
    assert_not_includes response.body, "他のユーザーのゲームブック"
  end

  test "他のユーザーのゲームブック詳細画面は表示できない" do
    other_gamebook = create_gamebook(
      user: @other_user,
      title: "他のユーザーのゲームブック"
    )

    login_as(@user)
    get gamebook_path(other_gamebook)

    assert_redirected_to gamebooks_path
    assert_equal "ゲームブックが見つかりませんでした", flash[:alert]
  end

  test "ゲームブックが新しい順に表示される" do
    create_gamebook(
      user: @user,
      title: "古いゲームブック",
      created_at: 2.days.ago
    )

    create_gamebook(
      user: @user,
      title: "新しいゲームブック",
      created_at: 1.day.ago
    )

    login_as(@user)
    get gamebooks_path

    new_position = response.body.index("新しいゲームブック")
    old_position = response.body.index("古いゲームブック")

    assert_operator new_position, :<, old_position
  end

  test "ゲームブックがない場合は案内が表示される" do
    login_as(@user)

    get gamebooks_path

    assert_includes response.body, "まだゲームブックがありません"
  end

  test "生成状態が日本語で表示される" do
    create_gamebook(
      user: @user,
      title: "完成したゲームブック",
      generation_status: :completed
    )

    login_as(@user)
    get gamebooks_path

    assert_includes response.body, "生成完了"
  end

  test "未ログイン時はログイン画面へリダイレクトされる" do
    get gamebooks_path

    assert_redirected_to login_path
  end

  test "未ログイン時はゲームブック詳細画面を表示できない" do
    gamebook = create_gamebook(
      user: @user,
      title: "未ログイン確認用ゲームブック"
    )

    get gamebook_path(gamebook)

    assert_redirected_to login_path
  end

  test "プレイ途中のデータがある場合は続きから遊ぶリンクを表示する" do
    gamebook = create_gamebook(
      user: @user,
      title: "再開用ゲームブック"
    )

    current_scene = gamebook.scenes.create!(
      scene_key: "resume_scene",
      title: "再開するシーン",
      body: "前回の続きから物語が始まる。",
      situation: "冒険の途中",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: current_scene,
      status: :playing,
      started_at: 1.hour.ago
    )

    login_as(@user)
    get gamebook_path(gamebook)

    assert_response :success
    assert_select(
      "a[href='#{play_session_path(play_session)}']",
      text: "続きから遊ぶ"
    )
  end

  test "複数のプレイ途中データがある場合は最後に更新されたデータを再開対象にする" do
    gamebook = create_gamebook(
      user: @user,
      title: "最新プレイデータ確認用ゲームブック"
    )

    current_scene = gamebook.scenes.create!(
      scene_key: "resume_scene",
      title: "再開確認シーン",
      body: "再開するシーンの本文",
      situation: "冒険の途中",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    older_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: current_scene,
      status: :playing,
      started_at: 3.hours.ago,
      updated_at: 2.hours.ago
    )

    latest_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: current_scene,
      status: :playing,
      started_at: 2.hours.ago,
      updated_at: 1.hour.ago
    )

    login_as(@user)
    get gamebook_path(gamebook)

    assert_response :success

    assert_select(
      "a[href='#{play_session_path(latest_session)}']",
      text: "続きから遊ぶ"
    )

    assert_select(
      "a[href='#{play_session_path(older_session)}']",
      count: 0
    )
  end

  private

  def login_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end

  def create_gamebook(user:, title:, generation_status: :completed, created_at: Time.current)
    user.gamebooks.create!(
      title: title,
      summary: "テスト用ゲームブックの概要",
      genre: "ファンタジー",
      world_setting: "魔法が存在する世界",
      tone: "シリアス",
      difficulty: "普通",
      play_time: 30,
      generation_status: generation_status,
      created_at: created_at
    )
  end
end
