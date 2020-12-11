package model
{
    import enums.SkillType;

    public class AwardM
    {
        private static var _instance:AwardM;

        private var _awardId:Number = SkillType.NOSKILL;
        private var _awardNum:Number = -1;

        public function AwardM()
        {

        }

        public static function get instance():AwardM
        {
            return _instance || (_instance = new AwardM());
        }

        public function get awardId():Number
        {
            return _awardId;
        }

        public function set awardId(value:Number):void
        {
            _awardId = value;
        }

        public function get awardNum():Number
        {
            return _awardNum;
        }

        public function set awardNum(value:Number):void
        {
            _awardNum = value;
        }

    }
}
