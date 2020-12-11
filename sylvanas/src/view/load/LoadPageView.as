package view.load
{
    import control.WxC;
    import control.WxShareC;

    import enums.ShowType;


    import fight.FightManager;
    import fight.zuma.ZumaMap;

    import laya.events.Event;
    import laya.media.SoundManager;
    import laya.net.Loader;
    import laya.utils.Handler;
    import laya.wx.mini.MiniAdpter;

    import manager.ApiManager;
    import manager.ConfigManager;
    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.GameLoader;
    import manager.GameTemplet;
    import manager.ResVo;
    import manager.SpineTemplet;
    import manager.UiManager;
    import manager.WebSocketManager;

    import model.LoadM;
    import model.LoadResM;
    import model.LoginInfoM;
    import model.LoginM;
    import model.SceneM;
    import model.UserInfoM;
    import model.WxM;


    import ui.sylvanas.LoadPageUI


    public class LoadPageView extends LoadPageUI implements ResVo
    {
        private var _resArray:Array;  //需要加载资源
        private var _spineArray:Array; //需要加载的动画
        private var _state:Number; //加载的状态
        private var _mFactory:GameTemplet;
        private var _totalSpineNum:int = -1;
        private var _isFirstWait:Boolean = true;

        public var _curProgressValue = 0
        public var smoothTick = 0

        public var total_slow_time = 2000;
        public var slow_time = 0

        public function LoadPageView()
        {
            LoginM.instance.resArr = LoadResM.instance.mainRes;
            LoginM.instance.loginState = GameConst.loadMainState;
            LoginM.instance.spineArr = LoadResM.instance.mainSpineArr;
            super();
        }

        public function StartGames(parm:Object = null):void
        {
            progressBar.value = 0;
            progressBar.visible = false;
            _totalSpineNum = -1;

            //            clearSlowProgress()
            //            startSlowPropress()

            screenResize();
            loadLoginn();
            //            setGameVersionNum()
        }

        private function setGameVersionNum():void
        {
            var versionStr:String = "本网络游戏适合6周岁以上用户使用；请您确定已如实进行实名注册；为了您的健康，请合理控制游戏时间。\n抵制不良游戏，拒绝盗版游戏。 注意自我保护，谨防受骗上当。 适度游戏益脑，沉迷游戏伤身。 合理安排时间，享受健康生活。";
        }

        //        public function set curProgressValue(value):void
        //        {
        //            if (value >= 1)
        //            {
        //                clearSmoothProgressBar()
        //                progressBar.value = 1
        //            } else
        //            {
        //                smoothTick = (value - progressBar.value) / 10
        //                if (smoothTick < 0)
        //                {
        //                    smoothTick = 0
        //                }
        //                _curProgressValue = value
        //            }
        //
        //        }

        public static function advLoad():void
        {
            Laya.loader.load(LoginM.instance.resArr, null)
        }

        public function startSmoothProgressBar():void
        {
            Laya.timer.loop(10, this, smoothProgressBar)
        }

        public function clearSmoothProgressBar():void
        {
            Laya.timer.clear(this, smoothProgressBar)
        }

        public function smoothProgressBar():void
        {
            progressBar.value = progressBar.value + smoothTick
        }


        public function loginState(state:Number):void
        {
            switch (state)
            {
                case GameConst.loadMainState:
                {
                    onMainPageLoad();

                    break;
                }
                case GameConst.loadFightState:
                {
                    onFightLoad();
                    break;
                }

                default:
                {
                    break;
                }
            }
        }

        private function onMainPageLoad():void
        {
            var params:String;
            if (WxC.isInMiniGame())
            {
                tipText.text = "请求中心服务器分配游戏服务器";
                params = "js_code=" + WxC.wxminiCode + "&nickname=" + WxC.wxminiName + "&avatar=" + WxC.wxminiAvatar + "&ch=" +
                        WxC.getLaunchChannel() + "&version=" + WxC.game_version;
                ApiManager.instance.wxminiLogin(params, Handler.create(this, wxminiLoginSuccess), Handler.create(this, wxminiLoginFail));
            } else
            {
                tipText.text = "加载外公告";
                outsideCompleteHandler();
            }
        }

        private function initInfo(data:*):void
        {
            if (data)
            {
                WxM.instance.isShow = (data.is_open_share == 1);
                if (!GameLoader.manifest_name || GameLoader.manifest_name.length <= 0)
                {
                    GameLoader.manifest_name = data.version;
                }
                WxC.accessToken = data.access_token;
                UserInfoM.instance.name = data.nickname;
                UserInfoM.instance.avatar = data.avatar;
                LoginInfoM.instance.mini_server_domain = data.mini_server_domain;
                LoginInfoM.instance.token = data.access_token;
                LoginInfoM.instance.user_status = data.user_status;
            }
        }

        private function wxminiLoginSuccess(result:*):void
        {
            if (result.data)
            {
                var data:Object = result.data;

                initInfo(data);
                SceneM.instance.getSceneInfoComplete(result);
                //此处应该加载外公告
                outsideCompleteHandler();
            } else
            {
                if (WxC.wxminiLoginCount <= 0)
                {
                    WxC.wxminiLoginCount = 1;
                    WxC.wxminiCode = "";
                    loadLoginn();
                } else
                {
                    trace("微信登录wxminiLoginCount有误", WxC.wxminiLoginCount);
                }
            }
        }

        public function loadLoginn():void
        {
            _resArray = LoginM.instance.resArr;
            _state = LoginM.instance.loginState;
            _spineArray = LoginM.instance.spineArr;

            if (WxC.isInMiniGame() && (!WxC.wxminiCode || WxC.wxminiCode.length <= 0))
            {
                tipText.text = "开始微信授权";
                WxC.wx_login();
            } else
            {
                loginState(_state);
            }
        }

        private function wxminiLoginFail():void
        {
        }

        private function outsideCompleteHandler(msg:Object = null):void
        {
            loadConfigCallBack();
        }

        //        public function loadConfig():void
        //        {
        //            Laya.loader.load([{
        //                url: ConfigManager.getConfigPath(),
        //                type: Loader.JSON
        //            }], Handler.create(this, loadConfigCallBack));
        //        }

        private function loadConfigCallBack():void
        {
            WxShareC.instance.getMiniProgram()
            LoginM.instance.resArr = LoadResM.instance.mainRes;
            LoginM.instance.loginState = GameConst.loadMainState;
            LoginM.instance.spineArr = LoadResM.instance.mainSpineArr;

            _resArray = LoginM.instance.resArr;
            _state = LoginM.instance.loginState;
            _spineArray = LoginM.instance.spineArr;
            startLoadRes();
        }


        private function onFightLoad():void
        {
            progressBar.visible = true;
            progressBar.value = 0;

            //            onFightCommonResProgress()

            onFightFishResLoaded()
        }


        private function startLoadRes():void
        {
            progressBar.visible = true;
            progressBar.value = 0;
            Laya.loader.load(_resArray, Handler.create(this, function (isSuccess:Boolean)
            {
                if (isSuccess)
                {
                    loadSpineFactory();
                } else
                {
                    startLoadRes();
                }
            }), Handler.create(this, onProgress, null, false));
            Laya.loader.on(Event.ERROR, this, onerror);
        }


        //资源加载失败的回调方法
        private function onerror():void
        {

        }

        //资源加载过程中
        private function onProgress(pro:Number):void
        {
            progressBar.value = pro * 0.8;
        }


        private function screenResize():void
        {
            bg_img.width = Laya.stage.width;
            bg_img.height = Laya.stage.height;
            progressBar.bottom = 100;
            progressBar.x = Laya.stage.width / 2;

            tipText.bottom = 130;
            tipText.x = Laya.stage.width / 2;
        }

        public function playBgMusic():void
        {
            var musicPath:String = ConfigManager.getConfValue("cfg_global", 1, "bg_music") as String;
            SoundManager.playMusic(musicPath);
        }

        //加载骨骼动画工厂
        private function loadSpineFactory():void
        {
            if (_spineArray.length > 0)
            {
                //初始化总的spine数量，计算进度条
                if (_totalSpineNum < 0)
                {
                    _totalSpineNum = _spineArray.length;
                }

                progressBar.value = 0.8 + 0.2 * (_totalSpineNum - _spineArray.length) / _totalSpineNum;

                var path:String = _spineArray[0];
                if (SpineTemplet.isPathCache(path))
                {
                    _spineArray.splice(0, 1);
                    loadSpineFactory();
                } else
                {

                    _mFactory = new GameTemplet();
                    _mFactory.on(Event.COMPLETE, this, loadSpineComplete);
                    _mFactory.loadAni(path);
                }
            } else
            {
                progressBar.value = 1;
                Laya.timer.frameOnce(3, this, loadComplete);
            }
        }

        private function loadSpineComplete():void
        {
            var path:String = _spineArray[0];
            SpineTemplet.addFactoryCache(_mFactory, path);
            _spineArray.splice(0, 1);
            Laya.timer.frameOnce(1, this, loadSpineFactory);
        }

        private function endLoadMainState():void
        {
            SoundManager.setMusicVolume(GameConst.default_bgm_music);
            SoundManager.setSoundVolume(GameConst.default_sound);
            playBgMusic();

            var accessToken:String = LoginInfoM.instance.token;

            FightManager.instance;

            if (WxShareC.isInMiniGame())
            {
                // 初始化离屏画布
                initSharedCanvas();

                // 初始化被动分享
                WxShareC.wxShare(2, 2);
            }

            if (accessToken)
            {
                UiManager.instance.closePanel("Load", false);
                UiManager.instance.loadView("MainPage");
            }
        }

        // 初始化离屏画布
        public function initSharedCanvas():void
        {
            Laya.loader.load(["res/atlas/ui/friendsRanking.atlas"], Handler.create(null, function ()
            {
                //加载完成
                //使用接口将图集透传到子域
                MiniAdpter.sendAtlasToOpenDataContext("res/atlas/ui/friendsRanking.atlas");
            }));
        }

        private function endLoadFish():void
        {
            if (!LoginM.instance.isBulletPreload())
            {
                LoginM.instance.setBulletPreload();
            }
            ZumaMap.instance.initFightChain(LoginM.instance.sceneId)
            GameEventDispatch.instance.event(GameEvent.RestInRoom);
        }


        //资源加载完成
        private function loadComplete():void
        {
            if (_state == GameConst.loadMainState)
            {
                endLoadMainState();
            } else if (_state == GameConst.loadFightState)
            {
                endLoadFish();
            }
        }

        private function wxMiniLoginComplete():void
        {
            if (WxC.wxminiCode && WxC.wxminiCode.length > 0)
            {
                tipText.text = "微信授权成功";
                loginState(_state);
            } else
            {
                //微信授权失败
                tipText.text = "微信授权失败";
            }
        }


        private function closePage():void
        {
            UiManager.instance.closePanel("Load", false);
        }

        private function exitLoginView():void
        {
            UiManager.instance.closePanel("Load", false);
        }

        public function startSlowPropress():void
        {
            Laya.timer.loop(20, this, slowProgress)
        }

        public function slowProgress():void
        {
            slow_time += 20
            if (slow_time >= total_slow_time)
            {
                slow_time = total_slow_time
            }
            progressBar.value = 0.1 * (slow_time / total_slow_time)
        }

        public function clearSlowProgress():void
        {
            total_slow_time = 2000
            slow_time = 0
            Laya.timer.clear(this, slowProgress)
        }

        public function onFightCommonResLoaded():void
        {
        }

        public function onFightCommonResProgress():void
        {
            clearSlowProgress()
            progressBar.value = 0.1 + 0.4 * LoadM.instance.fightCommonResLoadPercent
        }

        public function onFightFishResLoaded():void
        {
            Laya.loader.load(_resArray, Handler.create(this, function (isSuccess:Boolean)
            {
                if (isSuccess)
                {
                    loadSpineFactory()
                }
            }), Handler.create(this, onProgress, null, false));
        }

        public function onFightFishResProgress():void
        {
            clearSlowProgress()
            progressBar.value = 0.5 + 0.4 * LoadM.instance.fightFishResLoadPercent
        }

        public function register():void
        {
            UiManager.instance.closePanel("MainPage", false);
            GameEventDispatch.instance.once(GameEvent.EnterFightPage, this, closePage);
            GameEventDispatch.instance.once(GameEvent.ExitLoginView, this, exitLoginView);
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.on(GameEvent.FightCommonResLoaded, this, onFightCommonResLoaded);
            GameEventDispatch.instance.on(GameEvent.FightCommonResPregress, this, onFightCommonResProgress);

            GameEventDispatch.instance.on(GameEvent.FightFishResLoaded, this, onFightFishResLoaded);

            GameEventDispatch.instance.on(GameEvent.WxMiniLoginComplete, this, wxMiniLoginComplete);

            startSmoothProgressBar()
        }

        public function unRegister():void
        {
            if (_isFirstWait)
            {
                _isFirstWait = false;
            }
            UiManager.instance.closePanel("Login", true);
            GameEventDispatch.instance.off(GameEvent.EnterFightPage, this, closePage);
            GameEventDispatch.instance.off(GameEvent.ExitLoginView, this, exitLoginView);
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
            GameEventDispatch.instance.off(GameEvent.FightCommonResLoaded, this, onFightCommonResLoaded);
            GameEventDispatch.instance.off(GameEvent.FightCommonResPregress, this, onFightCommonResProgress);
            GameEventDispatch.instance.off(GameEvent.FightFishResLoaded, this, onFightFishResLoaded);

            GameEventDispatch.instance.off(GameEvent.WxMiniLoginComplete, this, wxMiniLoginComplete);
            clearSmoothProgressBar()
            clearSlowProgress()
        }
    }
}
