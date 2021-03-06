ActiveAdmin.register User do

  filter :user_type, as: :select, collection: User.user_types
  filter :email
  filter :nickname
  filter :instagram

  permit_params :email, :nickname, :image, :desc, :instagram, :user_type
  index :as => :table do

    
    selectable_column
    id_column
    column :email
    column :user_type
    column :nickname
    # column :instagram
    column() {|user| link_to "#{ user.instagram }", user.instagram if user.instagram.present? }
    column("작가승인") { |user| 
      if user.user_type != "seller"
        link_to "승인", accept_seller_profile_path(user), remote: "true" if user.user_type != "seller"
      else
        link_to "취소", cancel_seller_profile_path(user), remote: "true" if user.user_type == "seller"
      end
    }
    actions default: true do |obj|
    
    end
  end
end
