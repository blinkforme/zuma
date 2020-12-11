package view.shop
{


    import conf.cfg_goods;

    import laya.events.Event;
    import laya.ui.Image;
    import laya.ui.Label;
    import laya.utils.Handler;
    import laya.ui.Button;
    import laya.ui.Box;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;
    import manager.ConfigManager;

    import model.UserInfoM;

    import model.ShopM;

    import ui.sylvanas.ShopPageUI;

    import conf.cfg_shop;


    public class ShopPage extends ShopPageUI implements ResVo
    {
        private static var _instance:ShopPage;
        private var _curListPage:Number = 0;
        private var _curTotalPage:Number = 0;
        private var _maxCount:Number = 0;

        public function ShopPage()
        {

        }

        public static function get instance():ShopPage
        {
            return _instance || (_instance = new ShopPage());
        }

        public function StartGames(parm:Object = null):void
        {

            this.hitTestPrior = false;
            bmask.on(Event.CLICK, this, null);
            quitBtn.on(Event.CLICK, this, onQuitBtnClick);
            leftBtn.on(Event.CLICK, this, onLeftBtnClick);
            rightBtn.on(Event.CLICK, this, onRightBtnClick);

            initAllBatterySkin();

            skinList.renderHandler = new Handler(this, initBatterySkin);
            screenResize();
            skinList.y = 0;
        }

        private function initBatterySkin(cell:Box, index:int):void
        {

            var cellInfo:cfg_shop = cell.dataSource;
            cell.offAll(Event.CLICK);
            cell.on(Event.CLICK, this, onCellClick, [cellInfo.goodsId]);

            var batterySkin:Image = cell.getChildByName("batterySkin") as Image;
            var coinImg:Image = cell.getChildByName("coinImg") as Image;
            var useBtn:Button = cell.getChildByName("useBtn") as Button;
            var moneyLabel:Label = cell.getChildByName("money") as Label;

            batterySkin.skin = cfg_goods.instance(cellInfo.goodsId).icon;
            coinImg.visible = false;
            if (cellInfo.goodsId == UserInfoM.useSkinId)
            {
                useBtn.skin = "ui/common/btn_using.png";
                moneyLabel.text = "使用中";
            }
            else
            {
                if (UserInfoM.haveSkinsId.indexOf(cellInfo.goodsId) > -1)
                {
                    useBtn.skin = "ui/common/btn_green.png";
                    moneyLabel.text = "装备";
                }
                else
                {
                    useBtn.skin = "ui/common/btn_goldcoin.png";
                    coinImg.visible = true;
                    moneyLabel.text = cellInfo.price + "";
                }
            }
        }

        private function onCellClick(itemId:int):void
        {
            if (UserInfoM.haveSkinsId.indexOf(itemId) > -1)
            {
                //装备
                ShopM.instance.changeSkin(itemId);
            }
            else
            {
                //购买
                ShopM.instance.exchangeSkinItem(itemId);
            }

        }


        private function initAllBatterySkin():void
        {
            var shopItemList:Array = ConfigManager.items('cfg_shop');
            var maxNum:int;
            maxNum = 6;
            _maxCount = maxNum;
            // 总页数
            var totalPage:Number = Math.ceil(shopItemList.length / maxNum);
            skinList.array = shopItemList;
            skinList.height = totalPage * 454;
            // 当前页数
            var startIndex:int = 1;
            _curListPage = startIndex;
            _curTotalPage = totalPage;
        }

        private function onLeftBtnClick():void
        {
            _curListPage -= 1;
            if (_curListPage <= 1)
            {
                _curListPage = 1;
                skinList.y = -(_curListPage - 1) * 454;
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "当前是第一页")
                return;
            }
            skinList.y = -(_curListPage - 1) * 454;
        }

        private function onRightBtnClick():void
        {
            _curListPage += 1;
            if (_curListPage >= _curTotalPage)
            {
                _curListPage = _curTotalPage;
                skinList.y = -(_curListPage - 1) * 454;
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "当前是最后一页")
                return;
            }
            skinList.y = -(_curListPage - 1) * 454;
        }


        private function onQuitBtnClick():void
        {
            UiManager.instance.closePanel("Shop", false);
        }


        private function screenResize():void
        {
            bmask.width = GameConst.design_width * 1.5;
            bmask.height = GameConst.design_height * 1.5;
            this.size(Laya.stage.width, Laya.stage.height);
        }


        public function register():void
        {
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.on(GameEvent.InitShop, this, initAllBatterySkin);
        }

        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.off(GameEvent.InitShop, this, initAllBatterySkin);
        }

    }
}
