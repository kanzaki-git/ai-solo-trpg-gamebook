require "test_helper"

class PlayHistoryTest < ActiveSupport::TestCase
  test "プレイ状況を取得できる" do
    play_history = play_histories(:one)

    assert_equal play_sessions(:one), play_history.play_session
  end

  test "訪問したシーンを取得できる" do
    play_history = play_histories(:one)

    assert_equal scenes(:one), play_history.scene
  end

  test "選択肢がなくても有効である" do
    play_history = play_histories(:one)

    assert_nil play_history.choice
    assert play_history.valid?
  end

  test "選択した選択肢を取得できる" do
    play_history = play_histories(:two)

    assert_equal choices(:two), play_history.choice
  end
end
