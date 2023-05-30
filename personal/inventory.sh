# bin/rails dev:betas:enable SHOP_ID=1 BETA=
bin/rails dev:products:create SHOP_ID=1 NUM=5 MIN_VARIANTS=5 MAX_VARIANTS=10
bin/rails dev:locations:create SHOP_ID=1 NUM=4
bin/rails dev:purchase_orders:create SHOP_ID=1 NUM=5 MAX_ITEMS=10
# bin/rails dev:inventory:movements:create SHOP_ID=1 NUM=5 MAX_ITEMS=10
