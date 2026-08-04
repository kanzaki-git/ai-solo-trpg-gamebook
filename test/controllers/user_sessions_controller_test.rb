require "test_helper"

class UserSessionsControllerTest < ActionDispatch::IntegrationTest
  # 実際にSorceryで暗号化されたパスワードを持つユーザーをsetupで作成
  setup do
    @user = User.create!(
      name: "Login Test User",
      email: "login-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "正しいメールアドレスとパスワードでログインできる" do
    post login_path, params: {
      email: @user.email,
      password: "password123"
    }

    assert_redirected_to root_path
    assert_equal "ログインしました", flash[:notice]
  end

  test "間違ったパスワードではログインできない" do
    post login_path, params: {
      email: @user.email,
      password: "wrong-password"
    }

    assert_response :unprocessable_entity
    assert_equal "メールアドレスまたはパスワードが正しくありません", flash[:alert]
    assert_nil session[:user_id]
  end

  test "ログアウトできる" do
    post login_path, params: {
      email: @user.email,
      password: "password123"
    }

    assert_not_nil session[:user_id]

    delete logout_path

    assert_redirected_to root_path
    assert_equal "ログアウトしました", flash[:notice]
    assert_nil session[:user_id]
  end
end
