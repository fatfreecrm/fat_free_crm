# frozen_string_literal: true

class Inventory::CheckoutController < ApplicationController
  before_action :require_user

  # GET /inventory/checkout
  # Main checkout page with barcode scanner
  #----------------------------------------------------------------------------
  def index
    @recent_checkouts = Sample.checked_out
                              .where(checked_out_by: current_user.id)
                              .order(checked_out_at: :desc)
                              .limit(10)
  end

  # POST /inventory/checkout/scan
  # Process barcode scan and return sample data
  #----------------------------------------------------------------------------
  def scan
    @sample = find_sample_by_code(params[:code])

    respond_to do |format|
      if @sample
        format.json { render json: sample_json(@sample) }
        format.js
      else
        format.json { render json: { error: 'Sample not found', code: params[:code] }, status: :not_found }
        format.js { render :not_found }
      end
    end
  end

  # POST /inventory/checkout/process
  # Process checkout for a sample
  #----------------------------------------------------------------------------
  def process_checkout
    @sample = find_sample_by_code(params[:code])

    respond_to do |format|
      if @sample
        if @sample.status == 'available'
          @sample.checkout!(current_user)
          format.json { render json: { success: true, message: 'Sample checked out successfully', sample: sample_json(@sample) } }
          format.js { render :checkout_success }
        else
          format.json { render json: { error: 'Sample is not available for checkout', status: @sample.status }, status: :unprocessable_entity }
          format.js { render :checkout_error }
        end
      else
        format.json { render json: { error: 'Sample not found', code: params[:code] }, status: :not_found }
        format.js { render :not_found }
      end
    end
  end

  # POST /inventory/checkout/return
  # Process return/checkin for a sample
  #----------------------------------------------------------------------------
  def process_return
    @sample = find_sample_by_code(params[:code])

    respond_to do |format|
      if @sample
        if @sample.status == 'checked_out'
          @sample.checkin!
          format.json { render json: { success: true, message: 'Sample returned successfully', sample: sample_json(@sample) } }
          format.js { render :return_success }
        else
          format.json { render json: { error: 'Sample is not checked out', status: @sample.status }, status: :unprocessable_entity }
          format.js { render :return_error }
        end
      else
        format.json { render json: { error: 'Sample not found', code: params[:code] }, status: :not_found }
        format.js { render :not_found }
      end
    end
  end

  # GET /inventory/checkout/lookup/:code
  # Lookup sample by QR code or SKU
  #----------------------------------------------------------------------------
  def lookup
    @sample = find_sample_by_code(params[:code])

    respond_to do |format|
      if @sample
        format.html { redirect_to @sample }
        format.json { render json: sample_json(@sample) }
      else
        format.html { redirect_to inventory_checkout_path, alert: "Sample not found: #{params[:code]}" }
        format.json { render json: { error: 'Sample not found' }, status: :not_found }
      end
    end
  end

  private

  def find_sample_by_code(code)
    return nil if code.blank?

    # Try to find by QR code first, then SKU, then bundle QR code
    Sample.find_by(qr_code: code) ||
      Sample.find_by(sku: code) ||
      find_sample_by_bundle_qr(code)
  end

  def find_sample_by_bundle_qr(code)
    bundle = Bundle.find_by(qr_code: code)
    bundle&.samples&.available&.first
  end

  def sample_json(sample)
    {
      id: sample.id,
      name: sample.name,
      full_name: sample.full_name,
      brand: sample.brand,
      location: sample.location,
      qr_code: sample.qr_code,
      sku: sample.sku,
      tiktok_affiliate_link: sample.tiktok_affiliate_link,
      has_fire_sale: sample.has_fire_sale,
      best_price: sample.best_price,
      original_price: sample.original_price,
      discount_percentage: sample.discount_percentage,
      status: sample.status,
      description: sample.description,
      picture_url: sample.picture.attached? ? url_for(sample.picture) : nil,
      bundle: sample.bundle ? { id: sample.bundle.id, name: sample.bundle.name, qr_code: sample.bundle.qr_code } : nil,
      checked_out_at: sample.checked_out_at,
      checked_out_by: sample.checked_out_user&.name
    }
  end
end
