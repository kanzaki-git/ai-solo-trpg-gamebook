require "test_helper"

class ChoiceFlagRuleTest < ActiveSupport::TestCase
  test "choiceがなければ無効である" do
    rule = choice_flag_rules(:one)
    rule.choice = nil

    assert_not rule.valid?
  end

  test "flagがなければ無効である" do
    rule = choice_flag_rules(:one)
    rule.flag = nil

    assert_not rule.valid?
  end

  test "rule_typeがなければ無効である" do
    rule = choice_flag_rules(:one)
    rule.rule_type = nil

    assert_not rule.valid?
  end

  test "rule_typeのenumが正しく設定されている" do
    expected = {
      "required" => 0,
      "add" => 1,
      "remove" => 2
    }

    assert_equal expected, ChoiceFlagRule.rule_types
  end

  test "同じ選択肢とフラグとルール種別を重複登録できない" do
    existing_rule = choice_flag_rules(:one)
    duplicate_rule = ChoiceFlagRule.new(
      choice: existing_rule.choice,
      flag: existing_rule.flag,
      rule_type: existing_rule.rule_type
    )

    assert_not duplicate_rule.valid?
    assert duplicate_rule.errors.of_kind?(:flag_id, :taken)
  end
end
