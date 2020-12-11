package manager
{
    public class GameConst
    {
        public static const handshake_ok:int = 200; // 握手成功
        public static const handshake_illegal:int = 301; // 非法账户
        public static const handshake_new:int = 404; // 新建用户
        public static const playercreate_ok:int = 0; // 用户创建成功
        public static const playercreater_ename:int = 1; // 用户名称已经使用过
        public static const fixed_update_time:Number = (1 / 30);
        public static const area_play_type_max_num:int = 15;
        public static const draw_collision_rect:Boolean = false;

        public static const quit_state_left_confirm_right_cancel:int = 0;
        public static const quit_state_left_cancel_right_confirm:int = 1;
        public static const quit_state_mid_confirm:int = 2;
        public static const quit_state_no_btn:int = 3;

        public static const reconnect_type_other_device_login:int = 1; // 账号在其他设备登录
        public static const reconnect_type_kick:int = 2; // 玩家被踢出
        public static const reconnect_type_socket_error:int = 3; // 网络出错
        public static const reconnect_type_server_error:int = 4; // 服务器异常
        public static const reconnect_type_user_check_error:int = 5; // 用户校验失败
        public static const reconnect_type_network_error:int = 6; // 网络状态提示
        public static const reconnect_admin_kick:int = 7; // 管理员主动踢下线&封号

        public static const FIGHT_PAGE:String = "fight_page";
        public static const MAIN_PAGE:String = "main_page"

        public static const StopZuma:Number = 1;
        public static const StartZuma:Number = 0;

        //----------------------------------------------cj-------------------------------------------
        public static const design_width:int = 720;
        public static const design_height:int = 1280;

        public static const zuma_with:Number = 720;
        public static const zuma_height:Number = 1170;
        public static const war_with:Number = 720;
        public static const war_height:Number = 110;

        public static const war_percent:Number = 11 / 128;
        public static const zuma_percent:Number = 117 / 128;

        public static const BallWith:Number = 65;

        //默认声音大小
        public static const default_sound:Number = 0.5;
        public static const default_bgm_music:Number = 0.5;

        public static const ani_type_frame:int = 0; // 帧动画
        public static const ani_type_skeleton:int = 1; // 骨骼动画
        public static const ani_type_3d:int = 2; // 3d动画

        public static const fight_max_layer:int = 5;        //战斗场景层级的最大层数
        public static const bg_layer_index:int = 0;      //战斗背景
        public static const shadow_layer_index:int = 1;     //战斗场景中阴影层级
        public static const ball_layer_index:int = 2;     //自动产出的球界面
        public static const firegun_layer_index:int = 3;     //炮口层
        public static const ani_layer_index:int = 4;     //战斗特效

        public static const fightUiUpLayer_max = 3;
        public static const fightUiUpLayer_power = 1;
        public static const fightUiUpLayer_ani = 0;
        public static const fightUiUpLayer_timer = 2;//倒计时

        //待机 行走 死亡 战斗
        public static const action_sleep:Number = 0;
        public static const action_walk:Number = 1;
        public static const action_dead:Number = 2;
        public static const action_atk:Number = 3;
        public static const action_big_atk:Number = 4;

        public static const Account_Type_Vectory:Number = 0;
        public static const Account_Type_Fail:Number = 1;
        //------------------------------------------------cj-----------------------------------------

        public static const server_local:Boolean = true;

        public static const GameToosCalBySheet:Boolean = false;

        public static const edition_department_version:Boolean = true;

        public static const appid:String = "wxeb898598bd6698dd";
        public static const loadMainState:Number = 0; // 加载主界面的状态
        public static const loadFightState:Number = 1; // 加载战斗界面的状态
        public static const user_status_normal:String = "normal";
        public static const user_status_ban:String = "ban";
        public static const user_status_limited:String = "limited";

        public static const platform_android_guangfan = "guangfan";
        public static const platform_mini_baidu = "mini_baidu";

        public static const font_red = "red";
        public static const font_red_sheet = "取出立即购买获得消确定继 续搜索同意拒绝复制升级解 锁游戏领前往充放置全部加 入房间重抽报名免费退出看 广告倍分享两点我豪礼";
        public static const font_green = "green";
        public static const font_green_sheet = "存入取消查看确定装备邀请 一键升级返回大厅反馈分享 礼包码炫耀下领奖励提交开 启使用完成布置规则询赠送 购买个观看广告退出";

        public static const outside_btn_type_zero = 0
        public static const outside_btn_type_one = 1

        // 待机奖励
        public static const receiveCoin:String = "receiveCoin"; // 领取待机奖励

        // 奖励动画相关
        public static const unused_remove_self:Boolean = true;
        public static const currency_coin:int = 1;
        public static const currency_silver:int = 6;//银币

        public static const font_type_own:Number = 0; //自己捕鱼获得的钱币
        public static const font_type_other:Number = 1; //其他人捕鱼获得的钱币
        public static const font_type_plot_type_battery:Number = 2; //剧情模式炮台飘雪
        public static const font_type_plot_type_fish:Number = 3; //剧情模式鱼血量
        public static const font_type_plot_type_battery_treat:Number = 4;//炮台加血
        public static const font_type_shield_absorb:Number = 5; //护盾吸收值

        public static const cache_test_open:Boolean = false;//缓存测试是否开启

    }
}
