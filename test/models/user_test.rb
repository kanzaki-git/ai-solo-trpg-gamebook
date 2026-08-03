require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
    )
  end

  test "有効なユーザーを保存できる" do
    assert @user.valid?
  end

  test "ユーザー名が空欄の場合は無効になる" do
    @user.name = nil

    assert_not @user.valid?
    assert_includes @user.errors[:name], "can't be blank"
  end

  test "メールアドレスが空欄の場合は無効になる" do
    @user.email = nil

    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "同じメールアドレスは登録できない" do
    @user.email = users(:one).email

    assert_not @user.valid?
    assert_includes @user.errors[:email], "has already been taken"
  end

  test "パスワードが暗号化されて保存される" do
    original_password = @user.password

    assert @user.save
    assert_not_equal original_password, @user.crypted_password
    assert_predicate @user.crypted_password, :present?
    assert_predicate @user.salt, :present?
  end
end
