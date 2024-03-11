# lib」ディレクトリ以下のファイル読み込み,EmailValidatorクラスを呼び出し
require "validator/email_validator"

class User < ApplicationRecord
  before_validation :downcase_email

  # パスワードを暗号化するメソッドを追加
  has_secure_password

  validates :name, presence: true,
  length: { maximum: 30, allow_blank: true }

  validates :email, presence: true,
                    email: { allow_blank: true }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password,
                         allow_blank: true
                       },
                       allow_nil: true

  class << self
    #　↓　emailからアクティブなユーザーを返す
    def find_by_activated(email)
      find_by(email: email, activated: true)
    end
  end

  #　↓　自分と同じメールアドレスだけど他人でアクティブなユーザーがいる場合trueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_by_activated(email).present?
  end

  private

  def downcase_email
    self.email.downcase! if email
  end
end
