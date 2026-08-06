require "test_helper"

class PlaySessionItemTest < ActiveSupport::TestCase
  test "プレイ状況を取得できる" do
    play_session_item = play_session_items(:one)

    assert_equal play_sessions(:one), play_session_item.play_session
  end

  test "所持品を取得できる" do
    play_session_item = play_session_items(:one)

    assert_equal items(:one), play_session_item.item
  end
end
