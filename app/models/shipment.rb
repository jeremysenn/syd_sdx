class Shipment < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :capture_seq_nbr, :blob_id, :camera_name, :camera_group, :sys_date_time, :location,
#    :branch_code, :cust_nbr, :event_code, :ticket_nbr, :contr_nbr, :booking_nbr, :container_nbr, :cust_name, :thumbnail

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'shipments_data'
  
  belongs_to :blob

   ### SEARCH WITH RANSACK ###
  def self.ransack_search(query, sort, direction)
    search = Shipment.ransack(query)
    search.sorts = "#{sort} #{direction}"
    shipments = search.result

    # Search through the mounted archives if any exists and current database doesn't return anything
#    if not MountedArchive.empty? and shipments.empty?
#      Shipment.search_mounted_archives(query)
#    end

    return shipments
  end

  ### SEARCH WITH RANSACK BY EXTERNAL/LAW USER ###
#  def self.ransack_search_external_user(query, sort, direction, customer_name)
#    search = Shipment.ransack(query)
#    search.sorts = "#{sort} #{direction}"
#    shipments = search.result
#
#    return shipments
#
#  end

  ### SEARCH WITH RANSACK BY EXTERNAL/LAW USER ###
  def self.ransack_search_external_user(query, sort, direction, customer_name)
    search = Shipment.ransack(query)
    search.sorts = "#{sort} #{direction}"
    shipments = []
    search.result.each do |shipment|
      if shipment.is_customer_shipment(customer_name)
        shipments << shipment
      end
    end

    return shipments
  end


  def jpeg_image
    blob.jpeg_image
  end

  def preview
    blob.preview
  end
  
  def jpeg_image_data_uri
    unless jpeg_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
    else
      nil
    end
  end
  
  def preview_data_uri
    unless preview.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview)}"
    else
      nil
    end
  end

  ### SEARCH ARCHIVES WITH RANSACK ###
  def self.search_mounted_archives(query)
    shipments = []
    MountedArchive.all.each do |mounted_archive|
      if mounted_archive.client_active? # Check to see if able to successfully connect to mounted archive database
        connect_database(mounted_archive)
        search = Shipment.ransack(query)
        shipments << search.result
      end
    end
    establish_connection :development
    return shipments
  end

  def is_customer_shipment(customer_name)
    Shipment.where(ticket_nbr: ticket_nbr, cust_name: customer_name).exists?
  end

#  def check_or_define_thumbnail
#    if thumbnail.blank?
#      unless Shipment.where(ticket_nbr: ticket_nbr, location: location, thumbnail: true).exists?
#        thumbnail_shipment = Shipment.where(ticket_nbr: ticket_nbr, location: location).first
#        thumbnail_shipment.update_attribute(:thumbnail, true)
#      end
#    end
#  end

#  def thumbnail_shipment
#    thumbnail_shipment = Shipment.where(ticket_nbr: ticket_nbr, thumbnail: true)
#    unless thumbnail_shipment.blank?
#      thumbnail_shipment.first
#    else
#      nil
#    end
#  end

  def self.api_find_all_by_shipment_number(shipment_number)
    require 'socket'
    host = ENV['JPEGGER_SERVICE']
    port = 3333
#    command = "fetch table=<shipments> ticket_nbr=<#{shipment_number}> rows=<100>!"
#    command = "fetch sql=<select * from shipments where ticket_nbr='#{shipment_number}'>rows=<100>!"
    command = "<FETCH><SQL>select * from shipments where ticket_nbr='#{shipment_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    socket = TCPSocket.open(host,port) # Connect to server
    socket.send(command, 0)
    
    sleep 2 # Give socket a little time to send, then receive
    
#    response = socket.recvfrom(port)
    response = socket.recvfrom(200000)
    socket.close
    
    data= Hash.from_xml(response.first) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No shipments found
    end
    
#    unless response.blank?
#      response_array = response.first.split(/\r\n/)
#      response_array -= ["EOF!"] # Remove EOF element from array
#      return response_array.collect {|e| e.scan( /<([^>]*)>/).first.first} # Return just an array of capture sequence numbers
#    else
#      return nil
#    end
    
  end
  
  def self.api_find_by_capture_sequence_number(capture_sequence_number)
    require 'socket'
    host = ENV['JPEGGER_SERVICE']
    port = 3333
    command = "<FETCH><SQL>select * from shipments where capture_seq_nbr='#{capture_sequence_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    socket = TCPSocket.open(host,port) # Connect to server
    socket.send(command, 0)
    response = socket.recvfrom(port)
    socket.close
    
    data= Hash.from_xml(response.first) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No shipment found
    end

  end

end