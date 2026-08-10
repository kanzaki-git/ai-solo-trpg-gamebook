require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  test "必須フラグが設定されていない場合は選択可能になる" do
    choice = choices(:one)
    play_session = play_sessions(:one)

    assert choice.available_for?(play_session)
  end

  test "必須フラグをすべて所持している場合は選択可能になる" do
    choice = choices(:one)
    play_session = play_sessions(:one)

    choice.choice_flag_rules.create!(
      flag: flags(:one),
      rule_type: :required
    )

    assert choice.available_for?(play_session)
  end

  test "必須フラグを所持していない場合は選択できない" do
    choice = choices(:one)
    play_session = play_sessions(:one)

    choice.choice_flag_rules.create!(
      flag: flags(:one),
      rule_type: :required
    )
    play_session.play_session_flags.destroy_all

    assert_not choice.available_for?(play_session)
  end

  test "必須所持品をすべて所持している場合は選択可能になる" do
    choice = choices(:one)
    play_session = play_sessions(:one)

    choice.choice_item_rules.create!(
      item: items(:one),
      rule_type: :required
    )

    assert choice.available_for?(play_session)
  end

  test "必須所持品を所持していない場合は選択できない" do
    choice = choices(:one)
    play_session = play_sessions(:one)

    choice.choice_item_rules.create!(
      item: items(:one),
      rule_type: :required
    )
    play_session.play_session_items.destroy_all

    assert_not choice.available_for?(play_session)
  end

  test "複数の必須所持品のうち一つでも不足している場合は選択できない" do
    choice = choices(:one)
    play_session = play_sessions(:one)
    another_item = Item.create!(
      gamebook: gamebooks(:one),
      key: "another_item",
      name: "別の所持品",
      description: "テスト用の所持品"
    )

    choice.choice_item_rules.create!(
      item: items(:one),
      rule_type: :required
    )
    choice.choice_item_rules.create!(
      item: another_item,
      rule_type: :required
    )

    assert_not choice.available_for?(play_session)
  end
end
