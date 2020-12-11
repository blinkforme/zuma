package struct
{
    import laya.ui.FontClip;
    import laya.utils.Handler;

    import manager.GameConst;

    public class QuitTipInfo
    {
        public var content:String;

        public var state:int;
        public var autoCloseTime:int;

        public var confirmEvent:String;
        public var confirmEventArgs:Object;

        public var cancelEvent:String;
        public var cancelEventArgs:Object;

        public var middleTxt:String = "确定"
        public var middileTxtColor:String = GameConst.font_green

        public var leftTxt:String = "返回"
        public var leftTxtColor:String = GameConst.font_green
        public var rightTxt:String = "确定"
        public var rightTxtColor:String = GameConst.font_red

        //        确认后回调的函数
        public var confirmCallback:Handler;

        //是否有倒计时
        public var isHaveTime:Boolean = true;
    }
}
