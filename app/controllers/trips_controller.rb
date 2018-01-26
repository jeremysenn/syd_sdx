class TripsController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET /trips
  # GET /trips.json
  def index
    authorize! :index, :trips
    @dispatch_information = Trip.dispatch_info_by_user_guid(current_user.token)
    @trips = Trip.all_trips(@dispatch_information)
#    @trucks = Trip.all_trucks(@dispatch_information)
    @containers = Container.all_by_dispatch_information(@dispatch_information)
    @task_functions = Trip.task_functions(@dispatch_information)
    @container_types = Trip.container_types(@dispatch_information)
  end
  
  # GET /trips/1
  # GET /trips/1.json
  def show
    authorize! :show, :trips
    @trip = Trip.find(current_user.token, params[:id])
    @tasks = Trip.tasks(@trip)
  end

  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def trip_params
      params.require(:trip).permit(:id, :description, :quantity, :net)
    end
end
