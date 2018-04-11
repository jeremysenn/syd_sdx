class TicketItemsController < ApplicationController
  before_filter :login_required  

  
  def save_vin
    respond_to do |format|
      format.json { 
        @save_vin_response = TicketItem.save_vin(current_user.token, current_yard_id, params[:id], params[:year], params[:make_id], params[:model_id], 
          params[:body_id], params[:color_id], params[:vehicle_id_number])
        if @save_vin_response["Success"] == "true"
          render json: {"success" => "true"}, status: :ok
        elsif @save_vin_response["Success"] == "false"
          render json: {"success" => "false", "failure_information" => @save_vin_response["FailureInformation"]}, status: :ok
        else
          render json: {error: 'Error saving ticket item VINs information'}, status: :unprocessable_entity
        end
        }
    end
  end
  
  def quick_add
    respond_to do |format|
      format.html {}
      format.json {
        @ticket_item_quick_add_response = TicketItem.quick_add(current_user.token, current_yard_id, params[:id], params[:ticket_id], 
          params[:commodity_id], params[:commodity_name], params[:price])
        if @ticket_item_quick_add_response == 'true'
          render json: {}, :status => :ok
        else
          render json: {}, status: :unprocessable_entity
        end
      }
    end
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_item_params
      params.require(:ticket_item).permit(:id)
    end
end