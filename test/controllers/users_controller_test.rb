require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "ユーザー登録画面を表示できる" do
    get new_user_url

    assert_response :success
  end

  test "正しい入力でユーザーを登録できる" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          name: "テストユーザー",
          email: "new-user@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_url
    assert_equal "ユーザー登録が完了しました", flash[:notice]
  end

  test "パスワード確認が一致しない場合はユーザーを登録できない" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          name: "テストユーザー",
          email: "invalid-user@example.com",
          password: "password123",
          password_confirmation: "different123"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
