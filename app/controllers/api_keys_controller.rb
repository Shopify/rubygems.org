class ApiKeysController < ApplicationController
  include ApiKeyable
  before_action :redirect_to_signin, unless: :signed_in?
  before_action :redirect_to_verify, unless: :password_session_active?

  def index
    @api_key  = session.delete(:api_key)
    @api_keys = current_user.api_keys
    redirect_to new_profile_api_key_path if @api_keys.empty?
  end

  def new
    @api_key = current_user.api_keys.build
  end

  def create
    key = generate_unique_rubygems_key
    @api_key = current_user.api_keys.build(api_key_params.merge(hashed_key: hashed_key(key)))

    # unless set_rubygem_from_params
    #   flash[:error] = @api_key.errors.full_messages.to_sentence
    #   render :new
    #   return
    # end

    if @api_key.save
      Mailer.delay.api_key_created(@api_key.id)

      session[:api_key] = key
      redirect_to profile_api_keys_path, flash: { notice: t(".success") }
    else
      flash[:error] = @api_key.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @api_key = current_user.api_keys.find(params.require(:id))

    flash[:error] = @api_key.errors.full_messages.to_sentence unless @api_key.valid?
  end

  def update
    @api_key = current_user.api_keys.find(params.require(:id))

    # unless set_rubygem_from_params
    #   flash[:error] = @api_key.errors.full_messages.to_sentence
    #   render :edit
    #   return
    # end

    if @api_key.update(api_key_params)
      redirect_to profile_api_keys_path, flash: { notice: t(".success") }
    else
      flash[:error] = @api_key.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    api_key = current_user.api_keys.find(params.require(:id))

    if api_key.destroy
      flash[:notice] = t(".success", name: api_key.name)
    else
      flash[:error] = api_key.errors.full_messages.to_sentence
    end
    redirect_to profile_api_keys_path
  end

  def reset
    if current_user.api_keys.destroy_all
      flash[:notice] = t(".success")
    else
      flash[:error] = t("try_again")
    end
    redirect_to profile_api_keys_path
  end

  private

  # def set_rubygem_from_params
  #   rubygem_name = api_key_params.dig(:rubygem)
  #   unless rubygem_name.present?
  #     @api_key.rubygem = nil
  #     return true
  #   end

  #   rubygem = Rubygem.name_is(rubygem_name).first
  #   if rubygem
  #     @api_key.rubygem = rubygem
  #   else
  #     @api_key.errors[:rubygem] << "#{rubygem_name} cannot be found."
  #     false
  #   end
  # end

  # def api_key_build_params
  #   api_key_params.except(:rubygem)
  # end

  def api_key_params
    params.require(:api_key).permit(:name, *ApiKey::API_SCOPES, :mfa, :rubygem_name)
  end

  def redirect_to_verify
    session[:redirect_uri] = profile_api_keys_path
    redirect_to verify_session_path
  end
end
