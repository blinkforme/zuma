package model
{
    public class LoginM
    {
        private static var _instance:LoginM;
        private var _resArr:Array;
        private var _loginState:Number;
        private var _spineArr:Array;
        private var _prePlayAniArr:Array;
        private var _sceneId:Number;
        private var _contestId:int;
        private var _contestReply:Boolean;

        private var _pageId:String;
        private var _IsfirstEntryGame:Boolean = true;
        private var _preLoadFishIds:Array = null;
        private var _preLoadBullet:Boolean = false;

        public function LoginM()
        {
            _preLoadFishIds = [];
        }

        public function setFishIdPreload(fishId:int):void
        {
            _preLoadFishIds[fishId] = 1;
        }

        public function isFishIdPreload(fishId:int):Boolean
        {
            if (_preLoadFishIds[fishId])
            {
                return true;
            }
            return false;
        }

        public function setBulletPreload():void
        {
            _preLoadBullet = true;
        }

        public function isBulletPreload():Boolean
        {
            return _preLoadBullet;
        }

        public static function get instance():LoginM
        {
            return _instance || (_instance = new LoginM());
        }

        public function get IsfirstEntryGame():Boolean
        {
            return _IsfirstEntryGame
        }

        public function set IsfirstEntryGame(isFirst:Boolean):void
        {
            _IsfirstEntryGame = isFirst;
        }

        public function get pageId():String
        {
            return _pageId;
        }

        public function set pageId(id:String):void
        {
            _pageId = id;
        }


        public function get sceneId():Number
        {
            return _sceneId;
        }

        public function set sceneId(id:Number):void
        {
            _contestId = 0;
            _sceneId = id;
        }

        public function getContestId():Number
        {
            return _contestId;
        }

        public function getContestReply():Boolean
        {
            return _contestReply;
        }

        public function setContestId(contestId:Number, sceneId:Number, contestReply:Boolean = true):void
        {
            _contestId = contestId;
            _sceneId = sceneId;
            _contestReply = contestReply;
        }


        public function set resArr(res:Array):void
        {
            _resArr = res;
        }

        public function get resArr():Array
        {
            return _resArr;
        }

        public function set loginState(state:Number):void
        {
            _loginState = state;
        }

        public function get loginState():Number
        {
            return _loginState;
        }

        public function get spineArr():Array
        {
            return _spineArr
        }

        public function set spineArr(arr:Array):void
        {
            _spineArr = arr;
        }

        public function get prePlayAniArr():Array
        {
            return _prePlayAniArr
        }

        public function set prePlayAniArr(arr:Array):void
        {
            _prePlayAniArr = arr;
        }

    }
}
