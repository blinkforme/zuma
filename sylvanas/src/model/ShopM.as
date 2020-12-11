package model
{


import control.UserInfoC;

import manager.GameEvent;
import manager.GameEventDispatch;
import control.WxShareC;
import manager.ApiManager;
import view.shop.ShopPage;


    public class ShopM
    {
        private static var _instance:ShopM;

        private var _useSkinId :Number = 0;
        private var _buySkinId :Array = [];
        public var _itemList :Array = [];

        public function ShopM()
        {

        }

        public static function get instance():ShopM
        {
            return _instance || (_instance = new ShopM());
        }

        public function get useSkinId():Number
        {
            return _useSkinId;
        }

        public function set useSkinId(value:Number):void
        {
            _useSkinId = value;
        }

        public function get buySkinId():Array
        {
            return _buySkinId;
        }

        public function set buySkinId(value:Array)
        {
            _buySkinId = value;
        }


        public function requestShopList():void
        {
            var url:String = '/exchange_list?token=' + LoginInfoM.instance.token;
            var params:String = 'token=' + LoginInfoM.instance.token;

            ApiManager.instance.base_request(url, params, 'GET', shopListComplete);
        }

        public function shopListComplete(res):void
        {
            if (res.code == 'success') {
                _itemList = res.data
                GameEventDispatch.instance.event(GameEvent.InitShop);
            }
        }

        //购买皮肤
        public function exchangeSkinItem(itemId:int):void
        {
            var itemId = itemId;
            var url:String = '/exchange';
            var params:String = 'token=' + LoginInfoM.instance.token + '&goods_id=' + itemId;

            ApiManager.instance.base_request(url, params, 'POST', exchangeSkinComplete);
        }

        public function exchangeSkinComplete(res):void
        {
            if(res.code == 'success')
            {
                UserInfoM.haveSkinsId = res.data.user_exchange_ids;
                GameEventDispatch.instance.event(GameEvent.InitShop);
                UserInfoM.gold = res.data.user_gold;
                GameEventDispatch.instance.event(GameEvent.GoldChange);
            }
            else if (res.code == 'gold_err')
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, res.msg +"");
            }
            else if (res.code == 'repeat_exchange')
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, res.msg +"");
            }
        }

        //更换皮肤
        public function changeSkin(itemId:int):void
        {
            var itemId = itemId;
            var url:String = '/change_skin';
            var params:String = 'token=' + LoginInfoM.instance.token + '&skin_goods_id=' + itemId;

            ApiManager.instance.base_request(url, params, 'POST', changeSkinComplete);
        }

        public function changeSkinComplete(res):void
        {
            if(res.code == 'success')
            {
                UserInfoM.useSkinId = res.data.use_skin_id;
                GameEventDispatch.instance.event(GameEvent.InitShop);
                GameEventDispatch.instance.event(GameEvent.InitMosterSkin);
            }
        }

    }
}
