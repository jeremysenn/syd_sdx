class CommoditiesController < ApplicationController
  before_filter :login_required
#  before_action :set_commodity, only: [:show, :edit, :update, :destroy]

  # GET /commodities
  # GET /commodities.json
  def index
    unless params[:q].blank?
      results = Commodity.search(current_token, current_yard_id, params[:q])
      if results.class == 'Hash'
        single_commodity_hash = results
        results = []
        results << single_commodity_hash
      end
    else
      results = Commodity.all(current_token, current_yard_id)
    end
    unless results.blank?
      @commodities = Kaminari.paginate_array(results).page(params[:page]).per(10)
    else
      @commodities = []
    end
  end

  # GET /commodities/1
  # GET /commodities/1.json
  def show
    @commodity = Commodity.find_by_id(current_token, current_yard_id, params[:id])
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @commodity['MenuText'], "price" => @commodity['ScalePrice']} } 
    end
  end

  # GET /commodities/new
  def new
    @commodity = Commodity.new
  end

  # GET /commodities/1/edit
  def edit
    @commodity = Commodity.find_by_id(current_token, current_yard_id, params[:id])
  end

  # POST /commodities
  # POST /commodities.json
  def create
    @commodity = Commodity.new(commodity_params)

    respond_to do |format|
      if @commodity.save
        format.html { redirect_to @commodity, notice: 'Commodity was successfully created.' }
        format.json { render :show, status: :created, location: @commodity }
      else
        format.html { render :new }
        format.json { render json: @commodity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commodities/1
  # PATCH/PUT /commodities/1.json
  def update
    respond_to do |format|
      if @commodity.update(commodity_params)
        format.html { redirect_to @commodity, notice: 'Commodity was successfully updated.' }
        format.json { render :show, status: :ok, location: @commodity }
      else
        format.html { render :edit }
        format.json { render json: @commodity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commodities/1
  # DELETE /commodities/1.json
  def destroy
    @commodity.destroy
    respond_to do |format|
      format.html { redirect_to commodities_url, notice: 'Commodity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commodity
      @commodity = Commodity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commodity_params
      params.require(:commodity).permit(:commodityname, :password)
    end
end
