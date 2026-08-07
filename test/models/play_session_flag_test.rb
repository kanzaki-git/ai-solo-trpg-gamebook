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

  test "同じプレイ状況に同じフラグを重複登録できない" do
    existing_flag = play_session_flags(:one)
    duplicate_flag = PlaySessionFlag.new(
      play_session: existing_flag.play_session,
      flag: existing_flag.flag
    )

    assert_not duplicate_flag.valid?
    assert duplicate_flag.errors.of_kind?(:flag_id, :taken)
  end
end
