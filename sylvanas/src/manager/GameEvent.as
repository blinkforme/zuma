package manager
{
    public class GameEvent
    {
        public static const ReceiveHandshake:String = "AA";//
        public static const ReceiveSGHandshake:String = "AB";//小游戏握手
        public static const WsClose:String = "AC";
        public static const SGWsClose:String = "AD";//小游戏网络断开
        public static const WsError:String = "AE";
        public static const FightStart:String = "AH";//战斗开始
        public static const FightStop:String = "AI";//战斗结束
        public static const BallIntoHole:String = "BallIntoHole";//球进入洞口
        public static const GameTimeOut:String = "GameTimeOut";//游戏时间结束
        public static const FightOverReturnMain:String = "FightOverReturnMain";//战斗结束返回主界面
        public static const UpdatePowerData:String = "UpdatePowerData";
        public static const ComboAniShow:String = "ComboAniShow";
        public static const GoOnGameOneTimes:String = "GoOnGameOneTimes";
        public static const UpdateSkillState:String = "UpdateSkillState";
        //
        public static const EliminateComplete:String = "EliminateComplete";//消除

        public static const FightCommonResLoaded:String = "EF"
        public static const FightFishResLoaded:String = "EG"

        public static const QuitTip:String = "AQ" //退出游戏
        public static const MsgTip:String = "AR"; //消息的toast的提示,根据msg id
        public static const MsgTipContent:String = "AS"; //直接传提示

        public static const EnterFightPage:String = "Aq"; //进入战斗界面


        public static const UpdateFirstCharge:String = "A1";//更新首冲状态

        public static const SystemReset:String = "BR";//系统重置

        public static const ReturnConfirm:String = "Ba";
        public static const LoadUi:String = "Bb";

        public static const ExitLoginView:String = "Bo"; //退出登录界面

        public static const ScreenResize:String = "Br"; //屏幕重置
        public static const ScreenResizeEnd:String = "Bs";
        public static const CloseUi:String = "Bv";
        public static const StartLoad:String = "B5";//开始加载资源
        public static const RestInRoom:String = "B6"//进入房间
        public static const SingleFightStart:String = "SingleFightStart"//单机模式开启


        public static const WxMiniLoginComplete:String = "CP";//微信授权完成

        public static const WxCheckSessionOk:String = "CQ"; //用户登陆状态有效
        public static const WxCheckSessionFail:String = "CR"; //用户登陆状态无效


        public static const CloseReset:String = "CU"

        public static const WxGetClipBoard:String = "CV";

        public static const OpenWait:String = "CX"
        public static const CloseWait:String = "CY"
        public static const RightWait:String = "Cd"
        public static const AreaShareSucess:String = "Ce"


        public static const ScreenShareComplete:String = "Co";

        public static const StartLoadFightCommonRes:String = "ED"
        public static const ContinueLoadFightCommon:String = "EE"

        public static const FightCommonResPregress:String = "EH"

        public static const AndroidReturnKey:String = "AndroidReturnKey"; //android 返回键


        public static const LeaveRoom:String = "LeaveRoom"; //退出房间

        public static const GoldSave:String = "GoldSave"; //金币存储
        public static const GoldChange:String = "GoldChange";  //金币变化
        public static const NatureSave:String = "NatureSave";  //属性养成存储
        public static const NatureChange:String = "NatureChange"; //玩家养成系统属性变化

        public static const PowerSave:String = "PowerSave";//体力值存储


        // 首页关卡
        public static const InitUserinfo:String = "InitUserinfo"; // 初始化首页用户信息
        public static const InitScene:String = "InitScene"; // 初始化首页关卡

        public static const ResetOfflineInfo:String = "ResetOfflineInfo"; // 重置金币

        public static const InitOfflinePower:String = "InitOfflinePower";//初始化离线体力值
        public static const InitOfflinePowerTime:String = "InitOfflinePowerTime";//体力生成时间
        public static const ResetPower:String = "ResetPower";//重置体力值
        public static const LoopPower:String = "LoopPower";//增加体力存储时间

        public static const InitShop:String = "InitShop";//初始化商城
        public static const InitMosterSkin:String = "InitMosterSkin";//更换怪物皮肤
        public static const ReviveCount:String = "ReviveCount";//复活次数

        public static const LoadMiniAdRes:String = "LoadMiniAdRes";
    }
}
