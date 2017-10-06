class Company < ActiveRecord::Base
  before_save :default_dragon_api
  before_save :default_jpegger_service_ip
  before_save :default_jpegger_service_port
  
  after_create :create_gross_and_tare_event_codes
  
  has_many :users
  has_many :inventories, through: :users
  has_many :event_codes
  
  mount_uploader :logo, LogoUploader
  
  validates_presence_of :name
  
  ############################
  #     Instance Methods     #
  ############################
  
  # Set the default dragon_api IP and port to what's set in environment variable
  def default_dragon_api
    self.dragon_api ||= "#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}"
  end
  
  # Set the default Jpegger service IP to what's set in environment variable
  def default_jpegger_service_ip
    self.jpegger_service_ip ||= "#{ENV['JPEGGER_SERVICE']}"
  end
  
  # Set the default Jpegger service port to 3333
  def default_jpegger_service_port
    self.jpegger_service_port ||= "3333"
  end
  
  def leads_online_config_settings_present?
    if leads_online_store_id.blank? or leads_online_ftp_username.blank? or leads_online_ftp_password.blank?
      return false
    else
      return true
    end
  end
  
  def full_address
    unless (address1.blank? and city.blank? and state.blank? and zip.blank?)
      "#{address1}<br>#{address2.blank? ? '' : address2 + '<br>'} #{city} #{state} #{zip}"
    end
  end
  
  def image_event_codes
    event_codes.where(include_in_images: true)
  end
  
  def shipment_event_codes
    event_codes.where(include_in_shipments: true)
  end
  
  def fetch_event_codes
    event_codes.where(include_in_fetch_lists: true)
  end
  
  def create_gross_and_tare_event_codes
    EventCode.create(company_id: self.id, name: 'Gross', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Tare', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
  end
  
  #############################
  #     Class Methods         #
  #############################
end