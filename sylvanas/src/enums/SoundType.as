package enums
{
    public class SoundType
    {
        public static const ROLLING:String = "rolling_music";//祖玛开始/结束滚动声音
        public static const lAUNCH:String = "pop_music";//发射声音
        public static const BUTTON:String = "button_music";//点击音效
        public static const WARN:String = "warn_music";//警告
        public static const ELIMINATE:String = "chime_music";//消除
        public static const STRIKE:String = "strike_music";//撞击
        public static const ROLLBACK:String = "rollback_music";//回退撞击
        public static const BOMB:String = "bomb_music";//爆炸
        public static const BEGIN:String = "begin_music";//开始

        public static function CHIME_MUISIC(index:Number):String
        {
            return "chime_music_" + index
        }

    }
}
