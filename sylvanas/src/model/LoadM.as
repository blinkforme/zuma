package model
{
    import manager.GameEvent;
    import manager.GameEventDispatch;

    public class LoadM
    {
        private static var _instance:LoadM;

        public static function dispose()
        {
            _instance = null
        }


        //场景公共资源加载进度
        public var fightCommonResLoadPercent = 0;

        //场景鱼资源加载进度
        public var fightFishResLoadPercent = 0;


        // 0-- 未加载公共资源
        // 1-- 加载完成公共图片资源
        // 2-- 加载完成鱼资源
        // 3-- 骨骼动画解析完成
        public var fightResLoadStatus:Number = 0;


        public function resetFishLoadStatus():void
        {
            LoadM.instance.fightCommonResLoadPercent = 0;
            LoadM.instance.fightFishResLoadPercent = 0;
            LoadM.instance.fightResLoadStatus = 0
        }

        public function resetFightMode():void
        {
            if (fightResLoadStatus == 0)
            {

            } else if (fightResLoadStatus == 1)
            {
                Laya.loader.clearUnLoaded();
                GameEventDispatch.instance.event(GameEvent.ContinueLoadFightCommon)
            } else if (fightResLoadStatus == 2)
            {
                fightResLoadStatus = 1;
                GameEventDispatch.instance.event(GameEvent.ContinueLoadFightCommon)
            }
        }

        public function LoadM()
        {
        }


        public static function get instance():LoadM
        {
            return _instance || (_instance = new LoadM());
        }


    }
}
