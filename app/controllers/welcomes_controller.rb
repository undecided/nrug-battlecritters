class WelcomesController < ApplicationController
  # Root URL - let me choose whether to be a player or server
  def index

  end

  # Warning: This is an ABUSE of restful routing.
  # I'm a player or server ;
  # Players: show me a list of servers to connect to (or let me input a new one)
  # Servers: wait for connections
  def new
    setup_current_server
    if @role == 'server'
      redirect_to boards_index_url
    else
      @other_servers = Server.where.not("hostname LIKE ?", "UUID%")
    end
  end

  # I'm a player; I have entered the server hostname
  def create
    Server.where(:current_role => 'server').each do |old_server|
      old_server.update_attribute :current_role, ''
    end

    Server.make_main(params[:server][:hostname])
    redirect_to gameplays_index_path(:uuid => params[:uuid])
  end

  def show

  end


  private

  def setup_current_server
    params[:server][:hostname] = @uuid
    permitted_params = params.permit(:server => [:current_role, :hostname])
    @role = params[:server][:current_role]
    if @role == 'server'
      # Reset everything!
      Board.delete_all
      Server.all.each do |old_server|
        old_server.update_attribute :current_role, ''
        old_server.update_attribute :winner, false
        old_server.update_attribute :loser, false
      end
    end
    Server.find_or_create_by permitted_params[:server]
  end
end
