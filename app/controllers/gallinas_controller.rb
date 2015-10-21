class GallinasController < ApplicationController
  before_action :set_gallina, only: [:show, :edit, :update, :destroy]

  # GET /gallinas
  # GET /gallinas.json
  def index
    @gallinas = Gallina.all
  end

  # GET /gallinas/1
  # GET /gallinas/1.json
  def show
    @current_user_is_member = false
    if @gallina.users.include?(current_user)
      @current_user_is_member = true
    end
  end

  # GET /gallinas/new
  def new
    @gallina = Gallina.new
  end

  # GET /gallinas/1/edit
  def edit
  end

  # POST /gallinas
  # POST /gallinas.json
  def create
    @gallina = Gallina.new(gallina_params)

    respond_to do |format|
      if @gallina.save
        gallina_member = GallinaMember.new
        gallina_member.gallina_id = @gallina.id
        gallina_member.user_id = current_user.id
        gallina_member.save
        format.html { redirect_to @gallina, notice: 'Gallina was successfully created.' }
        format.json { render :show, status: :created, location: @gallina }
      else
        format.html { render :new }
        format.json { render json: @gallina.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gallinas/1
  # PATCH/PUT /gallinas/1.json
  def update
    if !@gallina.users.include?(current_user)
      redirect_to @gallina
      return
    end
    respond_to do |format|
      if @gallina.update(gallina_params)
        format.html { redirect_to @gallina, notice: 'Gallina was successfully updated.' }
        format.json { render :show, status: :ok, location: @gallina }
      else
        format.html { render :edit }
        format.json { render json: @gallina.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gallinas/1
  # DELETE /gallinas/1.json
  def destroy
#    @gallina.destroy
#    respond_to do |format|
#      format.html { redirect_to gallinas_url, notice: 'Gallina was successfully destroyed.' }
#      format.json { head :no_content }
#    end
  end

  def invite
    @gallina = Gallina.find_by_id(params[:id])
    @invited = User.find_by_id(params[:invited_id])

    if !@gallina.users.include?(current_user)
      redirect_to @gallina
      return
    end

    if @invited && @gallina.users.include?(current_user)  && !@gallina.users.include?(@invited)
      gallina_member = GallinaMember.new
      gallina_member.gallina_id = @gallina.id
      gallina_member.user_id = @invited.id
      gallina_member.save
    end
  end

  def review_submission
    @gallina = Gallina.find_by_id(params[:gallina_id])
    @reviewed = User.find_by_id(params[:user_id])
  end

  def reviewed
    reviewer_id = current_user.id
    reviewed_id = params[:reviewed_id]

    if !Question.find_by_id(params[:questions].first.first).metric.gallina.users.include?(current_user)
      redirect_to Question.find_by_id(params[:questions].first.first).metric.gallina
      return
    end

    params[:questions].each do |question|
      review = Review.new
      review.reviewer_id = reviewer_id
      review.reviewed_id = reviewed_id
      review.question_id = question.first
      review.grade = question.second
      review.save
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gallina
      @gallina = Gallina.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gallina_params
      params.require(:gallina).permit(:name, :description)
    end
end
