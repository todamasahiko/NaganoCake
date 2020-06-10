class Public::OrdersController < ApplicationController
  before_action :authenticate_member!
  before_action :request_post?, only: [:confirm]

  def index
    @orders = current_member.orders
  end

  def show
    @order = Order.find(params[:id]) #order特定
    @order_item = @order.order_items #特定したorserからorder_items全部取得
    @total = 0 #変数提議　合計を計算する変数
  end

  def new

    # jsjgjgjgjg
    @i = current_member.cart_items
    @all = Item.all
    @i.each do |item|
      @all = @all.where.not(id:  item.item_id)
  end
    @item_random = @all.order("RANDOM()").limit(6)
    # lkdjkljkljdfkgj


    @order = Order.new
    @address = Address.new
  end

  def confirm
    params[:order][:payment_method] = params[:order][:payment_method].to_i #payment_methodの数値に変換
    @order = Order.new(order_params) #情報を渡している
  #分岐
    if params[:order][:address_number] == "1" #address_numberが　”1”　なら下記　ご自身の住所が選ばれたら
      @order.postal_code = current_member.postal_code #自身の郵便番号をorderの郵便番号に入れる
      @order.address = current_member.address #自身の住所をorderの住所に入れる
      @order.name = current_member.last_name+current_member.first_name #自身の宛名をorderの宛名に入れる

    elsif  params[:order][:address_number] ==  "2" #address_numberが　”2”　なら下記　登録済からの選択が選ばれたら
      @order.postal_code = Address.find(params[:order][:address]).postal_code #newページで選ばれた配送先住所idから特定して郵便番号の取得代入
      @order.address = Address.find(params[:order][:address]).shipping_address #newページで選ばれた配送先住所idから特定して住所の取得代入
      @order.name = Address.find(params[:order][:address]).name #newページで選ばれた配送先住所idから特定して宛名の取得代入

    elsif params[:order][:address_number] ==  "3" #address_numberが　”3”　なら下記　新しいお届け先が選ばれたら
      @address = Address.new() #変数の初期化
      @address.shipping_address = params[:order][:shipping_address] #newページで新しいお届け先に入力した住所を取得代入
      @address.name = params[:order][:name] #newページで新しいお届け先に入力した宛名を取得代入
      @address.postal_code = params[:order][:postal_code] #newページで新しいお届け先に入力した郵便番号を取得代入
      @address.member_id = current_member.id #newページで新しいお届け先に入力したmember_idを取得代入
      if @address.save #保存
      @order.postal_code = @address.postal_code #上記で代入された郵便番号をorderに代入
      @order.name = @address.name #上記で代入された宛名をorderに代入
      @order.address = @address.shipping_address #上記で代入された住所をorderに代入
      else
       render 'new'
       end
  end

    @cart_items = CartItem.where(member_id: current_member.id) #自身のカートから買った商品情報を取得代入
    @total = 0 ##変数提議　合計を計算する変数
  end


  def thanks
    #購入確定後のページ表示
  end

  def create
    @order = Order.new(order_params) #初期化代入
    @order.member_id = current_member.id #自身のidを代入
    @order.save #orderに保存
#order_itmemの保存
current_member.cart_items.each do |cart_item| #カートの商品を1つずつ取り出しループ
  @order_item = OrderItem.new #初期化宣言
  @order_item.item_id = cart_item.item_id #商品idを注文商品idに代入
  @order_item.number_of_items = cart_item.number_of_items #商品の個数を注文商品の個数に代入
  @order_item.items_tax_included_price = (cart_item.item.unit_price_without_tax*1.1).floor #消費税込みに計算して代入
  @order_item.order_id =  @order.id #注文商品に注文idを紐付け
  @order_item.save #注文商品を保存
end #ループ終わり

    current_member.cart_items.destroy_all #カートの中身を削除
    redirect_to public_orders_thanks_path #thanksに遷移

end

  private

  def request_post?
    redirect_to new_public_order_path, notice: "もう一度最初から入力してください。" unless request.post?
  end

  def order_params
    params.require(:order).permit(:payment_method, :address, :postage, :postal_code, :name, :total_fee, :addre)
  end

  def address_params
    params.permit(:shipping_address, :name, :postal_code, :member_id)
  end
  # :name,:postal_code,
end

# 頭よくなればできる sessionを用いた購入確定
  # def session_create
  #   session[:order] = Order.new()
  #   session[:order] = params
  # if session[:order][:address_number] == 1
  #   session[:order][:postal_code] = current_member.postal_code
  #   session[:order][:address] = current_member.address
  #   session[:order][:name] = current_member.last_name+current_member.first_name

  # elsif  session[:order][:address_number] ==  2
  #   session[:order][:address] = Address.find(id: :address)
  # end


  #   session[:order][:payment_method] = params[:order][:payment_method].to_i
  #   redirect_to  public_orders_confirm_path
     # session[:order].clear 「sessionのデータ解放」
  # end