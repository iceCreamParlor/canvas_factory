# frozen_string_literal: true

class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
        else
          session["devise.#{provider}_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end
  [:kakao, :google_oauth2].each do |provider|
    provides_callback_for provider
  end
  # provider별로 서로 다른 로그인 경로 설정

  def after_sign_in_path_for(resource)
    auth = request.env['omniauth.auth']
    @identity = Identity.find_for_oauth(auth)
    @user = User.find(current_user.id)

    if Rails.env.production?
      # SNS 로그인 했을 때, 유저 세션을 기억하게 하는 코드
      cookies.signed["remember_user_token"] = {
        :value => @user.class.serialize_into_cookie(@user.reload),
        :expires => 3.months.from_now,
        :domain => ENV["BASE_URL"]
      }
    end

    if @user.persisted?
      if @identity.provider == "kakao"
        # register_info2_path
        root_path
      else
        # register_info1_path
        root_path
      end
    else
      root_path
    end
  end
end
