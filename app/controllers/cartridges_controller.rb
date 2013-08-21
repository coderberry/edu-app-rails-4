class CartridgesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    user = current_user
    user ||= User.with_access_token(params[:token]) if params[:token].present?
    if user
      render json: user.cartridges
    else
      render json: { cartridges: [] }
    end
  end

  def show
    if params[:id] == 'new'
      render json: {}, status: 200
    else
      cartridge = Cartridge.where(uid: params[:uid]).first
      if cartridge
        render json: cartridge
      else
        render json: {}, status: 404
      end
    end
  end

  # This method accepts a JSON post and will extract the title out from the JSON
  def create
    cartridge = current_user.cartridges.build({
      name: params[:name],
      xml: params[:xml]
    })
    if cartridge.save
      render json: cartridge, status: 201
    else
      render json: { errors: cartridge.errors }, status: 422
    end
  end

  def update
    cartridge = current_user.cartridges.where(uid: params[:uid]).first
    if cartridge
      cartridge.name = params[:name]
      cartridge.xml = params[:xml]
      if cartridge.save
        render json: cartridge, status: 200
      else
        render json: { errors: cartridge.errors }, status: 422
      end
    else
      render json: {}, status: 404
    end
  end

  def destroy
    uid = params[:cartridge][:uid]
    cartridge = current_user.cartridges.where(uid: uid).first
    if cartridge
      cartridge.destroy
      head 200
    else
      head 404
    end
  end

  def import
    cartridge = current_user.cartridges.create_from_url(params[:url])
    if cartridge
      if !cartridge.new_record?
        render json: cartridge, status: 201
      else
        render json: { errors: cartridge.errors }, status: 422
      end
    else
      head 500
    end
  end

  def create_from_xml
    cartridge = current_user.cartridges.create_from_xml(params[:xml])
    if cartridge
      if !cartridge.new_record?
        render json: cartridge, status: 201
      else
        render json: { errors: cartridge.errors }, status: 422
      end
    else
      head 500
    end
  end

  def xml
    cartridge = Cartridge.where(uid: params[:uid]).first
    if cartridge
      tool_config = IMS::LTI::ToolConfig.create_from_xml(cartridge.xml)
      render xml: tool_config.to_xml
    else
      head 404
    end
  end
end
