require "test_helper"

class GamebookTest < ActiveSupport::TestCase
  test "ユーザーに所属するゲームブックを保存できる" do
    gamebook = Gamebook.new(user: users(:one))

    assert gamebook.save
    assert_equal users(:one), gamebook.user
  end

  test "ユーザーが設定されていない場合は無効になる" do
    gamebook = Gamebook.new

    assert_not gamebook.valid?
    assert gamebook.errors.of_kind?(:user, :blank)
  end

  test "生成状態の初期値は0になる" do
    gamebook = Gamebook.new(user: users(:one))

    assert_equal 0, gamebook.generation_status
  end
end
