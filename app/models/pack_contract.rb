class PackContract
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # Get all pack_contracts by search string (Customer First Name, Last Name, CustomerNumber, ContractNumber or Company)
  def self.all(auth_token, yard_id, search)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/Contracts"
    
    payload = {
      "SearchText" => search
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json'}, :payload => json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.info "Pack Contracts response: #{data}"
    
    unless data["GetMobileContractsResponse"]["Contracts"]["ContractListInformation"].blank?
      if data["GetMobileContractsResponse"]["Contracts"]["ContractListInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetMobileContractsResponse"]["Contracts"]["ContractListInformation"]]
      else # Array of results returned
        return data["GetMobileContractsResponse"]["Contracts"]["ContractListInformation"]
      end
    else # No pack contracts found
      return []
    end
  end
  
  def self.find_by_id(auth_token, yard_id, pack_contract_id)
    pack_contracts = PackContract.all(auth_token, yard_id, pack_contract_id)
    # Find pack contract within array of hashes
    pack_contract = pack_contracts.find {|pc| pc['Id'] == pack_contract_id}
    return pack_contract_id
  end
  
  def self.find_by_contract_number(auth_token, yard_id, contract_number)
    PackContract.all(auth_token, yard_id, contract_number).first
  end
  
  def self.update(auth_token, yard_id, pack_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/Pack"
    payload = {
      "Id" => pack_params[:id],
      "PrintDescription" => pack_params[:description],
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data
    return data["SavePackResponse"]["Success"]
  end
  
  def self.test_array
    [{"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-11-07T17:37:27", "DateCreated"=>"2014-11-07T17:36:48", "Id"=>"658eb105-a3d8-44e1-8b7a-0966b583bd43", "InternalPackNumber"=>"MN411", "InventoryCode"=>"Auto Bats", "Location"=>nil, "NetWeight"=>"100.0000", "PrintDescription"=>"Car/Truck Batteries", "Quantity"=>"20.00", "Row"=>nil, "TagNumber"=>"411", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T18:56:03.177", "DateCreated"=>"2015-12-08T18:56:03", "Id"=>"07043fd5-525e-4568-b54a-0c3d17c5ca99", "InternalPackNumber"=>"OY624", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"624", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-10T19:27:02.46", "DateCreated"=>"2014-01-10T19:26:56.053", "Id"=>"15829af0-1841-4877-bb7b-15dce019bf7b", "InternalPackNumber"=>"MN66", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"25.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"66", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-15T14:33:55.247", "DateCreated"=>"2014-10-15T14:33:55.157", "Id"=>"eb98d798-133a-4997-9d2f-1d25a9112143", "InternalPackNumber"=>nil, "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"2990.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"338", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-09-28T17:28:26.487", "DateCreated"=>"2015-09-28T17:28:20", "Id"=>"92042bbd-c571-465a-9212-28b79f9d9055", "InternalPackNumber"=>"MN526", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"1500.0000", "PrintDescription"=>"Stainless St", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"526", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-07-10T11:35:42", "DateCreated"=>"2015-07-10T11:35:28", "Id"=>"141d9f3f-5565-4568-bf62-2ae9667e6cb4", "InternalPackNumber"=>"MN505", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"55.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"505", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-10-01T16:47:06.383", "DateCreated"=>"2015-10-01T16:47:06", "Id"=>"1b8f7781-ab53-4b05-aa93-2b492dc492c8", "InternalPackNumber"=>"MN544", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"12.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"544", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-23T18:44:34.2", "DateCreated"=>"2014-10-23T18:44:22.54", "Id"=>"6a674594-e366-43ce-b4ac-37a998ee9c1b", "InternalPackNumber"=>"MN392", "InventoryCode"=>"#1 HMS", "Location"=>nil, "NetWeight"=>"50.0000", "PrintDescription"=>"#1 HMS", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"392", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2016-01-20T21:01:13.703", "DateCreated"=>"2016-01-20T21:01:06", "Id"=>"2438b20a-7890-4918-bb5c-4839abed8196", "InternalPackNumber"=>"MN732", "InventoryCode"=>"#1 Steel", "Location"=>nil, "NetWeight"=>"1000.0000", "PrintDescription"=>"#1 Steel", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"732", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T17:23:39.923", "DateCreated"=>"2015-09-30T17:23:39", "Id"=>"35560731-fc8d-4a84-a107-5347a28fd254", "InternalPackNumber"=>"MN537", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"78.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"537", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T14:45:09.613", "DateCreated"=>"2015-09-30T14:43:34", "Id"=>"6747ea2b-071f-472b-9cb3-53beee6aded3", "InternalPackNumber"=>"MN527", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"90.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"527", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T19:05:02.867", "DateCreated"=>"2015-12-08T19:05:02", "Id"=>"6038b4c8-e4ee-4149-a1e4-5b0523c12eaf", "InternalPackNumber"=>"OY623", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"150.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"623", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-23T12:06:20", "DateCreated"=>"2014-10-23T12:06:03", "Id"=>"35d88861-08d6-4127-8730-5b660275b828", "InternalPackNumber"=>"MN387", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"500.0000", "PrintDescription"=>"Flats", "Quantity"=>"50.00", "Row"=>nil, "TagNumber"=>"387", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T15:22:01.333", "DateCreated"=>"2015-09-30T15:22:01", "Id"=>"d29b61d1-374f-4307-ab26-6f1d69223306", "InternalPackNumber"=>"MN532", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"395.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"532", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-07-28T14:54:15.107", "DateCreated"=>"2014-07-28T14:53:59.827", "Id"=>"12113d45-ce65-4c45-884d-7eed7b37e94c", "InternalPackNumber"=>"MN233", "InventoryCode"=>"#1 HMS", "Location"=>nil, "NetWeight"=>"30.0000", "PrintDescription"=>"#1 HMS", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"233", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-06-02T17:15:51.647", "DateCreated"=>"2014-06-02T17:15:39.223", "Id"=>"7ffd6784-7ef6-4c31-b1d3-800806b3c951", "InternalPackNumber"=>"MN181", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"8500.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"181", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T22:02:25.683", "DateCreated"=>"2014-10-07T22:02:25.603", "Id"=>"aa2314ae-8b16-4219-aa2c-88189f27e7f5", "InternalPackNumber"=>"193", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"10.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"193", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T12:35:25.563", "DateCreated"=>"2014-05-14T12:35:19.013", "Id"=>"59092e61-4819-42d8-8559-8ad1bbf902e5", "InternalPackNumber"=>"MN162", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"10.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"162", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T12:06:54.997", "DateCreated"=>"2014-05-14T12:06:42.46", "Id"=>"82994061-19bf-4847-b093-8ca9cb313d38", "InternalPackNumber"=>"MN160", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"160", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-07-08T20:21:52", "DateCreated"=>"2015-07-08T20:21:39", "Id"=>"afbf5087-6fb9-4a82-9794-9100cc1c4909", "InternalPackNumber"=>"MN498", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"2000.0000", "PrintDescription"=>"Stainless St", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"498", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T11:38:51.847", "DateCreated"=>"2014-05-14T11:38:44.38", "Id"=>"32391083-7a7a-40d2-a790-9249bfcc6da0", "InternalPackNumber"=>"MN154", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"154", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-25T16:14:58.37", "DateCreated"=>"2014-03-25T16:14:13.987", "Id"=>"e9133165-8bd5-4437-8f6b-92c1faebdb77", "InternalPackNumber"=>"MN97", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"35.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"97", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-17T17:10:46.09", "DateCreated"=>"2014-01-17T17:10:26.47", "Id"=>"00e7dde1-c8ed-44af-a2fd-94f50616908f", "InternalPackNumber"=>"MN83", "InventoryCode"=>"Brass", "Location"=>nil, "NetWeight"=>"10.0000", "PrintDescription"=>"Brass", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"83", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-09T10:07:21.99", "DateCreated"=>"2014-10-09T10:07:21.98", "Id"=>"a463b1f7-7909-42db-8b8f-957a051153a9", "InternalPackNumber"=>"309", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"300.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"309", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-07-15T17:18:56.72", "DateCreated"=>"2014-07-15T17:18:42.347", "Id"=>"91bf6f03-9c97-4fde-9e39-98511f7dccf6", "InternalPackNumber"=>"MN226", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"25.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"226", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-10T19:40:01.027", "DateCreated"=>"2014-01-10T19:39:54.557", "Id"=>"b40cf028-8db8-4c99-a0cf-9865c1dcc53a", "InternalPackNumber"=>"MN68", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"25.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"68", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-09T10:07:12.033", "DateCreated"=>"2014-10-09T10:07:12.013", "Id"=>"789f09dc-b675-4664-9990-9b64d36b5b02", "InternalPackNumber"=>"310", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"310", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T15:48:38.443", "DateCreated"=>"2015-09-30T15:48:38", "Id"=>"a9872d76-3f33-4f5b-b0d4-9c43f12e4c5e", "InternalPackNumber"=>"MN536", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"485.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"536", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-28T09:08:49.347", "DateCreated"=>"2014-08-28T09:08:41.787", "Id"=>"b1405d7e-fd02-4563-8adf-9f2456d2d283", "InternalPackNumber"=>"MN246", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"845.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"246", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-07-15T17:36:49.667", "DateCreated"=>"2014-07-15T17:36:38.86", "Id"=>"76862cd4-bf71-453e-882a-a39dc131a197", "InternalPackNumber"=>"MN228", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"228", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-09-28T15:47:10", "DateCreated"=>"2015-09-28T15:47:04", "Id"=>"73be2d47-29d6-49f5-b733-a55e36ac2509", "InternalPackNumber"=>"MN518", "InventoryCode"=>"A1 Copper", "Location"=>"Warehouse 1", "NetWeight"=>"975.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>"Row B Left Column", "TagNumber"=>"518", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-27T19:05:11.507", "DateCreated"=>"2014-08-27T19:05:04.52", "Id"=>"2b5c9e88-6bd2-4424-815a-a56974baadcd", "InternalPackNumber"=>"MN242", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"5000.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"242", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-06-11T18:45:50.507", "DateCreated"=>"2014-06-11T18:45:50.473", "Id"=>"b0bb1efe-7dda-4ff7-b85e-a7c1a22ae7ce", "InternalPackNumber"=>"MN196", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"196", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-14T14:22:48.847", "DateCreated"=>"2014-10-14T14:22:48.807", "Id"=>"588d5d84-f508-4d31-9813-ab12b090ac4e", "InternalPackNumber"=>nil, "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"99.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"188", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-14T12:08:21.47", "DateCreated"=>"2014-10-14T12:08:21.433", "Id"=>"9dd072a7-f3a3-479d-b5f8-aca3893775a7", "InternalPackNumber"=>nil, "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"500.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"320", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-11-04T17:13:04.043", "DateCreated"=>"2014-11-04T17:11:33.663", "Id"=>"ee942e17-0759-4680-9fca-acf920aef3b9", "InternalPackNumber"=>"MN406", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"0.0000", "PrintDescription"=>"Stainless St", "Quantity"=>"1.00", "Row"=>nil, "TagNumber"=>"406", "UnitOfMeasure"=>nil, "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-28T12:33:01.763", "DateCreated"=>"2014-03-28T12:32:55.173", "Id"=>"16c3d7bb-09f5-47cf-9e8b-ad861d32ea67", "InternalPackNumber"=>"MN128", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"25.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"128", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-06-11T18:45:38.107", "DateCreated"=>"2014-06-11T18:45:38.097", "Id"=>"6ac28c3e-c46c-4aaa-8759-af705c12c748", "InternalPackNumber"=>"MN197", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"10.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"197", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T18:20:21.24", "DateCreated"=>"2015-09-30T18:20:20", "Id"=>"95575a34-3d47-465b-8608-b0a468e976b5", "InternalPackNumber"=>"MN538", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"12.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"538", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T19:04:35.833", "DateCreated"=>"2015-12-08T19:04:35", "Id"=>"dfa7be99-7e31-4506-ac33-b1885a84f659", "InternalPackNumber"=>"OY622", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"100.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"622", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-22T14:53:41.957", "DateCreated"=>"2014-10-22T14:52:55.21", "Id"=>"d38b210e-e23d-434b-a811-b3ffb321388b", "InternalPackNumber"=>"MN374", "InventoryCode"=>"CPU Chips", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"CPU Chips", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"374", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-28T09:15:22.793", "DateCreated"=>"2014-08-28T09:15:15.093", "Id"=>"1710a47f-0cb4-49f8-a058-b51591db9d92", "InternalPackNumber"=>"MN248", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"4600.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"248", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-09-15T16:03:00.347", "DateCreated"=>"2014-09-15T16:00:45.69", "Id"=>"d619f263-d834-4cf4-b3dd-b86ad6958262", "InternalPackNumber"=>"TEST258", "InventoryCode"=>"316", "Location"=>nil, "NetWeight"=>"70.0000", "PrintDescription"=>"316 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"258", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T17:53:01.943", "DateCreated"=>"2014-10-07T17:53:01.92", "Id"=>"e37e1465-4b9d-4643-8d69-b8a48515d4ef", "InternalPackNumber"=>"194", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"8.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"194", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-27T15:02:26.95", "DateCreated"=>"2014-03-27T15:02:26.937", "Id"=>"57e598df-6f2d-4e47-aa25-ba4d772e5452", "InternalPackNumber"=>"MN121", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"0.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"121", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-21T18:20:04.243", "DateCreated"=>"2014-05-21T18:16:42.867", "Id"=>"8942584d-b205-49f0-98f3-bb672b21daf7", "InternalPackNumber"=>"MN171", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"450.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"171", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T21:27:40.417", "DateCreated"=>"2014-10-07T21:27:40.333", "Id"=>"aaebacc7-3351-4bf5-bf2e-bd2686cf78f5", "InternalPackNumber"=>"194", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"8.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"194", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T12:24:07.86", "DateCreated"=>"2014-05-14T12:24:02.017", "Id"=>"7c4cc999-d0a8-48a9-8de0-ca3e69baaa6c", "InternalPackNumber"=>"MN161", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"161", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-14T14:11:45.067", "DateCreated"=>"2014-10-14T14:11:45.03", "Id"=>"41497556-2824-41e1-894a-ca43709f5900", "InternalPackNumber"=>nil, "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"15.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"167", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T10:54:08.5", "DateCreated"=>"2014-05-14T10:54:02.043", "Id"=>"7d5d80de-ae7e-4175-8012-ca705846b338", "InternalPackNumber"=>"MN153", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"153", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-10T18:57:29.88", "DateCreated"=>"2014-01-10T18:57:13.1", "Id"=>"c551b8ae-0aef-4c97-9885-cb1e0a13649e", "InternalPackNumber"=>"MN59", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"50.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"59", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-26T16:06:26.893", "DateCreated"=>"2014-03-26T16:06:12.03", "Id"=>"759b2303-af87-4eed-a642-cc0929f3c588", "InternalPackNumber"=>"MN108", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"87.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"108", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-26T17:22:42.407", "DateCreated"=>"2014-03-26T17:22:31.84", "Id"=>"76d9d56b-a6d7-4642-bf1a-db5dda2ad33f", "InternalPackNumber"=>"MN109", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"500.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"109", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-09T09:26:49.343", "DateCreated"=>"2014-10-09T09:26:45.07", "Id"=>"4afc56c7-47be-43c5-8fe4-dbdcc2d3e621", "InternalPackNumber"=>"302", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"758.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"302", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-09-29T21:12:54.91", "DateCreated"=>"2014-09-29T21:12:22.677", "Id"=>"18fd85be-6aaf-4aa8-b304-dcb9cc8efbf5", "InternalPackNumber"=>"MN268", "InventoryCode"=>"A1 Copper", "Location"=>"Warehouse 1", "NetWeight"=>"0.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>"Row B Left Column", "TagNumber"=>"268", "UnitOfMeasure"=>nil, "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-09-19T14:06:08.57", "DateCreated"=>"2014-09-19T14:06:08.48", "Id"=>"0998219e-a0af-4b92-912c-e025ac5013f0", "InternalPackNumber"=>"191", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"17.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"191", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-14T10:40:33.583", "DateCreated"=>"2014-05-14T10:40:26.663", "Id"=>"75724167-866f-4861-a49a-e10f2fd18ac2", "InternalPackNumber"=>"MN152", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"120.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"152", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-27T18:17:31.557", "DateCreated"=>"2014-08-27T18:17:23.303", "Id"=>"47bc552c-547c-409c-8b60-e1732b38b063", "InternalPackNumber"=>"MN239", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"5000.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"239", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T15:40:38.87", "DateCreated"=>"2015-09-30T15:40:38", "Id"=>"706e52ca-d314-47ec-9dbc-e2a062cc97fc", "InternalPackNumber"=>"MN535", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"145.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"535", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-05-13T16:58:22.517", "DateCreated"=>"2014-05-13T16:58:14.167", "Id"=>"52403382-9ed5-4505-ac64-e3ebc4206f65", "InternalPackNumber"=>"MN147", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"147", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2013-11-21T17:00:37.493", "DateCreated"=>"2013-11-21T17:00:29.997", "Id"=>"d758cf1b-5d17-42c5-bb50-e5c228e42375", "InternalPackNumber"=>"MN54", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"11.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"54", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-28T09:50:15", "DateCreated"=>"2014-08-28T09:50:06", "Id"=>"9a7de7bb-4966-48ae-8134-e7a37e1468c6", "InternalPackNumber"=>"MN250", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"4500.0000", "PrintDescription"=>"Flats Test", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"250", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T22:18:25.977", "DateCreated"=>"2014-10-07T22:18:25.883", "Id"=>"e691f1dc-32d5-439f-8f52-e9879ce67f55", "InternalPackNumber"=>"194", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"8.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"194", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T16:44:03.667", "DateCreated"=>"2015-12-08T16:44:03", "Id"=>"92a4efe7-88a2-4f69-ab9c-e9de630de4d6", "InternalPackNumber"=>"SY10", "InventoryCode"=>"316", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"316 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"10", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-10T19:08:16.523", "DateCreated"=>"2014-01-10T19:08:10.797", "Id"=>"a838a596-7bed-4a8f-9038-ea4123942626", "InternalPackNumber"=>"MN65", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"25.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"65", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-06-02T17:16:09.447", "DateCreated"=>"2014-06-02T17:15:57.327", "Id"=>"16d2a858-fed4-4a7d-92af-ead8ca825092", "InternalPackNumber"=>"MN182", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"9000.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"182", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-03-26T15:45:46.773", "DateCreated"=>"2014-03-26T15:45:31.7", "Id"=>"61f09b74-cde7-4541-9eff-ef57a9e1ead5", "InternalPackNumber"=>"MN104", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"85.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"104", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-08-28T09:07:44.81", "DateCreated"=>"2014-08-28T09:07:31.087", "Id"=>"46aa66fa-8641-474e-bd37-f18c6f7fcd5e", "InternalPackNumber"=>"MN244", "InventoryCode"=>"Flats", "Location"=>nil, "NetWeight"=>"4500.0000", "PrintDescription"=>"Flats", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"244", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-01-21T11:50:01.147", "DateCreated"=>"2014-01-21T11:49:45.097", "Id"=>"77736145-2d32-4e6e-bdc1-f24c99c7cd2e", "InternalPackNumber"=>"MN84", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"20.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"84", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-09T08:51:46.903", "DateCreated"=>"2014-10-09T08:51:34.197", "Id"=>"643c6061-6f89-45fd-8591-f2d3f1dd4ecd", "InternalPackNumber"=>"MN307", "InventoryCode"=>"A1 Copper", "Location"=>"Warehouse 1", "NetWeight"=>"4500.0000", "PrintDescription"=>"#1 CU", "Quantity"=>"0.00", "Row"=>"Row B Left Column", "TagNumber"=>"307", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T21:20:48.307", "DateCreated"=>"2014-10-07T21:20:48.22", "Id"=>"33bd3536-9708-4ed6-9074-f6da34421c53", "InternalPackNumber"=>"MN194", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"8.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"194", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-22T12:14:58.397", "DateCreated"=>"2014-10-22T12:14:48.28", "Id"=>"36555367-53a3-4f57-ae32-fc0f74b7b4a2", "InternalPackNumber"=>"MN359", "InventoryCode"=>"CPU Chips", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"CPU Chips", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"359", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2014-10-07T21:39:50.527", "DateCreated"=>"2014-10-07T21:39:50.503", "Id"=>"abea73e9-08a8-4edb-adcf-fdfebb50618e", "InternalPackNumber"=>"MN194", "InventoryCode"=>"A1 Copper", "Location"=>nil, "NetWeight"=>"8.0000", "PrintDescription"=>"#1 Copper", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"194", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}, {"Customer"=>"A Valued Customer", "CustomerId"=>"00000000-0000-0000-0000-000000000000", "DateClosed"=>"2015-09-30T15:28:00.33", "DateCreated"=>"2015-09-30T15:28:00", "Id"=>"6f0221b0-4e45-4eda-a4b1-fffd8e3ff7c9", "InternalPackNumber"=>"MN0", "InventoryCode"=>"UBC", "Location"=>nil, "NetWeight"=>"740.0000", "PrintDescription"=>"UBCs", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"0", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}]
  end
  
end