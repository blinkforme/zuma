package view.account
{
    import fight.FightManager;
    import fight.zuma.ZumaManager;

    import laya.events.Event;
    import laya.ui.Image;
    import laya.ui.Label;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;

    import model.AccountM;
    import model.UserInfoM;
    import model.FightM;

    import ui.sylvanas.AccountPageUI;

    import control.WxShareC;

    public class AccountView extends AccountPageUI implements ResVo
    {

        private var _source:Array;

        public function AccountView():void
        {

        }

        public function StartGames(parm:Object = null):void
        {
            initDataSource();
            if (AccountM.instance.acoountType == GameConst.Account_Type_Vectory)
            {
                gameWinOption();
            }
            else if (AccountM.instance.acoountType == GameConst.Account_Type_Fail)
            {
                gameLoseOption();
            }
            nomalBtn.stateNum = 1;
            closeBtn.visible = false;
            nomalBtn.on(Event.CLICK, this, onNomalBtn);
            doubleBtn.on(Event.CLICK, this, onDoubleBtn);
            screenResize();
        }

        private function initDataSource():void
        {
            AccountM.instance.shareGoBack = 0;
            _source = [];
            var cun:Number = FightM.instance.curLevelGetGold();
            var obj:Object;
            if (AccountM.instance.acoountType == GameConst.Account_Type_Vectory)
            {
                obj = {
                    type: "消灭球",
                    num: FightM.instance.sceneScore,
                    coin: FightM.instance.sceneScore * cun
                }
                UserInfoM.instance.receiveGold(obj.coin);
                UserInfoM.instance.changePower(1);
            }
            _source.push(obj);
        }

        private function gameWinOption():void
        {
            titleBg.skin = "ui/account/img_redribbon.png";
            title.skin = "ui/account/word_victory.png";
            nomalBtn.label = "双倍领取";
            doubleBtn.text = "放弃双倍领取";
            winBox.visible = true;
            loseBox.visible = false;
            resultsList.dataSource = _source;
        }

        private function gameLoseOption():void
        {
            titleBg.skin = "ui/account/img_grayribbon.png";
            loseBox.visible = true;
            winBox.visible = false;
            reviveShow();
        }

        private function reviveShow():void
        {
            var reviveLabel = loseBox.getChildByName("reviveLabel") as Label;
            var giveupLabel = loseBox.getChildByName("giveupLabel") as Label;
            var showImage = loseBox.getChildByName("showImage") as Image;
            var score = loseBox.getChildByName("score") as Label;
            score.text = FightM.instance.sceneScore + "";

            if (FightM.instance.reviveCount > 0) //可复活
            {
                title.skin = "ui/account/word_resurrection.png";
                nomalBtn.label = "分享可复活哦";
                doubleBtn.text = "不用了，谢谢";
                reviveLabel.visible = true;
                reviveLabel.text = "(本局还可以再复活" + FightM.instance.reviveCount + "次)";
                showImage.visible = true;
                giveupLabel.visible = true;
                score.pos(35.5, 45);
                score.fontSize = 40;
            }
            else //失败
            {
                title.skin = "ui/account/word_lose.png";
                nomalBtn.label = "再来一局";
                doubleBtn.text = "返回主界面";
                reviveLabel.visible = false;
                giveupLabel.visible = false;
                showImage.visible = false;
                score.pos(35.5, 105);
                score.fontSize = 50;
            }

        }


        //分享双倍领取
        private function onNomalBtn():void
        {
            if (AccountM.instance.acoountType == GameConst.Account_Type_Vectory)
            {
                //成功分享领双倍
                var query:String = 'uid=win';
                WxShareC.wxShare(1, 1, query);
                UserInfoM.instance.receiveGold(FightM.instance.sceneScore * FightM.instance.curLevelGetGold());
                GameEventDispatch.instance.event(GameEvent.FightOverReturnMain);
            }
            else if (AccountM.instance.acoountType == GameConst.Account_Type_Fail)
            {
                //复活看视频(目前没有视频，分享再来一次)
                if (FightM.instance.reviveCount > 0)
                {
                    var query:String = 'uid=lose';
                    WxShareC.wxShare(1, 1, query);
                }
                else
                {
                    startGameAgain();
                }
            }
            //后续优化 TODO
            //            if (AccountM.instance.shareGoBack == 1)
            //            {
            //                shareBox.visible = true;
            //                请分享到微信群
            //            } else if (AccountM.instance.shareGoBack > 1)
            //            {
            //                不要频繁打扰同一个微信群
            //            }
        }

        private function startGameAgain():void
        {
            if (UserInfoM.power > 0)
            {
                FightManager.instance.oneTimeAgain();
                UserInfoM.instance.changePower(-1);
                UiManager.instance.closePanel("Account", false);
            }
            else
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "体力不足");
            }

        }

        //正常领取
        private function onDoubleBtn():void
        {
            /*  if (AccountM.instance.acoountType == GameConst.Account_Type_Vectory)
              {
                  //成功一倍领取
              }
              else if (AccountM.instance.acoountType == GameConst.Account_Type_Fail)
              {
                  //失败关游戏
              }*/
            GameEventDispatch.instance.event(GameEvent.FightOverReturnMain);
        }

        private function screenResize():void
        {
            bgmask.width = GameConst.design_width * 1.6;
            bgmask.height = GameConst.design_height * 1.6;
            this.size(Laya.stage.width, Laya.stage.height);
        }


        //注册消息发送事件
        public function register():void
        {
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.on(GameEvent.ReviveCount, this, reviveShow);
        }

        //取消注册的消息发送事件
        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.off(GameEvent.ReviveCount, this, reviveShow);
        }
    }
}