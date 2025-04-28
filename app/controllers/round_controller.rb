class RoundController < ApplicationController
  skip_before_action :authenticate_user!, only: [:public_show]
  def index
    @rounds = Round.all
  end

  def new
    @round = Round.new
  end

  def create
    @round = Round.new(round_params)
    @round.user = current_user
    
    if @round.save
      redirect_to rounds_path, notice: 'Ronda creada exitosamente.'
    else
      render :new
    end
  end

  def show
    @round = Round.find(params[:id])
    @public_view = false
  end
  
  def public_show
    @round = Round.find_by!(hash_id: params[:hash_id])
    @public_view = true
    render :show
  end

  def edit
    @round = Round.find(params[:id])
  end

  def update
    @round = Round.find(params[:id])
    
    if @round.update(round_params)
      redirect_to rounds_path, notice: 'Ronda actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @round = Round.find(params[:id])
    @round.destroy
    
    redirect_to rounds_path, notice: 'Ronda eliminada exitosamente.'
  end

  private

  def round_params
    params.require(:round).permit(:name, :web_hook)
  end
end
