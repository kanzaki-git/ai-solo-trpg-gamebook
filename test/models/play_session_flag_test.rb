require "test_helper"

class PlaySessionFlagTest < ActiveSupport::TestCase
  test "プレイ状況を取得できる" do
    play_session_flag = play_session_flags(:one)

    assert_equal play_sessions(:one), play_session_flag.play_session
  end

  test "フラグを取得できる" do
    play_session_flag = play_session_flags(:one)

    assert_equal flags(:one), play_session_flag.flag
  end
end
