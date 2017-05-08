class PacksController < ApplicationController
  before_filter :login_required  

  # GET /packs
  # GET /packs.json
  def index
    authorize! :index, :packs
#    @packs = current_user.packs
#    @packs = Yard.packs(current_yard_id)
     @status = "#{params[:status].blank? ? '0' : params[:status]}"
#     @packs = Kaminari.paginate_array(Pack.test_array).page(params[:page]).per(10)
    @packs = Kaminari.paginate_array(Pack.all(current_user.token, current_yard_id, @status)).page(params[:page]).per(10)
  end

  # GET /packs/1
  # GET /packs/1.json
  def show
    authorize! :show, :packs
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack = Pack.find_by_id(current_user.token, current_yard_id, @status, params[:id])
#    @pack = {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T18:56:03.177", "DateCreated"=>"2015-12-08T18:56:03", "Id"=>"07043fd5-525e-4568-b54a-0c3d17c5ca99", "InternalPackNumber"=>"OY624", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"624", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack['PrintDescription']} } 
    end
  end

  # GET /packs/new
  def new
  end

  # GET /packs/1/edit
  def edit
    authorize! :edit, :packs
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack = Pack.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST /packs
  # POST /packs.json
  def create
    @pack = Pack.new(pack_params)

    respond_to do |format|
      if @pack.save
        format.html { 
          flash[:success] = 'Pack was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @pack
        }
        format.json { render :show, status: :created, location: @pack }
      else
        format.html { render :new }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packs/1
  # PATCH/PUT /packs/1.json
  def update
    @pack = Pack.update(current_user.token, current_yard_id, pack_params)
    respond_to do |format|
      format.html {
        if @pack == 'true'
          flash[:success] = 'Pack List was successfully updated.'
        else
          flash[:danger] = 'Error updating Pack List.'
        end
        redirect_to packs_path
      }
    end
  end

  # DELETE /packs/1
  # DELETE /packs/1.json
  def destroy
    @pack.destroy
    respond_to do |format|
      format.html { redirect_to packs_url, notice: 'Pack was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack
      @pack = Pack.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_params
      params.require(:pack).permit(:id, :description, :quantity, :net)
    end
end