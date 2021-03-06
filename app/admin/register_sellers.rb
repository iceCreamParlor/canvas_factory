ActiveAdmin.register RegisterSeller do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  permit_params :user_id, { images: [] }

  form(html: { multipart: true }) do |f|
    f.inputs do
      f.input :user, :as => :select, :collection => User.all.collect {|user| [user.nickname, user.id] }
      f.label :images
      f.file_field :images, multiple: true
    end
    f.actions
  end
  index do
    column :user
    column :is_confirmed
    
    column("작가승인") { |register_seller| 
      user = register_seller.user
      if user.user_type != "seller"
        link_to "승인", accept_seller_profile_path(user), remote: "true" if user.user_type != "seller"
      else
        link_to "취소", cancel_seller_profile_path(user), remote: "true" if user.user_type == "seller"
      end
    }
    actions
  end

  show do
    default_main_content
    # renders app/views/admin/posts/_some_partial.html.erb
    render 'seller_images', { register_seller: register_seller }
  end
  
end
