require "test_helper"

class ChoiceItemRuleTest < ActiveSupport::TestCase
  test "choiceがなければ無効である" do
    rule = choice_item_rules(:one)
    rule.choice = nil

    assert_not rule.valid?
  end

  test "itemがなければ無効である" do
    rule = choice_item_rules(:one)
    rule.item = nil

    assert_not rule.valid?
  end

  test "rule_typeがなければ無効である" do
    rule = choice_item_rules(:one)
    rule.rule_type = nil

    assert_not rule.valid?
  end

  test "rule_typeのenumが正しく設定されている" do
    expected = {
      "required" => 0,
      "add" => 1,
      "remove" => 2
    }

    assert_equal expected, ChoiceItemRule.rule_types
  end

  test "同じ選択肢と所持品とルール種別を重複登録できない" do
    existing_rule = choice_item_rules(:one)
    duplicate_rule = ChoiceItemRule.new(
      choice: existing_rule.choice,
      item: existing_rule.item,
      rule_type: existing_rule.rule_type
    )

    assert_not duplicate_rule.valid?
    assert duplicate_rule.errors.of_kind?(:item_id, :taken)
  end
end
