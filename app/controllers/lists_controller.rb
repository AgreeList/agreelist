class ListsController < ApplicationController
  before_action :admin_required, only: [:new, :edit, :create, :update, :destroy]
  before_action :set_list, only: [:show, :edit, :update, :destroy, :create_statement]

  # GET /lists
  def index
    @lists = List.all
  end

  # GET /lists/1
  def show
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  def create
    @list = List.new(list_params)

    if @list.save
      redirect_to @list, notice: 'List was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      redirect_to @list, notice: 'List was successfully updated.'
    else
      render :edit
    end
  end

  def create_statement
    if @list.statements.create(content: params[:statement_content], individual: current_user)
      redirect_to @list, notice: "Statement created"
    else
      render :edit
    end
  end

  # DELETE /lists/1
  def destroy
    @list.destroy
    redirect_to lists_url, notice: 'List was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def list_params
      params.require(:list).permit(:name, :url)
    end
end
