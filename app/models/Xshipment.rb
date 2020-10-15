#class Shipment < ActiveResource::Base
#  self.site = "http://#{ENV['JPEGGER_SERVICE']}/api/v1" # Azure container group API
#  self.primary_key = 'capture_seq_nbr'
#  
#  validates_presence_of :ticket_nbr
#  validates_presence_of :file, on: :create
#  
#  schema do
#    string :ticket_nbr
#    string :event_code
#    string :yardid
#    string :cust_name
#    text :file
#  end
#  
#  #############################
#  #     Instance Methods      #
#  #############################
#  
#  def uri
##    "#{Image.site}images/#{capture_seq_nbr}/display"
#    "#{Shipment.site.scheme}://#{Shipment.site.host}:#{Shipment.site.port}#{self.azure_url}"
#  end
#  
#  def thumbnail_uri
#    "#{Shipment.site.scheme}://#{Shipment.site.host}:#{Shipment.site.port}#{self.thumbnail_url}"
#  end
#  
#  def hidden?
#    self.hidden == '1'
#  end
#  
#  def file
#    self.get(:file)
#  end
#  
#  def image_attachment?
#    content_type.start_with? 'image'
#  end
#  
#  def pdf_attachment?
#    content_type == 'application/pdf'
#  end
#  
#  def file_extension
#    extension = File.extname(self.azure_url)
#    unless extension.blank? 
#      return extension.upcase
#    else
#      return nil
#    end
#  end
#  
#  #############################
#  #     Class Methods         #
#  #############################
#  
#  def self.multipart_create(params)
#    api_url = "#{Shipment.site}/shipments"
##    json_encoded_payload = JSON.generate(params)
#    RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: params)
#  end
#  
#end