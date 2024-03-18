require "test_helper"

class UserTest < ActiveSupport::TestCase

  # 共通のユーザーを宣言。active_user ... ユーザーテーブルからアクティブなユーザーを一人取り出す
  def Setup
    @user = active_user
  end

  # テスト項目１：ユーザーネームのバリデーションテストを実施
  # name属性が定義されていない時に正くエラーメッセージが出るか確認
  # 期待された結果が返ってきたらエラーは発生しない
  # 入力必須項目の定義し、その中でユーザーオブジェクトを作成・保存。
  test "name_validation" do
    user = User.new(email: "test@example.com", password: "password")
    user.save
    # name属性が定義されていないので、バリデーションエラーが発生するので、その対策
    # バリデーションエラーは配列で返されるので期待されるエラーメッセージを配列で宣言
    required_msg = ["名前を入力してください"]

    assert_equal(required_msg, user.errors.full_messages) 

    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    # 31文字でテストした場合バリデーションエラーが発生するのでその対策
    maxlength_msg = ["名前は30文字以内で入力してください"]

    assert_equal(maxlength_msg, user.errors.full_messages)


    # 30文字以内は正しく保存されているか
    name = "あ" * max
    user.name = name
    assert_difference("User.count", 1) do
    user.save
    end

  end

  test "email_validation" do
    # テスト項目
    # 入力必須項目
    user = User.new(name: "test@example.com", password: "password")
    user.save
    required_msg = ["メールアドレスを入力してください"]

    assert_equal(required_msg, user.errors.full_messages) 


    # 255文字制限
    max = 255
    domain = "@example.com"
    email = "a" * ((max + 1) - domain.length) + domain
    assert max < email.length

    user.email = email
    user.save
    maxlength_msg = ["メールアドレスは255文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

        #2つの書式チェックを行う
    # ①正し書式は保存保存できるのか
    # 以下のメールアドレスはバリデーションに引っかからないようにする
    ok_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    ok_emails.each do |email|
      user.email = email
      assert user.save
    end

    # ②間違った書式はエラーを吐いているのか？
    ng_emails = %w(
      aaa
      a.ex.com
      メール@ex.com
      a~a@ex.com
      a@|.com
      a@ex.
      .a@ex.com
      a＠ex.com
      Ａ@ex.com
      a@?,com
      １@ex.com
      "a"@ex.com
      a@ex@co.jp
    )
    ng_emails.each do |email|
      user.email = email
      user.save
      format_msg = ["メールアドレスは不正な値です"]
      assert_equal(format_msg, user.errors.full_messages)
    end
  end

  test "email_downcase" do
    # emailが小文字かされているか
    # バリデーション実行後のユーザーメールアドレスと、小文字にしたemailが一致していればテストが通るようにする
    email = "USER@EXAMPLE.COM"
    user = User.new(email: email)
    user.save
    assert user.email == email.downcase
  end

end
