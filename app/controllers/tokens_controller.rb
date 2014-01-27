class TokensController < ApplicationController
  before_filter :assert_admin!
  def index
    u=User.find_by_account_id_and_id(*params.values_at(:account_id, :user_id))
    render json: {
      tokens: u.authentication_tokens.map{|t|
        TokenView.new(t).render
      }
    }
  end

  def create
    u=User.find_by_account_id_and_id(*params.values_at(:account_id, :user_id))
    t=u.build_authentication_token
    u.save!
    render json: TokenView.new(t).render
  end

  def show
    u=User.find_by_account_id_and_id(*params.values_at(:account_id, :user_id))
    t=u.authentication_tokens.find(params[:id])
    render json: TokenView.new(t).render
  end

  def destroy
    u=User.find_by_account_id_and_id(*params.values_at(:account_id, :user_id))
    token = u.authentication_tokens.find(params[:id])
    token.destroy
    render json: TokenView.new(token)
  end

  private

  def assert_admin!
    # Follow Sidekiq example and just 404
    raise ActiveRecord::RecordNotFound unless current_user.admin?
  end

  TokenView = Struct.new(:token) do
    def render
      {token: token.token, id: token.id, created_at: token.created_at}
    end
  end
end