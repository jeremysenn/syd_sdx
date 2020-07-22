class CustomersController < ApplicationController
  before_filter :login_required
#  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    authorize! :index, :customers
    unless current_user.mobile_greeter?
      @yard_filter = "#{params[:yard_filter].blank? ? 'all_yards' : params[:yard_filter]}" # Default yard filter to all yards
    else
      @yard_filter = '1\my_yard' # Default yard filter to my yard for mobile_greeter
    end
    unless params[:q].blank?
      if @yard_filter == 'all_yards'
        @search = Customer.search(current_user.token, current_yard_id, params[:q])
      else
        @search = Customer.search_by_yard(current_user.token, current_yard_id, params[:q])
      end
    else
#      if @yard_filter == 'all_yards'
#        @search = Customer.all(current_user.token, current_yard_id)
#      else
#        @search = Customer.all_by_yard(current_user.token, current_yard_id)
#      end
    end
    respond_to do |format|
      format.html {
        unless @search.blank?
          @customers = Kaminari.paginate_array(@search).page(params[:page]).per(10)
        else
#          redirect_to new_customer_path(first_name: params[:first_name], last_name: params[:last_name], license_number: params[:license_number], dob: params[:dob],
#            sex: params[:sex], issue_date: params[:issue_date], expiration_date: params[:expiration_date], streetaddress: params[:streetaddress], city: params[:city], state: params[:state], zip: params[:zip])
          @customers = []
        end
      }
      format.json {
#        @customers = Kaminari.paginate_array(results).page(params[:page]).per(10)
#        render json: @customers.map{|c| c['Id']}
#        @customers = results.map {|customer| ["#{customer['FirstName']} #{customer['LastName']}", customer['Id']]}
        unless @search.blank?
          @customers = @search.collect{ |customer| {id: customer['Id'], text: "#{customer['FirstName']} #{customer['LastName']} #{customer['Company']}"} }
        else
          @customers = nil
        end
        Rails.logger.info "results: {#{@customers}}"
        render json: {results: @customers}
      }
      format.js {
        unless @search.blank?
          @customers = Kaminari.paginate_array(@search).page(params[:page]).per(10)
        else
          redirect_to new_customer_path(first_name: params[:first_name], last_name: params[:last_name], license_number: params[:license_number], dob: params[:dob],
            sex: params[:sex], issue_date: params[:issue_date], expiration_date: params[:expiration_date], streetaddress: params[:streetaddress], city: params[:city], state: params[:state], zip: params[:zip])
          @customers = []
        end
      }
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    authorize! :show, :customers
    
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
#    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], yardid: current_yard_id) if CustPic.table_exists?
    @cust_pics_array = CustPic.api_find_all_by_customer_number(params[:id], current_user.company, current_yard_id).reverse # Customer images
    @customer_user = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id).last
    @customer_users = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id)
#    @paid_tickets = Ticket.search(3, current_user.token, current_yard_id, "#{@customer['Company']}")
    @paid_tickets = Customer.paid_tickets(current_user.token, current_yard_id, params[:id])
    @closed_tickets = Customer.closed_tickets(current_user.token, current_yard_id, params[:id])
    workorders = Workorder.all_by_customer(current_user.token, current_yard_id, params[:id])
    @workorders = Kaminari.paginate_array(workorders).page(params[:page]).per(5) unless workorders.blank?
  end

  # GET /customers/new
  def new
    authorize! :create, :customers
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
    authorize! :edit, :customers
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
    @customer_user = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id).last
    @customer_users = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id)
    @new_user = User.new
#    if @customer_user.blank?
#      @new_user = User.new
#    end
  end

  # POST /customers
  # POST /customers.json
  def create
#    @customer = Customer.new(customer_params)
    create_customer_response = Customer.create(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if create_customer_response["Success"] == 'true'
          flash[:success] = 'Customer was successfully created.'
          redirect_to customer_path(create_customer_response['Item']['Id'])
#          redirect_to customers_path
        else
          flash[:danger] = 'Error creating customer.'
          redirect_to customers_path
        end
      }
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    create_customer_response = Customer.update(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if create_customer_response["Success"] == 'true'
          flash[:success] = 'Customer was successfully updated.'
        else
          flash[:danger] = 'Error updating customer.'
        end
        redirect_to customer_path(customer_params[:id])
      }
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_ticket
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
#    @ticket_number = Ticket.next_available_number(current_user.token, current_yard_id)
    @guid = SecureRandom.uuid
    @ticket = Ticket.create(current_user.token, current_yard_id, @customer['Id'], @guid, params[:related_workorder_id])
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket was successfully created.'
        redirect_to edit_ticket_path(@guid, status: 2, commodity_id: params[:commodity_id], created_from_trip: params[:related_workorder_id].blank? ? nil : true) 
        }
    end
  end
  
  # GET /customers/service_requests
  def service_requests
    if current_user.customer? and not current_user.customer_guid.blank?
      workorders = Workorder.all_by_customer(current_user.token, current_yard_id, current_user.customer_guid)
      @workorders = Kaminari.paginate_array(workorders).page(params[:page]).per(5) unless workorders.blank?
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:id, :first_name, :last_name, :company, :phone, :email, :address_1, :address_2, :city, :state, :zip, :tax_collection, 
        :id_number, :id_expiration, :id_state)
    end
end
