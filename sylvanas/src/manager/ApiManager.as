package manager
{

    import control.WxC;

    import enums.SkillType;

    import laya.debug.tools.JsonTool;

    import laya.debug.tools.JsonTool;

    import laya.events.Event;
    import laya.net.HttpRequest;
    import laya.utils.Handler;
    import laya.utils.Handler;

    import model.FightM;

    import model.LoginInfoM;

    public class ApiManager
    {
        public var API_URL:String;
        private var _handler:Handler;
        private var _handlerTwo:Handler;

        private static var _instance:ApiManager;

        public function ApiManager()
        {

        }

        public static function get instance():ApiManager
        {
            return _instance || (_instance = new ApiManager());
        }

        private function get_api_address():String
        {
            return LoginInfoM.instance.api_domain_protocal + "://" + LoginInfoM.instance.api_domain
        }

        public function base_request(url, params, method, cb):Object
        {

            var request:HttpRequest = new HttpRequest();

            var FULL_URL:String = get_api_address() + url;

            request.send(FULL_URL, params, method, 'json')

            request.once(Event.COMPLETE, this, function (data)
            {
                cb(request.data)
            });
            return null;
        }

        public function basehttp(url:String, params:String, method:String, handler:Handler, handlerTwo:Handler):void
        {
            _handler = handler;
            _handlerTwo = handlerTwo;
            var request:HttpRequest = new HttpRequest();
            var FULL_URL:String = get_api_address() + url;


            request.send(FULL_URL, params, method, 'json');
            request.once(Event.COMPLETE, this, complete, [handler]);
            request.once(Event.ERROR, this, error);
        }

        private function error(msg:Object):void
        {
            if (_handlerTwo != null)
            {
                _handlerTwo.runWith(msg);
            }
        }

        private function complete(handler:Handler, msg:Object):void
        {
            handler.runWith(msg);
        }

        public function checkVersion(version:String, h1:Handler, h2:Handler):Object
        {
            var r_url:String = "/version_info";
            var method:String = "post";

            var params:String = "version=" + version
            basehttp(r_url, params, method, h1, h2)
            return null;
        }

        public function syncUserInfo(nickname:String, avatar:String, sex:Number, h1:Handler, h2:Handler):Object
        {
            var r_url:String = "/foreign/save_user_info";
            var method:String = "post";

            var params:String = "access_token=" + LoginInfoM.instance.token + "&nickname=" + nickname + "&avatar=" + avatar + "&sex=" + sex
            basehttp(r_url, params, method, h1, h2)
            return null;
        }

        public function login(params, cb)
        {
            var r_url:String = "/third_login";
            var method:String = "post";
            base_request(r_url, params, method, cb)
        }

        public function wxminiLogin(params, cb:Handler, errorCb:Handler):void
        {
            var r_url:String = "/minilogin";
            var method:String = "post";
            basehttp(r_url, params, method, cb, errorCb)
        }


        public function shareInfo(access_token:String, h1:Handler, h2:Handler):void
        {
            var params:String = "access_token=" + access_token
            var r_url:String = "/collect/wxmini/shared_info?" + params;
            var method:String = "get";
            basehttp(r_url, "", method, h1, h2)
        }


        public function getShareInfo(access_token:String, inviteId:Number, h1:Handler, h2:Handler):void
        {
            var r_url:String = "/collect/wxmini/share_invite";
            var method:String = "post";
            var params:String = "access_token=" + access_token + "&invite_user_uid=" + inviteId;
            basehttp(r_url, params, method, h1, h2)
        }

        public function getUserSkill(h1:Handler, h2:Handler):void
        {
            var acesn:String
            if (WxC.isInMiniGame())
            {
                acesn = WxC.accessToken;
            } else
            {
                acesn = LoginInfoM.instance.token;
            }
            var params:String = "token=" + acesn;
            var r_url:String = "/get_user_skill" + "?" + params;
            var method:String = "get";
            basehttp(r_url, params, method, h1, h2)
        }

        public function saveUserSkill():void
        {
            var acesn:String
            if (WxC.isInMiniGame())
            {
                acesn = WxC.accessToken;
            } else
            {
                acesn = LoginInfoM.instance.token;
            }
            var skillData:Array = [{id: SkillType.FTOZEN, num: FightM.instance.skillNumArr[SkillType.FTOZEN]},
                {id: SkillType.GOBACK, num: FightM.instance.skillNumArr[SkillType.GOBACK]}];
            var r_url:String = "/save_user_skill";
            var method:String = "post";
            var params:String = "token=" + acesn + "&skills=" + JSON.stringify(skillData);
            basehttp(r_url, params, method, Handler.create(this, saveSkillSccuss), null)
        }

        private function saveSkillSccuss(res:*):void
        {

        }

        public function get_game_jump_list( h1:Handler, h2:Handler):void
        {
            var r_url:String = "/foreign/game_jump_list" ;
            var method:String = "get";
            basehttp(r_url, "", method, h1, h2)
        }
    }

}
