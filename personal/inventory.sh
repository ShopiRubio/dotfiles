# bin/rails dev:betas:enable SHOP_ID=1 BETA=double_sync_transfer_and_movements
# bin/rails dev:betas:enable SHOP_ID=1 BETA=inventory_transfers_on_movements
bin/rails dev:betas:enable SHOP_ID=1 BETA=purchase_orders
bin/rails dev:products:create SHOP_ID=1 NUM=5
bin/rails dev:locations:create SHOP_ID=1 NUM=4
bin/rails dev:purchase_orders:create SHOP_ID=1 NUM=5 MAX_ITEMS=10
# bin/rails dev:inventory:movements:create SHOP_ID=1 NUM=5 MAX_ITEMS=10
# bin/rails dev:transfers:create SHOP_ID=1 NUM=5 MAX_ITEMS=10
