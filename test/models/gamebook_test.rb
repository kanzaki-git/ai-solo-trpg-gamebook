require "test_helper"

class GamebookTest < ActiveSupport::TestCase
  test "ユーザーに所属するゲームブックを保存できる" do
    gamebook = Gamebook.new(
      user: users(:one),
      genre: "ファンタジー",
      world_setting: "剣と魔法の世界",
      tone: "明るい",
      difficulty: "普通",
      play_time: 30
    )

    assert gamebook.save
    assert_equal users(:one), gamebook.user
  end

  test "ユーザーが設定されていない場合は無効になる" do
    gamebook = Gamebook.new

    assert_not gamebook.valid?
    assert gamebook.errors.of_kind?(:user, :blank)
  end

  test "生成状態の初期値はgeneratingになる" do
    gamebook = Gamebook.new(user: users(:one))

    assert_equal "generating", gamebook.generation_status
    assert_predicate gamebook, :generating?
  end
end
