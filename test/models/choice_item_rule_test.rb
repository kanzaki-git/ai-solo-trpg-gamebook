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

  test "rule_typeのenumが正しく設定されている" do
    expected = {
      "required" => 0,
      "add" => 1,
      "remove" => 2
    }

    assert_equal expected, ChoiceItemRule.rule_types
  end
end
