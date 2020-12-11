package control
{
    import laya.events.Event;
    import laya.utils.Handler;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;

    import model.FightM;
    import model.LoadM;
    import model.LoadResM;

    public class LoadC
    {
        private static var _instance:LoadC;

        public function LoadC()
        {
            GameEventDispatch.instance.on(GameEvent.StartLoadFightCommonRes, this, startLoadCommonFightRes);
            GameEventDispatch.instance.on(GameEvent.ContinueLoadFightCommon, this, continueLoadFightCommon);

            Laya.loader.on(Event.ERROR, this, onLoaderError);
        }

        public function isPreLoadCommonRes():Boolean
        {
            //            if (QQBrowserC.isInQQBrowser())
            //            {
            //                return false
            //            }else if(BaiduC.instance.isInBaiduMini()){
            //                return true
            //            }
            //            else
            //            {
            return false
            //            }

        }

        public function onLoaderError(image, url):void
        {
            console.log("onLoaderError")
            console.log(image, url)
        }

        public function continueLoadFightCommon():void
        {
            console.log("continueLoadFightCommon")
            console.log("LoadM.instance.fightResLoadStatus:" + LoadM.instance.fightResLoadStatus)
            if (LoadM.instance.fightResLoadStatus == 0)
            {
                startLoadCommonFightRes()
            }

            else if (LoadM.instance.fightResLoadStatus == 1)
            {
                GameEventDispatch.instance.event(GameEvent.FightCommonResLoaded);
                loadFishRes()
            }
        }

        private function loadFishRes():void
        {
//            console.log("loadFishRes fightMode:" + FightM.instance.getFightMode())

            Laya.loader.load(LoadResM.instance.getFishRes, Handler.create(this, function (isSuccess:Boolean)
            {
                if (isSuccess)
                {

                    LoadM.instance.fightResLoadStatus = 2;
                    GameEventDispatch.instance.event(GameEvent.FightFishResLoaded);
                }
            }), Handler.create(this, onFishResProgress, null, false));
        }


        public function startLoadCommonFightRes():void
        {
            LoadM.instance.resetFishLoadStatus()

            var resArr:Array = LoadResM.instance.commonSceneArr()

            Laya.loader.load(resArr, Handler.create(this, function (isSuccess:Boolean)
            {
                if (isSuccess)
                {
                    LoadM.instance.fightResLoadStatus = 1;
                    GameEventDispatch.instance.event(GameEvent.FightCommonResLoaded);
                    loadFishRes()
                }
            }), Handler.create(this, onCommonResProgress, null, false));
        }


        public function onFishResProgress(p:Number):void
        {
            LoadM.instance.fightFishResLoadPercent = p
            GameEventDispatch.instance.event(GameEvent.FightFishResPregress);
        }

        public function onCommonResProgress(p:Number):void
        {
            LoadM.instance.fightCommonResLoadPercent = p
            GameEventDispatch.instance.event(GameEvent.FightCommonResPregress);
        }

        public static function get instance():LoadC
        {
            return _instance || (_instance = new LoadC());
        }
    }
}
