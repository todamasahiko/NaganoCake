class AddMemberIdToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :member_id, :integer
  end
end
