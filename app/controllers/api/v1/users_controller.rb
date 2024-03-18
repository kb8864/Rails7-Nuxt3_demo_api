class Api::V1::UsersController < ApplicationController

  #ユーザー一覧を取得するアクション
  def index
    users = User.all
    render json: users.as_json(only: [:id, :name, :email, :created_at])
  end
end
