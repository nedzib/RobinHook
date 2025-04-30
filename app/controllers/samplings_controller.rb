class SamplingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]
  before_action :set_round
  before_action :set_subgroup, only: [ :create ], if: -> { params[:subgroup_id].present? }

  def create
    if @subgroup
      # Muestreo por equipo
      @sampler = RoundRobinSamplerService.new(@subgroup)
      @participant = @sampler.sample
      source = "del equipo #{@subgroup.name}"
    else
      # Muestreo global
      @sampler = GlobalRoundRobinSamplerService.new(@round)
      @participant = @sampler.sample
      source = "global"
    end

    if @participant
      if params[:pr_url].present? && @round.web_hook.present?
        message = "#{@participant.name} ha sido seleccionado (#{source}) para revisar el PR: #{params[:pr_url]}"
        notifier = WebhookNotificationService.new(@round.web_hook)
        notifier.send_notification(message)
        flash[:notice] = "#{@participant.name} ha sido seleccionado y se ha enviado la notificación."
      else
        flash[:notice] = "#{@participant.name} ha sido seleccionado."
      end
    else
      flash[:alert] = "No hay participantes disponibles."
    end

    respond_to do |format|
      format.html do
        # Determinar si la solicitud viene de la vista pública
        is_public_view = params[:public_view] == "true"
        
        # Redirigir a la vista pública o privada según corresponda
        if is_public_view
          redirect_to rounds_public_path(hash_id: @round.hash_id)
        else
          redirect_to round_path(@round)
        end
      end
      format.js
    end
  end

  private

  def set_round
    @round = Round.find(params[:round_id])
  end

  def set_subgroup
    @subgroup = @round.subgroups.find(params[:subgroup_id])
  end
end
