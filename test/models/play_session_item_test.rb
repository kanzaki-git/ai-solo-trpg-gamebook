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

  test "同じプレイ状況に同じ所持品を重複登録できない" do
    existing_item = play_session_items(:one)
    duplicate_item = PlaySessionItem.new(
      play_session: existing_item.play_session,
      item: existing_item.item
    )

    assert_not duplicate_item.valid?
    assert duplicate_item.errors.of_kind?(:item_id, :taken)
  end
end
