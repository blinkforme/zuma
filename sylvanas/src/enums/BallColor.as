package enums
{
    public class BallColor
    {
        public static const PURPLE:Number = 1
        public static const GREEN:Number = 2
        public static const BLUE:Number = 3
        public static const RED:Number = 4
        public static const YELLOW:Number = 5
        public static const WHITE:Number = 6

        public static function numToColor(color:Number):String
        {
            var dic:Object = {
                1: "紫", 2: "绿", 3: "蓝", 4: "红", 5: "黄", 6: "浅褐色"
            }
            return dic[color]
        }
    }
}
