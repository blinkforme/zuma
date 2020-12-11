package view.mainPage
{
    import conf.cfg_goods;
    import conf.cfg_path;
    import conf.cfg_scene;
    import conf.cfg_shop;

    import control.UserInfoC;
    import control.WxC;
    import control.WxShareC;

    import enums.ShowType;
    import enums.SkillType;

    import laya.display.Animation;

    import manager.ApiManager;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;
    import manager.ConfigManager;

    import model.FightM;
    import model.LoginInfoM;
    import model.LoginM;
    import model.OfflinePowerM;
    import model.SceneM;
    import model.UserInfoM;
    import model.ShopM;

    import ui.sylvanas.MainPageUI;

    import laya.utils.Handler;
    import laya.ui.Box;
    import laya.ui.Image;
    import laya.events.Event;
    import laya.ui.Label;
    import laya.media.SoundManager;
    import laya.utils.Ease;
    import laya.utils.Tween;

    public class MainPageView extends MainPageUI implements ResVo
    {
        private var currentSceneId:int = 1; // 当前关卡ID
        private var showBoxNum:int = 0; // 当前关卡ID
        private var _curListPage:Number = 0;

        private var _leftButArr:Array = [];
        private var _rightButArr:Array = [];

        //青蛙动画
        private var scaleDelta:Number = 1;

        private var isStartGame = false;

        private var sceneInfoSkin:String;

        private static var _instance:MainPageView;

        public function MainPageView()
        {

        }

        public static function get instance():MainPageView
        {
            return _instance || (_instance = new MainPageView());
        }


        public function StartGames(param:Object = {}):void
        {
            this.hitTestPrior = false;

            allBtnMouseEnabled(true);

            // 初始化关卡信息并
            UserInfoC.instance.getUserInfo();
            UserInfoC.instance.getUserPowerInfo();
            // SceneM.instance.initScensInMainPage();

            LoginInfoM.instance.mainPageShow = true;
            settingBtn.on(Event.CLICK, this, onSettingBtn);
            rankBtn.on(Event.CLICK, this, showFriendsRanking);
            shopBtn.on(Event.CLICK, this, onShopBtnClick);

            isStartGame = false;
            //初始化界面显示信息
            initUiPanel();
            initFrog();
            sceneLists.renderHandler = new Handler(this, initScene);
            leftListBtn.on(Event.CLICK, this, onLeftBtnBox);
            rightListBtn.on(Event.CLICK, this, onRightBtnBox);

            // 显示领取收益弹框
            addGold.on(Event.CLICK, this, showShareGold);

            //加体力值
            addPowerBtn.on(Event.CLICK, this, onAddPowerClick);

            screenResize();

            initSceneData();

            if (WxShareC.loadResSuccess)
            {
                initMiniProgramBtn()
            }
        }

        private function showShareGold():void
        {
            updateUserinfo();
            //            UserInfoM.instance.receiveGold(obj.coin);
        }

        public function initUiPanel():void
        {
            if (WxC.isInMiniGame() && WxC.wxminiAvatar)
            {
                userAvatar.skin = WxC.wxminiAvatar;
            }
            friendBtn.visible = false;
            if (WxShareC.isInMiniGame())
            {
                rankBtn.visible = true;
            } else
            {
                rankBtn.visible = false;
            }
            _leftButArr = [rankBtn, settingBtn, friendBtn,];
            _rightButArr = [addGold, shopBtn];

            var oneBtn:Object;
            var j:Number = 0;
            for (var i:int = 0; i < _leftButArr.length; i++)
            {
                oneBtn = _leftButArr[i];
                if (oneBtn.visible == true)
                {
                    oneBtn.y = 110 * j;
                    j++;
                }
            }
            j = 0;
            for (var i:int = 0; i < _rightButArr.length; i++)
            {
                oneBtn = _rightButArr[i];
                if (oneBtn.visible == true)
                {
                    oneBtn.y = 110 * j;
                    j++;
                }
            }
        }

        // 初始化相关用户信息
        private function initUserinfo():void
        {
            initGoldNum();
        }

        // 初始化金币数
        private function initGoldNum():void
        {
            userCoin.text = UserInfoM.gold + "";
            userpower.text = UserInfoM.power + "";
        }

        // 关卡渲染
        private function initScene(cell:Box, index:int):void
        {
            var sceneInfo:Object = cell.dataSource;
            var showImg:Image = cell.getChildByName('show_img') as Image;
            var iconPass:Image = cell.getChildByName('iconPass') as Image;
            var fontLock:Label = cell.getChildByName('fontLock') as Label;
            showImg.skin = sceneInfo.sceneBg + "";
            // 点击关卡
            cell.offAll(Event.CLICK);
            if (sceneInfo.pass != 0)
            {
                cell.on(Event.CLICK, this, openFrogAni, [sceneInfo.sceneId]);
            } else if (sceneInfo.pass == 0)
            {
                // 关卡未解锁
            }
            // 关卡状态（0：未解锁，1：已通关，2：已解锁）
            if (sceneInfo.pass == 0)
            {
                iconPass.skin = 'ui/mainPage/img_suo.png';
                iconPass.visible = true;
                fontLock.visible = true;
            } else if (sceneInfo.pass == 1)
            {
                iconPass.skin = 'ui/mainPage/img_yitongg.png';
                iconPass.visible = true;
                fontLock.visible = false;
            } else if (sceneInfo.pass == 2)
            {
                iconPass.visible = false;
                fontLock.visible = false;
            }
            showBoxNum++;

            if (showBoxNum == 1)
            {
                cell.scale(0.6, 0.6);
                cell.x = (showBoxNum - 1) * 266 + 133 * 0.4 + 40;
                cell.y = 106 * 0.4;

            } else if (showBoxNum == 2)
            {
                cell.scale(1, 1);
                cell.x = (showBoxNum - 1) * 266 - 20;
                cell.y = 0;
                //frogImage.skin = sceneInfo.monsterImg + "";
                sceneInfoSkin = sceneInfo.monsterImg + "";
            } else if (showBoxNum == 3)
            {
                cell.scale(0.6, 0.6);
                cell.x = (showBoxNum - 1) * 266 - 133 * 0.4 + 30;
                cell.y = 106 * 0.4;
            }
        }

        private function onLeftBtnBox():void
        {
            var curpage:Number = _curListPage - 1;
            if ((curpage - 1) < 0)
            {
                curpage = 0
                _curListPage = 0;
            } else
            {
                _curListPage -= 1
            }
            showBoxNum = 0;
            sceneLists.tweenTo(curpage, 200);
        }

        private function onRightBtnBox():void
        {
            var curpage:Number = _curListPage + 1;
            if ((curpage + 1) > (sceneLists.length - 1))
            {
                curpage = sceneLists.length - 1;
                _curListPage = sceneLists.length - 1;
            } else
            {
                _curListPage += 1;
            }
            showBoxNum = 0;
            sceneLists.tweenTo(curpage, 200);
        }

        // 初始化关卡信息
        private function initSceneData():void
        {
            // var sceneInfo:Object = WxShareC.getStorageSync('sceneInfo');
            var sceneInfo:Object = SceneM.sceneInfo;
            currentSceneId = sceneInfo && sceneInfo.sceneId ? sceneInfo.sceneId : 1;
            fightBtn.on(Event.CLICK, this, openFrogAni, [currentSceneId]); // 获取到关卡信息后再绑定点击事件

            var sceneList:Array = ConfigManager.items('cfg_scene');
            var renderSceneList:Array = [];
            var renderScene:Array = [];
            var renderSceneInfo:Object;
            renderSceneList = sceneList;
            FightM.instance.allSceneNum = renderSceneList.length;
            // 渲染资源
            var sceneObj:cfg_scene;
            var pathObj:cfg_path;
            for (var j:int = 0; j < renderSceneList.length; j++)
            {
                sceneObj = renderSceneList[j] as cfg_scene;
                pathObj = cfg_path.instance(sceneObj.path_id + "") as cfg_path;
                renderSceneInfo = {
                    sceneId: renderSceneList[j].id,
                    sceneBg: cfg_goods.instance(sceneObj.gun_bg + "").icon,
                    pass: renderSceneList[j].id == 1 ? 2 : 0,
                    star: 0
                }
                renderScene.push(renderSceneInfo);
            }

            // 关卡缓存信息
            var sceneInfoList:Array = [];
            if (sceneInfo)
            {
                sceneInfoList = sceneInfo.sceneList;
            }
            // 渲染信息
            for (var l:int = 0; l < sceneInfoList.length; l++)
            {
                renderScene[l].pass = sceneInfoList[l].pass;
                renderScene[l].star = sceneInfoList[l].star;
            }

            // 总页数
            var totalPage:int = Math.ceil(sceneList.length / 3);
            // 当前页数
            var curPage:int = 1;
            var startIndex:int = 1;
            for (var i:int = 0; i < sceneList.length; i++)
            {
                if (sceneList[i].id == currentSceneId)
                {
                    curPage = Math.ceil((i + 1) / 3);
                    startIndex = i - 1;
                    break;
                }
            }
            _curListPage = startIndex;
            sceneLists.array = renderScene;
            sceneLists.visible = true;
            showBoxNum = 0;
            sceneLists.tweenTo(_curListPage, 10);
        }

        // 开始游戏
        private function openFrogAni(scenId:Number):void
        {
            if (UserInfoM.power <= 0)
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "体力不足")
            }
            else
            {
                var id = scenId;
                closeFightPage(id);
            }
        }

        private function closeFightPage(scenId:Number):void
        {
            if (!isStartGame)
            {
                isStartGame = true;
                allBtnMouseEnabled(false);
                LoginM.instance.sceneId = scenId;
                startFrogAni();
                onChangegPower(-1);
                Laya.timer.once(1500, this, openGames);
            }

        }

        private function allBtnMouseEnabled(isEnable:Boolean):void
        {
            settingBtn.mouseEnabled = isEnable;
            addPowerBtn.mouseEnabled = isEnable;
            rankBtn.mouseEnabled = isEnable;
            friendBtn.mouseEnabled = isEnable;
            addGold.mouseEnabled = isEnable;
            fightBtn.mouseEnabled = isEnable;
            shopBtn.mouseEnabled = isEnable;
        }

        private function initFrog():void
        {
            frogImage.rotation = 0;
            frogImage.scale(1, 1);
            frogImage.pos(406, 256);
        }

        private function openGames():void
        {
            Laya.timer.clear(this, frogAnimate);
            initFrog();
            ApiManager.instance.getUserSkill(Handler.create(this, getUserSkillSuccess), Handler.create(this, getUserSkillError));
            GameEventDispatch.instance.event(GameEvent.StartLoad, [GameConst.loadFightState]);
            UiManager.instance.closePanel("MainPage", false);
        }

        private function getUserSkillSuccess(res:*):void
        {
            if (res.data)
            {
                var msgArr:Array = res.data as Array;
                for (var i:int = 0; i < msgArr.length; i++)
                {
                    FightM.instance.skillNumArr[msgArr[i].skill_id] = msgArr[i].num;
                }
                GameEventDispatch.instance.event(GameEvent.UpdateSkillState);
            } else
            {
                ApiManager.instance.saveUserSkill();
            }
        }

        private function getUserSkillError(res:*):void
        {

        }

        //开始动画
        private function startFrogAni():void
        {
            scaleDelta = 1;
            Laya.timer.frameLoop(1, this, frogAnimate);
        }

        private function frogAnimate(e:Event = null):void
        {
            var fixRot = 142.5 * GameConst.fixed_update_time
            frogImage.rotation += fixRot;
            //心跳缩放
            var fixSca = 0.6 * GameConst.fixed_update_time;
            scaleDelta += fixSca;
            frogImage.scale(scaleDelta, scaleDelta);

            if (scaleDelta >= 2.5)
            {
                Laya.timer.clear(this, frogAnimate);
                Tween.to(frogImage, {scaleX: 1, scaleY: 1}, 500, Ease.bounceOut);
            }
        }


        private function onSettingBtn():void
        {
            UiManager.instance.loadView("Setting", null, ShowType.SMALL_TO_BIG)
        }

        // 领取待机收益后更新金币数值并播放动画
        private function updateUserinfo():void
        {
            //            playCoinAni();
            // 播放金币音效
            //            playCoinMusic();
            // 更新金币数
            userCoin.text = UserInfoM.gold ? UserInfoM.gold + '' : '0';
        }

        // 金币动画
        private function playCoinAni():void
        {
            var j:int = 0;
            var randArray:Array = [];
            for (j = 0; j < 8; j++)
            {
                randArray.push(Math.random());
            }
            var coinFly:Array = [0, 0, 0, 30, 10, 0, 50, 10, 0, 30, 10, 0, -30, -10, 0, -10, -50, 0, -10, -30, 0, 0, 0, 0];
            var count:int = Math.floor(coinFly.length / 3);
            for (j = 0; j < count; j++)
            {
                var pos_x:int = addGold.x + 50 + coinFly[j * 3];
                var pos_y:int = addGold.y + 60 + coinFly[j * 3 + 1];
                var end_x:int = userCoin.x;
                var end_y:int = userCoin.y;
                var delay:int = coinFly[j * 3 + 2];
                var effect:GoodsFlyEffect = GoodsFlyEffect.Create(1, pos_x, pos_y, end_x, end_y, delay, this, true, randArray);
                GoodsFlyManager.instance.addFlyEffect(effect);
            }
        }

        // 播放金币音效
        private function playCoinMusic():void
        {
            SoundManager.playSound('music/reward.mp3', 1);
        }

        //        // 初始化待机cd动画
        //        private function initOfflineCdAni():void
        //        {
        //            offlineCdAni.clear();
        //            // 待机收益cd动画
        //            offlineCdAni = FishAniManager.instance.load('cd');
        //            var cd:Object = ConfigManager.getConfObject('cfg_anicollision', 'cd');
        //            offlineCdAni.visible = true;
        //            offlineCdAni.interval = 10 * 1000 / cd.anilength;
        //            offlineCdAni.zOrder = -1;
        //            offlineCdAni.pos(-4, -4);
        //            addGold.addChild(offlineCdAni);
        //            offlineCdAni.play(0, true);
        //        }

        //体力值

        private function initPowerLoop():void
        {
            if (UserInfoM.power >= UserInfoM.power_up_limit)
            {
                Laya.timer.clear(this, powerdownLoop);
                return
            }
            else
            {
                Laya.timer.clear(this, powerdownLoop);
                Laya.timer.loop(1000, this, powerdownLoop);
            }
        }

        private function onChangegPower(change:int):void
        {
            var powerchange = change
            UserInfoM.instance.changePower(powerchange);

            powerImage.visible = true;
            Tween.to(powerImage, {scaleX: 2.5, scaleY: 2.5}, 200, Ease.sineIn, Handler.create(this, onTweenComplete));
        }

        public function onTweenComplete():void
        {
            Tween.to(powerImage, {scaleX: 1, scaleY: 1}, 500, Ease.sineIn, Handler.create(this, powerImagefalse), 500);

            function powerImagefalse():void
            {
                powerImage.pos(12, 29);
                powerImage.scale(1, 1);
                powerImage.visible = false;
            }
        }

        private function updatePower():void
        {
            userpower.text = UserInfoM.power ? UserInfoM.power + '' : '0';
        }


        private function initPowerNum():void
        {
            if (UserInfoM.power >= UserInfoM.power_up_limit)
            {
                Laya.timer.clear(this, powerdownLoop);
                return;
            }


            Laya.timer.clear(this, powerdownLoop);
            Laya.timer.loop(1000, this, powerdownLoop);

        }

        private function powerdownLoop():void
        {
            // 待机信息
            var offlineInfo:Object = OfflinePowerM.offlinePowerInfo;
            var initOfflineTime:int = UserInfoM.power_has_go_time * 1000;
            var totalTime:int = UserInfoM.power_up_limit_time * 1000;
            var delayTime:int = totalTime - initOfflineTime;
            if (delayTime <= 0 && initOfflineTime != 0)
            {
                UserInfoM.instance.changePower(1);
                UserInfoM.power_has_go_time = 0;
            }
            else
            {
                UserInfoM.power_has_go_time += 1;
            }

        }

        private function onAddPowerClick():void
        {
            if (UserInfoM.power >= 20)
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "体力已满")
            }
            else
            {
                var query:String = 'uid=';
                WxShareC.wxShare(1, 1, query);
                UserInfoM.instance.changePower(1);
            }
        }

        private function onShopBtnClick():void
        {
            UiManager.instance.loadView("Shop", null, ShowType.SMALL_TO_BIG);
        }

        //更换怪物皮肤
        public function changeMonsterSkin():void
        {
            frogImage.skin = cfg_goods.instance(UserInfoM.useSkinId).big_icon;
        }

        // 显示好友排行榜
        private function showFriendsRanking():void
        {
            UiManager.instance.loadView('FriendsRanking', null, ShowType.SMALL_TO_BIG);
        }

        private function initMiniProgramBtn():void
        {
            if (WxShareC.isInMiniGame())
            {
                console.log("WxShareC.miniProgramArr.length -> ", WxShareC.miniProgramArr.length)
                if (WxShareC.miniProgramArr.length > 0)
                {
                    mini_program.visible = true
                    mini_program.on(Event.CLICK, this, navigateToMiniProgram)
                    var obj = WxShareC.getCurMiniPro()
                    resetAdAni()
                    mini_name.text = obj.game_name
                    mini_name_bg.text = obj.game_name
                    if (WxShareC.miniProgramArr.length > 1)
                    {
                        Laya.timer.loop(5000, this, updataIndexMiniPro)
                    }
                } else
                {
                    mini_program.visible = false
                }
            } else
            {
                mini_program.visible = false
            }
        }

        private function navigateToMiniProgram():void
        {
            if (WxC.isInMiniGame())
            {

                WxShareC.navigateToMiniProgram()
            } else
            {

            }
        }

        private function updataIndexMiniPro():void
        {
            WxShareC.updataIndexMiniPro()
            var obj = WxShareC.getCurMiniPro()
            resetAdAni()
            mini_name.text = obj.game_name
            mini_name_bg.text = obj.game_name
        }

        private function resetAdAni():void
        {
            var adAni:Animation = WxShareC.instance.adAni()
            if (mini_program.getChildByName("ad_btn"))
            {
                mini_program.removeChildByName("ad_btn")
            }
            mini_program.addChild(adAni)
        }

        private function screenResize():void
        {
            var scale:Number = Laya.stage.width / GameConst.zuma_with;
            banner.width = Laya.stage.width;
            banner.height = Laya.stage.width / 720 * 250;
            topBox.width = scale * GameConst.zuma_with;
            topImg.width = scale * GameConst.zuma_with;
            bottomImg.scaleX = scale;
            bottomImg.scaleY = scale;
            bottomImg.bottom = banner.height;
            sceneLists.centerX = 0;
            sceneLists.top = 240;
            leftBtnBox.left = 34;
            rightBtnBox.right = 16;
            bg_img.width = Laya.stage.width;
            bg_img.height = Laya.stage.height;
            this.size(Laya.stage.width, Laya.stage.height);
        }

        //注册消息发送事件
        public function register():void
        {
            LoginM.instance.pageId = GameConst.MAIN_PAGE;
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.on(GameEvent.InitUserinfo, this, initUserinfo);
            GameEventDispatch.instance.on(GameEvent.InitScene, this, initSceneData);
            GameEventDispatch.instance.on(GameEvent.GoldChange, this, initGoldNum);
            GameEventDispatch.instance.on(GameEvent.ResetOfflineInfo, this, updateUserinfo);
            GameEventDispatch.instance.on(GameEvent.InitOfflinePower, this, initPowerNum);
            GameEventDispatch.instance.on(GameEvent.ResetPower, this, updatePower);
            GameEventDispatch.instance.on(GameEvent.LoopPower, this, initPowerLoop);
            GameEventDispatch.instance.on(GameEvent.InitMosterSkin, this, changeMonsterSkin);
            GameEventDispatch.instance.on(GameEvent.LoadMiniAdRes, this, initMiniProgramBtn);
        }

        //取消注册的消息发送事件
        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.off(GameEvent.InitUserinfo, this, initUserinfo);
            GameEventDispatch.instance.off(GameEvent.InitScene, this, initSceneData);
            GameEventDispatch.instance.off(GameEvent.GoldChange, this, initGoldNum);
            GameEventDispatch.instance.off(GameEvent.ResetOfflineInfo, this, updateUserinfo);
            GameEventDispatch.instance.off(GameEvent.InitOfflinePower, this, initPowerNum);
            GameEventDispatch.instance.off(GameEvent.ResetPower, this, updatePower);
            GameEventDispatch.instance.off(GameEvent.LoopPower, this, initPowerLoop);
            GameEventDispatch.instance.off(GameEvent.InitMosterSkin, this, changeMonsterSkin);
            GameEventDispatch.instance.on(GameEvent.LoadMiniAdRes, this, initMiniProgramBtn);
        }
    }
}
