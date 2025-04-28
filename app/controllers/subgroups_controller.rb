class SubgroupsController < ApplicationController
  before_action :set_round
  before_action :set_subgroup, only: [ :destroy ]

  def create
    # Registrar los parámetros recibidos para depuración
    Rails.logger.info "Params recibidos en create: #{params.inspect}"

    # Crear el subgrupo de forma simple
    @subgroup = Subgroup.new
    @subgroup.name = params[:subgroup][:name]
    @subgroup.round = @round

    if @subgroup.save
      Rails.logger.info "Subgrupo creado exitosamente: #{@subgroup.inspect}"
      redirect_to round_path(@round), notice: "Subgrupo creado exitosamente."
    else
      Rails.logger.error "Error al crear subgrupo: #{@subgroup.errors.full_messages.join(', ')}"
      redirect_to round_path(@round), alert: "Error al crear subgrupo: #{@subgroup.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    participants = Participant.where(subgroup_id: @subgroup.id)
    participants.each do |participant|
      participant.update(subgroup_id: nil, round_id: @round.id)
    end
    @subgroup.destroy
    redirect_to round_path(@round), notice: "Subgrupo eliminado exitosamente."
  end

  private

  def set_round
    @round = Round.find(params[:round_id])
  end

  def set_subgroup
    @subgroup = @round.subgroups.find(params[:id])
  end

  def subgroup_params
    params.require(:subgroup).permit(:name)
  end
end
