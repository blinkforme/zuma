package manager
{
    import fight.CoordGm;

    import laya.utils.Browser;

    public class ScreenAdaptManager
    {
        public var width:int = 0;
        public var height:int = 0;

        private static var _instance:ScreenAdaptManager;

        public var minWidth:int = 720;
        public var maxWidth:int = 1120;
        public var minHeight:int = 1220;
        public var maxHeight:int = 1800;
        //public var maxRate:Number = maxWidth / minHeight;
        //public var minRate:Number = minWidth / maxHeight;
        public var maxRate:Number = maxHeight / minWidth;
        public var minRate:Number = minHeight / maxWidth;
        private var useClientHeight:int = 0;
        private var useClientWidth:int = 0;
        private var useBrowserWidth:int = 0;
        private var useBrowserHeight:int = 0;
        private var notch:String = "";

        public function ScreenAdaptManager()
        {


        }

        private function update():void
        {
            //bodyWidth = Browser.clientHeight;
            //bodyHeight = Browser.clientWidth;
            if (useBrowserWidth != Browser.clientWidth || useBrowserHeight != Browser.clientHeight || notch != GameTools.notch())// || notch !=  __JS__("notch()"))
            {

                //计算适配的设计宽高
                var browserRate:Number = Browser.clientHeight / Browser.clientWidth;
                if (Browser.clientWidth > Browser.clientHeight)
                {
                    browserRate = Browser.clientWidth / Browser.clientHeight;
                }
                useBrowserWidth = Browser.clientWidth;
                useBrowserHeight = Browser.clientHeight;
                notch = GameTools.notch();//__JS__("notch()")
                if (browserRate >= minRate && browserRate <= maxRate)
                {
                    var i:int = minWidth;
                    var preI:int = 0;
                    var iminRate:Number = 0;
                    var imaxRate:Number = 0;
                    var imaxWidth:int = maxWidth;
                    var findRate:Boolean = false;
                    //计算最小i
                    i = Math.ceil(minHeight / browserRate);
                    if (i < minWidth)
                    {
                        i = minWidth;
                    }
                    while (i <= imaxWidth)
                    {
                        iminRate = minHeight / i;
                        imaxRate = maxHeight / i;
                        if (imaxRate >= browserRate && iminRate <= browserRate)
                        {
                            //找到合适的分辨率

                            findRate = true;
                            useClientWidth = i;
                            useClientHeight = Math.floor(i * browserRate);
                            //trace("find height = " + useClientHeight + " width = " + useClientWidth);
                            break;
                        }
                        else
                        {
                            preI = i;
                            i = Math.floor((i + imaxWidth) / 2);
                            if ((minHeight / i) > browserRate)
                            {
                                imaxWidth = i;
                                i = preI + 1;
                            }
                            else
                            {
                                if (i <= preI)
                                {
                                    i = preI + 1;
                                }
                            }
                        }
                    }
                    if (!findRate)
                    {
                        useClientHeight = Math.floor(i * browserRate);
                        useClientWidth = i;
                    }
                }
                else if (browserRate > minRate)
                {
                    useClientHeight = minHeight;
                    useClientWidth = maxWidth;
                }
                else
                {
                    useClientHeight = maxHeight;
                    useClientWidth = minWidth;
                }
                //开始调整屏幕适配
                Laya.stage.width = useClientWidth;
                Laya.stage.height = useClientHeight;
//                trace("width = " + useClientWidth + " height = " + useClientHeight + " bwidth = " + Browser.clientWidth + " bHeight = " + Browser.clientHeight);
                CoordGm.instance.updateZumaScale();
                GameEventDispatch.instance.event(GameEvent.ScreenResize, null);
            }
        }

        public function init():void
        {
            update();
            loopCheck();
            //Laya.timer.frameLoop(1, this, this.update);
        }

        public function loopCheck():void
        {
            Laya.timer.frameLoop(1, this, this.update);
        }

        public static function get instance():ScreenAdaptManager
        {
            return _instance || (_instance = new ScreenAdaptManager());
        }

    }
}

