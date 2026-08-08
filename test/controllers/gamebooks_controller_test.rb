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
