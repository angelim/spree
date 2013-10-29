module Spree
  module Admin
    class ImagesController < ResourceController
      before_filter :load_data

      create.before :set_viewable
      update.before :set_viewable
      destroy.before :destroy_before

      def update_positions
        params[:positions].each do |id, index|
          Image.where(:id => id).update_all(:position => index)
        end

        respond_to do |format|
          format.js  { render :text => 'Ok' }
        end
      end

      private
  
      def location_after_save
        admin_product_images_url(@product)
      end

      def load_data
        @product = Product.find_by_permalink(params[:product_id])
        @variants = @product.variants.collect do |variant|
          [variant.options_text, variant.id ]
        end
        @variants.insert(0, [I18n.t(:all), 'All'])
      end

      def set_viewable
        viewable_id = params[:image].has_key?(:viewable_id) && params[:image].delete(:viewable_id)
        if viewable_id
          if viewable_id == "All"
            @image.viewable = @product
          else
            @image.viewable_type = 'Spree::Variant'
            @image.viewable_id = viewable_id
          end
        else
          @image.viewable = @product
        end
      end

      def destroy_before
        @viewable = @image.viewable
      end

    end
  end
end
