class TicketItem
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.save_vin(auth_token, yard_id, ticket_item_id, year, make_id, model_id, body_id, color_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/savevins"
    payload = {
      "TicketItemsId" => ticket_item_id,
      "VehicleIdentificationNumbers" => [{
          "Id" => SecureRandom.uuid,
          "Year" => year,
          "VehicleMakeId" => make_id,
          "VehicleModelId" => model_id,
          "BodyStyleId" => body_id,
          "ColorId" => color_id,
          "TicketItemsId" => ticket_item_id
        }],
      }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info "payload: #{json_encoded_payload}"
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    return data["SaveVehicleIdentificationNumbersResponse"]
  end
  
  def self.vins(auth_token, yard_id, ticket_item_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/getvins?ticketItemId=#{ticket_item_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    if data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"].is_a? Hash
      # Only one VIN for ticket item, so put into array
      return [data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"]]
    else
      # Multiple VIN's for ticket item, so already in an array
      return data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"]
    end
  end
  
end