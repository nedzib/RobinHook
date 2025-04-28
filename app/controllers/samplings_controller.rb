class SamplingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  before_action :set_subgroup
  
  def create
    @sampler = RoundRobinSamplerService.new(@subgroup)
    @participant = @sampler.sample
    
    if @participant
      if params[:pr_url].present? && @round.web_hook.present?
        message = "#{@participant.name} ha sido seleccionado para revisar el PR: #{params[:pr_url]}"
        notifier = WebhookNotificationService.new(@round.web_hook)
        notifier.send_notification(message)
        flash[:notice] = "#{@participant.name} ha sido seleccionado y se ha enviado la notificación."
      else
        flash[:notice] = "#{@participant.name} ha sido seleccionado."
      end
    else
      flash[:alert] = "No hay participantes disponibles en este equipo."
    end
    
    respond_to do |format|
      format.html { redirect_to round_path(@round) }
      format.js
    end
  end
  
  private
  
  def set_subgroup
    @round = Round.find(params[:round_id])
    @subgroup = @round.subgroups.find(params[:subgroup_id])
  end
end
