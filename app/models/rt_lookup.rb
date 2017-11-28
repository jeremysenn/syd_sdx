class RtLookup < ActiveRecord::Base
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.api_find_all_by_ticket_number(ticket_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from rt_lookup where ticket_nbr='#{ticket_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    
    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
#    Rails.logger.debug "***********RtLookup.api_find_all_by_ticket_number response: #{response}"
    
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return [] # No rt_lookups found
    end

  end
  
end

