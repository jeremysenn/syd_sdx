class User < ActiveRecord::Base
  ROLES = %w[customer admin].freeze

  attr_accessor :password
  before_save :prepare_password
#  after_create :generate_token, if: :admin?
  before_save { |user| user.username = username.downcase }
  before_save { |user| user.email = email.downcase }
  
  has_one :access_token
  has_one :user_setting
  belongs_to :company
  
  before_create :confirmation_token
#  after_commit :create_user_settings, :on => :create
  after_create :create_user_settings
  after_create :create_company, unless: :company?
  after_commit :send_registration_notice_email, :on => :create
    
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
  validates_presence_of :role, :message => 'Please select type of user.'
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :username, length: { minimum: 7 }
  validates_presence_of :company_name
  validates_presence_of :address1
  validates_presence_of :city
  validates_presence_of :state
  validates_uniqueness_of :username, scope: :dragon_account_number, case_sensitive: false
  validates_uniqueness_of :email, case_sensitive: false
  validates :terms_of_service, acceptance: true, on: :create, allow_nil: false
  
  ############################
  #     Instance Methods     #
  ############################
  
  def generate_scrap_dragon_token(user_params)
#    user = User.find(user_params[:id])
    company = Company.where(account_number: user_params[:dragon_account_number]).first unless user_params[:dragon_account_number].blank?
    unless company.blank?
      api_url = "https://#{company.dragon_api}/token"
    else
     api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    end
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user_params[:username], password: user_params[:password]})
#    JSON.parse(response)
    Rails.logger.info response
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_scrap_dragon_token(user_id, pass)
    user = User.find(user_id)
    api_url = "https://#{user.company.dragon_api}/token"
    begin
      response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user.username, password: pass})
#    Rails.logger.info response
      access_token_string = JSON.parse(response)["access_token"]
      access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 12.hours)
      return 'success'
    rescue RestClient::ExceptionWithResponse => e
      e.response
#    rescue => exception
      Rails.logger.info e.response
      e.response
    end
  end
  
  def create_scrap_dragon_user(user_params)
#    user = User.find(user_params[:id])
    company = Company.where(account_number: user_params[:dragon_account_number]).first unless user_params[:dragon_account_number].blank?
    unless company.blank?
      api_url = "https://#{company.dragon_api}/api/user"
    else
      api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/user"
    end
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardName" => user_params[:company_name],
      "YardPhone" => user_params[:phone],
      "YardAddress1" => user_params[:address1],
      "YardAddress2" => user_params[:address2],
      "YardCity" => user_params[:city],
      "YardState" => user_params[:state]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data["AddApiUserResponse"]["Success"]
    return data["AddApiUserResponse"]
  end
  
  def create_scrap_dragon_user_for_current_user(auth_token, user_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user"
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardName" => user_params[:company_name],
      "YardPhone" => user_params[:phone],
      "YardAddress1" => user_params[:address1],
      "YardAddress2" => user_params[:address2],
      "YardCity" => user_params[:city],
      "YardState" => user_params[:state]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiUserResponse"]
  end
  
  def create_scrap_dragon_customer_user(auth_token, user_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user/customer"
    
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardId" => user_params[:yard_id],
      "CustomerIdCollection" => [user_params[:customer_guid]]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiCustomerUserResponse"]
  end
  
  def reset_scrap_dragon_password(user_id, new_password)
    user = User.find(user_id)
    api_url = "https://#{user.company.dragon_api}/api/user/#{user.username}/password"
    
    payload = {
      "Password" => new_password
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{user.token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info data
    return data["ResetUserPasswordResponse"]
  end
  
  def yards
    Yard.find_all(self)
  end
  
  def create_user_settings
    UserSetting.create(user_id: id, show_thumbnails: customer? ? true : false)
  end
  
  def create_company
    company = Company.where(account_number: dragon_account_number).last unless dragon_account_number.blank?
    if company.blank?
      unless company_name.blank?
        company = Company.create(name: company_name, account_number: dragon_account_number)
      else
        company = Company.create(name: "User #{username} Company", account_number: dragon_account_number)
      end
    end
    self.company_id = company.id
    self.save
  end
  
  def show_thumbnails?
    user_setting.show_thumbnails?
  end
  
  def show_ticket_thumbnails?
    user_setting.show_ticket_thumbnails?
  end
  
  def show_customer_thumbnails?
    user_setting.show_customer_thumbnails?
  end
  
  def images_table?
    user_setting.table_name == "images"
  end
  
  def shipments_table?
    user_setting.table_name == "shipments"
  end
  
  def admin?
    role == "admin"
  end
  
  def basic?
    role == "basic"
  end
  
  def customer?
    role == "customer"
  end
  
  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end
  
  def company?
    company_id.present?
  end
  
  ### Devices ###
  def devices
    user_setting.devices
  end
  
  def scale_devices
    user_setting.scale_devices
  end
  
  def camera_devices
    user_setting.camera_devices
  end
  
  def license_reader_devices
    user_setting.license_reader_devices
  end
  
  def license_imager_devices
    user_setting.license_imager_devices
  end
  
  def finger_print_reader_devices
    user_setting.finger_print_reader_devices
  end
  
  def signature_pad_devices
    user_setting.signature_pad_devices
  end
  
  def printer_devices
    user_setting.printer_devices
  end
  
  def qbo_access_credential
    QboAccessCredential.find_by_company_id(location)
  end
  
  def device_group
    user_setting.device_group
  end
  
  def customer_camera
    user_setting.customer_camera
  end
  
  def scanner_devices
    user_setting.scanner_devices
  end
  ### End Devices ###
  
  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
  
  def token
    access_token.token_string
  end
  
  def send_registration_notice_email
    NewUserRegistrationWorker.perform_async(self.id) # Send out admin email to notify of new user registration, in sidekiq background process
  end
  
  def send_confirmation_instructions_email
    UserConfirmationInstructionsSendEmailWorker.perform_async(self.id) # Send out confirmation instructions email to new user, in sidekiq background process
  end
  
  def send_after_confirmation_info_email
    UserConfirmedSendEmailWorker.perform_async(self.id) # Send out email with additional Dragon Dog information after user email is confirmed, in sidekiq background process
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.authenticate(login, pass, account_number)
#    user = find_by_username(login) || find_by_email(login)
    user = User.where(username: login.downcase, dragon_account_number: [nil, '']).first || User.where(email: login.downcase, dragon_account_number: [nil, '']).first if account_number.blank?
    user = User.where(username: login.downcase, dragon_account_number: account_number).first || User.where(email: login.downcase, dragon_account_number: account_number).first unless account_number.blank?
#    if user and user.password_hash == user.encrypt_password(pass)
    if user
      response = user.update_scrap_dragon_token(user.id, pass)
      if response == 'success'
        return user 
      end
    else
      nil
    end
  end
  
  def self.generate_scrap_dragon_token(user_params, user_id)
    company = Company.where(account_number: user_params[:dragon_account_number]).first unless user_params[:dragon_account_number].blank?
    unless company.blank?
      api_url = "https://#{company.dragon_api}/token"
    else
     api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    end
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user_params[:username], password: user_params[:password]})
    Rails.logger.info response
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: user_id, expiration: Time.now + 24.hours)
  end
  
  def self.update_scrap_dragon_token(user_id, pass)
    user = User.find(user_id)
    api_url = "https://#{user.company.dragon_api}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user.username, password: pass})
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 12.hours)
  end
  
  def self.create_scrap_dragon_user(user_params)
    company = Company.where(account_number: user_params[:dragon_account_number]).first unless user_params[:dragon_account_number].blank?
    unless company.blank?
      api_url = "https://#{company.dragon_api}/api/user"
    else
      api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/user"
    end
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardName" => user_params[:company_name],
      "YardPhone" => user_params[:phone],
      "YardAddress1" => user_params[:address1],
      "YardAddress2" => user_params[:address2],
      "YardCity" => user_params[:city],
      "YardState" => user_params[:state]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiUserResponse"]
  end
  
  def self.create_scrap_dragon_user_for_current_user(auth_token, user_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user"
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardName" => user_params[:company_name],
      "YardPhone" => user_params[:phone],
      "YardAddress1" => user_params[:address1],
      "YardAddress2" => user_params[:address2],
      "YardCity" => user_params[:city],
      "YardState" => user_params[:state]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiUserResponse"]
  end
  
  def self.create_scrap_dragon_customer_user(auth_token, user_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user/customer"
    
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardId" => user_params[:yard_id],
      "CustomerIdCollection" => [user_params[:customer_guid]],
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiCustomerUserResponse"]
  end
  
  def send_password_reset
    create_password_reset_token
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password_instructions(self).deliver
  end
  
  def create_password_reset_token
    self.password_reset_token = SecureRandom.urlsafe_base64.to_s
  end
  
  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end
  
  def confirmation_token
    if self.confirm_token.blank?
        self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
  
end