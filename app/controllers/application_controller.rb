class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :authenticate_user!
  before_action :block_external
  before_action :fetch_users
  before_action :fetch_groups

  before_action :configure_permitted_parameters, if: :devise_controller?

  #Rescue from record not found error and redirect to home page
  rescue_from ActiveRecord::RecordNotFound do |exception|
    if self.class.name.include?("::")
      redirect_to "/", :alert => "#{exception.message.split("::").join(" ")}"
    else
      redirect_to root_url, :alert => "#{exception.message}"
    end
  end

  #Rescue from bad text and redirect to referer
  rescue_from ActiveRecord::StatementInvalid do |exception|
    if exception.message.include?("Incorrect string value")
      redirect_to (request.referer or "/"), :alert => "Ensure that no special characters like emojis are being used in your form submission"
    else
      raise ActiveRecord::StatementInvalid.new(exception.message)
    end
  end

  protected

  # Function to check if request type is JSON or JS to skip authenticity token skip
  def json_request?
    request.format.json? or request.format.js?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :first_name, :last_name])
    update_attrs = [:password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit(:account_update, keys: update_attrs)
  end

  def fetch_users
    @users = User.all
  end

  def fetch_groups
    # @groups = Group.all
  end

  def block_external
    # render plain: "Development ongoing, external access is not permitted" if  !(IPAddr.new("115.99.237.242/32") === current_ip_address || IPAddr.new("127.0.0.1/24") === current_ip_address)
  end

  def disable_access
    render plain: "No permissions to view this" if current_user.id != 2
  end

  def current_ip_address
    request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR'] || req.ip
  end
end
