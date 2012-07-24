class FulfillmentJob
  @queue = :default

  LOGIN_CREDENTIALS = {:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true}

  def self.perform(fulfillment_id)
    fulfillment = Fulfillment.includes(:line_items, :shop, :tracker).find(fulfillment_id)
    line_items = fulfillment.line_items.map(&:attributes)
    options = {
      warehouse: fulfillment.warehouse,
      email: fulfillment.email,
      shipping_method: fulfillment.shipping_method
    }
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(LOGIN_CREDENTIALS)
    response = shipwire.fulfill(fulfillment.tracker.shipwire_order_id, fulfillment.order.shipping_address, line_items, options)
    response.success? ? fulfillment.success : fulfillment.record_failure
  end
end