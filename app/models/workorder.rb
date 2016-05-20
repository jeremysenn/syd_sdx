class Workorder
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/workorder"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    if data["GetUserWorkOrderCollectionResponse"]["Collection"]["WorkOrderInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [data["GetUserWorkOrderCollectionResponse"]["Collection"]["WorkOrderInformation"]]
    else # Array of results returned
      return data["GetUserWorkOrderCollectionResponse"]["Collection"]["WorkOrderInformation"]
    end
  end
  
  def self.status(status_number)
    if status_number == "0"
      return "Requested"
    elsif status_number == "1"
      return "Processing"
    elsif status_number == "2"
      return "Fulfilled"
    elsif status_number == "3"
      return "Void"
    else
      return "Unknown"
    end
  end
  
end